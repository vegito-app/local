package firebase

import (
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/firestore"
	"github.com/7d4b9/utrade/backend/firebase"
	"google.golang.org/api/option"
)

type Client struct {
	firestore *firestore.Client
}

func NewClient(opts ...option.ClientOption) (*Client, error) {
	app, err := firebase.NewApp(opts...)
	if err != nil {
		return nil, fmt.Errorf("firebase new app: %w", err)
	}
	firestore, err := app.Firestore(context.Background())
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
