package storage

import (
	"context"
	"errors"
	"fmt"
	"strconv"

	"cloud.google.com/go/firestore"
	"github.com/7d4b9/utrade/backend/firebase"
	"github.com/7d4b9/utrade/backend/internal/http/api"
	"google.golang.org/api/iterator"
)

type VegetableStorage struct {
	firestore *firestore.Client
}

func NewVegetableStorage(firestore *firestore.Client) *VegetableStorage {
	return &VegetableStorage{
		firestore: firestore,
	}
}

func (s *VegetableStorage) StoreVegetable(ctx context.Context, userID string, v api.Vegetable) error {
	data := map[string]any{
		"name":          v.Name,
		"description":   v.Description,
		"saleType":      v.SaleType,
		"weightGrams":   v.WeightGrams,
		"priceCents":    v.PriceCents,
		"ownerId":       userID,
		"createdAt":     firestore.ServerTimestamp,
		"userCreatedAt": v.UserCreatedAt.UTC(),
	}

	_, err := s.firestore.Collection("vegetables").Doc(v.ID).Set(ctx, data)
	if err != nil {
		return fmt.Errorf("failed to store vegetable %q: %w", v.ID, err)
	}

	for i, img := range v.Images {
		imageDoc := s.firestore.Collection("vegetables").
			Doc(v.ID).
			Collection("images").
			Doc(strconv.Itoa(i))

		data := map[string]interface{}{
			"url":    img.URL,
			"status": img.Status,
		}
		if _, err := imageDoc.Set(ctx, data, firestore.MergeAll); err != nil {
			return fmt.Errorf("failed to store image %q for vegetable %q: %w", strconv.Itoa(i), v.ID, err)
		}
	}

	return nil
}

func (f *Storage) GetVegetable(ctx context.Context, userID, id string) (*api.Vegetable, error) {
	doc, err := f.firestore.Collection("vegetables").Doc(id).Get(ctx)
	if err != nil {
		if firebase.FirestoreIsNotFound(err) {
			return nil, api.ErrVegetableNotFound
		}
		return nil, fmt.Errorf("failed to get vegetable %q: %w", id, err)
	}
	data := doc.Data()
	if data["ownerId"] != userID {
		return nil, fmt.Errorf("unauthorized access to vegetable %q", id)
	}
	var v api.Vegetable
	if err := doc.DataTo(&v); err != nil {
		return nil, fmt.Errorf("failed to convert document %q to Vegetable: %w", doc.Ref.ID, err)
	}

	imagesIter := doc.Ref.Collection("images").
		OrderBy(firestore.DocumentID, firestore.Asc).
		Documents(ctx)
	defer imagesIter.Stop()
	var images []api.VegetableImage
	for {
		docSnap, err := imagesIter.Next()
		if err != nil {
			if errors.Is(err, iterator.Done) {
				break
			}
			return nil, fmt.Errorf("failed to iterate vegetable images: %w", err)
		}
		var img api.VegetableImage
		if err := docSnap.DataTo(&img); err != nil {
			return nil, fmt.Errorf("failed to decode vegetable image: %w", err)
		}
		// img.ID = docSnap.Ref.ID
		images = append(images, img)
	}
	v.Images = images

	return &v, nil
}

func (f *Storage) ListVegetables(ctx context.Context, userID string) ([]*api.Vegetable, error) {
	iter := f.firestore.Collection("vegetables").Where("ownerId", "==", userID).Documents(ctx)
	defer iter.Stop()

	var list []*api.Vegetable
	for {
		doc, err := iter.Next()
		if err != nil {
			if errors.Is(err, iterator.Done) {
				break
			}
			return nil, fmt.Errorf("error while listing vegetables: %w", err)
		}
		var v api.Vegetable

		if err := doc.DataTo(&v); err != nil {
			return nil, fmt.Errorf("failed to convert document %q to Vegetable: %w", doc.Ref.ID, err)
		}
		v.ID = doc.Ref.ID // Ensure the ID is set from the document reference

		imagesIter := doc.Ref.Collection("images").
			OrderBy(firestore.DocumentID, firestore.Asc).
			Documents(ctx)
		defer imagesIter.Stop()
		var images []api.VegetableImage
		for {
			docSnap, err := imagesIter.Next()
			if err != nil {
				if errors.Is(err, iterator.Done) {
					break
				}
				return nil, fmt.Errorf("failed to iterate vegetable images: %w", err)
			}
			var img api.VegetableImage
			if err := docSnap.DataTo(&img); err != nil {
				return nil, fmt.Errorf("failed to decode vegetable image: %w", err)
			}
			// img.ID = docSnap.Ref.ID
			images = append(images, img)
		}
		v.Images = images

		list = append(list, &v)
	}
	return list, nil
}

func (f *Storage) DeleteVegetable(ctx context.Context, userID, id string) error {
	doc := f.firestore.Collection("vegetables").Doc(id)
	snap, err := doc.Get(ctx)
	if err != nil {
		if firebase.FirestoreIsNotFound(err) {
			return fmt.Errorf("%w: %s", api.ErrVegetableNotFound, id)
		}
		return fmt.Errorf("failed to find vegetable %q: %w", id, err)
	}
	if snap.Data()["ownerId"] != userID {
		return fmt.Errorf("unauthorized delete attempt on vegetable %q", id)
	}

	imagesIter := doc.Collection("images").Documents(ctx)
	for {
		imageDoc, err := imagesIter.Next()
		if err != nil {
			if errors.Is(err, iterator.Done) {
				break
			}
			return fmt.Errorf("failed to iterate images for deletion: %w", err)
		}
		if _, err := imageDoc.Ref.Delete(ctx); err != nil {
			return fmt.Errorf("failed to delete image %q: %w", imageDoc.Ref.ID, err)
		}
	}

	_, err = doc.Delete(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete vegetable %q: %w", id, err)
	}
	return nil
}

func (s *Storage) SetVegetableImageUploaded(ctx context.Context, vegetableID, imageID, imageURL string) error {
	imageDoc := s.firestore.Collection("vegetables").
		Doc(vegetableID).
		Collection("images").
		Doc(imageID)

	data := map[string]interface{}{
		"url":    imageURL,
		"status": api.VegetableImageStatusUploaded,
	}

	_, err := imageDoc.Set(ctx, data, firestore.MergeAll)
	if err != nil {
		return fmt.Errorf("failed to set image data for vegetable %q image %q: %w", vegetableID, imageID, err)
	}
	return nil
}
