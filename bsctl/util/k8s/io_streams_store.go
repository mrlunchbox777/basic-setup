package k8s

import (
	"bytes"
)

// StreamStores - input/output stream stores
type StreamStores struct {
	In     *bytes.Buffer
	Out    *bytes.Buffer
	ErrOut *bytes.Buffer
}

// NewStreamStores - create new stream stores as buffers
func NewStreamStores() *StreamStores {
	return &StreamStores{
		In:     bytes.NewBuffer(nil),
		Out:    bytes.NewBuffer(nil),
		ErrOut: bytes.NewBuffer(nil),
	}
}
