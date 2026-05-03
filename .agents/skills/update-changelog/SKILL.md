---
name: update-changelog
description: Updates the existing changelog entry for the current version after a version bump; use to capture new changes without changing the version.
---

# Update Changelog Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Update the current version changelog entry without changing the version.

## Entry quality bar
- Treat the current-version entry as curated release notes, not an append-only scratchpad.
- Consolidate related bullets into outcome-focused statements (prefer user/contributor impact over implementation minutiae).
- Remove duplicate or near-duplicate bullets and keep section wording consistent.
- Keep entries concise (target roughly 3-6 bullets per section when work volume allows).

## When to use
- Version already bumped for this branch/working copy and you need to record additional changes.
- The branch has a current-version changelog entry that is not merged to `main` yet; update that same entry instead of creating another version header.
- If neither branch nor `main` has an entry for the current version, run [Version Bump Skill](../version-bump/SKILL.md) first.

## Prerequisites
- Tools: `git`, editor.
- Permissions to push branch changes.

## Inputs
- Current version from `resources/version.yaml` (fallback to `bsctl/static/resources/constants.yaml` during transition).
- Summary of new work to capture (staged/unstaged changes and recent commits).

## Required context
- Current version in `resources/version.yaml` (fallback to `bsctl/static/resources/constants.yaml` during transition).
- Whether `main` already contains that version entry (use `git show origin/main:CHANGELOG.md` or GitHub UI/API).

## Steps
1. Read the current version from `resources/version.yaml` (fallback to `bsctl/static/resources/constants.yaml` during transition).
2. Find the entry for that version in branch `CHANGELOG.md`.
3. If the version exists in branch changelog (including when it is not yet merged to `main`), update that same entry in place.
4. If branch entry is missing but `main` already has that version entry, cherry-pick/recreate that entry at the top and then update it.
5. If branch and `main` both lack that version entry, stop and run [Version Bump Skill](../version-bump/SKILL.md).
6. If this PR branch already contains one bump, keep reusing that entry for subsequent commits; do not create another version header unless explicitly requested.
7. Consolidate the entry before finalizing: merge overlapping bullets, collapse low-level implementation-only bullets into higher-level outcomes, and remove duplicates.
8. Update Added/Changed/Fixed bullets with concise, user-visible or contributor-impacting changes; keep style and tense consistent.
9. When updating an existing entry, keep the version unchanged and set the entry date to today's date (`YYYY-MM-DD`, UTC).
10. If adding more changes later without bumping a new version, update that same entry again (rewrite/refine, not append-only) and refresh the date to today's date.
11. Validate with `git diff`; run tests if code changed.
12. If this branch already has a docs bump/current-version entry, rerun docs-bump checks after each meaningful change to catch version/changelog drift early.

## Outputs
- Updated `CHANGELOG.md` entry for the current version reflecting all new work.
