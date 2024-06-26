package cmd

import (
	bsHelp "github.com/mrlunchbox777/basic-setup/bsctl/cmd/help"
	"github.com/spf13/cobra"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	"github.com/mrlunchbox777/basic-setup/bsctl/cmd/basic_setup"
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
func NewRootCmd(factory bsUtil.Factory) *cobra.Command {

	cmd := &cobra.Command{
		Use:     cmdUse,
		Short:   cmdShort,
		Long:    cmdLong,
		Example: cmdExample,
	}

	cmd.CompletionOptions.DisableDefaultCmd = false
	cmd.CompletionOptions.DisableNoDescFlag = true
	cmd.CompletionOptions.DisableDescriptions = false

	cmd.AddCommand(NewCompletionCmd(factory))
	cmd.AddCommand(NewVersionCmd(factory))

	cmd.AddCommand(basic_setup.NewBasicSetupCmd(factory))

	addHelpCommandsRecursively(cmd, false)

	return cmd
}

var (
	skipHelpList = []string{
		"help",
	}
)

func addHelpCommandsRecursively(cmd *cobra.Command, addRootHelp bool) {
	if addRootHelp {
		cmd.AddCommand(bsHelp.NewHelpCmd(cmd))
	}
	for _, c := range cmd.Commands() {
		shouldSkip := false
		for _, skip := range skipHelpList {
			// Commands that don't have *.Use are covered by the test "Test_AllCommandsHaveUseNames"
			if c.Use == skip {
				shouldSkip = true
			}
		}
		if shouldSkip {
			continue
		}
		addHelpCommandsRecursively(c, true)
	}
}
