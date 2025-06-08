package api

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	nethttp "net/http"
	"strings"
	"time"

	"github.com/7d4b9/utrade/backend/internal/http"
	vegetableimage "github.com/7d4b9/utrade/images/vegetable"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
)

var ErrVegetableNotFound = errors.New("vegetable not found")

type VegetableImage struct {
	URL        string               `json:"url"`
	UploadedAt time.Time            `json:"uploadedAt"`
	Status     VegetableImageStatus `json:"status"`
}

type VegetableImageStatus string

const (
	VegetableImageStatusPending  VegetableImageStatus = "pending"
	VegetableImageStatusUploaded VegetableImageStatus = "uploaded"
)

type Vegetable struct {
	ID            string           `json:"id,omitempty"`
	Name          string           `json:"name"`
	OwnerID       string           `json:"ownerId"`
	Description   string           `json:"description"`
	SaleType      string           `json:"saleType"`
	WeightGrams   int              `json:"weightGrams"`
	PriceCents    int              `json:"priceCents"`
	Images        []VegetableImage `json:"images"`
	CreatedAt     time.Time        `json:"createdAt"`
	UserCreatedAt time.Time        `json:"userCreatedAt,omitempty"`
}

// Implementations must return ErrVegetableNotFound when a requested vegetable
// does not exist so that HTTP handlers can translate it into a 404 response.
type VegetableStorage interface {
	StoreVegetable(ctx context.Context, userID string, v Vegetable) (err error)

	// GetVegetable returns a vegetable by its ID.
	// Returns ErrVegetableNotFound if the vegetable does not exist.
	GetVegetable(ctx context.Context, userID, id string) (*Vegetable, error)

	ListVegetables(ctx context.Context, userID string) ([]*Vegetable, error)

	// DeleteVegetable removes a vegetable by ID.
	// Returns ErrVegetableNotFound if the vegetable does not exist.
	DeleteVegetable(ctx context.Context, userID, id string) error
}

type VegetableImageValidator interface {
	SetImageValidation(ctx context.Context, userID string, images []vegetableimage.VegetableCreatedImageMessage) error
}

// VegetableService defines all routes handled by VegetableService
type VegetableService struct {
	storage        VegetableStorage
	imageValidator VegetableImageValidator
}

func NewVegetableService(mux *nethttp.ServeMux, storage VegetableStorage, imageValidator VegetableImageValidator) (*VegetableService, error) {
	service := &VegetableService{
		storage:        storage,
		imageValidator: imageValidator,
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

func isAlreadyValidatedURL(url string) bool {
	return strings.HasPrefix(url, "https://cdn.utrade.dev/")
}

func (s *VegetableService) CreateVegetable(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := requestUserID(r)
	var v Vegetable
	if err := json.NewDecoder(r.Body).Decode(&v); err != nil {
		log.Error().Err(err).Msg("failed to decode vegetable payload")
		nethttp.Error(w, "invalid payload", nethttp.StatusBadRequest)
		return
	}
	v.ID = uuid.NewString()
	var createdImages []vegetableimage.VegetableCreatedImageMessage
	for index, img := range v.Images {
		createdImages = append(createdImages, vegetableimage.VegetableCreatedImageMessage{
			VegetableID: v.ID,
			ImageID:     fmt.Sprintf("%d", index),
			ImageURL:    img.URL,
		})
		// Only reset URLs that are not yet moderated
		if !isAlreadyValidatedURL(img.URL) {
			v.Images[index].URL = ""
		}
	}
	err := s.storage.StoreVegetable(ctx, userID, v)
	if err != nil {
		nethttp.Error(w, "store failed", nethttp.StatusInternalServerError)
		return
	}

	if err := s.imageValidator.SetImageValidation(ctx, v.ID, createdImages); err != nil {
		nethttp.Error(w, "set image validation failed", nethttp.StatusInternalServerError)
		return
	}

	w.WriteHeader(nethttp.StatusCreated)
	if err := json.NewEncoder(w).Encode(v); err != nil {
		log.Error().Err(err).Msg("failed to encode vegetable response")
		nethttp.Error(w, "failed to encode response", nethttp.StatusInternalServerError)
		return
	}
}

func (s *VegetableService) ListVegetables(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := requestUserID(r)
	veggies, err := s.storage.ListVegetables(ctx, userID)
	if err != nil {
		log.Error().Err(err).Msg("failed to list vegetables")
		nethttp.Error(w, "list failed", nethttp.StatusInternalServerError)
		return
	}
	if veggies == nil {
		veggies = []*Vegetable{}
	}
	json.NewEncoder(w).Encode(veggies)
}

func (s *VegetableService) GetVegetable(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := requestUserID(r)
	id := r.URL.Query().Get("id")
	if id == "" {
		nethttp.Error(w, "missing id", nethttp.StatusBadRequest)
		return
	}
	veggie, err := s.storage.GetVegetable(ctx, userID, id)
	if err != nil {
		if errors.Is(err, ErrVegetableNotFound) {
			nethttp.Error(w, "vegetable not found", nethttp.StatusNotFound)
		} else {
			nethttp.Error(w, "get failed", nethttp.StatusInternalServerError)
		}
		return
	}
	json.NewEncoder(w).Encode(veggie)
}

func (s *VegetableService) DeleteVegetable(w nethttp.ResponseWriter, r *nethttp.Request) {
	ctx := r.Context()
	userID := requestUserID(r)
	id := r.URL.Query().Get("id")
	if id == "" {
		nethttp.Error(w, "missing id", nethttp.StatusBadRequest)
		return
	}
	if err := s.storage.DeleteVegetable(ctx, userID, id); err != nil {
		if errors.Is(err, ErrVegetableNotFound) {
			nethttp.Error(w, "vegetable not found", nethttp.StatusNotFound)
		} else {
			nethttp.Error(w, "delete failed", nethttp.StatusInternalServerError)
		}
		return
	}
	w.WriteHeader(nethttp.StatusNoContent)
}
