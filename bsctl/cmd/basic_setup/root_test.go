package basic_setup

import (
	"testing"

	"github.com/stretchr/testify/assert"

	bbTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
)

func TestBasicSetup_RootUsage(t *testing.T) {
	// Arrange
	factory := bbTestUtil.GetFakeFactory()
	// Act
	cmd := NewBasicSetupCmd(factory)
	// Assert
	assert.NotNil(t, cmd)
	assert.Equal(t, "basic-setup", cmd.Use)
	commandsList := cmd.Commands()
	assert.Len(t, commandsList, 1)
	var commandUseNamesList []string
	for _, command := range commandsList {
		commandUseNamesList = append(commandUseNamesList, command.Use)
	}
	assert.Contains(t, commandUseNamesList, "add-general-rc")
}

func TestK3d_RootNoSubcommand(t *testing.T) {
	// Arrange
	factory := bbTestUtil.GetFakeFactory()
	store := factory.GetStreamsGetter().GetStreamStores()
	// Act
	cmd := NewBasicSetupCmd(factory)
	// Assert
	assert.Nil(t, cmd.Execute())
	assert.Empty(t, store.In.String())
	assert.Empty(t, store.ErrOut.String())
	assert.Contains(t, store.Out.String(), "Please provide a subcommand for basic-setup (see help)")
}
