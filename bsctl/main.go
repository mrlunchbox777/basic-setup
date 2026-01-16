package main

import (
	"fmt"
	"log/slog"
	"os"
	"path"
	"strings"

	"github.com/spf13/cobra"
	pflag "github.com/spf13/pflag"
	"github.com/spf13/viper"

	"github.com/mrlunchbox777/basic-setup/bsctl/cmd"
	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
)

// GetHomeDirFunc
//
// GetHomeDirFunc is a function that returns the user's home directory and an error if one occurred.
// Typically, this function is os.UserHomeDir.
type GetHomeDirFunc func() (string, error)

// GetReadInConfigFunc
//
// GetReadInConfigFunc is a function that reads in the configuration file and returns an error if one occurred.
// Typically, this function is viper.ReadInConfig.
type GetReadInConfigFunc func() error

func main() {
	factory := bsUtil.NewFactory()
	run(factory, os.UserHomeDir, factory.GetViper().ReadInConfig)
}

func run(factory bsUtil.Factory, getHomeDirFunc GetHomeDirFunc, readInConfigFunc GetReadInConfigFunc) {
	flags := pflag.NewFlagSet("bsctl", pflag.ExitOnError)
	flags.String("basic-setup-repo",
		"",
		"Location on the filesystem where the basic-setup repo is checked out")

	// setup the logger
	streams := factory.GetStreams()
	logger := slog.New(slog.NewJSONHandler(streams.ErrOut(), nil))
	// logger := slog.New(slog.NewTextHandler(streams.ErrOut(), nil))
	slog.SetDefault(logger)

	viperInstance := factory.GetViper()

	cobra.OnInitialize(func() {
		// automatically read in environment variables that match supported flags
		// e.g. kubeconfig is a recognized flag so the corresponding env variable is KUBECONFIG
		viperInstance.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
		viperInstance.AutomaticEnv()

		homeDirname, err := getHomeDirFunc()
		if err != nil {
			slog.Default().Error(fmt.Sprintf("Error getting user home directory: %v", err.Error()))
			panic(err)
		}
		viperInstance.SetConfigName("config")
		viperInstance.SetConfigType("yaml")
		viperInstance.AddConfigPath(path.Join(homeDirname,
			".bsctl"))
		viperInstance.AddConfigPath("/etc/bsctl")
		viperInstance.AddConfigPath(".")
		if err := readInConfigFunc(); err != nil {
			if _, ok := err.(viper.ConfigFileNotFoundError); ok {
				// Config file not found; ignore error if desired
				slog.Default().Warn("Config file not found (~/.bsctl/config, /etc/bsctl/config, or ./config).")
			} else {
				// Config file was found but another error was produced
				slog.Default().Error(fmt.Sprintf("Error reading config file: %v", err.Error()))
				panic(err)
			}
		}
	})

	bsCmd := cmd.NewRootCmd(factory)

	flags.AddFlagSet(bsCmd.PersistentFlags())
	pflag.CommandLine = flags

	cobra.CheckErr(bsCmd.Execute())
}
