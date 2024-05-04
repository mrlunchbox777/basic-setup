package k8s

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetIOStreams(t *testing.T) {
	ios := GetIOStream()
	assert.Equal(t, os.Stdin, ios.In)
	assert.Equal(t, os.Stdout, ios.Out)
	assert.Equal(t, os.Stderr, ios.ErrOut)
}
