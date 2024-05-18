package cmd

import (
	bsHelp "github.com/mrlunchbox777/basic-setup/bsctl/cmd/help"
	"github.com/spf13/cobra"
	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
)

var (
	cmdUse = `bsctl`

	cmdShort = i18n.T(`basic-setup command-line tool.`)

	// TODO: add more details
	cmdLong = templates.LongDesc(i18n.T(
		`basic-setup TODO: add more details.`))

	cmdExample = templates.Examples(i18n.T(`
		# Get help
		bsctl help`))
)

// NewRootCmd - create a new Cobra root command
func NewRootCmd(factory bsUtil.Factory, streams genericIOOptions.IOStreams) *cobra.Command {

	cmd := &cobra.Command{
		Use:     cmdUse,
		Short:   cmdShort,
		Long:    cmdLong,
		Example: cmdExample,
	}

	cmd.CompletionOptions.DisableDefaultCmd = false
	cmd.CompletionOptions.DisableNoDescFlag = true
	cmd.CompletionOptions.DisableDescriptions = false

	cmd.AddCommand(NewCompletionCmd(factory, streams))
	cmd.AddCommand(NewVersionCmd(factory, streams))

	addHelpCommandsRecursively(cmd)

	return cmd
}

var (
	skipHelpList = []string{
		"help",
	}
)

func addHelpCommandsRecursively(cmd *cobra.Command) {
	cmd.AddCommand(bsHelp.NewHelpCmd(cmd))
	for _, c := range cmd.Commands() {
		if c.Use == "" {
			continue
		}
		shouldSkip := false
		for _, skip := range skipHelpList {
			if c.Use == skip {
				shouldSkip = true
			}
		}
		if shouldSkip {
			continue
		}
		addHelpCommandsRecursively(c)
	}
}
