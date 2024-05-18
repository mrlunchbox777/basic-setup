package help

import (
	"testing"

	"github.com/spf13/cobra"
	"github.com/stretchr/testify/assert"
	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"

	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
)

// NewTestCmd - parent for deploy commands
func NewTestCmd(t *testing.T, factory bsUtil.Factory, streams genericIOOptions.IOStreams) *cobra.Command {
	cmd := &cobra.Command{
		Use:     "test",
		Short:   "test short",
		Long:    "test long",
		Example: "test example",
		Run: func(cmd *cobra.Command, args []string) {
			factory.GetLoggingClient().Info("test")
		},
	}

	cmd.AddCommand(NewSubTestCmd(t, factory, streams))
	AddHelpCommandRecursive(t, cmd)

	return cmd
}

// This test is needed to cover the help command
func NewSubTestCmd(t *testing.T, factory bsUtil.Factory, streams genericIOOptions.IOStreams) *cobra.Command {
	cmd := &cobra.Command{
		Use:     "sub-test",
		Short:   "sub-test short",
		Long:    "sub-test long",
		Example: "sub-test example",
		Run: func(cmd *cobra.Command, args []string) {
			factory.GetLoggingClient().Info("sub-test")
		},
	}

	return cmd
}

func AddHelpCommandRecursive(t *testing.T, command *cobra.Command) {
	helpCmd := NewHelpCmd(command)
	command.AddCommand(helpCmd)
	for _, subCommand := range command.Commands() {
		if subCommand.Use == "help" {
			continue
		}
		AddHelpCommandRecursive(t, subCommand)
	}
}

func TestHelp_TestChainForExampleHelp(t *testing.T) {
	// Arrange
	factory := bsTestUtil.GetFakeFactory()
	streams, in, out, outErr := genericIOOptions.NewTestIOStreams()
	testCommand := NewTestCmd(t, factory, streams)
	testCommand.SetArgs([]string{"sub-test", "help"})
	// Act
	assert.Nil(t, testCommand.Execute())
	// Assert
	assert.NotNil(t, testCommand)
	assert.Equal(t, "test", testCommand.Use)
	assert.Empty(t, in.String())
	assert.Empty(t, out.String())
	assert.Empty(t, outErr.String())
	assert.NotNil(t, testCommand.Commands())
	allCommands := testCommand.Commands()
	assert.Len(t, allCommands, 4)
	foundHelp, foundSubTest := false, false
	for _, command := range allCommands {
		assert.NotNil(t, command)
		if command.Use == "help" {
			foundHelp = true
		}
		if command.Use == "sub-test" {
			foundSubTest = true
			assert.Equal(t, "sub-test example", command.Example)
			assert.NotNil(t, command.Commands())
			subCommands := command.Commands()
			assert.Len(t, subCommands, 1)
			assert.NotNil(t, subCommands[0])
			assert.Equal(t, "help", subCommands[0].Use)
			assert.Equal(t, "  # Get help for this help command\n  test sub-test help --help", subCommands[0].Example)
		}
	}
	assert.True(t, foundSubTest)
	assert.True(t, foundHelp)
	assert.Equal(t, "test example", testCommand.Example)
}
