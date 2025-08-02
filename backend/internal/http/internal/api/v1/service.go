package v1

import (
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
}

func NewService() *Service {
	s := &Service{}
	return s
}

func (s *Service) Run(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
}

func (s *Service) Status(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(http.StatusOK)
}
