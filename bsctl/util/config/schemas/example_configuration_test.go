package schemas

import (
	"testing"

	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
)

func TestReconcileConfiguration_ExampleConfiguration(t *testing.T) {
	var tests = []struct {
		desc         string
		arg          *ExampleConfiguration
		willError    bool
		errorMessage string
	}{
		{
			"reconcile configuration, pass",
			&ExampleConfiguration{},
			false,
			"",
		},
		{
			"reconcile configuration, fail",
			&ExampleConfiguration{ShouldError: true},
			true,
			"should error was set",
		},
	}
	for _, tt := range tests {
		t.Run(tt.desc, func(t *testing.T) {
			// Arrange
			instance := viper.New()
			instance.Set("example-config-should-error", tt.arg.ShouldError)
			// Act
			err := tt.arg.ReconcileConfiguration(instance)
			// Assert
			if tt.willError {
				assert.NotNil(t, err)
				assert.Contains(t, err.Error(), tt.errorMessage)
				// we can't check the values because we don't know what they are because we don't know where it errored
			} else {
				assert.Nil(t, err)
				assert.Equal(t, tt.arg.ShouldError, instance.GetBool("example-config-should-error"))
			}
		})
	}
}

func TestGetSubConfigurations_ExampleConfiguration(t *testing.T) {
	// Arrange
	arg := &ExampleConfiguration{
		ExtraConfigs: []BaseConfiguration{
			&ExampleConfiguration{},
		},
	}
	// Act
	result := arg.getSubConfigurations()
	// Assert
	assert.Len(t, result, 1)
	assert.Equal(t, arg.ExtraConfigs[0], result[0])
}
