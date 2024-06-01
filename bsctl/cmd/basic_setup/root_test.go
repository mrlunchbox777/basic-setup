package basic_setup

import (
	"testing"

	"github.com/stretchr/testify/assert"
	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"

	bbTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
)

func TestBasicSetup_RootUsage(t *testing.T) {
	// Arrange
	streams, _, _, _ := genericIOOptions.NewTestIOStreams()
	factory := bbTestUtil.GetFakeFactory()
	// Act
	cmd := NewBasicSetupCmd(factory, streams)
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
	streams, in, out, errout := genericIOOptions.NewTestIOStreams()
	factory := bbTestUtil.GetFakeFactory()
	// Act
	cmd := NewBasicSetupCmd(factory, streams)
	// Assert
	assert.Nil(t, cmd.Execute())
	assert.Empty(t, in.String())
	assert.Empty(t, errout.String())
	assert.Contains(t, out.String(), "Please provide a subcommand for basic-setup (see help)")
}
