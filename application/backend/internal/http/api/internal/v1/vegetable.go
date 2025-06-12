package v1

import (
	"time"
)

type VegetableImageStatus string

const (
	VegetableImageStatusPending  VegetableImageStatus = "pending"
	VegetableImageStatusUploaded VegetableImageStatus = "uploaded"
)

type VegetableImageResponse struct {
	Path          string               `json:"path"`
	UploadedAt    time.Time            `json:"uploadedAt"`
	Status        VegetableImageStatus `json:"status"`
	ServedByCdn   bool                 `json:"servedByCdn"`
	DownloadToken *string              `json:"downloadToken,omitempty"`
}

type VegetableResponse struct {
	ID            string                   `json:"id,omitempty"`
	Name          string                   `json:"name"`
	OwnerID       string                   `json:"ownerId"`
	Description   string                   `json:"description"`
	SaleType      string                   `json:"saleType"`
	WeightGrams   int                      `json:"weightGrams"`
	PriceCents    int                      `json:"priceCents"`
	Images        []VegetableImageResponse `json:"images"`
	CreatedAt     time.Time                `json:"createdAt"`
	UserCreatedAt time.Time                `json:"userCreatedAt,omitempty"`
}

type VegetableImageRequest struct {
	Path          string  `json:"path"`
	DownloadToken *string `json:"downloadToken,omitempty"`
}

type VegetableRequest struct {
	ID            string                  `json:"id,omitempty"`
	Name          string                  `json:"name"`
	OwnerID       string                  `json:"ownerId"`
	Description   string                  `json:"description"`
	SaleType      string                  `json:"saleType"`
	WeightGrams   int                     `json:"weightGrams"`
	PriceCents    int                     `json:"priceCents"`
	Images        []VegetableImageRequest `json:"images"`
	CreatedAt     time.Time               `json:"createdAt"`
	UserCreatedAt time.Time               `json:"userCreatedAt,omitempty"`
}

type VegetableImageCreatedTopicMessage struct {
	Path string `json:"path"`
}

type VegetableImageValidatedTopicMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageIndex  int    `json:"imageIndex"`
	Path        string `json:"path"`
}
