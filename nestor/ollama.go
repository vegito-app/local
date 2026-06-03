package main

import (
	"fmt"
	"os"

	"github.com/vegito-app/ai-nestor/nestor/internal/task"
)

var ollamaTools = []task.Tool{
	ToolFunc{
		name: "ask_ollama",
		run: func(args map[string]string) (string, error) {
			return askOllama(args["prompt"])
		},
	},
}

func askOllama(prompt string) (string, error) {
	model := os.Getenv("NESTOR_OLLAMA_MODEL")
	if model == "" {
		model = "qwen3:8b"
	}

	return runCmd(fmt.Sprintf("ollama run %s %q", model, prompt))
}
