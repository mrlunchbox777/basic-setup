package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	"github.com/mrlunchbox777/basic-setup/bsctl/static"
	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
	"github.com/mrlunchbox777/basic-setup/bsctl/util/k8s"
)

var (
	versionUse = `version`

	versionShort = i18n.T(`Print basic-setup CLI version.`)

	versionLong = templates.LongDesc(i18n.T(`Print basic-setup CLI version.`))

	versionExample = templates.Examples(i18n.T(`
		# Print version
		bsctl version
		`))
)

// NewVersionCmd - new version command
func NewVersionCmd(factory bsUtil.Factory) *cobra.Command {
	cmd := &cobra.Command{
		Use:     versionUse,
		Short:   versionShort,
		Long:    versionLong,
		Example: versionExample,
		RunE: func(cmd *cobra.Command, args []string) error {
			streams := factory.GetStreams()
			return bsVersion(streams)
		},
	}

	return cmd
}

func bsVersion(streams k8s.IOStreams) error {
	constants, err := static.GetDefaultConstants()
	if err != nil {
		return err
	}
	fmt.Fprintf(streams.Out(), "basic-setup cli version %s\n", constants.BasicSetupCliVersion)

	return nil
}
