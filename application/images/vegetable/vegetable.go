package vegetable

type VegetableCreatedImageMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageIndex  int    `json:"imageIndex"`
	ImageURL    string `json:"imageUrl"`
}

type VegetableValidatedImageMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageIndex  int    `json:"imageIndex"`
	ImageURL    string `json:"imageUrl"`
}
