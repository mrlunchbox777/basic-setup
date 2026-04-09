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

## Precedence rules
- Default to one version bump per PR branch.
- After a branch has been bumped, do not bump again for follow-up commits unless the user explicitly requests another bump or release policy requires it.
- For follow-up commits on the same PR, update the existing current-version changelog entry via [Update Changelog Skill](../update-changelog/SKILL.md).
- If a docs bump is already present on the branch, rerun docs-bump checks after each meaningful change.

## Prerequisites
- Tools: `yq`, `git`, `make` (for tests when code changes are included).
- Permissions to push branch changes.

## Inputs
- Target semantic version: `X.Y.Z` (decide major/minor/patch per guidelines).

## Required context
- Decide bump type (major/minor/patch) per semantic versioning and repo guidelines.
- Current version lives at `resources/version.yaml` under `.BasicSetupCliVersion` (mirror `bsctl/static/resources/constants.yaml` during transition).

## Steps
1. Set the new version: `yq -i '.BasicSetupCliVersion = "X.Y.Z"' resources/version.yaml` and mirror `bsctl/static/resources/constants.yaml` while legacy paths still exist.
2. Create a new top `CHANGELOG.md` entry for `X.Y.Z` with today’s date (`YYYY-MM-DD`) and Keep a Changelog section headers (`### Added`, `### Changed`, `### Fixed`).
3. Immediately run [Update Changelog Skill](../update-changelog/SKILL.md) to populate/refine and consolidate the entry from staged/working-tree changes and recent commits.
4. Verify alignment: top changelog version matches `.BasicSetupCliVersion`; date is valid for CI validation (UTC +/- 1 day).
5. Validate changes: at minimum `git diff`; run `make test` if code changed.

## Decision table
- No bump yet on the PR branch: create a new version entry and set version files.
- Branch already has a bump for this PR: do not bump again; update that same entry.
- User explicitly requests another bump: create the next version.
- Release policy explicitly requires another bump: create the next version and document why.

## Outputs
- Updated `resources/version.yaml` with the new version (and mirrored `bsctl/static/resources/constants.yaml` during transition).
- Matching `CHANGELOG.md` entry for `X.Y.Z`.
