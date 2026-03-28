# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [0.1.13] - 2026-03-27

### Changed

- Added tooling pivot migration planning docs and execution tracking for WS1-WS6, including active issue links and script classification inventory.
- Updated WS6 cleanup scope to remove or archive `docs/bsctl-migration/`, clean stale references, and align CI/workflow pipeline paths to the post-pivot architecture.
- Added explicit WS6 cleanup guidance for contributor docs, `AGENTS.md`, and `.agents/skills/*` instructions.
- Addressed PR review feedback by correcting `shared-scripts/bin/*` inventory coverage, linking Big Bang migration to dedicated tracker `#294`, and making execution-tracking issue references auto-linkable.

---

## [0.1.12] - 2026-03-26

### Changed

- gomod update(deps): bump the version-updates group

---

## [0.1.11] - 2026-03-19

### Changed

- Bump fgrosse/go-coverage-report from 1.2.0 to 1.3.0

---

## [0.1.10] - 2026-03-06

### Added

- Agents validation workflow to enforce instruction paths, required headings, and frontmatter.
- Skills manifest at `.agents/skills/manifest.md`.

### Changed

- Skills now include agent skills frontmatter (name/description) and documented expectations in `.agents/README.md`.
- Updated CHANGELOG date validation to compare full dates (UTC) with a +/- 1 day tolerance, including month/year boundaries.
- Updated the update-changelog skill to keep editing the branch's current-version entry when that version has not merged to `main` yet.
- Updated the version-bump skill to delegate changelog content updates to the update-changelog skill instead of duplicating instructions.

---

## [0.1.9] - 2026-03-06

### Changed

- Bump k8s.io/cli-runtime from 0.35.1 to 0.35.2
- Bump k8s.io/kubectl from 0.35.1 to 0.35.2

---

## [0.1.8] - 2026-03-06

### Added

- Added version bump skill documentation and linked it from `AGENTS.md`.

### Changed

- Clarified version bump guidance to capture staged/working copy changes and recent commits in changelog entries.
- Updated docs-bump workflow to skip version divergence checks when running on main.
- Fixed changelog validation to ignore leading blank lines after the divider and mirrored the tolerance when fetching main for comparison.
- Corrected version bump skill `yq` example quoting so the full command renders properly.
- Moved the main-branch short-circuit ahead of remote fetch in the docs-bump version check to avoid unnecessary network calls.
- Added main-branch short-circuit to the changelog comparison workflow to avoid false failures on `main`.
- Bump BasicSetup CLI version to 0.1.8.

---

## [0.1.7] - 2026-03-05

### Changed

- Bump actions/upload-artifact from 6 to 7

---

## [0.1.6] - 2026-03-05

### Changed

- Bump k8s.io/cli-runtime from 0.35.0 to 0.35.1
- Bump k8s.io/kubectl from 0.35.0 to 0.35.1

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
