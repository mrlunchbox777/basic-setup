package config

import (
	"errors"
	"strings"
	"testing"

	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"

	"github.com/mrlunchbox777/basic-setup/bsctl/util/config/schemas"
	bbUtilLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/log"
	bbUtilTestLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/test/log"
)

// NewClient tested in client_getter_test.go

func TestClientGetConfig(t *testing.T) {
	// Arrange
	expected := "test"
	getConfigFunc := func(client *ConfigClient) *schemas.GlobalConfiguration {
		return &schemas.GlobalConfiguration{
			BasicSetupRepo: expected,
		}
	}
	client := &ConfigClient{
		getConfig: getConfigFunc,
	}

	// Act
	actual := client.GetConfig()

	// Assert
	assert.NotNil(t, actual)
	assert.Equal(t, expected, actual.BasicSetupRepo)
}

func TestClientSetAndBindFlag(t *testing.T) {
	// Arrange
	expected := "test"
	setAndBindFlagFunc := func(client *ConfigClient, name string, value interface{}, description string) error {
		return errors.New(expected)
	}
	client := &ConfigClient{
		setAndBindFlag: setAndBindFlagFunc,
	}

	// Act
	actual := client.SetAndBindFlag("", "", "")

	// Assert
	assert.NotNil(t, actual)
	assert.Equal(t, expected, actual.Error())
}

func TestNewClient(t *testing.T) {
	// Test cases
	tt := []struct {
		description   string
		viper         bool
		loggingClient bool
		shouldFail    bool
		expected      string
	}{
		{
			description:   "should fail when logging client is nil",
			viper:         true,
			loggingClient: false,
			shouldFail:    true,
			expected:      "logging client is required",
		},
		{
			description:   "should fail when viper instance is nil",
			viper:         false,
			loggingClient: true,
			shouldFail:    true,
			expected:      "viper instance is required",
		},
		{
			description:   "should succeed",
			viper:         true,
			loggingClient: true,
			shouldFail:    false,
			expected:      "",
		},
	}

	for _, tc := range tt {
		t.Run(tc.description, func(t *testing.T) {
			// Arrange
			var viperInstance *viper.Viper
			if tc.viper {
				viperInstance = viper.New()
			}
			var loggingClient *bbUtilLog.Client
			output := strings.Builder{}
			if tc.loggingClient {
				loggingFunc := func(msgs ...string) {
					for _, msg := range msgs {
						_, err := output.WriteString(msg)
						assert.Nil(t, err)
					}
				}
				rawLoggingClient := bbUtilTestLog.NewFakeClient(loggingFunc)
				loggingClient = &rawLoggingClient
			}

			// Act
			actual, actualErr := NewClient(nil, nil, loggingClient, nil, viperInstance)

			// Assert
			if tc.shouldFail {
				assert.NotNil(t, actualErr)
				assert.Equal(t, tc.expected, actualErr.Error())
				assert.Nil(t, actual)
				assert.Empty(t, output.String())
			} else {
				assert.Nil(t, actualErr)
				assert.NotNil(t, actual)
				assert.Empty(t, output.String())
			}
		})
	}
}
