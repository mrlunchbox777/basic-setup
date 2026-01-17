# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [0.1.5] - 2026-01-17
### Added
- Added AGENTS.md with coding standards for Go, Bash, documentation, testing, version bumping, and linting
- Added Dependabot auto-bump workflow to automatically update version and CHANGELOG when Dependabot creates PRs

### Changed
- Improved Dependabot CHANGELOG script with better PR title parsing using regex patterns
- Enhanced version bump script with semver validation and numeric component checks
- Added idempotency checks to prevent duplicate version bumps in workflows
- Added yq installation step to ensure tool availability in CI
- Improved error handling with trap for temp file cleanup in CHANGELOG script

### Fixed
- Fixed shebang format to match project convention (#! with space)
- Fixed CHANGELOG entry formatting to match existing style

## [0.1.4] - 2026-01-16
### Changed
- Updated GitHub Actions dependencies: actions/checkout from v4 to v6, asdf-vm/actions from v3 to v4

## [0.1.3] - 2026-01-16
### Fixed
- Updated test expectations after bbctl v1.5.0 upgrade - error messages changed from "FakeWriter intentionally errored" to "FakeReader intentionally errored"
- Updated go.mod dependencies via go mod tidy

## [0.1.2] - 2025-06-27
### Added
- Added `ReaderTee` and `WriterTee` to `bsctl/util/k8s/io_streams_tees.go` to allow reading from and writing to multiple streams simultaneously.

## [0.1.1] - 2024-06-28
### Added
- Added unit tests for `ReaderTee` and `WriterTee` in `bsctl/util/k8s/io_streams_tees_test.go`.

## [0.1.0] - 2024-04-11
### Added
- create MVP

