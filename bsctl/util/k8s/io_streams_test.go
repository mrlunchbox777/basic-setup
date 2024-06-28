package k8s

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/assert"
	genericCLIOptions "k8s.io/cli-runtime/pkg/genericclioptions"
)

func TestIOStreamsConcrete_In(t *testing.T) {
	t.Run("IOStreamsConcrete In", func(t *testing.T) {
		t.Parallel()
		// Arrange
		// Act
		streams := &IOStreamsConcrete{
			InObj: bytes.NewBufferString("test"),
		}
		// Assert
		assert.Equal(t, streams.InObj, streams.In())
		assert.Equal(t, "test", streams.In().(*bytes.Buffer).String())
	})
}

func TestIOStreamsConcrete_Out(t *testing.T) {
	t.Run("IOStreamsConcrete Out", func(t *testing.T) {
		t.Parallel()
		// Arrange
		// Act
		streams := &IOStreamsConcrete{
			OutObj: bytes.NewBufferString("test"),
		}
		// Assert
		assert.Equal(t, streams.OutObj, streams.Out())
		assert.Equal(t, "test", streams.Out().(*bytes.Buffer).String())
	})
}

func TestIOStreamsConcrete_ErrOut(t *testing.T) {
	t.Run("IOStreamsConcrete ErrOut", func(t *testing.T) {
		t.Parallel()
		// Arrange
		// Act
		streams := &IOStreamsConcrete{
			ErrOutObj: bytes.NewBufferString("test"),
		}
		// Assert
		assert.Equal(t, streams.ErrOutObj, streams.ErrOut())
		assert.Equal(t, "test", streams.ErrOut().(*bytes.Buffer).String())
	})
}

func TestIOStreamsFromK8s(t *testing.T) {
	t.Run("IOStreamsFromK8s", func(t *testing.T) {
		t.Parallel()
		// Arrange
		k8sStreams := &genericCLIOptions.IOStreams{
			In:     bytes.NewBufferString("test"),
			Out:    bytes.NewBufferString("test"),
			ErrOut: bytes.NewBufferString("test"),
		}
		// Act
		streams := IOStreamsFromK8s(k8sStreams)
		// Assert
		assert.Equal(t, k8sStreams.In, streams.In())
		assert.Equal(t, "test", streams.In().(*bytes.Buffer).String())
		assert.Equal(t, k8sStreams.Out, streams.Out())
		assert.Equal(t, "test", streams.Out().(*bytes.Buffer).String())
		assert.Equal(t, k8sStreams.ErrOut, streams.ErrOut())
		assert.Equal(t, "test", streams.ErrOut().(*bytes.Buffer).String())
	})
}
