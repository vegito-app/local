package v1

import (
	"time"
)

type VegetableImageStatus string

const (
	VegetableImageStatusPending  VegetableImageStatus = "pending"
	VegetableImageStatusUploaded VegetableImageStatus = "uploaded"
)

type VegetableAvailabilityType string

const (
	AvailabilitySameDay          VegetableAvailabilityType = "same_day"
	AvailabilityFuture           VegetableAvailabilityType = "future_date"
	AvailabilityAlreadyHarvested VegetableAvailabilityType = "already_harvested"
)

type VegetableImageResponse struct {
	Path          string               `json:"path"`
	UploadedAt    time.Time            `json:"uploadedAt"`
	Status        VegetableImageStatus `json:"status"`
	ServedByCdn   bool                 `json:"servedByCdn"`
	DownloadToken *string              `json:"downloadToken,omitempty"`
}

type VegetableResponse struct {
	ID          string `json:"id,omitempty"`
	Name        string `json:"name"`
	OwnerID     string `json:"ownerId"`
	Description string `json:"description"`
	SaleType    string `json:"saleType"`
	// WeightGrams       int                       `json:"weightGrams"`
	PriceCents        int                       `json:"priceCents"`
	Images            []VegetableImageResponse  `json:"images"`
	CreatedAt         time.Time                 `json:"createdAt"`
	UserCreatedAt     time.Time                 `json:"userCreatedAt,omitempty"`
	Active            bool                      `json:"active"`
	AvailabilityType  VegetableAvailabilityType `json:"availabilityType"`
	AvailabilityDate  *time.Time                `json:"availabilityDate,omitempty"`
	QuantityAvailable int                       `json:"quantityAvailable"`
}

type VegetableImageRequest struct {
	Path          string  `json:"path"`
	DownloadToken *string `json:"downloadToken,omitempty"`
}

type VegetableRequest struct {
	ID          string `json:"id,omitempty"`
	Name        string `json:"name"`
	OwnerID     string `json:"ownerId"`
	Description string `json:"description"`
	SaleType    string `json:"saleType"`
	// WeightGrams       int                       `json:"weightGrams"`
	PriceCents        int                       `json:"priceCents"`
	Images            []VegetableImageRequest   `json:"images"`
	CreatedAt         time.Time                 `json:"createdAt"`
	UserCreatedAt     time.Time                 `json:"userCreatedAt,omitempty"`
	Active            bool                      `json:"active"`
	AvailabilityType  VegetableAvailabilityType `json:"availabilityType"`
	AvailabilityDate  time.Time                 `json:"availabilityDate,omitempty"`
	QuantityAvailable int                       `json:"quantityAvailable"`
}

type VegetableImageCreatedTopicMessage struct {
	Path string `json:"path"`
}

type VegetableImageValidatedTopicMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageIndex  int    `json:"imageIndex"`
	Path        string `json:"path"`
}

type UpdateMainImageRequest struct {
	MainImageIndex int `json:"mainImageIndex"`
}
