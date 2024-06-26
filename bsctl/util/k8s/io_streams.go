package k8s

import (
	"bytes"
	"io"

	genericCLIOptions "k8s.io/cli-runtime/pkg/genericclioptions"
)

// IOStreams - input/output streams
type IOStreams interface {
	In() io.Reader
	Out() io.Writer
	ErrOut() io.Writer
}

// IOStreamsConcrete - concrete implementation of IOStreams
type IOStreamsConcrete struct {
	InObj     io.Reader
	OutObj    io.Writer
	ErrOutObj io.Writer
}

// In - get input stream
func (s *IOStreamsConcrete) In() io.Reader {
	return s.InObj
}

// Out - get output stream
func (s *IOStreamsConcrete) Out() io.Writer {
	return s.OutObj
}

// ErrOut - get error output stream
func (s *IOStreamsConcrete) ErrOut() io.Writer {
	return s.ErrOutObj
}

// IOStreamsFromK8s - create IOStreams from k8s CLI options
func IOStreamsFromK8s(options *genericCLIOptions.IOStreams) IOStreams {
	return &IOStreamsConcrete{
		InObj:     options.In,
		OutObj:    options.Out,
		ErrOutObj: options.ErrOut,
	}
}

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

// IOStreamsStore - store for IOStreams
type IOStreamsStore struct {
	IOStreams    IOStreams
	StreamStores *StreamStores
}

// GetIOStreams - get IOStreams
func (s *IOStreamsStore) GetIOStreams() IOStreams {
	return s.IOStreams
}

// GetStreamStores - get StreamStores
func (s *IOStreamsStore) GetStreamStores() *StreamStores {
	return s.StreamStores
}

// StreamStoresWrapper - lets StreamStores be used as IOStreams
type StreamStoresWrapper struct {
	StreamStores *StreamStores
}

// In - get input stream
func (s *StreamStoresWrapper) In() io.Reader {
	return s.StreamStores.In
}

// Out - get output stream
func (s *StreamStoresWrapper) Out() io.Writer {
	return s.StreamStores.Out
}

// ErrOut - get error output stream
func (s *StreamStoresWrapper) ErrOut() io.Writer {
	return s.StreamStores.ErrOut
}

// NewStreamsStoreWrapper - create a new StreamStoresWrapper
// to use StreamStores as IOStreams
func NewStreamsStoreWrapper(stores *StreamStores) IOStreams {
	return &StreamStoresWrapper{
		StreamStores: stores,
	}
}
