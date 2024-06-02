package config

import (
	"errors"
	"fmt"
	"os"
	"path"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v2"
	genericIoOptions "k8s.io/cli-runtime/pkg/genericiooptions"
	bbTestLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/test/log"

	"github.com/mrlunchbox777/basic-setup/bsctl/util/config/schemas"
)

func GetValueFromViper(t *testing.T, v *viper.Viper, key string, arg interface{}) (interface{}, error) {
	switch arg.(type) {
	case bool:
		return v.GetBool(key), nil
	case time.Duration:
		return v.GetDuration(key), nil
	case float64:
		return v.GetFloat64(key), nil
	case int:
		return v.GetInt(key), nil
	case int32:
		return v.GetInt32(key), nil
	case int64:
		return v.GetInt64(key), nil
	case []int:
		return v.GetIntSlice(key), nil
	case string:
		return v.GetString(key), nil
	case map[string]string:
		return v.GetStringMapString(key), nil
	case []string:
		return v.GetStringSlice(key), nil
	case uint:
		return v.GetUint(key), nil
	case uint32:
		return v.GetUint32(key), nil
	case uint64:
		return v.GetUint64(key), nil
	default:
		return nil, errors.New("unsupported type")
	}
}

func WriteConfigFile(t *testing.T, dirname string, config schemas.BaseConfiguration) {
	content, err := yaml.Marshal(config)
	assert.NoError(t, err)
	assert.NoError(t, os.MkdirAll(dirname, 0755))
	assert.NoError(t, os.WriteFile(path.Join(dirname, "config.yaml"), content, 0644))
}

func GetDefaultConfig(t *testing.T) schemas.BaseConfiguration {
	return &schemas.GlobalConfiguration{
		BasicSetupRepo: "test",
		ExampleConfiguration: schemas.ExampleConfiguration{
			ShouldError:  false,
			ExtraConfigs: []schemas.BaseConfiguration{},
		},
	}
}

func TestSetAndBindFlag(t *testing.T) {
	// Arrange
	var tests = []struct {
		desc      string
		arg       interface{}
		willError bool
		expected  interface{}
	}{
		{
			"set bool",
			true,
			false,
			true,
		},
		{
			"set duration",
			time.Duration(1),
			false,
			time.Duration(1),
		},
		{
			"set float64",
			float64(1),
			false,
			float64(1),
		},
		{
			"set int",
			int(1),
			false,
			int(1),
		},
		{
			"set int32",
			int32(1),
			false,
			int32(1),
		},
		{
			"set int64",
			int64(1),
			false,
			int64(1),
		},
		{
			"set int slice",
			[]int{1},
			false,
			[]int{1},
		},
		{
			"set string",
			"test",
			false,
			"test",
		},
		{
			"set interface map",
			map[string]interface{}{"test": "test"},
			true,
			nil,
		},
		{
			"set string map",
			map[string]string{"test": "test"},
			false,
			map[string]string{"test": "test"},
		},
		{
			"set string slice map",
			map[string][]string{"test": {"test"}},
			true,
			nil,
		},
		{
			"set string slice",
			[]string{"test"},
			false,
			[]string{"test"},
		},
		{
			"set time",
			time.Time{},
			true,
			nil,
		},
		{
			"set uint",
			uint(1),
			false,
			uint(1),
		},
		{
			"set uint32",
			uint32(1),
			false,
			uint32(1),
		},
		{
			"set uint64",
			uint64(1),
			false,
			uint64(1),
		},
	}

	for _, tt := range tests {
		// Arrange
		name := "testName"
		description := "testDescription"
		streams, in, out, errOut := genericIoOptions.NewTestIOStreams()
		var loggingFunc = func(args ...string) {
			_, err := streams.ErrOut.Write([]byte(args[0]))
			assert.NoError(t, err)
		}
		loggingClient := bbTestLog.NewFakeClient(loggingFunc)
		command := &cobra.Command{}
		v := viper.New()
		configClient := ConfigClient{
			command:       command,
			loggingClient: &loggingClient,
			viperInstance: v,
		}
		var result interface{}
		// Act
		primaryErr := SetAndBindFlag(&configClient, name, tt.arg, description)
		err := v.BindPFlags(command.PersistentFlags())
		// Assert
		assert.NoError(t, err)
		assert.Empty(t, in.String())
		assert.Empty(t, out.String())
		assert.Empty(t, errOut.String())
		if tt.willError {
			assert.Error(t, primaryErr)
			assert.Nil(t, command.PersistentFlags().Lookup(name))
			result, err = GetValueFromViper(t, v, name, tt.arg)
			assert.Error(t, err)
			assert.Nil(t, result)
		} else {
			assert.NoError(t, primaryErr)
			assert.Equal(t, name, command.PersistentFlags().Lookup(name).Name)
			assert.Equal(t, description, command.PersistentFlags().Lookup(name).Usage)
			result, err = GetValueFromViper(t, v, name, tt.arg)
			assert.NoError(t, err)
			assert.Equal(t, tt.expected, result)
		}
	}
}

