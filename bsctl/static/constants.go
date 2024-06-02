package static

import (
	"embed"

	yaml "gopkg.in/yaml.v2"
)

var (
	//go:embed resources
	resources embed.FS
	constants = Constants{}
)

func GetConstants() (Constants, error) {
	constants.readFileFunc = resources.ReadFile
	err := constants.readConstants()
	return constants, err
}

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
