package main

import (
	"github.com/vegito-app/ai-nestor/nestor/internal/task"
)

var dockerTools = []task.Tool{
	ToolFunc{
		name: "docker_ps",
		run: func(args map[string]string) (string, error) {
			return runCmd("docker ps")
		},
	},
	ToolFunc{
		name: "docker_logs",
		run: func(args map[string]string) (string, error) {
			return runCmd("docker logs --tail=200 " + args["container"])
		},
	},
	ToolFunc{
		name: "docker_exec",
		run: func(args map[string]string) (string, error) {
			return runCmd(
				"docker exec " +
					args["container"] +
					" bash -lc \"" +
					args["cmd"] +
					"\"",
			)
		},
	},
}
