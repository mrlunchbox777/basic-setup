package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	"github.com/mrlunchbox777/basic-setup/bsctl/static"
	bsUtil "github.com/mrlunchbox777/basic-setup/bsctl/util"
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
func NewVersionCmd(factory bsUtil.Factory, streams genericIOOptions.IOStreams) *cobra.Command {
	cmd := &cobra.Command{
		Use:     versionUse,
		Short:   versionShort,
		Long:    versionLong,
		Example: versionExample,
		RunE: func(cmd *cobra.Command, args []string) error {
			return bsVersion(streams)
		},
	}

	return cmd
}

func bsVersion(streams genericIOOptions.IOStreams) error {
	constants, err := static.GetConstants()
	if err != nil {
		return err
	}
	fmt.Fprintf(streams.Out, "basic-setup cli version %s\n", constants.BasicSetupCliVersion)

	return nil
}
