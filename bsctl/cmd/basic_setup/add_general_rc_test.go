package basic_setup

import (
	"bytes"
	"testing"

	bbTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestNewAddGeneralRcCmd(t *testing.T) {
	// Arrange
	factory := bbTestUtil.GetFakeFactory()
	// Act
	cmd := NewAddGeneralRcCmd(factory)
	// Assert
	assert.NotNil(t, cmd)
	assert.Equal(t, "add-general-rc", cmd.Use)
	assert.Equal(t, 0, len(cmd.Commands()))
}

func TestNewAddGeneralRcCmdRunE(t *testing.T) {
	// Arrange
	factory := bbTestUtil.GetFakeFactory()
	streams := factory.GetStreams()
	cmd := NewAddGeneralRcCmd(factory)
	// Act
	err := cmd.RunE(cmd, []string{})
	// Assert
	assert.NotNil(t, cmd)
	assert.NoError(t, err)
	assert.Equal(t, "add-general-rc", cmd.Use)
	assert.Equal(t, "Please provide a subcommand for basic-setup (see help)\n", streams.Out().(*bytes.Buffer).String())
	assert.Equal(t, "", streams.ErrOut().(*bytes.Buffer).String())
	assert.Equal(t, "", streams.In().(*bytes.Buffer).String())
}
