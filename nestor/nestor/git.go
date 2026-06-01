package main

func init() {
	addTool(ToolFunc{
		"git_status",
		func(args map[string]string) (string, error) {
			return runCmd("git status")
		},
	})

	addTool(ToolFunc{
		"git_diff",
		func(args map[string]string) (string, error) {
			return runCmd("git diff")
		},
	})

	addTool(ToolFunc{
		"git_log",
		func(args map[string]string) (string, error) {
			return runCmd("git log --oneline -20")
		},
	})

	addTool(ToolFunc{
		"git_branch",
		func(args map[string]string) (string, error) {
			return runCmd("git branch -a")
		},
	})

	addTool(ToolFunc{
		"git_checkout",
		func(args map[string]string) (string, error) {
			return runCmd("git checkout " + args["branch"])
		},
	})

	addTool(ToolFunc{
		"git_commit",
		func(args map[string]string) (string, error) {
			return runCmd(
				"git add -A && git commit -m " + args["message"],
			)
		},
	})
}
