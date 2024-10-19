package firebase

import (
	"context"
	"fmt"

	firebase "firebase.google.com/go/v4"

	"github.com/spf13/viper"
)

var config = viper.New()

const adminSDKserviceAccountIDConfig = "adminsdk_serviceaccount_id"

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("firebase")
}

type App struct {
	*firebase.App
}

func NewApp(ctx context.Context) (*App, error) {
	adminSDKserviceAccountID := config.GetString(adminSDKserviceAccountIDConfig)
	app, err := firebase.NewApp(ctx, &firebase.Config{
		ServiceAccountID: adminSDKserviceAccountID,
		DatabaseURL:      "https://moov-438615-rtdb.firebaseio.com",
	})
	if err != nil {
		return nil, fmt.Errorf("firebase new app: %w", err)
	}
	return &App{
		App: app,
	}, nil
}
