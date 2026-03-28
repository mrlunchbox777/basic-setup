---
name: update-changelog
description: Updates the existing changelog entry for the current version after a version bump; use to capture new changes without changing the version.
---

# Update Changelog Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Update the current version changelog entry without changing the version.

## When to use
- Version already bumped for this branch/working copy and you need to record additional changes.
- The branch has a current-version changelog entry that is not merged to `main` yet; update that same entry instead of creating another version header.
- If neither branch nor `main` has an entry for the current version, run [Version Bump Skill](../version-bump/SKILL.md) first.

## Prerequisites
- Tools: `git`, editor.
- Permissions to push branch changes.

## Inputs
- Current version from `bsctl/static/resources/constants.yaml`.
- Summary of new work to capture (staged/unstaged changes and recent commits).

## Required context
- Current version in `bsctl/static/resources/constants.yaml`.
- Whether `main` already contains that version entry (use `git show origin/main:CHANGELOG.md` or GitHub UI/API).

## Steps
1. Read the current version from `bsctl/static/resources/constants.yaml`.
2. Find the entry for that version in branch `CHANGELOG.md`.
3. If the version exists in branch changelog (including when it is not yet merged to `main`), update that same entry in place.
4. If branch entry is missing but `main` already has that version entry, cherry-pick/recreate that entry at the top and then update it.
5. If branch and `main` both lack that version entry, stop and run [Version Bump Skill](../version-bump/SKILL.md).
6. Update Added/Changed/Fixed bullets with concise, user-visible changes; avoid duplicate bullets and keep style consistent.
7. When updating an existing entry, keep the version unchanged and set the entry date to today's date (`YYYY-MM-DD`, UTC).
8. If adding more changes later without bumping a new version, update that same entry again and refresh the date to today's date.
9. Validate with `git diff`; run tests if code changed.

## Outputs
- Updated `CHANGELOG.md` entry for the current version reflecting all new work.
