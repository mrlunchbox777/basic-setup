package main

import (
	"log/slog"
	"os"
	"path"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"

	"github.com/mrlunchbox777/basic-setup/bsctl/cmd"
	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
	bsK8sUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/k8s"
)

func main() {
	flags := pflag.NewFlagSet("bsctl", pflag.ExitOnError)
	flags.String("basic-setup-repo",
		"",
		"Location on the filesystem where the basic-setup repo is checked out")

	// setup the logger
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	// logger := slog.New(slog.NewTextHandler(os.Stderr, nil))
	slog.SetDefault(logger)

	cobra.OnInitialize(func() {
		// automatically read in environment variables that match supported flags
		// e.g. kubeconfig is a recognized flag so the corresponding env variable is KUBECONFIG
		viper.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
		viper.AutomaticEnv()

		homeDirname, err := os.UserHomeDir()
		if err != nil {
			slog.Default().Error("Error getting user home directory: %v", err)
			panic(err)
		}
		viper.SetConfigName("config")
		viper.SetConfigType("yaml")
		viper.AddConfigPath(path.Join(homeDirname,
			".bsctl"))
		viper.AddConfigPath("/etc/bsctl")
		viper.AddConfigPath(".")
		if err := viper.ReadInConfig(); err != nil {
			if _, ok := err.(viper.ConfigFileNotFoundError); ok {
				// Config file not found; ignore error if desired
				slog.Default().Warn("Config file not found (~/.bsctl/config, /etc/bsctl/config, or ./config).")
			} else {
				// Config file was found but another error was produced
				slog.Default().Error("Error reading config file: %v", err)
				panic(err)
			}
		}
	})

	factory := bsUtil.NewFactory()

	bsCmd := cmd.NewRootCmd(factory, bsK8sUtil.GetIOStream())

	flags.AddFlagSet(bsCmd.PersistentFlags())
	pflag.CommandLine = flags

	cobra.CheckErr(bsCmd.Execute())
}
