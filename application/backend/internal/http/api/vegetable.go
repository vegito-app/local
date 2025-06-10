package api

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	nethttp "net/http"
	"strings"
	"sync"
	"time"

	"github.com/7d4b9/utrade/backend/internal/http"
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
	SetImageValidation(ctx context.Context, userID string, image *VegetableImage) error
}

// VegetableService defines all routes handled by VegetableService
type VegetableService struct {
	storage               VegetableStorage
	imageValidator        VegetableImageValidator
	cdnImagesURLprefix    string
	cdnImagesBucketPrefix string
}

func NewVegetableService(mux *nethttp.ServeMux, storage VegetableStorage, imageValidator VegetableImageValidator) (*VegetableService, error) {
	cdnBucket := config.GetString(vegetableValidatedImagesCDNbucketConfig)
	cdnURLPrefix := fmt.Sprintf("https://%s/", cdnBucket)
	service := &VegetableService{
		storage:               storage,
		imageValidator:        imageValidator,
		cdnImagesURLprefix:    cdnURLPrefix,
		cdnImagesBucketPrefix: fmt.Sprintf("gs://%s", cdnBucket),
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

func (s *VegetableService) isAlreadyValidatedURL(url string) bool {
	return strings.HasPrefix(url, s.cdnImagesURLprefix)
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
	// var createdImages []vegetableimage.VegetableCreatedImageMessage
	var wg sync.WaitGroup
	defer wg.Wait()
	for index, img := range v.Images {
		if s.isAlreadyValidatedURL(img.URL) {
			log.Debug().
				Str("image_url", img.URL).
				Msg("Skip Image validation in CDN")
			continue
		}
		wg.Add(1)
		go func(index int, img VegetableImage) {
			defer wg.Done()
			if err := s.imageValidator.SetImageValidation(ctx, v.ID, &img); err != nil {
				log.Error().Err(err).Msg("failed to set image validation")
			}
		}(index, img)
		v.Images[index].Status = VegetableImageStatusPending
		v.Images[index].UploadedAt = time.Now()
		v.Images[index].URL = ""
	}
	err := s.storage.StoreVegetable(ctx, userID, v)
	if err != nil {
		nethttp.Error(w, "store failed", nethttp.StatusInternalServerError)
		return
	}
	w.WriteHeader(nethttp.StatusCreated)
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
	for _, veggie := range veggies {
		for i := range veggie.Images {
			if strings.HasPrefix(veggie.Images[i].URL, s.cdnImagesBucketPrefix) {
				veggie.Images[i].URL = s.cdnImagesURLprefix + strings.TrimPrefix(veggie.Images[i].URL, s.cdnImagesBucketPrefix)
			}
		}
	}
	if err := json.NewEncoder(w).Encode(veggies); err != nil {
		log.Error().Err(err).Msg("failed to encode vegetables response")
		nethttp.Error(w, "failed to encode response", nethttp.StatusInternalServerError)
		return
	}
	log.Debug().Int("count", len(veggies)).Msg("Listed vegetables")
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
	for i := range veggie.Images {
		if strings.HasPrefix(veggie.Images[i].URL, s.cdnImagesBucketPrefix) {
			veggie.Images[i].URL = s.cdnImagesURLprefix + strings.TrimPrefix(veggie.Images[i].URL, s.cdnImagesBucketPrefix)
		}
	}
	if err := json.NewEncoder(w).Encode(veggie); err != nil {
		log.Error().Err(err).Msg("failed to encode vegetable response")
		nethttp.Error(w, "failed to encode response", nethttp.StatusInternalServerError)
		return
	}
	log.Debug().Str("id", id).Msg("Retrieved vegetable")
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
