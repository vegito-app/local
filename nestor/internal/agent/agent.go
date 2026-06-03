package agent

import (
	"context"
	"fmt"
	"os"
	"sort"
	"strings"
)

const DefaultMaxIterations = 20

type ToolRunner interface {
	RunTask(name string, args map[string]string) (string, error)
	ToolNames() []string
}

type Agent struct {
	LLM           *OllamaClient
	Tools         ToolRunner
	MaxIterations int
}

func New(tools ToolRunner) *Agent {
	return &Agent{
		LLM:           NewOllamaClientFromEnv(),
		Tools:         tools,
		MaxIterations: DefaultMaxIterations,
	}
}

func (a *Agent) RunGoal(ctx context.Context, goal string) (string, error) {
	messages := []Message{
		{
			Role:    "system",
			Content: a.systemPrompt(),
		},
		{
			Role:    "user",
			Content: goal,
		},
	}

	for i := 0; i < a.MaxIterations; i++ {
		raw, err := a.LLM.Chat(ctx, messages)
		if err != nil {
			return "", err
		}

		messages = append(messages, Message{
			Role:    "assistant",
			Content: raw,
		})

		response, err := ParseResponse(raw)
		if err != nil {
			messages = append(messages, Message{
				Role: "user",
				Content: "Ta réponse n'est pas un JSON valide. Réponds uniquement avec un JSON de type " +
					`{"tool":"read_file","args":{"path":"go.mod"}}` +
					" ou " +
					`{"done":true,"result":"..."}` +
					fmt.Sprintf(". Erreur: %v", err),
			})
			continue
		}

		if response.Done {
			return response.Result, nil
		}

		if response.Tool == "" {
			messages = append(messages, Message{
				Role:    "user",
				Content: "Aucun outil demandé et done=false. Choisis un outil ou termine avec done=true.",
			})
			continue
		}

		observation, err := a.Tools.RunTask(response.Tool, response.Args)
		if err != nil {
			observation = "error: " + err.Error()
		}

		messages = append(messages, Message{
			Role: "user",
			Content: fmt.Sprintf(
				"TOOL_RESULT for %s:\n%s\n\nContinue. Réponds uniquement en JSON.",
				response.Tool,
				observation,
			),
		})
	}

	return "", fmt.Errorf("agent stopped after %d iterations without done=true", a.MaxIterations)
}

func (a *Agent) systemPrompt() string {
	toolNames := a.Tools.ToolNames()
	sort.Strings(toolNames)

	workspace := os.Getenv("LOCAL_WORKSPACE")
	nestorHome := os.Getenv("NESTOR_HOME")
	pwd, _ := os.Getwd()

	return strings.TrimSpace(fmt.Sprintf(`Tu es Nestor, un agent logiciel autonome vivant dans un conteneur de développement.

Tu dois aider à réaliser l'objectif demandé en utilisant les outils disponibles.

Outils disponibles:
%s

Règles impératives:
- Réponds toujours avec un seul objet JSON valide.
- Ne mets jamais de Markdown autour du JSON.
- Pour utiliser un outil, réponds exactement avec:
  {"tool":"nom_outil","args":{"cle":"valeur"}}
- Quand l'objectif est atteint, réponds exactement avec:
  {"done":true,"result":"résumé court du résultat"}
- Ne prétends jamais avoir exécuté une action: utilise un outil.
- Utilise les chemins relatifs au workspace courant quand c'est possible.

Environnement d'exécution:
- LOCAL_WORKSPACE=%s
- NESTOR_HOME=%s
- Répertoire courant=%s

Tu dois considérer LOCAL_WORKSPACE comme la racine du projet.
Si un fichier n'est pas trouvé, utilise d'abord find ou list_dir pour explorer le workspace.
Privilégie les chemins sous LOCAL_WORKSPACE.
Ignore systématiquement .containers, .git, node_modules, .terraform, .dart_tool, .gradle, .idea et .vscode sauf demande explicite.
Le code source du projet est prioritaire sur les caches, images Docker, overlays et artefacts générés.
Commence généralement par project_root ou workspace_info avant une exploration complexe.
`, formatToolList(toolNames), workspace, nestorHome, pwd))
}

func formatToolList(names []string) string {
	if len(names) == 0 {
		return "- aucun outil"
	}

	lines := make([]string, 0, len(names))
	for _, name := range names {
		lines = append(lines, "- "+name)
	}

	return strings.Join(lines, "\n")
}
