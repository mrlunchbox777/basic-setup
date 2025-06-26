package main

import (
	"fmt"
	"os"
	"testing"

	utilTest "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestMain(t *testing.T) {
	// Arrange
	// Act
	main()
	// Assert
}

func TestRun(t *testing.T) {
	tests := []struct {
		name  string
		flags []string
		in    string
		out   string
		err   string
	}{
		{
			name:  "no flags",
			flags: []string{},
			in:    "",
			out:   "",
			err:   "",
		},
		{
			name:  "help flag",
			flags: []string{"--help"},
			in:    "",
			out:   "",
			err:   "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			args := []string{"bsctl"}
			args = append(args, tt.flags...)
			os.Args = args
			factory := utilTest.GetFakeFactory()
			streamsGetter := factory.GetStreamsGetter()
			stores := streamsGetter.GetStreamStores()
			// Act
			run(factory, os.UserHomeDir, factory.GetViper().ReadInConfig)
			// Assert
			assert.NotNil(t, stores)
			assert.Equal(t, tt.out, stores.Out.String())
			assert.Equal(t, tt.err, stores.ErrOut.String())
			assert.Equal(t, tt.in, stores.In.String())
		})
	}
}

func TestCobraOnInitializeInRunVersion(t *testing.T) {
	tests := []struct {
		name      string
		args      []string
		expected  string
		err       string
		panic     interface{} // *string
		panicType string
	}{
		{
			name:      "no extra args",
			args:      []string{"bsctl"},
			expected:  "",
			err:       "",
			panic:     nil,
			panicType: "",
		},
		{
			name: "version arg pass",
			args: []string{
				"bsctl",
				"version",
			},
			expected:  "basic-setup cli version",
			err:       "Config file not found (~/.bsctl/config, /etc/bsctl/config, or ./config)",
			panic:     nil,
			panicType: "",
		},
		{
			name: "version arg panic on get user home dir",
			args: []string{
				"bsctl",
				"version",
			},
			expected:  "",
			err:       "",
			panic:     "Error getting user home directory: user: Current not implemented on darwin/amd64",
			panicType: "homeDir",
		},
		{
			name: "version arg panic on read in config",
			args: []string{
				"bsctl",
				"version",
			},
			expected:  "",
			err:       "",
			panic:     "Error reading config file: viper: no configuration file loaded",
			panicType: "readInConfig",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			factory := utilTest.GetFakeFactory()
			os.Args = tt.args
			streams := factory.GetStreamsGetter().GetStreamStores()
			viperInstance := factory.GetViper()
			viperInstance.Set("basic-setup-repo", "test")
			var getHomeDirFunc GetHomeDirFunc
			var readInConfigFunc GetReadInConfigFunc
			switch tt.panicType {
			case "homeDir":
				getHomeDirFunc = func() (string, error) {
					return "", fmt.Errorf(tt.panic.(string))
				}
				readInConfigFunc = viperInstance.ReadInConfig
			case "readInConfig":
				getHomeDirFunc = os.UserHomeDir
				readInConfigFunc = func() error {
					return fmt.Errorf(tt.panic.(string))
				}
			case "":
				getHomeDirFunc = os.UserHomeDir
				readInConfigFunc = viperInstance.ReadInConfig
			}
			panicked := false
			// Act
			if tt.panicType != "" {
				panicked = assert.PanicsWithError(t, tt.panic.(string), func() {
					run(factory, getHomeDirFunc, readInConfigFunc)
				})
			} else {
				run(factory, getHomeDirFunc, readInConfigFunc)
			}
			// Assert
			assert.Equal(t, tt.panicType != "", panicked)
			assert.Contains(t, streams.Out.String(), tt.expected)
			assert.Contains(t, streams.ErrOut.String(), tt.err)
			assert.Empty(t, streams.In.String())
		})
	}
}
