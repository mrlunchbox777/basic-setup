package config

import (
	"strings"
	"testing"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"

	bbUtilLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/log"
	bbUtilTestLog "repo1.dso.mil/big-bang/product/packages/bbctl/util/test/log"
)

func TestClientGetter_GetClient(t *testing.T) {
	var tests = []struct {
		desc        string
		useLog      bool
		useCommand  bool
		willError   bool
		expectedErr string
	}{
		{
			desc:        "both are used",
			useLog:      true,
			useCommand:  true,
			willError:   false,
			expectedErr: "",
		},
		{
			desc:        "only log is used",
			useLog:      true,
			useCommand:  false,
			willError:   false,
			expectedErr: "",
		},
		{
			desc:        "only command is used",
			useLog:      false,
			useCommand:  true,
			willError:   true,
			expectedErr: "is required",
		},
	}

	for _, test := range tests {
		// Arrange
		clientGetter := ClientGetter{}
		var stringBuilder strings.Builder = strings.Builder{}
		var loggingClient *bbUtilLog.Client = nil
		var command *cobra.Command = nil
		if test.useLog {
			logFunc := func(args ...string) {
				for _, arg := range args {
					stringBuilder.WriteString(arg)
				}
			}
			client := bbUtilTestLog.NewFakeClient(logFunc)
			loggingClient = &client
		}
		if test.useCommand {
			command = &cobra.Command{}
		}
		v := viper.New()
		// Act
		client, err := clientGetter.GetClient(command, loggingClient, v)
		// Assert
		if test.willError {
			assert.Nil(t, client)
			assert.NotNil(t, err)
			assert.Contains(t, err.Error(), test.expectedErr)
		} else {
			assert.NotNil(t, client)
			assert.Nil(t, err)
		}
		assert.Empty(t, stringBuilder.String())
	}
}
