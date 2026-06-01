package main

func init() {
	addTool(ToolFunc{
		"docker_ps",
		func(args map[string]string) (string, error) {
			return runCmd("docker ps")
		},
	})

	addTool(ToolFunc{
		"docker_logs",
		func(args map[string]string) (string, error) {
			return runCmd(
				"docker logs --tail=200 " + args["container"],
			)
		},
	})

	addTool(ToolFunc{
		"docker_exec",
		func(args map[string]string) (string, error) {
			return runCmd(
				"docker exec " +
					args["container"] +
					" bash -lc \"" +
					args["cmd"] +
					"\"",
			)
		},
	})
}
