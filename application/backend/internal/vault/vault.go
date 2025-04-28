package vault

import (
	"context"
	"fmt"
	"time"

	"github.com/7d4b9/utrade/backend/vault"
	"github.com/spf13/viper"
)

var config = viper.New()

const (
	addrConfig                = "addr"
	maxUserRecoveryKeysConfig = "max_user_recovery_xorkeys"
	minRotationInterval       = 24 * time.Hour
)

// UserStorage is backend storage for secured userData
type Vault interface {
	DecryptUserRecoveryKey(encryptedUserRecoveryKey []byte) ([]byte, error)
	EncryptUserRecoveryKey(userRecoveryKey []byte) ([]byte, error)
}

// UserStorage is backend storage for secured userData
type UserStorage interface {
	StoreEncryptedUserRecoveryKey(userID string, version int, encryptedUserRecoveryKey []byte) error
	RetrieveEncryptedUserRecoveryKey(userID string, version int) ([]byte, error)
	RetrieveLatestRecoveryKeyVersion(userID string) (int, error)
	StoreLatestRecoveryKeyVersion(userID string, version int) error
	RetrieveLastRotationTimestamp(userID string) (time.Time, error)
	StoreLastRotationTimestamp(userID string, timestamp time.Time) error
	DeleteOldRecoveryKeyVersions(userID string, keepLatestN int) error
}

type Client struct {
	apiClient Vault

	userStorage UserStorage

	maxRecoveryXorKeys int
}

func NewClient(ctx context.Context, userStorage UserStorage) (*Client, error) {
	config.AutomaticEnv()

	maxUserRecoveryKeys := config.GetInt(maxUserRecoveryKeysConfig)
	if maxUserRecoveryKeys == 0 {
		maxUserRecoveryKeys = 5
	}
	vaultAPIclient, err := vault.NewAPIclient(ctx)
	if err != nil {
		return nil, fmt.Errorf("new Vault vault: %w", err)
	}
	return &Client{
		apiClient: vaultAPIclient,

		userStorage: userStorage,

		maxRecoveryXorKeys: maxUserRecoveryKeys,
	}, nil
}

// StoreUserRecoveryKey encrypts and stores a new user recovery key with versioning and rotation limits.
func (c *Client) StoreUserRecoveryKey(userID string, recoveryKey []byte) error {

	lastRotation, err := c.userStorage.RetrieveLastRotationTimestamp(userID)
	if err == nil && time.Since(lastRotation) < minRotationInterval {
		return fmt.Errorf("recovery key rotation too frequent for user %s", userID)
	}

	latestVersion, err := c.userStorage.RetrieveLatestRecoveryKeyVersion(userID)
	if err != nil {
		latestVersion = 0
	}
	newVersion := latestVersion + 1

	encryptedSecret, err := c.apiClient.EncryptUserRecoveryKey(recoveryKey)
	if err != nil {
		return fmt.Errorf("failed to encrypt recoveryKey with Vault Transit: %w", err)
	}

	if err := c.userStorage.StoreEncryptedUserRecoveryKey(userID, newVersion, encryptedSecret); err != nil {
		return fmt.Errorf("failed to store encrypted recovery key: %w", err)
	}

	if err := c.userStorage.StoreLatestRecoveryKeyVersion(userID, newVersion); err != nil {
		return fmt.Errorf("failed to update latest version: %w", err)
	}

	if err := c.userStorage.StoreLastRotationTimestamp(userID, time.Now()); err != nil {
		return fmt.Errorf("failed to update last rotation timestamp: %w", err)
	}

	if err := c.userStorage.DeleteOldRecoveryKeyVersions(userID, c.maxRecoveryXorKeys); err != nil {
		return fmt.Errorf("failed to delete old recovery keys: %w", err)
	}

	return nil
}

// RetrieveUserRecoveryKey retrieves and decrypts the latest user recovery key.
func (c *Client) RetrieveUserRecoveryKey(userID string) ([]byte, error) {

	latestVersion, err := c.userStorage.RetrieveLatestRecoveryKeyVersion(userID)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve latest version: %w", err)
	}

	encryptedRecoveryKey, err := c.userStorage.RetrieveEncryptedUserRecoveryKey(userID, latestVersion)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve encrypted recovery key: %w", err)
	}

	recoveryKey, err := c.apiClient.DecryptUserRecoveryKey(encryptedRecoveryKey)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt recoveryKey with Vault Transit: %w", err)
	}

	return recoveryKey, nil
}

func (c *Client) GetUserRecoveryKeyVersion(userID string) (int, error) {
	return c.userStorage.RetrieveLatestRecoveryKeyVersion(userID)
}

func (c *Client) StoreRecoveryKeyVersion(userID string, version int) error {
	return c.userStorage.StoreLatestRecoveryKeyVersion(userID, version)
}
