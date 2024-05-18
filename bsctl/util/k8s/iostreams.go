package k8s

import (
	"os"

	genericIOOptions "k8s.io/cli-runtime/pkg/genericiooptions"
)

// GetIOStream - get io stream
func GetIOStream() genericIOOptions.IOStreams {
	streams := genericIOOptions.IOStreams{
		In:     os.Stdin,
		Out:    os.Stdout,
		ErrOut: os.Stderr,
	}

	return streams
}
