package firebase

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/7d4b9/utrade/backend/firebase"
	"github.com/7d4b9/utrade/backend/internal/vault"
	"github.com/spf13/viper"
	"google.golang.org/api/option"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

var config = viper.New()

const appCreationTimeoutConfig = "new_application_timeout"

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("firebase")
	config.SetDefault(appCreationTimeoutConfig, 1*time.Minute)
}

type Client struct {
	*VegetableStorage
	firestore *firestore.Client
	app       *firebase.App
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
	vegetableStorage := &VegetableStorage{
		firestore: firestore,
	}
	return &Client{
		VegetableStorage: vegetableStorage,
		app:              app,
		firestore:        firestore,
	}, nil
}

func (c *Client) Close() {
	if err := c.firestore.Close(); err != nil {
		log.Println("firebase close firestore, error:", err.Error())
	}
}

func (f *Client) StoreEncryptedUserRecoveryKey(userID string, version int, encryptedUserRecoveryKey []byte) error {
	ctx := context.Background()
	doc := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys").Doc(fmt.Sprintf("%d", version))
	_, err := doc.Set(ctx, map[string]any{
		"recoveryKey": encryptedUserRecoveryKey,
	})
	if err != nil {
		return fmt.Errorf("failed to store encrypted user recovery key version %d: %w", version, err)
	}
	return nil
}

func (f *Client) RetrieveEncryptedUserRecoveryKey(userID string, version int) ([]byte, error) {
	ctx := context.Background()
	doc := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys").Doc(fmt.Sprintf("%d", version))
	snapshot, err := doc.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve encrypted user recovery key version %d: %w", version, err)
	}
	data := snapshot.Data()
	recoveryKeyRaw, ok := data["recoveryKey"]
	if !ok {
		return nil, fmt.Errorf("recoveryKey not found for user %s version %d", userID, version)
	}
	recoveryKeyBytes, ok := recoveryKeyRaw.([]byte)
	if !ok {
		return nil, fmt.Errorf("invalid type for recoveryKey for user %s version %d", userID, version)
	}
	return recoveryKeyBytes, nil
}

func (f *Client) RetrieveLatestRecoveryKeyVersion(userID string) (int, error) {
	ctx := context.Background()
	doc := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys_metadata").Doc("metadata")
	snapshot, err := doc.Get(ctx)
	if errFromError, ok := status.FromError(err); ok {
		if errFromError.Code() == codes.NotFound {
			return 0, vault.ErrRecoveryKeyVersionNotFound
		}
	}
	if err != nil {
		return 0, fmt.Errorf("failed to retrieve latest version: %w", err)
	}
	data := snapshot.Data()
	versionRaw, ok := data["latestVersion"]
	if !ok {
		return 0, fmt.Errorf("latestVersion not found for user %s", userID)
	}
	version, ok := versionRaw.(int64)
	if !ok {
		return 0, fmt.Errorf("invalid type for latestVersion for user %s", userID)
	}
	return int(version), nil
}

func (f *Client) StoreLatestRecoveryKeyVersion(userID string, version int) error {
	ctx := context.Background()
	doc := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys_metadata").Doc("metadata")
	_, err := doc.Set(ctx, map[string]any{
		"latestVersion": version,
	}, firestore.MergeAll)
	if err != nil {
		return fmt.Errorf("failed to store latest version: %w", err)
	}
	return nil
}

func (f *Client) RetrieveLastRotationTimestamp(userID string) (time.Time, error) {
	ctx := context.Background()
	doc := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys_metadata").Doc("metadata")
	snapshot, err := doc.Get(ctx)
	if errFromError, ok := status.FromError(err); ok {
		if errFromError.Code() == codes.NotFound {
			return time.Time{}, vault.ErrRotationTimestampNotFound
		}
	}
	if err != nil {
		return time.Time{}, fmt.Errorf("failed to retrieve last rotation timestamp: %w", err)
	}
	data := snapshot.Data()
	timestampRaw, ok := data["lastRotationAt"]
	if !ok {
		return time.Time{}, vault.ErrRotationTimestampNotFound
	}
	timestamp, ok := timestampRaw.(time.Time)
	if !ok {
		return time.Time{}, fmt.Errorf("invalid type for lastRotationAt for user %s", userID)
	}
	return timestamp, nil
}

func (f *Client) StoreLastRotationTimestamp(userID string, timestamp time.Time) error {
	ctx := context.Background()
	doc := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys_metadata").Doc("metadata")
	_, err := doc.Set(ctx, map[string]any{
		"lastRotationAt": timestamp,
	}, firestore.MergeAll)
	if err != nil {
		return fmt.Errorf("failed to store last rotation timestamp: %w", err)
	}
	return nil
}

func (f *Client) DeleteOldRecoveryKeyVersions(userID string, keepLatestN int) error {
	ctx := context.Background()
	collection := f.firestore.Collection("users").Doc(userID).Collection("recoveryKeys")
	snapshots, err := collection.Documents(ctx).GetAll()
	if err != nil {
		return fmt.Errorf("failed to list recovery key versions: %w", err)
	}
	if len(snapshots) <= keepLatestN {
		return nil
	}
	toDelete := snapshots[:len(snapshots)-keepLatestN]
	for _, snap := range toDelete {
		_, err := snap.Ref.Delete(ctx)
		if err != nil {
			return fmt.Errorf("failed to delete old recovery key version: %w", err)
		}
	}
	return nil
}

func (f *Client) VerifyIDToken(ctx context.Context, idToken string) (string, error) {
	// Bypass verification if using Auth Emulator
	if f.app.UseAuthEmulator {
		// decode payload part of the JWT to extract user ID (mock)
		parts := strings.Split(idToken, ".")
		if len(parts) != 3 {
			return "", fmt.Errorf("invalid mock token structure")
		}
		payload, err := base64.RawURLEncoding.DecodeString(parts[1])
		if err != nil {
			return "", fmt.Errorf("invalid mock token payload: %w", err)
		}
		var data struct {
			UserID string `json:"user_id"`
			Sub    string `json:"sub"`
		}
		if err := json.Unmarshal(payload, &data); err != nil {
			return "", fmt.Errorf("unmarshal payload: %w", err)
		}
		if data.Sub != "" {
			return data.Sub, nil
		}
		if data.UserID != "" {
			return data.UserID, nil
		}
		return "", fmt.Errorf("no user id found in mock token")
	}

	// Normal production verification
	authClient, err := f.app.NewAuthClient(ctx)
	if err != nil {
		return "", fmt.Errorf("getting auth client: %w", err)
	}
	token, err := authClient.VerifyIDToken(ctx, idToken)
	if err != nil {
		return "", fmt.Errorf("invalid token: %w", err)
	}
	return token.UID, nil
}
