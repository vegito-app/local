package firebase

import (
	"context"
	"fmt"
	"mime/multipart"

	"cloud.google.com/go/firestore"
	apiV1 "github.com/7d4b9/utrade/backend/internal/http/api/v1"
)

type VegetableStorage struct {
	firestore *firestore.Client
}

func (f *Client) StoreVegetable(ctx context.Context, userID string, v apiV1.Vegetable) error {
	_, err := f.firestore.Collection("vegetables").Doc(v.ID).Set(ctx, map[string]any{
		"name":        v.Name,
		"description": v.Description,
		"saleType":    v.SaleType,
		"weightGrams": v.WeightGrams,
		"priceCents":  v.PriceCents,
		"imageUrl":    v.ImageURL,
		"ownerId":     userID,
		"createdAt":   firestore.ServerTimestamp,
	})
	if err != nil {
		return fmt.Errorf("failed to store vegetable %q: %w", v.ID, err)
	}
	return nil
}

func (f *Client) GetVegetable(ctx context.Context, userID, id string) (*apiV1.Vegetable, error) {
	doc, err := f.firestore.Collection("vegetables").Doc(id).Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get vegetable %q: %w", id, err)
	}
	data := doc.Data()
	if data["ownerId"] != userID {
		return nil, fmt.Errorf("unauthorized access to vegetable %q", id)
	}
	return mapToVegetable(doc.Ref.ID, data)
}

func (f *Client) ListVegetables(ctx context.Context, userID string) ([]*apiV1.Vegetable, error) {
	iter := f.firestore.Collection("vegetables").Where("ownerId", "==", userID).Documents(ctx)
	defer iter.Stop()

	var list []*apiV1.Vegetable
	for {
		doc, err := iter.Next()
		if err != nil {
			if err.Error() == "iterator done" {
				break
			}
			return nil, fmt.Errorf("error while listing vegetables: %w", err)
		}
		v, err := mapToVegetable(doc.Ref.ID, doc.Data())
		if err != nil {
			return nil, err
		}
		list = append(list, v)
	}
	return list, nil
}

func (f *Client) DeleteVegetable(ctx context.Context, userID, id string) error {
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

func mapToVegetable(id string, data map[string]any) (*apiV1.Vegetable, error) {
	v := &apiV1.Vegetable{
		ID:          id,
		Name:        toString(data["name"]),
		Description: toString(data["description"]),
		SaleType:    toString(data["saleType"]),
		WeightGrams: toInt(data["weightGrams"]),
		PriceCents:  toInt(data["priceCents"]),
		ImageURL:    toString(data["imageUrl"]),
	}
	return v, nil
}

func toString(v any) string {
	if s, ok := v.(string); ok {
		return s
	}
	return ""
}

func toInt(v any) int {
	switch val := v.(type) {
	case int64:
		return int(val)
	case float64:
		return int(val)
	default:
		return 0
	}
}

func (s *Client) StoreVegetableImage(ctx context.Context, userID string, file multipart.File) error {
	// imageUrl := uploadToCloudStorage(file)
	// updateVegetableImageURL(ctx, vegetableId, imageUrl)
	return nil
}
