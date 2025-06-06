package storage

import (
	"context"

	"cloud.google.com/go/firestore"
	"github.com/7d4b9/utrade/backend/firebase"
	"github.com/7d4b9/utrade/backend/internal/http/api"
)

type OrderStorage struct {
	firestore *firestore.Client
}

func NewOrderStorage(firestore *firestore.Client) *OrderStorage {
	return &OrderStorage{
		firestore: firestore,
	}
}

func (s *OrderStorage) StoreOrder(ctx context.Context, userID string, o api.Order) error {
	// Implementation goes here
	return nil
}

func (s *OrderStorage) GetOrder(ctx context.Context, userID, id string) (*api.Order, error) {
	doc := s.firestore.Collection("orders").Doc(id)
	snap, err := doc.Get(ctx)
	if firebase.FirestoreIsNotFound(err) {
		return nil, api.ErrOrderNotFound
	}

	var o api.Order
	if err := snap.DataTo(&o); err != nil {
		return nil, err
	}

	return &o, nil
}

func (s *OrderStorage) ListOrders(ctx context.Context, userID string) ([]*api.Order, error) {
	// Implementation goes here

	return nil, nil
}

func (s *OrderStorage) DeleteOrder(ctx context.Context, userID, id string) error {
	doc := s.firestore.Collection("orders").Doc(id)
	snap, err := doc.Get(ctx)
	if firebase.FirestoreIsNotFound(err) {
		return api.ErrOrderNotFound
	}
	var o api.Order
	if err := snap.DataTo(&o); err != nil {
		return err
	}
	_, err = doc.Delete(ctx)
	return err
}

func (s *OrderStorage) UpdateOrderStatus(ctx context.Context, userID, orderID, status string) error {
	doc := s.firestore.Collection("orders").Doc(orderID)
	snap, err := doc.Get(ctx)
	if firebase.FirestoreIsNotFound(err) {
		return api.ErrOrderNotFound
	}
	if err != nil {
		return err
	}
	var o api.Order
	if err := snap.DataTo(&o); err != nil {
		return err
	}
	_, err = doc.Update(ctx, []firestore.Update{
		{Path: "status", Value: status},
	})
	return err
}
