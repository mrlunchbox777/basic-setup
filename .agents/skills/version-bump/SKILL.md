# Version Bump Skill

## Purpose
Keep the BasicSetup CLI version and changelog in sync for releases.

## When to use
- Preparing a release or merging changes that require a new version.
- Automated bumps (e.g., Dependabot) are not handling this branch.
- For changelog-only edits after a bump, use [Update Changelog Skill](../update-changelog/SKILL.md).

## Required context
- Decide bump type (major/minor/patch) per semantic versioning and repo guidelines.
- Current version lives at `bsctl/static/resources/constants.yaml` under `.BasicSetupCliVersion`.

## Steps
1. Set the new version: `yq -i '.BasicSetupCliVersion = "X.Y.Z"' bsctl/static/resources/constants.yaml`.
2. Add a top entry in `CHANGELOG.md` after the `---` divider using Keep a Changelog format with:
   - Version `X.Y.Z` and today’s date (`YYYY-MM-DD`, ±1 day for timezone).
   - Added/Changed/Fixed subsections summarizing staged/working tree changes and recent commits (`git diff --stat`, `git log --oneline` can help).
   - Future edits to this entry should use [Update Changelog Skill](update-changelog.md), not another bump.
3. Verify alignment: changelog version matches `.BasicSetupCliVersion`; date is correct.
4. Validate changes: at minimum `git diff`; run `make test` if code changed.

## Outputs
- Updated `bsctl/static/resources/constants.yaml` with the new version.
- Matching `CHANGELOG.md` entry for `X.Y.Z`.
