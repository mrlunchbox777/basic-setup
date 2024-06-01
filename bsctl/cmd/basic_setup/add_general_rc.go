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
	addGeneralRcUse = `add-general-rc`

	addGeneralRcShort = i18n.T(`Add general rc to ~/.*rc.`)

	addGeneralRcLong = templates.LongDesc(i18n.T(`Ensure that general rc is added to ~/.*rc. That is, ensure that the general rc is added to the user's rc file.`))

	addGeneralRcExample = templates.Examples(i18n.T(`
		# Add general rc to ~/.*rc
		bsctl basic-setup add-general-rc
		`))
)

// NewAddGeneralRcCmd - new add-general-rc command
func NewAddGeneralRcCmd(factory bsUtil.Factory, streams genericIOOptions.IOStreams) *cobra.Command {
	cmd := &cobra.Command{
		Use:     addGeneralRcUse,
		Short:   addGeneralRcShort,
		Long:    addGeneralRcLong,
		Example: addGeneralRcExample,
		Run: func(cmd *cobra.Command, args []string) {
			_, err := streams.Out.Write([]byte(fmt.Sprintln("Please provide a subcommand for basic-setup (see help)")))
			cmdUtil.CheckErr(err)
		},
	}

	return cmd
}
