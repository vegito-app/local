package v1

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/7d4b9/utrade/backend/btc"
	"github.com/7d4b9/utrade/backend/internal/http/ui"
	uiconfig "github.com/7d4b9/utrade/backend/internal/http/ui/config"
	"github.com/rs/zerolog/log"
	"github.com/spf13/viper"
)

var config = viper.New()

const (
	uiBuildDirConfig = "frontend_build_dir"
)

func init() {
	config.AutomaticEnv()
	config.SetDefault(uiBuildDirConfig, "../frontend/build")
}

// Service defines all routes handled by Service
type Service struct {
	http.Handler
	vault Vault
}

type Firebase interface {
}

var (
	ErrRecoveryKeyNotFound = fmt.Errorf("recovery key not found")
)

type Vault interface {
	// StoreUserRecoveryKey stores a user's recovery key in the vault.
	// Returns an error if the storage fails (500).
	StoreUserRecoveryKey(userID string, recoveryKey []byte) error

	// RetrieveUserRecoveryKey retrieves a user's recovery key.
	// Returns (nil, ErrRecoveryKeyNotFound) if the key does not exist (404).
	RetrieveUserRecoveryKey(userID string) ([]byte, error)

	// GetUserRecoveryKeyVersion returns the latest version of the user's recovery key.
	// Returns (0, ErrRecoveryKeyNotFound) if not found (404).
	GetUserRecoveryKeyVersion(userID string) (int, error)

	// StoreRecoveryKeyVersion stores the version for a user's recovery key.
	// Returns an error if the storage fails (500).
	StoreRecoveryKeyVersion(userID string, version int) error
}

func NewService(firebase Firebase, btcService *btc.BTC, vault Vault) (*Service, error) {
	mux := http.NewServeMux()

	frontendDir := config.GetString(uiBuildDirConfig)
	uiServe, err := ui.NewUI(frontendDir)
	if err != nil {
		return nil, fmt.Errorf("http start api, server side ui render: %w", err)
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

	serviceV1 := &Service{
		vault:   vault,
		Handler: mux,
	}
	mux.HandleFunc("POST /run", serviceV1.run)
	mux.HandleFunc("GET /user/store-recoverykey", serviceV1.retrieveUserRecoveryKey)
	mux.HandleFunc("POST /user/store-recoverykey", serviceV1.storeUserRecoveryKey)
	mux.HandleFunc("POST /user/get-recoverykey-version", serviceV1.getUserRecoveryKeyVersion)

	return serviceV1, nil
}

func (s *Service) run(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
}

func (s *Service) Status(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
}

type StoreRecoveryKeyRequestBody struct {
	UserID      string `json:"userId"`
	RecoveryKey []byte `json:"recoveryKey"`
}

func (s *Service) retrieveUserRecoveryKey(w http.ResponseWriter, r *http.Request) {
	var reqBody struct {
		UserID string `json:"userId"`
	}
	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	recoveryKey, err := s.vault.RetrieveUserRecoveryKey(reqBody.UserID)
	if err != nil {
		if errors.Is(err, ErrRecoveryKeyNotFound) {
			http.Error(w, `{"error":"recovery key not found"}`, http.StatusNotFound)
		} else {
			http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"recoveryKey": string(recoveryKey),
	})
}

func (s *Service) storeUserRecoveryKey(w http.ResponseWriter, r *http.Request) {
	_ = r.Context()

	var reqBody StoreRecoveryKeyRequestBody

	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	if err := s.vault.StoreUserRecoveryKey(reqBody.UserID, reqBody.RecoveryKey); err != nil {
		http.Error(w, `{"error":"failed to store UserRecoveryKey in vault"}`, http.StatusInternalServerError)
		log.Error().Err(err).Msg("failed to store UserRecoveryKey in vault")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"recoveryKey stored successfully"}`))
}

// getUserRecoveryKeyVersion handles getting the current version of the recovery key for a user.
func (s *Service) getUserRecoveryKeyVersion(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID string `json:"userId"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid JSON body"}`, http.StatusBadRequest)
		return
	}
	version, err := s.vault.GetUserRecoveryKeyVersion(req.UserID)
	if err != nil {
		if errors.Is(err, ErrRecoveryKeyNotFound) {
			http.Error(w, `{"error":"recovery key version not found"}`, http.StatusNotFound)
		} else {
			http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		}
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{"version": version})
}
