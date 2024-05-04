package cmd

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
		Run: func(cmd *cobra.Command, args []string) {
			cmdUtil.CheckErr(bsVersion(factory, streams))
		},
	}

	return cmd
}

// query the cluster using helm module to get information on bigbang release
func bsVersion(factory bsUtil.Factory, streams genericIOOptions.IOStreams) error {
	fmt.Fprintf(streams.Out, "basic-setup cli version %s\n", BasicSetupCliVersion)

	return nil
}
