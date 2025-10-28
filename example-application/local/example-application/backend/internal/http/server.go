package http

import (
	"fmt"
	"net/http"

	"github.com/spf13/viper"
	backendhttp "github.com/vegito-app/vegito/backend/http"
	"github.com/vegito-app/vegito/backend/internal/firebase"
	apiv1 "github.com/vegito-app/vegito/backend/internal/http/internal/api/v1"
	"github.com/vegito-app/vegito/backend/internal/http/internal/ui"
	uiconfig "github.com/vegito-app/vegito/backend/internal/http/internal/ui/config"
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
	uiServe, err := ui.NewUI(frontendDir)
	if err != nil {
		return fmt.Errorf("http start api, server side ui render: %w", err)
	}
	mux.Handle("GET /ui/config/firebase", http.HandlerFunc(uiconfig.Firebase))
	mux.Handle("GET /ui/config/googlemaps", http.HandlerFunc(uiconfig.GoogleMaps))
	mux.Handle("GET /ui/public", http.StripPrefix("/ui", http.FileServer(http.Dir(frontendDir))))
	mux.Handle("GET /ui", uiServe)
	mux.Handle("GET /cgv", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Bienvenue à Autostop BackEnd!")
	}))
	mux.Handle("GET /confidentiality", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Bienvenue à Autostop BackEnd!")
	}))
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
