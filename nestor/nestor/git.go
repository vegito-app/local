package main

import (
	"github.com/vegito-app/ai-nestor/nestor/internal/task"
)

var gitTools = []task.Tool{
	ToolFunc{
		name: "git_status",
		run: func(args map[string]string) (string, error) {
			return runCmd("git status")
		},
	},
	ToolFunc{
		name: "git_diff",
		run: func(args map[string]string) (string, error) {
			return runCmd("git diff")
		},
	},
	ToolFunc{
		name: "git_log",
		run: func(args map[string]string) (string, error) {
			return runCmd("git log --oneline -20")
		},
	},
	ToolFunc{
		name: "git_branch",
		run: func(args map[string]string) (string, error) {
			return runCmd("git branch -a")
		},
	},
	ToolFunc{
		name: "git_checkout",
		run: func(args map[string]string) (string, error) {
			return runCmd("git checkout " + args["branch"])
		},
	},
	ToolFunc{
		name: "git_commit",
		run: func(args map[string]string) (string, error) {
			return runCmd(
				"git add -A && git commit -m " + args["message"],
			)
		},
	},
}
