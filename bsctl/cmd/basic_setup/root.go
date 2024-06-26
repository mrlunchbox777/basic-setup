package basic_setup

import (
	"fmt"

	"github.com/spf13/cobra"
	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"
	cmdUtil "k8s.io/kubectl/pkg/cmd/util"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
)

var (
	rootUse = `basic-setup`

	rootShort = i18n.T(`Manage and invoke basic setup functionality.`)

	rootLong = templates.LongDesc(i18n.T(`Manage and invoke basic setup functionality.`))

	rootExample = templates.Examples(i18n.T(`
		# Print basic setup help
		bsctl basic-setup -h
		`))
)

// NewBasicSetupCmd - new basic-setup command
func NewBasicSetupCmd(factory bsUtil.Factory, streams genericIOOptions.IOStreams) *cobra.Command {
	cmd := &cobra.Command{
		Use:     rootUse,
		Short:   rootShort,
		Long:    rootLong,
		Example: rootExample,
		Run: func(cmd *cobra.Command, args []string) {
			_, err := streams.Out.Write([]byte(fmt.Sprintln("Please provide a subcommand for basic-setup (see help)")))
			cmdUtil.CheckErr(err)
		},
	}

	cmd.AddCommand(NewAddGeneralRcCmd(factory, streams))

	return cmd
}
