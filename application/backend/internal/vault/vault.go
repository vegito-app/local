package vault

import (
	"fmt"

	"github.com/hashicorp/vault/api"
	"github.com/spf13/viper"
)

var config = viper.New()

const addrConfig = "addr"
const maxUserRecoveryKeysConfig = "max_user_recovery_xorkeys"

func init() {
	config.AutomaticEnv()
	config.SetDefault(addrConfig, "http://vault:8200")
	config.SetDefault(maxUserRecoveryKeysConfig, 5)
}

type Client struct {
	apiClient *api.Client

	maxRecoveryXorKeys int
}

func NewVaultClient() (*Client, error) {
	vaultAPIconfig := api.DefaultConfig()

	vaultAPIaddr := config.GetString(addrConfig)
	vaultAPIconfig.Address = vaultAPIaddr

	client, err := api.NewClient(vaultAPIconfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create Vault client: %w", err)
	}
	maxUserRecoveryKeys := config.GetInt(maxUserRecoveryKeysConfig)
	c := &Client{
		apiClient:          client,
		maxRecoveryXorKeys: maxUserRecoveryKeys,
	}
	return c, nil
}

func (c *Client) StoreUserRecoveryKey(userID string, recoveryKey []byte) error {
	client, err := NewVaultClient()
	if err != nil {
		return fmt.Errorf("unable to initialize Vault client: %w", err)
	}

	data := map[string]interface{}{
		"recoveryKey": recoveryKey,
	}

	_, err = client.apiClient.Logical().Write("secret/data/recoverykey", map[string]interface{}{
		"data": data,
	})

	if err != nil {
		return fmt.Errorf("failed to write recoveryKey to Vault: %w", err)
	}
	return nil
}

func (c *Client) RotateUserRecoveryKey(userID string, newKey []byte) error {

	// rotation: shift keys from 3→4, 2→3, ..., 0→1
	for i := c.maxRecoveryXorKeys; i >= 0; i-- {
		src := fmt.Sprintf("secret/data/recoverykey/%s/%d", userID, i)
		dst := fmt.Sprintf("secret/data/recoverykey/%s/%d", userID, i+1)

		secret, err := c.apiClient.Logical().Read(src)
		if err == nil && secret != nil && secret.Data != nil {
			if dataRaw, ok := secret.Data["data"].(map[string]interface{}); ok {
				_, _ = c.apiClient.Logical().Write(dst, map[string]interface{}{
					"data": dataRaw,
				})
			}
		}
	}

	// store new key in recoverykey/0
	path := fmt.Sprintf("secret/data/recoverykey/%s/0", userID)
	_, err := c.apiClient.Logical().Write(path, map[string]interface{}{
		"data": map[string]interface{}{"recoveryKey": newKey},
	})
	if err != nil {
		return fmt.Errorf("failed to write recoveryKey to Vault: %w", err)
	}
	return nil
}

func (c *Client) RetrieveUserRecoveryKey(userID string) ([]byte, error) {

	path := fmt.Sprintf("secret/data/recoverykey/%s/%d", userID, 0)
	secret, err := c.apiClient.Logical().Read(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read recoveryKey from Vault: %w", err)
	}

	if secret == nil || secret.Data == nil {
		return nil, fmt.Errorf("no data found at path %s", path)
	}

	dataMap, ok := secret.Data["data"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid data format at path %s", path)
	}

	val, ok := dataMap["recoveryKey"].(string)
	if !ok {
		return nil, fmt.Errorf("recoveryKey not found or invalid at path %s", path)
	}

	return []byte(val), nil
}
