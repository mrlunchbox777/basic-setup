package cmd

import (
	"testing"

	genericCliOptions "k8s.io/cli-runtime/pkg/genericclioptions"

	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestGetVersion(t *testing.T) {
	// Arrange
	factory := bsTestUtil.GetFakeFactory()
	streams, _, buf, _ := genericCliOptions.NewTestIOStreams()
	expectedOutput := "basic-setup cli version "
	cmd := NewVersionCmd(factory, streams)

	// Act
	assert.NoError(t, cmd.RunE(cmd, []string{}))

	// Assert
	assert.Contains(t, buf.String(), expectedOutput, "Output should contain the version string")
}
