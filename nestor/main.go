package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/vegito-app/ai-nestor/nestor/internal/http"
	"github.com/vegito-app/ai-nestor/nestor/internal/task"
	"github.com/vegito-app/ai-nestor/nestor/internal/tool"
)

func runCLI(tools *task.Tools) {
	fmt.Println("Nestor v0.3")
	fmt.Println(`{"tool":"run_cmd","args":{"cmd":"pwd"}}`)

	fmt.Println("Available tools:")
	tools.Print()

	scanner := bufio.NewScanner(os.Stdin)

	for {
		fmt.Print("> ")

		if !scanner.Scan() {
			return
		}
		if err := scanner.Err(); err != nil {
			fmt.Printf("error reading input: %v\n", err)
			return
		}

		line := strings.TrimSpace(scanner.Text())

		if line == "exit" || line == "quit" {
			return
		}

		var t tool.Tool

		if err := json.Unmarshal([]byte(line), &t); err != nil {
			fmt.Printf("json error: %v\n", err)
			continue
		}

		tool, ok := tools.Get(t.Name)
		if !ok {
			fmt.Printf("unknown tool: %s\n", t.Name)
			continue
		}

		result, err := tool.Run(t.Args)
		if err != nil {
			fmt.Printf("error: %v\n", err)
			continue
		}

		fmt.Println(result)
	}
}

func main() {
	toolRegistry, err := task.NewToolRegistry(
		osTools,
		gitTools,
		dockerTools,
		makeTools,
		ollamaTools,
	)

	if err != nil {
		panic(err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	taskLoop := task.NewLoop(ctx, toolRegistry)
	defer taskLoop.Stop()

	if len(os.Args) <= 1 {
		runCLI(toolRegistry)
	}

	switch os.Args[1] {
	case "serve":
		if err := http.StartAPI(taskLoop); err != nil {
			panic(err)
		}
		return
	}

}
