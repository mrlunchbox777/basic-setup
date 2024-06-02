package cmd

import (
	"testing"

	"github.com/stretchr/testify/assert"
	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"

	bbTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
)

func TestCmd_RootUsage(t *testing.T) {
	// Arrange
	streams, _, _, _ := genericIOOptions.NewTestIOStreams()
	factory := bbTestUtil.GetFakeFactory()
	// Act
	cmd := NewRootCmd(factory, streams)
	// Assert
	assert.NotNil(t, cmd)
	assert.Equal(t, "bsctl", cmd.Use)
	commandsList := cmd.Commands()
	assert.Len(t, commandsList, 3)
	var commandUseNamesList []string
	for _, command := range commandsList {
		commandUseNamesList = append(commandUseNamesList, command.Use)
	}
	assert.Contains(t, commandUseNamesList, "basic-setup")
	assert.Contains(t, commandUseNamesList, "version")
	assert.Contains(t, commandUseNamesList, "completion [bash|zsh|fish]")
}

func TestK3d_RootNoSubcommand(t *testing.T) {
	// Arrange
	streams, in, out, errout := genericIOOptions.NewTestIOStreams()
	factory := bbTestUtil.GetFakeFactory()
	// Act
	cmd := NewRootCmd(factory, streams)
	// Assert
	assert.Nil(t, cmd.Execute())
	assert.Empty(t, in.String())
	assert.Empty(t, errout.String())
	assert.Empty(t, out.String())
}
