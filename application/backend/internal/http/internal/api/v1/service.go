package v1

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/rs/zerolog/log"
)

// // Runner is the underlying data processing layer of Service.
// type Runner interface {
// 	// ExecJob should schedule the job to run asynchronously and return with the current running jobID.
// 	ExecJob(ctx context.Context, content []byte) (jobID string, err error)
// 	// GetJobstatus is used to get the current status of a job or return exist==false if the job does not exist.
// 	GetJobStatus(jobID string) (status string, exist bool)
// 	// ReadJobPerformance is used to get the running performance for a given jobID.
// 	ReadJobPerformance(jobID string) (float64, error)
// }

// Service defines all routes handled by Service
type Service struct {
	// runner Runner
	vault    Vault
	firebase Firebase
}

type Firebase interface {
}

type Vault interface {
	StoreUserRecoveryKey(userID string, recoveryKey []byte) error
	RetrieveUserRecoveryKey(userID string) ([]byte, error)
	GetUserRecoveryKeyVersion(userID string) (int, error)
	StoreRecoveryKeyVersion(userID string, version int) error
}

func NewService(vault Vault) *Service {
	s := &Service{vault: vault}
	return s
}

func (s *Service) Run(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
}

func (s *Service) Status(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
}

type StoreRecoveryKeyRequestBody struct {
	UserID      string `json:"userId"`
	RecoveryKey []byte `json:"recoveryKey"`
}

func (s *Service) RetrieveUserRecoveryKey(w http.ResponseWriter, r *http.Request) {
	var reqBody struct {
		UserID string `json:"userId"`
	}
	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	recoveryKey, err := s.vault.RetrieveUserRecoveryKey(reqBody.UserID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"recoveryKey": string(recoveryKey),
	})
}

func (s *Service) StoreUserRecoveryKey(w http.ResponseWriter, r *http.Request) {
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

// GetUserRecoveryKeyVersion handles getting the current version of the recovery key for a user.
func (s *Service) GetUserRecoveryKeyVersion(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID string `json:"userId"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid JSON body"}`, http.StatusBadRequest)
		return
	}
	version, err := s.vault.GetUserRecoveryKeyVersion(req.UserID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{"version": version})
}
