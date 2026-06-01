package main

func init() {
	addTool(ToolFunc{
		name: "make",
		run: func(args map[string]string) (string, error) {
			target := args["target"]
			if target == "" {
				return runCmd("make")
			}
			return runCmd("make " + target)
		},
	})
}
