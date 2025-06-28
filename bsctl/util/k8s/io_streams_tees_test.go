package k8s

import (
	"bytes"
	"io"
	"testing"

	"github.com/stretchr/testify/assert"
	bbUtilTestApiWrappers "repo1.dso.mil/big-bang/apps/developer-tools/bbctl/util/test/apiwrappers"
)

func TestRead(t *testing.T) {
	// Arrange
	readValue := []byte("test")
	expected := len(readValue)
	targets := []*bytes.Buffer{
		{},
		{},
	}
	tee := &ReaderTee{
		Original:       bytes.NewBuffer(readValue),
		ReaderTrackers: []io.Writer{targets[0], targets[1]},
	}

	// Act
	actual, err := tee.Read(readValue)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, expected, actual)
	assert.Equal(t, expected, targets[0].Len())
	assert.Equal(t, expected, targets[1].Len())
	assert.Equal(t, readValue, targets[0].Bytes())
	assert.Equal(t, readValue, targets[1].Bytes())
}

func TestWrite(t *testing.T) {
	// Arrange
	writeValue := []byte("test")
	expected := len(writeValue)
	targets := []*bytes.Buffer{
		{},
		{},
	}
	tee := &WriterTee{
		Original:      bytes.NewBuffer([]byte{}),
		TargetWriters: []io.Writer{targets[0], targets[1]},
	}

	// Act
	actual, err := tee.Write(writeValue)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, expected, actual)
	assert.Equal(t, expected, targets[0].Len())
	assert.Equal(t, expected, targets[1].Len())
	assert.Equal(t, writeValue, targets[0].Bytes())
	assert.Equal(t, writeValue, targets[1].Bytes())
}

func TestStreamTees(t *testing.T) {
	// Arrange
	inValue := []byte("test1")
	outValue := []byte("test2")
	errOutValue := []byte("test2")
	inTargets := []*bytes.Buffer{
		{},
		{},
	}
	outTargets := []*bytes.Buffer{
		{},
		{},
	}
	errOutTargets := []*bytes.Buffer{
		{},
		{},
	}
	tee := &StreamTees{
		InObj: &ReaderTee{
			Original:       bytes.NewBuffer(inValue),
			ReaderTrackers: []io.Writer{inTargets[0], inTargets[1]},
		},
		OutObj: &WriterTee{
			Original:      bytes.NewBuffer([]byte{}),
			TargetWriters: []io.Writer{outTargets[0], outTargets[1]},
		},
		ErrOutObj: &WriterTee{
			Original:      bytes.NewBuffer([]byte{}),
			TargetWriters: []io.Writer{errOutTargets[0], errOutTargets[1]},
		},
	}
	readBuffer := make([]byte, len(inValue))

	// Act
	readLen, err := tee.In().Read(readBuffer)
	assert.NoError(t, err)
	writeLen, err := tee.Out().Write(outValue)
	assert.NoError(t, err)
	errOutLen, err := tee.ErrOut().Write(errOutValue)
	assert.NoError(t, err)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, len(inValue), readLen)
	assert.Equal(t, len(outValue), writeLen)
	assert.Equal(t, len(errOutValue), errOutLen)
	assert.Equal(t, inValue, readBuffer)
	assert.Equal(t, inValue, inTargets[0].Bytes())
	assert.Equal(t, inValue, inTargets[1].Bytes())
	assert.Equal(t, outValue, outTargets[0].Bytes())
	assert.Equal(t, outValue, outTargets[1].Bytes())
	assert.Equal(t, errOutValue, errOutTargets[0].Bytes())
	assert.Equal(t, errOutValue, errOutTargets[1].Bytes())
}

