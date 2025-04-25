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
	vault Vault
}

type Vault interface {
	StoreUserRecoveryKey(userID string, xorKey []byte) error
	RetrieveUserRecoveryKey(userID string) ([]byte, error)
	RotateUserRecoveryKey(userID string, xorKey []byte) error
	GetRecoveryKeyVersion(userID string) (int, error)
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

type StoreRecoveryXorKeyRequestBody struct {
	UserID string `json:"userId"`
	XorKey []byte `json:"xorKey"`
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

func (s *Service) RotateUserRecoveryKey(w http.ResponseWriter, r *http.Request) {
	var reqBody StoreRecoveryXorKeyRequestBody

	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	if err := s.vault.RotateUserRecoveryKey(reqBody.UserID, reqBody.XorKey); err != nil {
		http.Error(w, `{"error":"failed to rotate UserRecoveryXorKey in vault"}`, http.StatusInternalServerError)
		log.Error().Err(err).Msg("failed to rotate UserRecoveryXorKey in vault")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"rotation successful"}`))
}

func (s *Service) StoreUserRecoveryKey(w http.ResponseWriter, r *http.Request) {
	_ = r.Context()

	var reqBody StoreRecoveryXorKeyRequestBody

	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	if err := s.vault.StoreUserRecoveryKey(reqBody.UserID, reqBody.XorKey); err != nil {
		http.Error(w, `{"error":"failed to store UserRecoveryXorKey in vault"}`, http.StatusInternalServerError)
		log.Error().Err(err).Msg("failed to store UserRecoveryXorKey in vault")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"xorKey stored successfully"}`))
}

func (s *Service) StoreUserRecoveryKeyWithRotation(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID      string `json:"userId"`
		RecoveryKey string `json:"recoveryKey"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid JSON body"}`, http.StatusBadRequest)
		return
	}
	if err := s.vault.StoreUserRecoveryKey(req.UserID, []byte(req.RecoveryKey)); err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"rotated"}`))
}

// GetRecoveryKeyVersion handles getting the current version of the recovery key for a user.
func (s *Service) GetRecoveryKeyVersion(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID string `json:"userId"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid JSON body"}`, http.StatusBadRequest)
		return
	}
	version, err := s.vault.GetRecoveryKeyVersion(req.UserID)
	if err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{"version": version})
}

// StoreRecoveryKeyVersion handles storing the current version of the recovery key for a user.
func (s *Service) StoreRecoveryKeyVersion(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID  string `json:"userId"`
		Version int    `json:"version"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error":"invalid JSON body"}`, http.StatusBadRequest)
		return
	}
	if err := s.vault.StoreRecoveryKeyVersion(req.UserID, req.Version); err != nil {
		http.Error(w, fmt.Sprintf(`{"error":"%s"}`, err.Error()), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"version stored"}`))
}
