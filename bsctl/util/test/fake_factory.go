package test

import (
	"fmt"
	"log/slog"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"

	"github.com/mrlunchbox777/basic-setup/bsctl/util/config"
	bbLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/log"
	fakeLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/test/log"
)

// GetFakeFactory - get fake factory
func GetFakeFactory() *FakeFactory {
	factory := &FakeFactory{
		viperInstance: viper.New(),
	}
	factory.SetLoggingFunc(nil)
	return factory
}

// SetLoggingFunc - set logging function
func (f *FakeFactory) SetLoggingFunc(loggingFunc fakeLog.LoggingFunction) {
	var loggingFuncToUse fakeLog.LoggingFunction
	if loggingFunc == nil {
		loggingFuncToUse = func(args ...string) {
			fmt.Println(args)
		}
	} else {
		loggingFuncToUse = loggingFunc
	}
	f.loggingFunc = loggingFuncToUse
}

// FakeFactory - fake factory
type FakeFactory struct {
	loggingFunc   fakeLog.LoggingFunction
	viperInstance *viper.Viper
}

func (f *FakeFactory) GetConfigClient(cmd *cobra.Command) (*config.ConfigClient, error) {
	return f.GetConfigClientWithParams(cmd, nil, nil)
}
func (f *FakeFactory) GetConfigClientWithParams(cmd *cobra.Command, loggingClient bbLog.Client, viperInstance *viper.Viper) (*config.ConfigClient, error) {
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
func (f *FakeFactory) GetLoggingClient() bbLog.Client {
	return f.GetLoggingClientWithParams(nil)
}

// GetLoggingClientWithParams - get logging client providing logger
func (f *FakeFactory) GetLoggingClientWithParams(logger *slog.Logger) bbLog.Client {
	var localFunc fakeLog.LoggingFunction
	if f.loggingFunc == nil {
		localFunc = func(args ...string) {
			fmt.Println(args)
		}
	} else {
		localFunc = f.loggingFunc
	}

	client := fakeLog.NewFakeClient(localFunc)
	return client
}

// GetViper - get viper
func (f *FakeFactory) GetViper() *viper.Viper {
	return f.viperInstance
}
