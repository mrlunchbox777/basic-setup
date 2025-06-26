package config

import (
	"errors"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	bbLog "repo1.dso.mil/big-bang/apps/developer-tools/bbctl/util/log"

	"github.com/mrlunchbox777/basic-setup/bsctl/util/config/schemas"
)

// GetConfigFunc type
type GetConfigFunc func(*ConfigClient) *schemas.GlobalConfiguration

// SetAndBindFlagFunc type
type SetAndBindFlagFunc func(*ConfigClient, string, interface{}, string) error

// ConfigClient is composed of functions to interact with configuration.
type ConfigClient struct {
	getConfig      GetConfigFunc
	setAndBindFlag SetAndBindFlagFunc
	loggingClient  *bbLog.Client
	command        *cobra.Command
	viperInstance  *viper.Viper
}

// NewClient returns a new config client with the provided configuration
func NewClient(
	getConfig GetConfigFunc,
	setAndBindFlag SetAndBindFlagFunc,
	loggingClient *bbLog.Client,
	command *cobra.Command,
	viperInstance *viper.Viper,
) (*ConfigClient, error) {
	if loggingClient == nil {
		return nil, errors.New("logging client is required")
	}
	if viperInstance == nil {
		return nil, errors.New("viper instance is required")
	}
	return &ConfigClient{
		getConfig:      getConfig,
		setAndBindFlag: setAndBindFlag,
		loggingClient:  loggingClient,
		command:        command,
		viperInstance:  viperInstance,
	}, nil
}

// GetConfig returns the global configuration.
func (client *ConfigClient) GetConfig() *schemas.GlobalConfiguration {
	return client.getConfig(client)
}

// SetAndBindFlag sets and binds a flag to a command and viper.
func (client *ConfigClient) SetAndBindFlag(name string, value interface{}, description string) error {
	return client.setAndBindFlag(client, name, value, description)
}
