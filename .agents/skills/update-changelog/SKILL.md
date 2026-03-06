# Update Changelog Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Update the existing changelog entry when the version is already bumped.

## When to use
- Version already bumped for this branch/working copy and you need to record additional changes.
- If no entry exists for the current version, run [Version Bump Skill](../version-bump/SKILL.md) first.

## Prerequisites
- Tools: `git`, editor.
- Permissions to push branch changes.

## Inputs
- Current version from `bsctl/static/resources/constants.yaml`.
- Summary of new work to capture (staged/unstaged changes and recent commits).

## Required context
- Current version in `bsctl/static/resources/constants.yaml`.
- Latest changelog entry for that version at the top of `CHANGELOG.md` after the divider.

## Steps
1. Confirm the version in `bsctl/static/resources/constants.yaml` matches the top `CHANGELOG.md` entry; if missing, run the bump skill.
2. Gather changes since the last changelog update (staged/unstaged plus recent commits) using `git diff --stat` and `git log --oneline <base>..HEAD`.
3. In `CHANGELOG.md`, update the Added/Changed/Fixed subsections for the current version with concise bullets covering the new work.
4. Keep the version and date unchanged unless project conventions require a new release date.
5. Validate with `git diff`; run tests if code changed.

## Outputs
- Updated `CHANGELOG.md` entry for the current version reflecting all new work.
