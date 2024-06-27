package k8s

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetIOStreamsGetter(t *testing.T) {
	assert.Equal(t, GetIOStreamsGetter(), GetIOStreamsGetterConfigured(false))
}

func TestGetIOStreamsGetterConfigured(t *testing.T) {
	tests := []struct {
		name     string
		buffered bool
	}{
		{
			name:     "buffered",
			buffered: true,
		},
		{
			name:     "not buffered",
			buffered: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			expected := &IOStreamsAndStores{}
			realStreams := &IOStreamsConcrete{
				InObj:     os.Stdin,
				OutObj:    os.Stdout,
				ErrOutObj: os.Stderr,
			}

			if tt.buffered {
				stores := NewStreamStores()
				tees := NewStreamTeesFromStreamsAndStores(realStreams, stores)

				expected.IOStreams = tees
				expected.StreamStores = stores
			} else {
				expected.IOStreams = realStreams
			}

			// Act
			actual := GetIOStreamsGetterConfigured(tt.buffered)

			// Assert
			assert.Equal(t, expected, actual)
		})
	}
}

func TestGetStoreOnlyStreams(t *testing.T) {
	// Arrange
	stores := NewStreamStores()
	expected := &IOStreamsAndStores{
		IOStreams:    NewStreamsStoreWrapper(stores),
		StreamStores: stores,
	}

	// Act
	actual := GetStoreOnlyStreams()

	// Assert
	assert.Equal(t, expected, actual)
}
