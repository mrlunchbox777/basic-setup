package util

import (
	"log/slog"

	"github.com/spf13/viper"

	bbLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/log"
)

// Factory interface
type Factory interface {
	GetLoggingClient() bbLog.Client                              // this can't bubble up an error, if it fails it will panic
	GetLoggingClientWithLogger(logger *slog.Logger) bbLog.Client // this can't bubble up an error, if it fails it will panic
	GetViper() *viper.Viper
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

// GetLoggingClient - get logging client
func (f *UtilityFactory) GetLoggingClient() bbLog.Client {
	return f.GetLoggingClientWithLogger(nil)
}

// GetLoggingClientWithLogger - get logging client providing logger
func (f *UtilityFactory) GetLoggingClientWithLogger(logger *slog.Logger) bbLog.Client {
	clientGetter := bbLog.ClientGetter{}
	client := clientGetter.GetClient(logger)
	return client
}

// GetViper - get viper
func (f *UtilityFactory) GetViper() *viper.Viper {
	return f.viperInstance
}
