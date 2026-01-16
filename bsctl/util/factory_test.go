package util

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewFactory(t *testing.T) {
	// Arrange
	// Act
	factory := NewFactory()
	// Assert
	assert.NotNil(t, factory)
}

func TestGetConfigClient(t *testing.T) {
	// Arrange
	factory := NewFactory()
	// Act
	client, err := factory.GetConfigClient(nil)
	// Assert
	assert.Nil(t, err)
	assert.NotNil(t, client)
}

func TestGetConfigClientWithParams(t *testing.T) {
	// Arrange
	factory := NewFactory()
	// Act
	client, err := factory.GetConfigClientWithParams(nil, nil, nil)
	// Assert
	assert.Nil(t, err)
	assert.NotNil(t, client)
}

func TestGetLoggingClient(t *testing.T) {
	// Arrange
	factory := NewFactory()
	// Act
	client := factory.GetLoggingClient()
	// Assert
	assert.NotNil(t, client)
}

func TestGetLoggingClientWithParams(t *testing.T) {
	// Arrange
	factory := NewFactory()
	// Act
	client := factory.GetLoggingClientWithParams(nil)
	// Assert
	assert.NotNil(t, client)
}

func TestGetViper(t *testing.T) {
	// Arrange
	factory := NewFactory()
	// Act
	viper := factory.GetViper()
	// Assert
	assert.NotNil(t, viper)
}

func TestGetStreams(t *testing.T) {
	// Arrange
	factory := NewFactory()
	// Act
	streams := factory.GetStreams()
	// Assert
	assert.NotNil(t, streams)
}
