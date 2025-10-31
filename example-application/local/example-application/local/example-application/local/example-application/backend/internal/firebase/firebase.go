package firebase

import (
	"context"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/spf13/viper"
	"github.com/vegito-app/vegito/backend/firebase"
	"google.golang.org/api/option"
)

var config = viper.New()

const appCreationTimeoutConfig = "new_application_timeout"

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("utrade_firebase")
	config.SetDefault(appCreationTimeoutConfig, 1*time.Minute)
}

type Client struct {
	firestore *firestore.Client
}

func NewClient(opts ...option.ClientOption) (*Client, error) {

	timeout := config.GetDuration(appCreationTimeoutConfig)
	ctx, cancelAppCreation := context.WithTimeout(context.Background(), timeout)
	defer cancelAppCreation()

	app, err := firebase.NewApp(ctx)
	if err != nil {
		return nil, fmt.Errorf("firebase new app: %w", err)
	}
	firestore, err := app.Firestore(ctx)
	if err != nil {
		return nil, fmt.Errorf("firebase failed to create client: %w", err)
	}
	return &Client{
		firestore: firestore,
	}, nil
}

func (c *Client) Close() {
	if err := c.firestore.Close(); err != nil {
		log.Println("firebase close firestore, error:", err.Error())
	}
}
