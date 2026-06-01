package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func init() {
	addTool(ToolFunc{"run_cmd", func(args map[string]string) (string, error) {
		return runCmd(args["cmd"])
	}})

	addTool(ToolFunc{"read_file", func(args map[string]string) (string, error) {
		return readFile(args["path"])
	}})

	addTool(ToolFunc{"write_file", func(args map[string]string) (string, error) {
		return "ok", writeFile(args["path"], args["content"])
	}})

	addTool(ToolFunc{"append_file", func(args map[string]string) (string, error) {
		return "ok", appendFile(args["path"], args["content"])
	}})

	addTool(ToolFunc{"list_dir", func(args map[string]string) (string, error) {
		return listDir(args["path"])
	}})

	addTool(ToolFunc{"pwd", func(args map[string]string) (string, error) {
		return pwd()
	}})

	addTool(ToolFunc{"file_info", func(args map[string]string) (string, error) {
		return fileInfo(args["path"])
	}})

	addTool(ToolFunc{"abs_path", func(args map[string]string) (string, error) {
		return absPath(args["path"])
	}})
	addTool(ToolFunc{"mkdir", func(args map[string]string) (string, error) {
		return "ok", os.MkdirAll(args["path"], 0755)
	}})
	addTool(ToolFunc{"rm", func(args map[string]string) (string, error) {
		return "ok", os.RemoveAll(args["path"])
	}})
	addTool(ToolFunc{"mv", func(args map[string]string) (string, error) {
		return "ok", os.Rename(args["src"], args["dst"])
	}})
	addTool(ToolFunc{"cp", func(args map[string]string) (string, error) {
		data, err := os.ReadFile(args["src"])
		if err != nil {
			return "", err
		}

		return "ok", os.WriteFile(
			args["dst"],
			data,
			0644,
		)
	}})
	addTool(ToolFunc{"grep", func(args map[string]string) (string, error) {
		return runCmd(
			fmt.Sprintf(
				"grep -RIn %q %s",
				args["pattern"],
				args["path"],
			),
		)
	}})
	addTool(ToolFunc{"find", func(args map[string]string) (string, error) {
		return findFiles(
			args["path"],
			args["pattern"],
		)
	}})
}

func findFiles(root, pattern string) (string, error) {
	var matches []string

	err := filepath.Walk(
		root,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return nil
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
