package v1

import (
	"time"
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
	OwnerID     string           `json:"ownerId"`
	WeightGrams int              `json:"weightGrams"`
	PriceCents  int              `json:"priceCents"`
	Images      []VegetableImage `json:"images"`
	CreatedAt   *time.Time       `json:"createdAt"`
}
