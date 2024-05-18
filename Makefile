.PHONY: default all build clean coverage fmt format golint install lint run test vet

# If the first argument is "run"...
ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

default: all

all: format build coverage lint golint install

build:
	cd ./bsctl; make build

clean:
	cd ./bsctl; make clean

coverage:
	cd ./bsctl; make coverage

fmt: format

format:
	cd ./bsctl; make format

install:
	cd ./bsctl; make install

golint:
	cd ./bsctl; make lint

lint: vet golint

run:
	cd ./bsctl; make run $(RUN_ARGS)

test:
	cd ./bsctl; make test

vet:
	cd ./bsctl; vet
