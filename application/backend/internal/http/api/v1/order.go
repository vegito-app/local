package v1

import (
	"context"
	"encoding/json"
	nethttp "net/http"

	"github.com/7d4b9/utrade/backend/internal/http"
)

type Order struct {
	ID          string           `json:"id,omitempty"`
	Name        string           `json:"name"`
	Description string           `json:"description"`
	SaleType    string           `json:"saleType"`
	WeightGrams int              `json:"weightGrams"`
	PriceCents  int              `json:"priceCents"`
	Images      []VegetableImage `json:"images"`
	CreatedAt   int64            `json:"createdAt"`
}

type OrderStorage interface {
	StoreOrder(ctx context.Context, userID string, o Order) error
	GetOrder(ctx context.Context, userID, id string) (*Order, error)
	ListOrders(ctx context.Context, userID string) ([]*Order, error)
	DeleteOrder(ctx context.Context, userID, id string) error
}

// OrderService defines all routes handled by OrderService
type OrderService struct {
	storage OrderStorage
}

func NewOrderService(mux *nethttp.ServeMux, storage OrderStorage) (*OrderService, error) {
	o := &OrderService{
		storage: storage,
	}

	mux.Handle("GET /order", http.ApplyMiddleware(
		nethttp.HandlerFunc(o.CreateOrder),
		FirebaseAuthMiddleware))
	return o, nil
}

func (s *OrderService) CreateOrder(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	var o Order
	if err := json.NewDecoder(r.Body).Decode(&o); err != nil {
		nethttp.Error(w, err.Error(), nethttp.StatusBadRequest)
		return
	}
	if err := s.storage.StoreOrder(ctx, userID, o); err != nil {
		nethttp.Error(w, err.Error(), nethttp.StatusInternalServerError)
		return
	}
	w.WriteHeader(nethttp.StatusCreated)
}
