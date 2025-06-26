package util

import (
	"log/slog"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"

	"github.com/mrlunchbox777/basic-setup/bsctl/util/config"
	bsUtilK8s "github.com/mrlunchbox777/basic-setup/bsctl/util/k8s"

	bbLog "repo1.dso.mil/big-bang/apps/developer-tools/bbctl/util/log"
)

// Factory interface
type Factory interface {
	GetConfigClient(*cobra.Command) (*config.ConfigClient, error)
	GetConfigClientWithParams(*cobra.Command, bbLog.Client, *viper.Viper) (*config.ConfigClient, error)
	GetLoggingClient() bbLog.Client                              // this can't bubble up an error, if it fails it will panic
	GetLoggingClientWithParams(logger *slog.Logger) bbLog.Client // this can't bubble up an error, if it fails it will panic
	GetViper() *viper.Viper
	GetStreams() bsUtilK8s.IOStreams
}

// NewFactory - new factory method
func NewFactory() *UtilityFactory {
	return &UtilityFactory{
		viperInstance: viper.New(),
	}
}

// UtilityFactory - util factory
type UtilityFactory struct {
	viperInstance *viper.Viper
}

// GetConfigClient - get config client
func (f *UtilityFactory) GetConfigClient(cmd *cobra.Command) (*config.ConfigClient, error) {
	return f.GetConfigClientWithParams(cmd, nil, nil)
}

func (f *UtilityFactory) GetConfigClientWithParams(cmd *cobra.Command, loggingClient bbLog.Client, viperInstance *viper.Viper) (*config.ConfigClient, error) {
	if loggingClient == nil {
		loggingClient = f.GetLoggingClient()
	}
	if viperInstance == nil {
		viperInstance = f.GetViper()
	}
	clientGetter := config.ClientGetter{}
	return clientGetter.GetClient(cmd, &loggingClient, viperInstance)
}

// GetLoggingClient - get logging client
func (f *UtilityFactory) GetLoggingClient() bbLog.Client {
	return f.GetLoggingClientWithParams(nil)
}

// GetLoggingClientWithLogger - get logging client providing logger
func (f *UtilityFactory) GetLoggingClientWithParams(logger *slog.Logger) bbLog.Client {
	clientGetter := bbLog.ClientGetter{}
	client := clientGetter.GetClient(logger)
	return client
}

// GetViper - get viper
func (f *UtilityFactory) GetViper() *viper.Viper {
	return f.viperInstance
}

// GetStreams - get streams
func (f *UtilityFactory) GetStreams() bsUtilK8s.IOStreams {
	getter := bsUtilK8s.GetIOStreamsGetterConfigured(false)
	return getter.GetIOStreams()
}
