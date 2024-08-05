package http

import (
	"fmt"
	"net/http"

	backendhttp "github.com/7d4b9/utrade/backend/http"
	"github.com/7d4b9/utrade/backend/internal/firebase"
	apiv1 "github.com/7d4b9/utrade/backend/internal/http/internal/api/v1"
	"github.com/7d4b9/utrade/backend/internal/http/internal/ui"
	"github.com/spf13/viper"
)

var config = viper.New()

const (
	uiBuildDirConfig = "frontend_build_dir"
	portConfig       = "port"
)

func init() {
	config.AutomaticEnv()
	config.SetDefault(portConfig, "8080")
	config.SetDefault(uiBuildDirConfig, "./frontend/build")
}

// StartAPI creates a new instance of apiv1.Service.
func StartAPI(firebaseClient *firebase.Client) error {

	frontendDir := config.GetString(uiBuildDirConfig)
	port := config.GetString(portConfig)
	mux := http.NewServeMux()

	serviceV1 := apiv1.NewService()
	mux.HandleFunc("POST /run", serviceV1.Run)

	ui, err := ui.NewUI(frontendDir)
	if err != nil {
		return fmt.Errorf("http start api, server side ui render: %w", err)
	}
	mux.Handle("GET /ui", ui)
	mux.Handle("GET /ui/", http.StripPrefix("/ui", http.FileServer(http.Dir(frontendDir))))
	mux.Handle("GET /info", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Bienvenue à Autostop BackEnd!")
	}))
	mux.Handle("GET /", http.FileServer(http.Dir(frontendDir)))

	if err := backendhttp.ListenAndServe(":"+port, mux); err != nil {
		return fmt.Errorf("HTTP listenAndServe: %w", err)
	}
	fmt.Print("BORDEL")
	return nil
}
