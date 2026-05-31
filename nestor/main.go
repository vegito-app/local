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

func appendFile(path, content string) error {
	f, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = f.WriteString(content)
	return err
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

func askOllama(prompt string) (string, error) {
	model := os.Getenv("NESTOR_OLLAMA_MODEL")
	if model == "" {
		model = "qwen3:latest"
	}
	return runCmd(fmt.Sprintf("ollama run %s %q", model, prompt))
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
	fmt.Println("Nestor v0.3")
	fmt.Println(`{"tool":"run_cmd","args":{"cmd":"pwd"}}`)
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

		case "read_file":
			result, err := readFile(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)
		case "run_cmd":
			out, err := runCmd(call.Args["cmd"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
			}
			fmt.Println(out)

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

		case "abs_path":
			result, err := absPath(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)
		case "append_file":
			fmt.Println(appendFile(call.Args["path"], call.Args["content"]))

		case "mkdir":
			fmt.Println(os.MkdirAll(call.Args["path"], 0755))

		case "rm":
			fmt.Println(os.RemoveAll(call.Args["path"]))

		case "mv":
			fmt.Println(os.Rename(call.Args["src"], call.Args["dst"]))

		case "cp":
			data, err := os.ReadFile(call.Args["src"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(os.WriteFile(call.Args["dst"], data, 0644))

		case "grep":
			out, err := runCmd(fmt.Sprintf("grep -RIn %q %s", call.Args["pattern"], call.Args["path"]))
			if err != nil && out == "" {
				fmt.Printf("error: %v\n", err)
			}
			fmt.Println(out)

		case "pwd":
			result, err := pwd()
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		case "find":
			root := call.Args["path"]
			pattern := call.Args["pattern"]
			filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
				if err == nil && strings.Contains(path, pattern) {
					fmt.Println(path)
				}
				return nil
			})

		case "ask_ollama":
			out, err := askOllama(call.Args["prompt"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(out)

		case "file_info":
			result, err := fileInfo(call.Args["path"])
			if err != nil {
				fmt.Printf("error: %v\n", err)
				continue
			}
			fmt.Println(result)

		case "git_status":
			out, _ := runCmd("git status")
			fmt.Println(out)

		case "git_diff":
			out, _ := runCmd("git diff")
			fmt.Println(out)

		case "git_log":
			out, _ := runCmd("git log --oneline -20")
			fmt.Println(out)

		case "git_branch":
			out, _ := runCmd("git branch -a")
			fmt.Println(out)

		case "git_checkout":
			out, _ := runCmd("git checkout " + call.Args["branch"])
			fmt.Println(out)

		case "git_commit":
			out, _ := runCmd("git add -A && git commit -m " + fmt.Sprintf("%q", call.Args["message"]))
			fmt.Println(out)

		case "docker_ps":
			out, _ := runCmd("docker ps")
			fmt.Println(out)

		case "docker_logs":
			out, _ := runCmd("docker logs --tail=200 " + call.Args["container"])
			fmt.Println(out)

		case "docker_exec":
			out, _ := runCmd("docker exec " + call.Args["container"] + " bash -lc " + fmt.Sprintf("%q", call.Args["cmd"]))
			fmt.Println(out)

		case "make":
			out, _ := runCmd("make " + call.Args["target"])
			fmt.Println(out)

		default:
			fmt.Printf("unknown tool: %s\n", call.Tool)
		}
	}
}
