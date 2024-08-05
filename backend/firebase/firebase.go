package firebase

import (
	"context"
	"fmt"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/spf13/viper"
	"google.golang.org/api/option"
)

var config = viper.New()

const appCreationTimeoutConfig = "new_application_timeout"

const (
	databaseURLConfig      = "database_url"
	projectIDConfig        = "project_id"
	serviceAccountIDConfig = "service_account_id"
	storageBucketConfig    = "storage_bucket"
)

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("utrade_firebase")

	config.SetDefault(appCreationTimeoutConfig, 1*time.Minute)
}

type App struct {
	*firebase.App
}

func NewApp(opts ...option.ClientOption) (*App, error) {

	databaseURL := config.GetString(databaseURLConfig)
	projectID := config.GetString(projectIDConfig)
	serviceAccountID := config.GetString(serviceAccountIDConfig)
	storageBucket := config.GetString(storageBucketConfig)

	timeout := config.GetDuration(appCreationTimeoutConfig)

	appCreationCtx, cancelAppCreation := context.WithTimeout(context.Background(), timeout)
	defer cancelAppCreation()

	app, err := firebase.NewApp(appCreationCtx, &firebase.Config{
		AuthOverride:     &map[string]interface{}{},
		DatabaseURL:      databaseURL,
		ProjectID:        projectID,
		ServiceAccountID: serviceAccountID,
		StorageBucket:    storageBucket,
	}, opts...)
	if err != nil {
		return nil, fmt.Errorf("firebase new app: %w", err)
	}
	return &App{
		App: app,
	}, nil
}

type AuthClient struct {
	authClient *auth.Client
	authToken  *auth.Token
}

// NewAuthClient verify the given client Firebase ID_TOKEN.
// The authenticated client is returned and can be used to retrieve specific client information.
func (f *App) NewAuthClient(ctx context.Context, idToken string) (*AuthClient, error) {
	client, err := f.App.Auth(context.Background())
	if err != nil {
		return nil, fmt.Errorf("firebase getting Auth client: %w", err)
	}
	token, err := client.VerifyIDToken(ctx, idToken)
	if err != nil {
		return nil, fmt.Errorf("firebase verifying ID token: %w", err)
	}
	return &AuthClient{
		authClient: client,
		authToken:  token,
	}, nil
}
