package vegetable

type VegetableCreatedImageMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageIndex  int    `json:"imageIndex"`
	ImagePath   string `json:"imagePath"`
}

type VegetableValidatedImageMessage struct {
	VegetableID string `json:"vegetableId"`
	ImageIndex  int    `json:"imageIndex"`
	ImagePath   string `json:"imagePath"`
}
