package v1

import (
	"net/http"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
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
}

type Vault interface {
	StorUserRecoveryXorKey()
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

func (s *Service) StoreUserRecoveryXorKey(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	client, err := secretmanager.NewClient(ctx)
	if err != nil {
		log.Error().Err(err).Msg("new firebase config secretmanager client")
		return
	}
	defer func() {
		err = client.Close()
		if err != nil {
			log.Error().Err(err).Msg("new firebase secretmanager client")
			return
		}
	}()

	// firebaseConfigSecretID := config.GetString(firebaseSecretSecretIDConfig)
	// firebaseConfigSecretVersionRequest := &secretmanagerpb.AccessSecretVersionRequest{
	// 	Name: firebaseConfigSecretID,
	// }
	// firebaseConfigSecretVersion, err := client.AccessSecretVersion(ctx, firebaseConfigSecretVersionRequest)
	// if err != nil {
	// 	log.Error().Err(err).Msg("firebase secret version access")
	// 	return
	// }
	// firebaseConfigSecret := firebaseConfigSecretVersion.GetPayload()
	// if firebaseConfigSecret == nil {
	// 	log.Error().Err(err).Msg("firebase config get payload from secret version")
	// 	return
	// }
	// firebaseConfigJSON := firebaseConfigSecret.Data
	// _, err = w.Write(firebaseConfigJSON)
	// if err != nil {
	// 	log.Error().Err(err).Msg("write firebase decoded secret JSON returned payload")
	// 	return
	// }
	w.WriteHeader(http.StatusOK)
}
