package vault

import (
	"fmt"
	"github.com/hashicorp/vault/api"
	"github.com/spf13/viper"
)

var config viper.Viper

const addrConfig = "addr"

func init() {
	config.AutomaticEnv()
	config.SetDefault(addrConfig, "http://vault:8200")
}

type Client struct {
	apiClient *api.Client
}

func NewVaultClient() (*Client, error) {
	vaultAPIconfig := api.DefaultConfig()

	vaultAPIaddr := config.GetString(addrConfig)
	vaultAPIconfig.Address = vaultAPIaddr

	client, err := api.NewClient(vaultAPIconfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create Vault client: %w", err)
	}
	c := &Client{
		apiClient: client,
	}
	return c, nil
}

func StoreUserRecoveryXorKey(xorKey []byte) error {
	client, err := NewVaultClient()
	if err != nil {
		return fmt.Errorf("unable to initialize Vault client: %w", err)
	}

	data := map[string]interface{}{
		"xorKey": xorKey,
	}

	_, err = client.apiClient.Logical().Write("secret/data/xorkey", map[string]interface{}{
		"data": data,
	})

	if err != nil {
		return fmt.Errorf("failed to write xorKey to Vault: %w", err)
	}
	return nil
}
