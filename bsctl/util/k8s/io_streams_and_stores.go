package k8s

import "io"

// IOStreamsAndStores - store for IOStreams
type IOStreamsAndStores struct {
	IOStreams    IOStreams
	StreamStores *StreamStores
}

// GetIOStreams - get IOStreams
func (s *IOStreamsAndStores) GetIOStreams() IOStreams {
	return s.IOStreams
}

// GetStreamStores - get StreamStores
func (s *IOStreamsAndStores) GetStreamStores() *StreamStores {
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
