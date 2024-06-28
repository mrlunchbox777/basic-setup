package static

import (
	"embed"

	yaml "gopkg.in/yaml.v2"
)

var (
	//go:embed resources
	resources embed.FS
)

type Readable interface {
	readConstants() error
}

type ReadFileFunc func(string) ([]byte, error)

func (r ReadFileFunc) ReadFile(s string) ([]byte, error) {
	return r(s)
}

type Constants struct {
	// readFileFunc - function to read file
	readFileFunc ReadFileFunc
	// BasicSetupCliVersion - constance for sematic versioning
	BasicSetupCliVersion string `yaml:"BasicSetupCliVersion"`
}

func (c *Constants) readConstants() error {
	yamlFile, err := c.readFileFunc.ReadFile("resources/constants.yaml")
	if err != nil {
		return err
	}
	err = yaml.Unmarshal(yamlFile, c)
	return err
}

// ConstantsClient is an interface that defines methods to interact with Constants
type ConstantsClient interface {
	GetConstants() (Constants, error)
}

// constantsClient is an implementation of the ConstantsClient interface
type constantsClient struct {
	readFileFunc ReadFileFunc
}

// NewConstantsClient creates a new ConstantsClient with the provided ReadFileFunc
func NewConstantsClient(readFileFunc ReadFileFunc) ConstantsClient {
	return &constantsClient{
		readFileFunc: readFileFunc,
	}
}

// GetConstants reads the constants from the YAML file and returns a Constants instance
func (c *constantsClient) GetConstants() (Constants, error) {
	constants := Constants{
		readFileFunc: c.readFileFunc,
	}
	err := constants.readConstants()
	return constants, err
}

// Default client using embedded resources
var DefaultClient = NewConstantsClient(resources.ReadFile)

// GetDefaultConstants returns constants using the default client
func GetDefaultConstants() (Constants, error) {
	return DefaultClient.GetConstants()
}
