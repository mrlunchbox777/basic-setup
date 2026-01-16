package cmd

import (
	"testing"

	"github.com/mrlunchbox777/basic-setup/bsctl/static"
	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestGetVersion(t *testing.T) {
	tests := []struct {
		name        string
		expected    string
		shouldError bool
	}{
		{
			name:        "GetVersionNoError",
			expected:    "basic-setup cli version 0.",
			shouldError: false,
		},
		{
			// TODO: get the error from how bbctl does it
			name:        "GetVersionError",
			expected:    "",
			shouldError: true,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			// Arrange
			factory := bsTestUtil.GetFakeFactory()
			cmd := NewVersionCmd(factory)
			store := factory.GetStreamsGetter().GetStreamStores()
			if test.shouldError {
				readFileFunc := func(s string) ([]byte, error) {
					return nil, assert.AnError
				}
				static.DefaultClient = static.NewConstantsClient(static.ReadFileFunc(readFileFunc))
			}

			// Act
			err := cmd.RunE(cmd, []string{})

			// Assert
			if test.shouldError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
			assert.Contains(t, store.Out.String(), test.expected)
		})
	}
}
