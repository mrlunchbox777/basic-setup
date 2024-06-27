package k8s

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewStreamsStore(t *testing.T) {
	// Arrange
	// Act
	actual := NewStreamStores()
	// Assert
	assert.NotNil(t, actual)
	assert.NotNil(t, actual.In)
	assert.NotNil(t, actual.Out)
	assert.NotNil(t, actual.ErrOut)
	assert.Equal(t, 0, actual.In.Len())
	assert.Equal(t, 0, actual.Out.Len())
	assert.Equal(t, 0, actual.ErrOut.Len())
}
