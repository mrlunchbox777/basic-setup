package basic_setup

import (
	"fmt"

	"github.com/spf13/cobra"
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
func NewBasicSetupCmd(factory bsUtil.Factory) *cobra.Command {
	cmd := &cobra.Command{
		Use:     rootUse,
		Short:   rootShort,
		Long:    rootLong,
		Example: rootExample,
		RunE: func(cmd *cobra.Command, args []string) error {
			streams := factory.GetStreams()
			_, err := streams.Out().Write([]byte(fmt.Sprintln("Please provide a subcommand for basic-setup (see help)")))
			return err
		},
	}

	cmd.AddCommand(NewAddGeneralRcCmd(factory))

	return cmd
}
