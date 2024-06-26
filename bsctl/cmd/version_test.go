package cmd

import (
	"strings"
	"testing"

	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestGetVersion(t *testing.T) {
	// Arrange
	factory := bsTestUtil.GetFakeFactory()
	cmd := NewVersionCmd(factory)
	store := factory.GetStreamsGetter().GetStreamStores()

	// Act
	assert.Nil(t, cmd.RunE(cmd, []string{}))

	// Assert
	if !strings.Contains(store.Out.String(), "basic-setup cli version ") {
		t.Errorf("unexpected output: %s", store.Out.String())
	}
}
