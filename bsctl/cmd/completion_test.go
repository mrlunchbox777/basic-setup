package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"

	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestBashCompletion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()
	store := factory.GetStreamsGetter().GetStreamStores()

	cmd := NewCompletionCmd(factory)
	assert.Nil(t, cmd.RunE(cmd, []string{"bash"}))

	if !strings.Contains(store.Out.String(), "bash completion") {
		t.Errorf("unexpected output")
	}
}

func TestZshCompletion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()
	store := factory.GetStreamsGetter().GetStreamStores()

	cmd := NewCompletionCmd(factory)
	assert.Nil(t, cmd.RunE(cmd, []string{"zsh"}))

	if !strings.Contains(store.Out.String(), "zsh completion") {
		t.Errorf("unexpected output")
	}
}

func TestFishCompletion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()
	store := factory.GetStreamsGetter().GetStreamStores()

	cmd := NewCompletionCmd(factory)
	assert.Nil(t, cmd.RunE(cmd, []string{"fish"}))

	if !strings.Contains(store.Out.String(), "fish completion") {
		t.Errorf("unexpected output")
	}
}

func TestFooCompletion(t *testing.T) {
	// Arrange
	factory := bsTestUtil.GetFakeFactory()
	store := factory.GetStreamsGetter().GetStreamStores()

	// Act
	if os.Getenv("BE_CRASHER") == "1" {
		cmd := NewCompletionCmd(factory)
		err := cmd.RunE(cmd, []string{"foo"})
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
		return
	}
	runCrasherCommand := exec.Command(os.Args[0], "-test.run=TestFooCompletion")
	runCrasherCommand.Env = append(os.Environ(), "BE_CRASHER=1")
	runCrasherCommand.Stderr = store.ErrOut
	runCrasherCommand.Stdout = store.Out
	runCrasherCommand.Stdin = store.In
	err := runCrasherCommand.Run()

	// Assert
	if e, ok := err.(*exec.ExitError); ok && !e.Success() {
		assert.Equal(t, 1, e.ExitCode())
		assert.NotNil(t, runCrasherCommand)
		assert.Equal(t, "exit status 1", e.Error())
		assert.Empty(t, store.In.String())
		assert.Empty(t, store.Out.String())
		assert.Equal(t, "error: unsupported shell type \"foo\"\n", store.ErrOut.String())
		return
	}
	t.Fatalf("process ran with err %v, want exit status 1", err)
}
