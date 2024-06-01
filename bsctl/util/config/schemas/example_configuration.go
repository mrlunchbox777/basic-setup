package schemas

import (
	"errors"

	"github.com/spf13/viper"
)

// ExampleConfiguration is example configuration and should be used as a template for new configurations, but never directly used outside of testing.
type ExampleConfiguration struct {
	// ShouldError if calling reconcile configuration will error
	ShouldError bool `mapstructure:"example-config-should-error" yaml:"example-config-should-error"`
	// ExtraConfigs is a list of extra configurations
	ExtraConfigs []BaseConfiguration
	// ShouldFailToMarshal is an optional field that can be set with an invalid value such that calling yaml.Marshal on the configuration will panic.
	// This should never be set outside of unit tests.
	ShouldFailToMarshal *any `yaml:"example-config-should-fail-to-marshal,omitempty"`
}

// ReconcileConfiguration reconciles the configuration.
func (u *ExampleConfiguration) ReconcileConfiguration(instance *viper.Viper) error {
	if instance.IsSet("example-config-should-error") {
		u.ShouldError = instance.GetBool("example-config-should-error")
	}
	if u.ShouldError {
		return errors.New("error reconciling ExampleConfiguration: should error was set")
	}
	return nil
}

// getSubConfigurations returns the sub-configurations.
func (u *ExampleConfiguration) getSubConfigurations() []BaseConfiguration {
	return u.ExtraConfigs
}
