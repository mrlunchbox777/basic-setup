package static

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestReadConstants(t *testing.T) {
	// Arrange & Act
	c, err := GetConstants()
	// Assert
	assert.Nil(t, err)
	assert.NotNil(t, c)
}

func TestAssertConstants(t *testing.T) {
	// Arrange & Act
	c, err := GetConstants()
	// Assert
	assert.Nil(t, err)
	assert.NotNil(t, c)
	assert.Equal(t, "0.1.0", c.BasicSetupCliVersion)
}

func TestErrorConstants(t *testing.T) {
	// Arrange
	c, err := GetConstants()
	assert.Nil(t, err)
	// Act
	c.readFileFunc = func(s string) ([]byte, error) {
		return nil, assert.AnError
	}
	err = c.readConstants()
	// Assert
	assert.NotNil(t, err)
}
