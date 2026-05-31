package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
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

func readFile(path string) (string, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

func writeFile(path, content string) error {
	return os.WriteFile(path, []byte(content), 0644)
}

func listDir(path string) (string, error) {
	entries, err := os.ReadDir(path)
	if err != nil {
		return "", err
	}

	var b strings.Builder
	for _, e := range entries {
		kind := "FILE"
		if e.IsDir() {
			kind = "DIR"
		}
		b.WriteString(fmt.Sprintf("[%s] %s\n", kind, e.Name()))
	}

	return b.String(), nil
}

func pwd() (string, error) {
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}
	return wd, nil
}

func fileInfo(path string) (string, error) {
	st, err := os.Stat(path)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf(
		"name=%s\nsize=%d\ndir=%v\nmode=%s\n",
		st.Name(),
		st.Size(),
		st.IsDir(),
		st.Mode(),
	), nil
}

func absPath(path string) (string, error) {
	return filepath.Abs(path)
}

func main() {
	fmt.Println("Nestor v0.2")
	fmt.Println("Available tools:")
	fmt.Println(" - run_cmd")
	fmt.Println(" - read_file")
	fmt.Println(" - write_file")
	fmt.Println(" - list_dir")
	fmt.Println(" - pwd")
	fmt.Println(" - file_info")
	fmt.Println(" - abs_path")

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

		case "read_file":
			result, err := readFile(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		case "write_file":
			if err := writeFile(call.Args["path"], call.Args["content"]); err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println("ok")

		case "list_dir":
			result, err := listDir(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		case "pwd":
			result, err := pwd()
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		case "file_info":
			result, err := fileInfo(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		case "abs_path":
			result, err := absPath(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		default:
			fmt.Printf("unknown tool: %s\n", call.Tool)
		}
	}
}
