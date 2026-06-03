package main

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
