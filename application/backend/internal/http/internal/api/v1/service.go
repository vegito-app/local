package v1

import (
	"encoding/json"
	"net/http"
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
	StorUserRecoveryXorKey(xorKey []byte) error
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

func (s *Service) StoreUserRecoveryXorKey(w http.ResponseWriter, r *http.Request) {
	_ = r.Context()

	var reqBody StoreRecoveryXorKeyRequestBody

	if err := json.NewDecoder(r.Body).Decode(&reqBody); err != nil {
		http.Error(w, `{"error":"invalid request body"}`, http.StatusBadRequest)
		return
	}

	if err := s.vault.StorUserRecoveryXorKey(reqBody.XorKey); err != nil {
		http.Error(w, `{"error":"failed to store xorKey in vault"}`, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"xorKey stored successfully"}`))
}
