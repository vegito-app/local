package vault

import (
	"net"

	"github.com/hashicorp/vault/api"
	"github.com/spf13/viper"
)

var config viper.Viper

const hostConfig = "host"
const portConfig = "port"

func init() {
	config.AutomaticEnv()
	config.SetDefault(hostConfig, "vault")
	config.SetDefault(portConfig, "8200")
}

type Client struct {
	apiClient *api.Client
}

func NewVaultClient() (*Client, error) {
	vaultAPIconfig := api.DefaultConfig()

	host := config.GetString(hostConfig)
	port := config.GetString(portConfig)

	addr := net.JoinHostPort(host, port)

	vaultAPIconfig.Address = "http://" + addr
	client, err := api.NewClient(vaultAPIconfig)
	if err != nil {
		return nil, err
	}
	c := &Client{
		apiClient: client,
	}
	return c, nil
}

func StoreUserRecoveryXorKey() {

}
