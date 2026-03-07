---
name: version-bump
description: Bumps the BasicSetup CLI version and adds a matching changelog entry; use when releasing or merging changes that require a new version.
---

# Version Bump Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Keep the BasicSetup CLI version and changelog in sync for releases.

## When to use
- Preparing a release or merging changes that require a new version.
- Automated bumps (e.g., Dependabot) are not handling this branch.
- For changelog-only edits after a bump, use [Update Changelog Skill](../update-changelog/SKILL.md).

## Prerequisites
- Tools: `yq`, `git`, `make` (for tests when code changes are included).
- Permissions to push branch changes.

## Inputs
- Target semantic version: `X.Y.Z` (decide major/minor/patch per guidelines).

## Required context
- Decide bump type (major/minor/patch) per semantic versioning and repo guidelines.
- Current version lives at `bsctl/static/resources/constants.yaml` under `.BasicSetupCliVersion`.

## Steps
1. Set the new version: `yq -i '.BasicSetupCliVersion = "X.Y.Z"' bsctl/static/resources/constants.yaml`.
2. Create a new top `CHANGELOG.md` entry for `X.Y.Z` with today’s date (`YYYY-MM-DD`) and Keep a Changelog section headers (`### Added`, `### Changed`, `### Fixed`).
3. Immediately run [Update Changelog Skill](../update-changelog/SKILL.md) to populate/refine the entry from staged/working-tree changes and recent commits.
4. Verify alignment: top changelog version matches `.BasicSetupCliVersion`; date is valid for CI validation (UTC +/- 1 day).
5. Validate changes: at minimum `git diff`; run `make test` if code changed.

## Outputs
- Updated `bsctl/static/resources/constants.yaml` with the new version.
- Matching `CHANGELOG.md` entry for `X.Y.Z`.
