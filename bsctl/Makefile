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
	@echo "make building..."
	./scripts/build.sh

clean:
	@echo "make cleaning..."
	./scripts/clean.sh

coverage:
	@echo "make coverage..."
	./scripts/coverage.sh

fmt: format

format:
	@echo "make format..."
	./scripts/format.sh

install:
	@echo "make installing..."
	./scripts/install.sh

golint:
	@echo "make golinting..."
	./scripts/golang_ci_lint.sh

lint: vet golint

run:
	@echo "make running with args ($(RUN_ARGS))..."
	./scripts/run.sh $(RUN_ARGS)

test:
	@echo "make testing..."
	./scripts/test.sh

vet:
	@echo "make linting..."
	./scripts/lint.sh
