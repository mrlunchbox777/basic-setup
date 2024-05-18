package help

// note the test for this package is in cmd/deploy/flux_test.go

import (
	"fmt"

	"github.com/spf13/cobra"
	cmdUtil "k8s.io/kubectl/pkg/cmd/util"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"
)

var (
	createUse = `help`
)

// NewHelpCmd - create a new help command
func NewHelpCmd(command *cobra.Command) *cobra.Command {
	helpCmd := &cobra.Command{
		Use:     createUse,
		Short:   getShortHelp(command),
		Long:    getLongHelp(command),
		Example: getCreateExampleHelp(command),
		Run: func(cmd *cobra.Command, args []string) {
			cmdUtil.CheckErr(createHelp(command))
		},
	}

	return helpCmd
}

// getCreateExampleHelp - get example help for the command
func getCreateExampleHelp(command *cobra.Command) string {
	commandName := prependCommandNameRecursively(command, "")
	return templates.Examples(i18n.T(`
	    # Get help for this help command
		` + commandName + `help --help`))
}

// prependCommandNameRecursively - prepend the command name to the help string to the root command
func prependCommandNameRecursively(command *cobra.Command, help string) string {
	newHelp := fmt.Sprintf("%v %v", command.Use, help)
	parent := command.Parent()
	if parent != nil {
		newHelp = prependCommandNameRecursively(parent, newHelp)
	}
	return newHelp
}

// getLongHelp - get long description for the command
func getLongHelp(command *cobra.Command) string {
	return templates.LongDesc(i18n.T(fmt.Sprintf("Get help for %v.", command.Use)))
}

// getShortHelp - get short description for the command
func getShortHelp(command *cobra.Command) string {
	return i18n.T(fmt.Sprintf("Get help for %v.", command.Use))
}

// createHelp - create help for the command
func createHelp(command *cobra.Command) error {
	err := command.Help()
	return err
}
