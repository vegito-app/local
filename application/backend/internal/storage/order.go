package storage

import (
	"cloud.google.com/go/firestore"
)

type OrderStorage struct {
	firestore *firestore.Client
}

func NewOrderStorage(firestore *firestore.Client) *OrderStorage {
	return &OrderStorage{
		firestore: firestore,
	}
}
