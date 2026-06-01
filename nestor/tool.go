package main

type ToolCall struct {
	Tool string            `json:"tool"`
	Args map[string]string `json:"args"`
}

type Tool interface {
	Name() string
	Run(args map[string]string) (string, error)
}

var registry = map[string]Tool{}

func addTool(tool Tool) {
	if _, ok := registry[tool.Name()]; ok {
		panic("tool already registered: " + tool.Name())
	}
	registry[tool.Name()] = tool
}

type ToolFunc struct {
	name string
	run  func(args map[string]string) (string, error)
}

func (t ToolFunc) Name() string {
	return t.name
}

func (t ToolFunc) Run(args map[string]string) (string, error) {
	return t.run(args)
}
