package storage

import (
	"context"
	"fmt"

	"cloud.google.com/go/firestore"
	"github.com/7d4b9/utrade/backend/internal/http/api"
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
		"name":        v.Name,
		"description": v.Description,
		"saleType":    v.SaleType,
		"weightGrams": v.WeightGrams,
		"priceCents":  v.PriceCents,
		"images":      v.Images,
		"ownerId":     userID,
		"createdAt":   firestore.ServerTimestamp,
	}
	if v.CreatedAt != nil {
		data["userCreatedAt"] = v.CreatedAt.Format("2006-01-02T15:04:05Z07:00")
	}

	_, err := s.firestore.Collection("vegetables").Doc(v.ID).Set(ctx, data)
	if err != nil {
		return fmt.Errorf("failed to store vegetable %q: %w", v.ID, err)
	}
	return nil
}

func (f *Storage) GetVegetable(ctx context.Context, userID, id string) (*api.Vegetable, error) {
	doc, err := f.firestore.Collection("vegetables").Doc(id).Get(ctx)
	if err != nil {
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
	return &v, nil
}

func (f *Storage) ListVegetables(ctx context.Context, userID string) ([]*api.Vegetable, error) {
	iter := f.firestore.Collection("vegetables").Where("ownerId", "==", userID).Documents(ctx)
	defer iter.Stop()

	var list []*api.Vegetable
	for {
		doc, err := iter.Next()
		if err != nil {
			if err.Error() == "iterator done" {
				break
			}
			return nil, fmt.Errorf("error while listing vegetables: %w", err)
		}
		var v api.Vegetable

		if err := doc.DataTo(&v); err != nil {
			return nil, fmt.Errorf("failed to convert document %q to Vegetable: %w", doc.Ref.ID, err)
		}
		list = append(list, &v)
	}
	return list, nil
}

func (f *Storage) DeleteVegetable(ctx context.Context, userID, id string) error {
	doc := f.firestore.Collection("vegetables").Doc(id)
	snap, err := doc.Get(ctx)
	if err != nil {
		return fmt.Errorf("failed to find vegetable %q: %w", id, err)
	}
	if snap.Data()["ownerId"] != userID {
		return fmt.Errorf("unauthorized delete attempt on vegetable %q", id)
	}
	_, err = doc.Delete(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete vegetable %q: %w", id, err)
	}
	return nil
}

func (s *Storage) UpdateVegetableImageURL(ctx context.Context, vegetableID, imageID, imageURL string) error {
	s.firestore.Collection("vegetables").Doc(vegetableID).Update(ctx, []firestore.Update{
		{Path: fmt.Sprintf("images.%s.url", imageID), Value: imageURL},
	})
	return nil
}
