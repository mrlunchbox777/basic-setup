package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"

	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"

	bsTestUtil "github.com/mrlunchbox777/basic-setup/bsctl/util/test"
	"github.com/stretchr/testify/assert"
)

func TestBashCompletion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()

	streams, _, buf, _ := genericIOOptions.NewTestIOStreams()

	cmd := NewCompletionCmd(factory, streams)
	assert.Nil(t, cmd.RunE(cmd, []string{"bash"}))

	if !strings.Contains(buf.String(), "bash completion") {
		t.Errorf("unexpected output")
	}
}

func TestZshCompletion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()

	streams, _, buf, _ := genericIOOptions.NewTestIOStreams()

	cmd := NewCompletionCmd(factory, streams)
	assert.Nil(t, cmd.RunE(cmd, []string{"zsh"}))

	if !strings.Contains(buf.String(), "zsh completion") {
		t.Errorf("unexpected output")
	}
}

func TestFishCompletion(t *testing.T) {
	factory := bsTestUtil.GetFakeFactory()

	streams, _, buf, _ := genericIOOptions.NewTestIOStreams()

	cmd := NewCompletionCmd(factory, streams)
	assert.Nil(t, cmd.RunE(cmd, []string{"fish"}))

	if !strings.Contains(buf.String(), "fish completion") {
		t.Errorf("unexpected output")
	}
}

func TestFooCompletion(t *testing.T) {
	// Arrange
	streams, in, out, errOut := genericIOOptions.NewTestIOStreams()
	factory := bsTestUtil.GetFakeFactory()

	// Act
	if os.Getenv("BE_CRASHER") == "1" {
		cmd := NewCompletionCmd(factory, streams)
		err := cmd.RunE(cmd, []string{"foo"})
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
		return
	}
	runCrasherCommand := exec.Command(os.Args[0], "-test.run=TestFooCompletion")
	runCrasherCommand.Env = append(os.Environ(), "BE_CRASHER=1")
	runCrasherCommand.Stderr = errOut
	runCrasherCommand.Stdout = out
	runCrasherCommand.Stdin = in
	err := runCrasherCommand.Run()

	// Assert
	if e, ok := err.(*exec.ExitError); ok && !e.Success() {
		assert.Equal(t, 1, e.ExitCode())
		assert.NotNil(t, runCrasherCommand)
		assert.Equal(t, "exit status 1", e.Error())
		assert.Equal(t, "error: unsupported shell type \"foo\"\n", errOut.String())
		assert.Empty(t, in.String())
		assert.Empty(t, out.String())
		return
	}
	t.Fatalf("process ran with err %v, want exit status 1", err)
}