func TestSetAndBindFlagFail(t *testing.T) {
	// Arrange
	streams, in, out, errOut := genericIoOptions.NewTestIOStreams()
	var loggingFunc = func(args ...string) {
		_, err := streams.ErrOut.Write([]byte(args[0]))
		assert.NoError(t, err)
	}
	loggingClient := bbTestLog.NewFakeClient(loggingFunc)
	configClient := ConfigClient{
		loggingClient: &loggingClient,
	}
	// Act
	err := SetAndBindFlag(&configClient, "test", map[string]interface{}{"test": "test"}, "test")
	// Assert
	assert.Error(t, err)
	assert.Empty(t, in.String())
	assert.Empty(t, out.String())
	assert.Empty(t, errOut.String())
}

func TestGetConfig(t *testing.T) {
	// Arrange
	streams, in, out, errOut := genericIoOptions.NewTestIOStreams()
	var loggingFunc = func(args ...string) {
		_, err := streams.ErrOut.Write([]byte(args[0]))
		assert.NoError(t, err)
	}
	loggingClient := bbTestLog.NewFakeClient(loggingFunc)
	v := viper.New()
	v.Set("basic-setup-repo", "test")
	command := &cobra.Command{}
	configClient := ConfigClient{
		command:       command,
		loggingClient: &loggingClient,
		viperInstance: v,
	}
	// Act
	config := getConfig(&configClient)
	// Assert
	assert.Empty(t, in.String())
	assert.Empty(t, out.String())
	assert.Empty(t, errOut.String())
	assert.NotNil(t, config)
	assert.Equal(t, "test", config.BasicSetupRepo)
}

func TestGetConfigFailValidation(t *testing.T) {
	// Arrange
	streams, in, out, errOut := genericIoOptions.NewTestIOStreams()
	var loggingFunc = func(args ...string) {
		_, err := streams.ErrOut.Write([]byte(args[0]))
		assert.NoError(t, err)
	}
	loggingClient := bbTestLog.NewFakeClient(loggingFunc)
	command := &cobra.Command{}
	v := viper.New()
	configClient := ConfigClient{
		command:       command,
		loggingClient: &loggingClient,
		viperInstance: v,
	}
	// Act
	assert.Panics(t, func() { getConfig(&configClient) })
	// Assert
	assert.Empty(t, in.String())
	assert.Empty(t, out.String())
	assert.NotEmpty(t, errOut.String())
	assert.Contains(t, errOut.String(), "Error during validation for configuration")
}

func TestReadConfig(t *testing.T) {
	// Arrange
	streams, in, out, errOut := genericIoOptions.NewTestIOStreams()
	var loggingFunc = func(args ...string) {
		_, err := streams.ErrOut.Write([]byte(args[0]))
		assert.NoError(t, err)
	}
	loggingClient := bbTestLog.NewFakeClient(loggingFunc)
	v := viper.New()
	v.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
	// v.AutomaticEnv() // don't set this because it will read from the environment
	randomString := strconv.FormatInt(time.Now().UnixMilli(), 10)
	configDir := fmt.Sprintf("/tmp/bsctl-test-%s/", randomString)
	assert.NoError(t, os.Mkdir(configDir, 0755))
	originalConfig := GetDefaultConfig(t)
	WriteConfigFile(t, configDir, originalConfig)
	v.SetConfigName("config")
	v.SetConfigType("yaml")
	v.AddConfigPath(configDir)
	assert.NoError(t, v.ReadInConfig())

	configClient := ConfigClient{
		getConfig:     getConfig,
		loggingClient: &loggingClient,
		viperInstance: v,
	}
	// Act
	allSettings := v.AllSettings()
	resultConfig := getConfig(&configClient)
	// Assert
	assert.NotNil(t, resultConfig)
	assert.NotEmpty(t, allSettings)
	assert.FileExists(t, path.Join(configDir, "config.yaml"))
	assert.Empty(t, in.String())
	assert.Empty(t, out.String())
	assert.Empty(t, errOut.String())
	assert.Equal(t, originalConfig, resultConfig)
}

func TestReadConfigAndOverride(t *testing.T) {
	// Arrange
	streams, in, out, errOut := genericIoOptions.NewTestIOStreams()
	var loggingFunc = func(args ...string) {
		_, err := streams.ErrOut.Write([]byte(args[0]))
		assert.NoError(t, err)
	}
	loggingClient := bbTestLog.NewFakeClient(loggingFunc)
	v := viper.New()
	v.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
	v.AutomaticEnv()
	randomString := strconv.FormatInt(time.Now().UnixMilli(), 10)
	configDir := fmt.Sprintf("/tmp/bbctl-test-%s/", randomString)
	assert.NoError(t, os.Mkdir(configDir, 0755))
	originalConfig := GetDefaultConfig(t)
	WriteConfigFile(t, configDir, originalConfig)
	v.SetConfigName("config")
	v.SetConfigType("yaml")
	v.AddConfigPath(configDir)
	assert.NoError(t, v.ReadInConfig())
	v.Set("basic-setup-repo", "test2")

	configClient := ConfigClient{
		getConfig:     getConfig,
		loggingClient: &loggingClient,
		viperInstance: v,
	}
	// Act
	allSettings := v.AllSettings()
	resultConfig := getConfig(&configClient)
	// Assert
	assert.NotNil(t, resultConfig)
	assert.NotEmpty(t, allSettings)
	assert.FileExists(t, path.Join(configDir, "config.yaml"))
	assert.Empty(t, in.String())
	assert.Empty(t, out.String())
	assert.Empty(t, errOut.String())
	assert.NotEqual(t, originalConfig, resultConfig)
	assert.Equal(t, "test2", resultConfig.BasicSetupRepo)
}
