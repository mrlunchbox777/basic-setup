# Update Changelog Skill

Use this when the version for this branch is already bumped but the changelog entry needs to reflect additional work on the same version.

## When to use
- Version already bumped for this branch/working copy, and new changes need to be captured in the existing changelog entry.
- If the version is not bumped yet, first run the [Version Bump Skill](version-bump.md).

## How to execute
1. Confirm the current version in `bsctl/static/resources/constants.yaml` matches the latest entry in `CHANGELOG.md`; if the entry is missing, run the version bump skill.
2. Gather changes since the last update (cover staged and working tree plus recent commits): e.g., `git diff --stat` for unstaged/staged changes and `git log --oneline <base>..HEAD` for commits already made.
3. In `CHANGELOG.md`, find the entry for the current version (topmost after the divider) and update the Added/Changed/Fixed subsections to include concise bullets for the new work.
4. Keep the version and date as-is unless a new release date is required by project conventions.
5. Validate: ensure the entry still matches the current version, summarize all relevant changes, and check `git diff` before opening PR; run tests if code changed.

## Outputs
- Updated `CHANGELOG.md` entry for the current version reflecting all branch changes.
