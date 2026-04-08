# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


---
## [0.1.19] - 2026-04-08

### Added

- Added local work snapshot support with `.agents/work-snapshot.local.md`, `make snapshot`, and `.agents/scripts/update-work-snapshot.sh` to speed up context handoffs between sessions.
- Added a `work-snapshot` skill at `.agents/skills/work-snapshot/SKILL.md` for maintaining the local handoff file after major milestones.

### Changed

- Updated `AGENTS.md`, `.agents/README.md`, and `.agents/skills/manifest.md` with guidance on reading snapshot state at session start and checking staleness before execution.
- Added a `Scope Control` section to `AGENTS.md` so agents pause on scope creep, ask whether to expand or defer, and when deferred, track follow-up work in a linked issue.
- Hardened `.github/workflows/release.yml` to avoid `inputs.*` evaluation on non-dispatch events and generate `release-candidate/metadata.json` via `jq` with correct JSON escaping and boolean typing.
- Updated `.agents/scripts/update-work-snapshot.sh` to fetch PR metadata in a single `gh pr view` call and fail clearly when `python3` is unavailable.
- Updated `docs/agent-skills-and-release-plan.md` and parent tracker #295 to add follow-up issue #319 for CI-based issue/PR label-family synchronization validation as separate scope from #307.
- Added validation in `.github/workflows/release.yml` to fail candidate generation when the resolved version is empty or `null`.
- Enforced single-line `--goal` and `--context` values in `.agents/scripts/update-work-snapshot.sh` to preserve snapshot field parsing.
- Updated release candidate metadata defaults so manual dispatch without `target_commitish` records `target_ref` as the branch/ref name instead of duplicating the commit SHA.
- Updated `.agents/skills/work-snapshot/SKILL.md` prerequisites to document the `python3` requirement used by the updater script.

---
## [0.1.18] - 2026-04-03

### Added

- Added `.github/workflows/release.yml` scaffold for release-candidate generation on eligible `main` merges with immutable candidate metadata artifacts and no direct publish path.
- Added `wip-pr-setup` skill at `.agents/skills/wip-pr-setup/SKILL.md` for standardized branch/PR setup, docs bump flow, and doing-state label sync.

### Changed

- Updated agent skill indexes in `AGENTS.md`, `.agents/README.md`, and `.agents/skills/manifest.md` to include `wip-pr-setup`.
- Updated `docs/agent-skills-and-release-plan.md` and issue #314 to require code-based yank handling with artifact removal and `-bad` tag rename while preserving research history.

---

## [0.1.17] - 2026-04-03

### Changed

- Bump github.com/go-playground/validator/v10 from 10.30.1 to 10.30.2

---

## [0.1.16] - 2026-03-30
### Changed
- Bump pascalgn/size-label-action from 0.5.5 to 0.5.7

## [0.1.15] - 2026-03-29

### Changed

- Updated `docs/agent-skills-and-release-plan.md` to use a release-candidate plus manual-promotion model, including explicit code-based yank/rollback coverage.

---

## [0.1.14] - 2026-03-28

### Added

- Added `sync-labels` skill with rules for syncing `kind/*`, `priority/*`, `status/*`, and `changes/*` labels between issues and PRs while keeping `size/*` PR-only and CI-managed.

### Changed

- Updated skills indexes in `AGENTS.md`, `.agents/README.md`, and `.agents/skills/manifest.md` to include the new sync-labels skill.
- Added `docs/agent-skills-and-release-plan.md` and mapped it to created tracker issues (#295-#311), including strict changelog-parse failure requirements for release creation.
- Clarified `sync-labels` kind precedence for issue-template labels (including `kind/support`) and aligned size-label documentation to CI-managed PR-only behavior.

---

## [0.1.13] - 2026-03-28

### Changed

- Added tooling pivot migration planning docs and execution tracking for WS1-WS6, including active issue links and script classification inventory.
- Updated WS6 cleanup scope to remove or archive `docs/bsctl-migration/`, clean stale references, and align CI/workflow pipeline paths to the post-pivot architecture.
- Added explicit WS6 cleanup guidance for contributor docs, `AGENTS.md`, and `.agents/skills/*` instructions.
- Addressed PR review feedback by correcting `shared-scripts/bin/*` inventory coverage, linking Big Bang migration to dedicated tracker #294, and making execution-tracking issue references auto-linkable.
- Standardized remaining issue references in pivot WIP/inventory docs to plain `#...` for GitHub auto-linking and clarified the `/tmp/ws*.md` prerequisite for issue-creation commands.
- Converted remaining triage/execution issue references in `docs/tooling-pivot-wip.md` from backticked/ranged forms to explicit plain `#...` links for better navigability.
- Expanded remaining issue ranges in `docs/tooling-pivot-wip.md` and `docs/tooling-pivot-migration-plan.md` into explicit issue lists so each tracker is individually clickable.

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
