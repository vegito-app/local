package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type ToolCall struct {
	Tool string            `json:"tool"`
	Args map[string]string `json:"args"`
}

func runCmd(cmd string) (string, error) {
	c := exec.Command("/bin/bash", "-lc", cmd)
	out, err := c.CombinedOutput()
	return string(out), err
}

func main() {
	fmt.Println("Nestor demo agent")
	fmt.Println("Entrez un JSON du type:")
	fmt.Println(`{"tool":"run_cmd","args":{"cmd":"pwd"}}`)

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

		switch call.Tool {
		case "run_cmd":
			result, err := runCmd(call.Args["cmd"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
			}
			fmt.Println(result)
		default:
			fmt.Printf("unknown tool: %s\n", call.Tool)
		}
	}
}
