package k8s

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetIOStreams(t *testing.T) {
	t.Run("GetIOStreams", func(t *testing.T) {
		t.Parallel()
		// Arrange
		streams := &IOStreamsConcrete{}
		streamStores := &StreamStores{}
		// Act
		ioStreamsAndStores := &IOStreamsAndStores{
			IOStreams:    streams,
			StreamStores: streamStores,
		}
		// Assert
		assert.Equal(t, streams, ioStreamsAndStores.GetIOStreams())
	})
}

func TestGetStreamStores(t *testing.T) {
	t.Run("GetStreamStores", func(t *testing.T) {
		t.Parallel()
		// Arrange
		streams := &IOStreamsConcrete{}
		streamStores := &StreamStores{}
		// Act
		ioStreamsAndStores := &IOStreamsAndStores{
			IOStreams:    streams,
			StreamStores: streamStores,
		}
		// Assert
		assert.Equal(t, streamStores, ioStreamsAndStores.GetStreamStores())
	})
}

func TestStreamStoresWrapper_In(t *testing.T) {
	t.Run("Stream Stores Wrapper In", func(t *testing.T) {
		t.Parallel()
		// Arrange
		streamStores := &StreamStores{}
		// Act
		streamStoresWrapper := &StreamStoresWrapper{
			StreamStores: streamStores,
		}
		// Assert
		assert.Equal(t, streamStores.In, streamStoresWrapper.In())
	})
}

func TestStreamStoresWrapper_Out(t *testing.T) {
	t.Run("Stream Stores Wrapper Out", func(t *testing.T) {
		t.Parallel()
		// Arrange
		streamStores := &StreamStores{}
		// Act
		streamStoresWrapper := &StreamStoresWrapper{
			StreamStores: streamStores,
		}
		// Assert
		assert.Equal(t, streamStores.Out, streamStoresWrapper.Out())
	})
}

func TestStreamStoresWrapper_ErrOut(t *testing.T) {
	t.Run("Stream Stores Wrapper ErrOut", func(t *testing.T) {
		t.Parallel()
		// Arrange
		streamStores := &StreamStores{}
		// Act
		streamStoresWrapper := &StreamStoresWrapper{
			StreamStores: streamStores,
		}
		// Assert
		assert.Equal(t, streamStores.ErrOut, streamStoresWrapper.ErrOut())
	})
}

func TestNewStreamsStoreWrapper(t *testing.T) {
	t.Run("New Streams Store Wrapper", func(t *testing.T) {
		t.Parallel()
		// Arrange
		streamStores := &StreamStores{}
		// Act
		streamStoresWrapper := NewStreamsStoreWrapper(streamStores)
		// Assert
		assert.Equal(t, streamStores, streamStoresWrapper.(*StreamStoresWrapper).StreamStores)
	})
}