func TestReaderTeeErrors(t *testing.T) {
	readValue := "test"
	tests := []struct {
		name            string
		errorOnOriginal bool
		errorOnTarget   bool
		nilTarget       bool
	}{
		{
			name:            "error on original",
			errorOnOriginal: true,
			errorOnTarget:   false,
			nilTarget:       false,
		},
		{
			name:            "error on target",
			errorOnOriginal: false,
			errorOnTarget:   true,
			nilTarget:       false,
		},
		{
			name:            "nil target",
			errorOnOriginal: false,
			errorOnTarget:   false,
			nilTarget:       true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			var original io.Reader = bytes.NewBuffer([]byte(readValue))
			var target io.Writer = &bytes.Buffer{}

			if tt.errorOnOriginal {
				original = bbUtilTestApiWrappers.CreateFakeReaderWriter(t, true, false)
			}
			if tt.errorOnTarget {
				target = bbUtilTestApiWrappers.CreateFakeReaderWriter(t, false, true)
			}
			if tt.nilTarget {
				target = nil
			}
			tee := &ReaderTee{
				Original:       original,
				ReaderTrackers: []io.Writer{target},
			}
			readBuffer := make([]byte, len(readValue))

			// Act
			actual, err := tee.Read(readBuffer)

			// Assert
			if tt.errorOnOriginal {
				assert.Error(t, err)
				// this will change when https://repo1.dso.mil/big-bang/apps/developer-tools/bbctl/-/merge_requests/89 is merged
				// assert.Equal(t, "FakeReader intentionally errored", err.Error())
				assert.Equal(t, "FakeWriter intentionally errored", err.Error())
				assert.Equal(t, 0, target.(*bytes.Buffer).Len())
				assert.Equal(t, []byte(nil), target.(*bytes.Buffer).Bytes())
				assert.Equal(t, 0, actual)
			} else if tt.errorOnTarget {
				assert.Error(t, err)
				assert.Equal(t, "FakeWriter intentionally errored", err.Error())
				assert.Equal(t, 0, target.(*bbUtilTestApiWrappers.FakeReaderWriter).ActualBuffer.(*bytes.Buffer).Len())
				assert.Equal(t, []byte(nil), target.(*bbUtilTestApiWrappers.FakeReaderWriter).ActualBuffer.(*bytes.Buffer).Bytes())
				assert.Equal(t, len(readValue), actual)
			} else if tt.nilTarget {
				assert.NoError(t, err)
				assert.Nil(t, target)
			} else {
				panic("unexpected test case")
			}
		})
	}
}

func TestWriterTeeErrors(t *testing.T) {
	writerValue := []byte("test")
	tests := []struct {
		name            string
		errorOnOriginal bool
		errorOnTarget   bool
		nilTarget       bool
	}{
		{
			name:            "error on original",
			errorOnOriginal: true,
			errorOnTarget:   false,
			nilTarget:       false,
		},
		{
			name:            "error on target",
			errorOnOriginal: false,
			errorOnTarget:   true,
			nilTarget:       false,
		},
		{
			name:            "nil target",
			errorOnOriginal: false,
			errorOnTarget:   false,
			nilTarget:       true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			var original io.Writer = bytes.NewBuffer([]byte{})
			var target io.Writer = &bytes.Buffer{}

			if tt.errorOnOriginal {
				original = bbUtilTestApiWrappers.CreateFakeReaderWriter(t, false, true)
			}
			if tt.errorOnTarget {
				target = bbUtilTestApiWrappers.CreateFakeReaderWriter(t, false, true)
			}
			if tt.nilTarget {
				target = nil
			}
			tee := &WriterTee{
				Original:      original,
				TargetWriters: []io.Writer{target},
			}

			// Act
			actual, err := tee.Write(writerValue)

			// Assert
			if tt.errorOnOriginal {
				assert.Error(t, err)
				assert.Equal(t, "FakeWriter intentionally errored", err.Error())
				assert.Equal(t, 0, target.(*bytes.Buffer).Len())
				assert.Equal(t, []byte(nil), target.(*bytes.Buffer).Bytes())
				assert.Equal(t, 0, actual)
			} else if tt.errorOnTarget {
				assert.Error(t, err)
				assert.Equal(t, "FakeWriter intentionally errored", err.Error())
				assert.Equal(t, 0, target.(*bbUtilTestApiWrappers.FakeReaderWriter).ActualBuffer.(*bytes.Buffer).Len())
				assert.Equal(t, []byte(nil), target.(*bbUtilTestApiWrappers.FakeReaderWriter).ActualBuffer.(*bytes.Buffer).Bytes())
				assert.Equal(t, len(writerValue), actual)
			} else if tt.nilTarget {
				assert.NoError(t, err)
				assert.Nil(t, target)
			} else {
				panic("unexpected test case")
			}
		})
	}
}
