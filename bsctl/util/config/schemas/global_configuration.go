package schemas

import (
	"errors"

	"github.com/spf13/viper"
)

type GlobalConfiguration struct {
	// Big Bang repository location: file path
	BasicSetupRepo string `mapstructure:"basic-setup-repo" yaml:"basic-setup-repo" validate:"required"`
	// Example configuration: object
	ExampleConfiguration ExampleConfiguration `mapstructure:"example-config" yaml:"example-config"`
}

// ReconcileConfiguration recursively reconciles the configurations.
func (g *GlobalConfiguration) ReconcileConfiguration(instance *viper.Viper) error {
	g.BasicSetupRepo = instance.GetString("basic-setup-repo")

	allErrors := []error{}
	for _, subConfig := range g.getSubConfigurations() {
		err := subConfig.ReconcileConfiguration(instance)
		if err != nil {
			allErrors = append(allErrors, err)
		}
	}
	if len(allErrors) > 0 {
		return errors.Join(allErrors...)
	}
	return nil
}

// getSubConfigurations returns the sub-configurations.
func (g *GlobalConfiguration) getSubConfigurations() []BaseConfiguration {
	return []BaseConfiguration{
		&g.ExampleConfiguration,
	}
}
