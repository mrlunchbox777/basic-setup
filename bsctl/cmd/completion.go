package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	genericCliOptions "k8s.io/cli-runtime/pkg/genericclioptions"
	cmdUtil "k8s.io/kubectl/pkg/cmd/util"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
)

var (
	completionUse = `completion [bash|zsh|fish]`

	completionShort = i18n.T(`Generate completion script.`)

	completionLong = templates.LongDesc(i18n.T(`
		To load completions:

		Bash:

		$ source <(bsctl completion bash)

		To load completions for each session, execute once:

		Linux:

		$ bsctl completion bash > /etc/bash_completion.d/bsctl

		macOS:

		$ bsctl completion bash > /usr/local/etc/bash_completion.d/bsctl

		Zsh:

		If shell completion is not already enabled in your environment,
		you will need to enable it.  You can execute the following once:

		$ echo "autoload -U compinit; compinit" >> ~/.zshrc

		To load completions for each session, execute once:

		$ bsctl completion zsh > "${fpath[1]}/_bsctl"

		Note: You will need to start a new shell for this setup to take effect.

		fish:

		$ bsctl completion fish | source

		To load completions for each session, execute once:

		$ bsctl completion fish > ~/.config/fish/completions/bsctl.fish `))
)

// NewCompletionCmd - create a new Cobra completion command
func NewCompletionCmd(factory bsUtil.Factory, streams genericCliOptions.IOStreams) *cobra.Command {
	var err error
	cmd := &cobra.Command{
		Use:                   completionUse,
		Short:                 completionShort,
		Long:                  completionLong,
		DisableFlagsInUseLine: true,
		ValidArgs:             []string{"bash", "zsh", "fish"},
		Args:                  cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs),
		Run: func(cmd *cobra.Command, args []string) {
			switch args[0] {
			case "bash":
				err = cmd.Root().GenBashCompletion(streams.Out)
			case "zsh":
				err = cmd.Root().GenZshCompletion(streams.Out)
			case "fish":
				err = cmd.Root().GenFishCompletion(streams.Out, true)
			default:
				cmdUtil.CheckErr(fmt.Errorf("unsupported shell type %q", args[0]))
			}
		},
	}
	factory.GetLoggingClient().HandleError("Unable to generate completion script: %v", err)

	return cmd
}
