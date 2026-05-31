package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

func main() {
	fmt.Println("Nestor v0.3")
	fmt.Println(`{"tool":"run_cmd","args":{"cmd":"pwd"}}`)

	fmt.Println("Available tools:")

	for name := range registry {
		fmt.Println(" -", name)
	}
	scanner := bufio.NewScanner(os.Stdin)

	for {
		fmt.Print("> ")

		if !scanner.Scan() {
			return
		}

		line := strings.TrimSpace(scanner.Text())

		if line == "exit" || line == "quit" {
			return
		}

		var call ToolCall

		if err := json.Unmarshal([]byte(line), &call); err != nil {
			fmt.Printf("json error: %v\n", err)
			continue
		}

		tool, ok := registry[call.Tool]
		if !ok {
			fmt.Printf("unknown tool: %s\n", call.Tool)
			continue
		}

		result, err := tool.Run(call.Args)
		if err != nil {
			fmt.Printf("error: %v\n", err)
			continue
		}

		fmt.Println(result)
	}
}
