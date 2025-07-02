package schemas

import (
	"testing"

	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
)

func TestReconcileConfiguration_GlobalConfiguration(t *testing.T) {
	var tests = []struct {
		desc         string
		arg          *GlobalConfiguration
		willError    bool
		errorMessage string
	}{
		{
			"reconcile configuration, pass",
			&GlobalConfiguration{
				ExampleConfiguration: ExampleConfiguration{},
			},
			false,
			"",
		},
		{
			"reconcile configuration, fail",
			&GlobalConfiguration{
				ExampleConfiguration: ExampleConfiguration{},
			},
			true,
			"should error was set",
		},
	}
	for _, tt := range tests {
		t.Run(tt.desc, func(t *testing.T) {
			// Arrange
			instance := viper.New()
			instance.Set("example-config-fail-validation-above-10", 5)
			if tt.willError {
				instance.Set("example-config-should-error", true)
			}
			// Act
			err := tt.arg.ReconcileConfiguration(instance)
			// Assert
			if tt.willError {
				assert.NotNil(t, err)
				assert.Contains(t, err.Error(), tt.errorMessage)
				// we can't check the values because we don't know what they are because we don't know where it errored
			} else {
				assert.Nil(t, err)
				assert.Equal(t, 5, tt.arg.ExampleConfiguration.FailValidationAbove10)
			}
		})
	}
}

func TestGetSubConfigurations_GlobalConfiguration(t *testing.T) {
	// Arrange
	arg := &GlobalConfiguration{}
	// Act
	result := arg.getSubConfigurations()
	// Assert
	assert.Equal(t, 1, len(result))
	assert.Equal(t, &arg.ExampleConfiguration, result[0])
}
