package cmd

import (
	"strings"
	"testing"

	genericCliOptions "k8s.io/cli-runtime/pkg/genericclioptions"

	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestGetVersion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()

	streams, _, buf, _ := genericCliOptions.NewTestIOStreams()

	cmd := NewVersionCmd(factory, streams)
	assert.Nil(t, cmd.RunE(cmd, []string{}))

	if !strings.Contains(buf.String(), "basic-setup cli version ") {
		t.Errorf("unexpected output: %s", buf.String())
	}
}
