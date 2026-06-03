package main

import "github.com/vegito-app/ai-nestor/nestor/internal/task"

var makeTools = []task.Tool{
	ToolFunc{
		name: "make",
		run: func(args map[string]string) (string, error) {
			target := args["target"]
			if target == "" {
				return runCmd("make")
			}
			return runCmd("make " + target)
		},
	},
}
