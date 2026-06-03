package tool

type Tool struct {
	Name string            `json:"name"`
	Args map[string]string `json:"args"`
}
