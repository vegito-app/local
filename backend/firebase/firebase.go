package firebase

import (
	"context"
	"encoding/base64"
	"fmt"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/rs/zerolog/log"
	"github.com/spf13/viper"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	"cloud.google.com/go/secretmanager/apiv1/secretmanagerpb"
	_ "github.com/GoogleCloudPlatform/functions-framework-go/funcframework"
	"google.golang.org/api/option"
)

var config = viper.New()

const adminSDKserviceAccountIDConfig = "adminsdk_serviceaccount_id"
const authEmulatorHostConfig = "auth_emulator_host"
const databaseEmulatorHostConfig = "database_emulator_host"

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("firebase")
}

type App struct {
	*firebase.App
}

func NewApp(ctx context.Context) (a *App, err error) {

	var opts []option.ClientOption

	authEmulatorHost := config.GetString(authEmulatorHostConfig)
	databaseEmulatorHost := config.GetString(databaseEmulatorHostConfig)

	if databaseEmulatorHost != "" || authEmulatorHost != "" {
		app, err := firebase.NewApp(ctx, nil, opts...)
		if err != nil {
			return nil, fmt.Errorf("firebase new app: %w", err)
		}
		return &App{
			App: app,
		}, nil
	}

	client, err := secretmanager.NewClient(ctx)
	if err != nil {
		return nil, err
	}
	defer func() {
		err = client.Close()
		if err != nil {
			log.Error().Err(err).Msg("close firebase secretmanager client")
		}
	}()
	adminSDKserviceAccountSecretID := config.GetString(adminSDKserviceAccountIDConfig)
	if adminSDKserviceAccountSecretID != "" {
		firebaseAdminSDKserviceAccountSecretID := &secretmanagerpb.AccessSecretVersionRequest{
			Name: adminSDKserviceAccountSecretID,
		}
		firebaseAdminSDKserviceAccount, err := client.AccessSecretVersion(ctx, firebaseAdminSDKserviceAccountSecretID)
		if err != nil {
			return nil, err
		}
		jsonCredentials, err := base64.RawStdEncoding.DecodeString(string(firebaseAdminSDKserviceAccount.Payload.Data))
		if err != nil {
			return nil, err
		}
		opts = append(opts, option.WithCredentialsJSON(jsonCredentials))
	}

	app, err := firebase.NewApp(ctx, nil, opts...)
	if err != nil {
		return nil, fmt.Errorf("firebase new app: %w", err)
	}
	return &App{
		App: app,
	}, nil
}

type AuthClient struct {
	*auth.Client
}

// NewAuthClient verify the given client Firebase ID_TOKEN.
// The authenticated client is returned and can be used to retrieve specific client information.
func (f *App) NewAuthClient(ctx context.Context) (*AuthClient, error) {
	client, err := f.App.Auth(ctx)
	if err != nil {
		return nil, fmt.Errorf("firebase getting Auth client: %w", err)
	}
	return &AuthClient{
		Client: client,
	}, nil
}
