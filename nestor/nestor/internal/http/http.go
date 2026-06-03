package http

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	nestorhttp "github.com/vegito-app/ai-nestor/nestor/http"
	"github.com/vegito-app/ai-nestor/nestor/internal/task"
)

type TaskHandle interface {
	SubmitTask(goal string) (task.ID, error)
	GetTask(id string) (task.Task, error)
	ListTasks() []task.Task
}

type RunRequest struct {
	Goal string `json:"goal"`
}

func StartAPI(t TaskHandle) error {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "ok")
	})

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Nestor API")
	})

	mux.HandleFunc("POST /agent/run", func(w http.ResponseWriter, r *http.Request) {
		var req RunRequest

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		id, err := t.SubmitTask(req.Goal)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		_ = json.NewEncoder(w).Encode(map[string]any{
			"task_id": id,
			"status":  "queued",
		})
	})

	mux.HandleFunc("GET /agent/tasks", func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewEncoder(w).Encode(t.ListTasks())
	})
	port := os.Getenv("PORT")
	if port == "" {
		port = "9090"
	}
	fmt.Printf("Starting server on port %s...\n", port)
	return nestorhttp.ListenAndServe(":"+port, mux)
}
