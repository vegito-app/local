package vegetable

type VegetableCreatedImageMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageID     string `json:"imageId"`
	ImageURL    string `json:"imageUrl"`
}

type VegetableValidatedImageMessage struct {
	VegetableID  string `json:"vegetableId"`
	ImageID      string `json:"imageId"`
	ValidatedURL string `json:"validatedUrl"`
}
