package v1

import (
	"context"
	"encoding/json"
	nethttp "net/http"

	"github.com/7d4b9/utrade/backend/internal/http"
	"github.com/google/uuid"
)

type VegetableImage struct {
	URL        string `json:"url"`
	UploadedAt int64  `json:"uploadedAt"`
	Status     string `json:"status"`
}

type Vegetable struct {
	ID          string           `json:"id,omitempty"`
	Name        string           `json:"name"`
	Description string           `json:"description"`
	SaleType    string           `json:"saleType"`
	WeightGrams int              `json:"weightGrams"`
	PriceCents  int              `json:"priceCents"`
	Images      []VegetableImage `json:"images"`
	CreatedAt   int64            `json:"createdAt"`
}

type VegetableStorage interface {
	StoreVegetable(ctx context.Context, userID string, v Vegetable) error
	GetVegetable(ctx context.Context, userID, id string) (*Vegetable, error)
	ListVegetables(ctx context.Context, userID string) ([]*Vegetable, error)
	DeleteVegetable(ctx context.Context, userID, id string) error
}

type VegetableImageValidator interface {
	SetImageValidation(ctx context.Context, userID string, images []VegetableImage) error
}

// VegetableService defines all routes handled by VegetableService
type VegetableService struct {
	storage        VegetableStorage
	imageValidator VegetableImageValidator
}

func NewVegetableService(mux *nethttp.ServeMux, storage VegetableStorage) (*VegetableService, error) {
	service := &VegetableService{
		storage: storage,
	}
	mux.Handle("POST /api/vegetables", http.ApplyMiddleware(
		nethttp.HandlerFunc(service.CreateVegetable),
		FirebaseAuthMiddleware))

	mux.Handle("GET /api/vegetables", http.ApplyMiddleware(
		nethttp.HandlerFunc(service.ListVegetables),
		FirebaseAuthMiddleware))

	mux.Handle("GET /api/vegetable", http.ApplyMiddleware(
		nethttp.HandlerFunc(service.GetVegetable),
		FirebaseAuthMiddleware))

	mux.Handle("DELETE /api/vegetable", http.ApplyMiddleware(
		nethttp.HandlerFunc(service.DeleteVegetable),
		FirebaseAuthMiddleware))
	return service, nil
}

func (s *VegetableService) CreateVegetable(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	var v Vegetable
	if err := json.NewDecoder(r.Body).Decode(&v); err != nil {
		nethttp.Error(w, "invalid payload", nethttp.StatusBadRequest)
		return
	}
	v.ID = uuid.NewString()
	if v.CreatedAt == 0 {
		v.CreatedAt = (r.Context().Value("requestTime")).(int64)
		if v.CreatedAt == 0 {
			// fallback to current unix time in seconds
			v.CreatedAt = (int64)(r.Context().Value("requestUnixTime").(int64))
		}
	}

	if err := s.imageValidator.SetImageValidation(ctx, v.ID, v.Images); err != nil {
		nethttp.Error(w, "set image validation failed", nethttp.StatusInternalServerError)
		return
	}
	if err := s.storage.StoreVegetable(ctx, userID, v); err != nil {
		nethttp.Error(w, "store failed", nethttp.StatusInternalServerError)
		return
	}

	w.WriteHeader(nethttp.StatusCreated)
}

func (s *VegetableService) ListVegetables(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	veggies, err := s.storage.ListVegetables(ctx, userID)
	if err != nil {
		nethttp.Error(w, "list failed", nethttp.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(veggies)
}

func (s *VegetableService) GetVegetable(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	id := r.URL.Query().Get("id")
	if id == "" {
		nethttp.Error(w, "missing id", nethttp.StatusBadRequest)
		return
	}
	veggie, err := s.storage.GetVegetable(ctx, userID, id)
	if err != nil {
		nethttp.Error(w, "get failed", nethttp.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(veggie)
}

func (s *VegetableService) DeleteVegetable(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	id := r.URL.Query().Get("id")
	if id == "" {
		nethttp.Error(w, "missing id", nethttp.StatusBadRequest)
		return
	}
	if err := s.storage.DeleteVegetable(ctx, userID, id); err != nil {
		nethttp.Error(w, "delete failed", nethttp.StatusInternalServerError)
		return
	}
	w.WriteHeader(nethttp.StatusNoContent)
}

// func (s *VegetableService) UpdateVegetable(w http.ResponseWriter, r *http.Request) {
// 	ctx := r.Context()
// 	userID := r.Header.Get("X-User-ID")
// 	var v Vegetable
// 	if err := json.NewDecoder(r.Body).Decode(&v); err != nil {
// 		http.Error(w, "invalid payload", http.StatusBadRequest)
// 		return
// 	}
// 	if err := s.storage.UpdateVegetable(ctx, userID, v); err != nil {
// 		http.Error(w, "update failed", http.StatusInternalServerError)
// 		return
// 	}
// 	return nil
// }
