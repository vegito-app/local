package task

import "fmt"

type Tool interface {
	Name() string
	Run(args map[string]string) (string, error)
}

type Tools struct {
	tools map[string]Tool
}

func (t Tools) Names() []string {
	names := make([]string, 0, len(t.tools))
	for name := range t.tools {
		names = append(names, name)
	}
	return names
}

func NewToolRegistry(toolSets ...[]Tool) (*Tools, error) {
	r := Tools{
		tools: make(map[string]Tool),
	}
	for _, toolSet := range toolSets {
		for _, tool := range toolSet {
			if err := r.Add(tool); err != nil {
				return nil, fmt.Errorf("new tool registry: %w", err)
			}
		}
	}
	return &r, nil
}

func (r Tools) Add(tool Tool) error {
	if _, exists := r.tools[tool.Name()]; exists {
		return fmt.Errorf("tool already exists: %s", tool.Name())
	}
	r.tools[tool.Name()] = tool
	return nil
}

func (r Tools) Print() {
	for name := range r.tools {
		fmt.Println(" -", name)
	}
}

func (r Tools) Get(name string) (Tool, bool) {
	tool, ok := r.tools[name]
	return tool, ok
}
