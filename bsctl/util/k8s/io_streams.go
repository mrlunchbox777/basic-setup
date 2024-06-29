package k8s

import (
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
