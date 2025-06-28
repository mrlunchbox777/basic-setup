package k8s

import (
	"errors"
	"io"
)

// ReaderTee - reads data from original to p and multiple writers
type ReaderTee struct {
	Original       io.Reader
	ReaderTrackers []io.Writer
}

// Read - read data from original reader into to p and all target writers
func (t *ReaderTee) Read(p []byte) (n int, err error) {
	var allErrors []error
	count, err := t.Original.Read(p)
	if err != nil {
		return count, err
	}

	for _, target := range t.ReaderTrackers {
		if target == nil {
			continue
		}
		_, err = target.Write(p)
		if err != nil {
			allErrors = append(allErrors, err)
		}
	}

	return count, errors.Join(allErrors...)
}

// WriterTee - writes data to multiple writers
type WriterTee struct {
	Original      io.Writer
	TargetWriters []io.Writer
}

// Write - write data to original and all target writers
func (t *WriterTee) Write(p []byte) (n int, err error) {
	var allErrors []error
	count, err := t.Original.Write(p)
	if err != nil {
		return count, err
	}

	for _, target := range t.TargetWriters {
		if target == nil {
			continue
		}
		_, err = target.Write(p)
		if err != nil {
			allErrors = append(allErrors, err)
		}
	}

	return count, errors.Join(allErrors...)
}

// StreamTees - tees streams to multiple writers
type StreamTees struct {
	InObj     *ReaderTee
	OutObj    *WriterTee
	ErrOutObj *WriterTee
}

// In - get input stream
func (s *StreamTees) In() io.Reader {
	return s.InObj
}

// Out - get output stream
func (s *StreamTees) Out() io.Writer {
	return s.OutObj
}

// ErrOut - get error output stream
func (s *StreamTees) ErrOut() io.Writer {
	return s.ErrOutObj
}

// NewStreamTees - create new stream tees
func NewStreamTees(in *ReaderTee, out *WriterTee, errOut *WriterTee) *StreamTees {
	return &StreamTees{
		InObj:     in,
		OutObj:    out,
		ErrOutObj: errOut,
	}
}

// NewStreamTeesFromStreams - create new stream tees from streams
func NewStreamTeesFromStreams(streams IOStreams, ins []io.Writer, outs []io.Writer, errOuts []io.Writer) *StreamTees {
	return NewStreamTees(
		&ReaderTee{
			Original:       streams.In(),
			ReaderTrackers: ins,
		},
		&WriterTee{
			Original:      streams.Out(),
			TargetWriters: outs,
		},
		&WriterTee{
			Original:      streams.ErrOut(),
			TargetWriters: errOuts,
		},
	)
}

// NewStreamTeesFromStreamsAndStores - create new stream tees from streams and stores
func NewStreamTeesFromStreamsAndStores(streams IOStreams, stores *StreamStores) *StreamTees {
	return NewStreamTeesFromStreams(
		streams,
		[]io.Writer{stores.In},
		[]io.Writer{stores.Out},
		[]io.Writer{stores.ErrOut},
	)
}
