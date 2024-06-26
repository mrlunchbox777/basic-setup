package k8s

import (
	"os"
)

// IOStreamsGetter - interface for getting IOStreams
type IOStreamsGetter interface {
	GetIOStreams() IOStreams
	GetStreamStores() *StreamStores
}

// GetIOStreams - get io streams without stores
func GetIOStreamsGetter() IOStreamsGetter {
	return GetIOStreamsGetterConfigured(false)
}

// GetIOStreamsGetterConfigured - get io streams with or without stores
func GetIOStreamsGetterConfigured(buffered bool) IOStreamsGetter {
	getter := &IOStreamsStore{}
	realStreams := &IOStreamsConcrete{
		InObj:     os.Stdin,
		OutObj:    os.Stdout,
		ErrOutObj: os.Stderr,
	}

	if buffered {
		stores := NewStreamStores()
		tees := NewStreamTeesFromStreamsAndStores(realStreams, stores)

		getter.IOStreams = tees
		getter.StreamStores = stores
	} else {
		getter.IOStreams = realStreams
	}

	return getter
}

// GetStoreOnlyStreams - get io stream with buffers
func GetStoreOnlyStreams() IOStreamsGetter {
	stores := NewStreamStores()
	return &IOStreamsStore{
		IOStreams:    NewStreamsStoreWrapper(stores),
		StreamStores: stores,
	}
}
