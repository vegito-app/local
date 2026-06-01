package http

import (
	"fmt"
	"net/http"

	nestorhttp "github.com/vegito-app/ai-nestor/nestor/http"
)

func StartAPI() error {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "ok")
	})

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Nestor API")
	})

	return nestorhttp.ListenAndServe(":9090", mux)
}
