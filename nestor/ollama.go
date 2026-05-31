package main

import (
	"fmt"
	"os"
)

func init() {
	addTool(ToolFunc{"ask_ollama", func(args map[string]string) (string, error) {
		return askOllama(args["prompt"])
	}})
}

func askOllama(prompt string) (string, error) {
	model := os.Getenv("NESTOR_OLLAMA_MODEL")
	if model == "" {
		model = "qwen3:latest"
	}

	return runCmd(fmt.Sprintf("ollama run %s %q", model, prompt))
}
