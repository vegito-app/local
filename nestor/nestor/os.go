package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/vegito-app/ai-nestor/nestor/internal/task"
)

var osTools = []task.Tool{
	ToolFunc{
		name: "run_cmd",
		run: func(args map[string]string) (string, error) {
			return runCmd(args["cmd"])
		},
	},
	ToolFunc{
		name: "read_file",
		run: func(args map[string]string) (string, error) {
			if args["path"] == "" {
				return "", fmt.Errorf("path is empty")
			}
			return readFile(args["path"])
		},
	},
	ToolFunc{
		name: "write_file",
		run: func(args map[string]string) (string, error) {
			return "ok", writeFile(args["path"], args["content"])
		},
	},
	ToolFunc{
		name: "append_file",
		run: func(args map[string]string) (string, error) {
			return "ok", appendFile(args["path"], args["content"])
		},
	},
	ToolFunc{
		name: "list_dir",
		run: func(args map[string]string) (string, error) {
			path := args["path"]
			if path == "" {
				path = os.Getenv("LOCAL_WORKSPACE")
			}

			if path == "" {
				path = "."
			}
			return listDir(path)
		},
	},
	ToolFunc{
		name: "pwd",
		run: func(args map[string]string) (string, error) {
			return pwd()
		},
	},
	ToolFunc{
		name: "workspace_info",
		run: func(args map[string]string) (string, error) {
			pwd, _ := os.Getwd()

			return fmt.Sprintf(
				`{"local_workspace":"%s","nestor_home":"%s","pwd":"%s","docker_host":"%s","user":"%s"}`,
				os.Getenv("LOCAL_WORKSPACE"),
				os.Getenv("NESTOR_HOME"),
				pwd,
				os.Getenv("DOCKER_HOST"),
				os.Getenv("USER"),
			), nil
		},
	},
	ToolFunc{
		name: "project_root",
		run: func(args map[string]string) (string, error) {
			root := os.Getenv("LOCAL_WORKSPACE")
			if root == "" {
				root, _ = os.Getwd()
			}
			return root, nil
		},
	},
	ToolFunc{
		name: "file_info",
		run: func(args map[string]string) (string, error) {
			return fileInfo(args["path"])
		},
	},
	ToolFunc{
		name: "abs_path",
		run: func(args map[string]string) (string, error) {
			return absPath(args["path"])
		},
	},
	ToolFunc{
		name: "mkdir",
		run: func(args map[string]string) (string, error) {
			return "ok", os.MkdirAll(args["path"], 0755)
		},
	},
	ToolFunc{
		name: "rm",
		run: func(args map[string]string) (string, error) {
			return "ok", os.RemoveAll(args["path"])
		},
	},
	ToolFunc{
		name: "mv",
		run: func(args map[string]string) (string, error) {
			return "ok", os.Rename(args["src"], args["dst"])
		},
	},
	ToolFunc{
		name: "cp",
		run: func(args map[string]string) (string, error) {
			data, err := os.ReadFile(args["src"])
			if err != nil {
				return "", err
			}

			return "ok", os.WriteFile(
				args["dst"],
				data,
				0644,
			)
		}},
	ToolFunc{
		name: "grep",
		run: func(args map[string]string) (string, error) {
			root := args["path"]
			if root == "" {
				root = os.Getenv("LOCAL_WORKSPACE")
			}

			return grepFiles(root, args["pattern"])
		},
	},
	ToolFunc{
		name: "find",
		run: func(args map[string]string) (string, error) {
			return findFiles(
				args["path"],
				args["pattern"],
			)
		},
	},
}
var ignoredDirs = []string{
	".git",
	".containers",
	"node_modules",
	".terraform",
	".dart_tool",
	".gradle",
	".idea",
	".vscode",
}

func findFiles(root, pattern string) (string, error) {
	if root == "" {
		root = os.Getenv("LOCAL_WORKSPACE")
	}

	if root == "" {
		root, _ = os.Getwd()
	}

	var matches []string

	err := filepath.Walk(
		root,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return nil
			}
			if info.IsDir() {
				for _, ignored := range ignoredDirs {
					if info.Name() == ignored {
						return filepath.SkipDir
					}
				}
			}

			if strings.Contains(path, pattern) {
				matches = append(matches, path)
			}

			return nil
		},
	)

	if err != nil {
		return "", err
	}

	return strings.Join(matches, "\n"), nil
}

func grepFiles(root, pattern string) (string, error) {
	if root == "" {
		root = os.Getenv("LOCAL_WORKSPACE")
	}

	if root == "" {
		root, _ = os.Getwd()
	}

	var matches []string

	err := filepath.Walk(
		root,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return nil
			}

			if info.IsDir() {
				for _, ignored := range ignoredDirs {
					if info.Name() == ignored {
						return filepath.SkipDir
					}
				}
				return nil
			}

			data, err := os.ReadFile(path)
			if err != nil {
				return nil
			}

			content := string(data)
			if strings.Contains(content, pattern) {
				matches = append(matches, path)
			}

			return nil
		},
	)

	if err != nil {
		return "", err
	}

	return strings.Join(matches, "\n"), nil
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
