package http

import (
	"fmt"
	"net/http"

	"github.com/7d4b9/utrade/backend/btc"
	backendhttp "github.com/7d4b9/utrade/backend/http"
	"github.com/7d4b9/utrade/backend/internal/firebase"
	apiv1 "github.com/7d4b9/utrade/backend/internal/http/internal/api/v1"
	"github.com/7d4b9/utrade/backend/internal/http/internal/ui"
	uiconfig "github.com/7d4b9/utrade/backend/internal/http/internal/ui/config"
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
	config.SetDefault(uiBuildDirConfig, "../frontend/build")
}

// Middleware CORS
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Autoriser les requêtes depuis n'importe quelle origine (en dev)
		w.Header().Set("Access-Control-Allow-Origin", "*")
		// Autoriser les méthodes HTTP spécifiques
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		// Autoriser les en-têtes spécifiques
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Gérer la pré-vérification des requêtes OPTIONS (préflight requests)
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Passer à l'étape suivante
		next.ServeHTTP(w, r)
	})
}

// StartAPI creates a new instance of apiv1.Service.
func StartAPI(firebaseClient *firebase.Client, btcService *btc.BTC, vault apiv1.Vault) error {
	frontendDir := config.GetString(uiBuildDirConfig)
	port := config.GetString(portConfig)
	mux := http.NewServeMux()
	serviceV1 := apiv1.NewService(vault)
	mux.HandleFunc("POST /run", serviceV1.Run)
	mux.HandleFunc("GET /user/store-recoverykey", serviceV1.RetrieveUserRecoveryKey)
	mux.HandleFunc("POST /user/store-recoverykey", serviceV1.StoreUserRecoveryKey)
	mux.HandleFunc("POST /user/rotate-recoverykey", serviceV1.StoreUserRecoveryKeyWithRotation)
	uiServe, err := ui.NewUI(frontendDir)
	if err != nil {
		return fmt.Errorf("http start api, server side ui render: %w", err)
	}
	mux.Handle("GET /ui/config/firebase", http.HandlerFunc(uiconfig.Firebase))
	mux.Handle("GET /ui/config/googlemaps", http.HandlerFunc(uiconfig.GoogleMaps))
	mux.Handle("GET /ui/public", http.StripPrefix("/ui", http.FileServer(http.Dir(frontendDir))))
	mux.Handle("GET /ui", uiServe)
	mux.Handle("GET /price", http.HandlerFunc(btcService.Price))
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
	if err := backendhttp.ListenAndServe("0.0.0.0:"+port, corsMiddleware(mux)); err != nil {
		return fmt.Errorf("HTTP listenAndServe: %w", err)
	}
	fmt.Print("See you the next time ! Bye")
	return nil
}
