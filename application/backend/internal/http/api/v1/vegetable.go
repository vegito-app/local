package v1

import (
	"context"
	"encoding/json"
	"mime/multipart"
	"net/http"
)

type Vegetable struct {
	ID          string `json:"id,omitempty"`
	Name        string `json:"name"`
	Description string `json:"description"`
	SaleType    string `json:"saleType"`
	WeightGrams int    `json:"weightGrams"`
	PriceCents  int    `json:"priceCents"`
	ImageURL    string `json:"imageUrl"`
	CreatedAt   int64  `json:"createdAt"`
}

type VegetableStorage interface {
	StoreVegetable(ctx context.Context, userID string, v Vegetable) error
	GetVegetable(ctx context.Context, userID, id string) (*Vegetable, error)
	ListVegetables(ctx context.Context, userID string) ([]*Vegetable, error)
	DeleteVegetable(ctx context.Context, userID, id string) error
	StoreVegetableImage(ctx context.Context, userID string, file multipart.File) error
}

// VegetableService defines all routes handled by VegetableService
type VegetableService struct {
	storage VegetableStorage
}

func (s *VegetableService) CreateVegetable(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	var v Vegetable
	if err := json.NewDecoder(r.Body).Decode(&v); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}
	if err := s.storage.StoreVegetable(ctx, userID, v); err != nil {
		http.Error(w, "store failed", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func (s *VegetableService) ListVegetables(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	veggies, err := s.storage.ListVegetables(ctx, userID)
	if err != nil {
		http.Error(w, "list failed", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(veggies)
}

func (s *VegetableService) GetVegetable(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	id := r.URL.Query().Get("id")
	if id == "" {
		http.Error(w, "missing id", http.StatusBadRequest)
		return
	}
	veggie, err := s.storage.GetVegetable(ctx, userID, id)
	if err != nil {
		http.Error(w, "get failed", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(veggie)
}

func (s *VegetableService) DeleteVegetable(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	id := r.URL.Query().Get("id")
	if id == "" {
		http.Error(w, "missing id", http.StatusBadRequest)
		return
	}
	if err := s.storage.DeleteVegetable(ctx, userID, id); err != nil {
		http.Error(w, "delete failed", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *VegetableService) UploadVegetableImage(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := r.Header.Get("X-User-ID")
	file, handler, err := r.FormFile("image")
	if err != nil {
		http.Error(w, "invalid file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	if handler.Size > 5*1024*1024 { // 5MB max
		http.Error(w, "image too large", http.StatusBadRequest)
		return
	}

	// Optionnel : filtrage par MIME ou analyse de contenu
	contentType := handler.Header.Get("Content-Type")
	if contentType != "image/jpeg" && contentType != "image/png" {
		http.Error(w, "unsupported image format", http.StatusUnsupportedMediaType)
		return
	}
	err = s.storage.StoreVegetableImage(ctx, userID, file)
	if err != nil {
		http.Error(w, "store vegetable image", http.StatusInternalServerError)
		return
	}
}
