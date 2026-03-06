# Version Bump Skill

Steps to bump the BasicSetup CLI version and keep release artifacts consistent.

## When to use
- Preparing a release or merging changes that warrant a new version.
- Dependabot or automated bumps already handled elsewhere; use this for manual bumps.
- For additional changelog edits after the bump, use the [Update Changelog Skill](update-changelog.md).

## How to execute
1. Choose bump type (major/minor/patch) using semantic versioning and repository guidelines.
2. Update `bsctl/static/resources/constants.yaml` at `.BasicSetupCliVersion` (e.g., `yq -i '.BasicSetupCliVersion = "X.Y.Z"' bsctl/static/resources/constants.yaml`).
3. Add the top entry in `CHANGELOG.md` after the `---` divider using Keep a Changelog format, with the same version and current date (`YYYY-MM-DD`), and include Added/Changed/Fixed subsections that summarize the changes on this branch (cover staged/working copy and recent commits, e.g., use `git diff --stat` and `git log --oneline` for context). For subsequent edits to this entry, use the [Update Changelog Skill](update-changelog.md) instead of re-bumping.
4. Verify the version and date alignment: ensure the changelog entry version matches `.BasicSetupCliVersion` and the date is today (allowing ±1 day for timezone, matching existing scripts).
5. Run relevant checks (at minimum `git diff` to confirm only intended changes; run `make test` when code changes are included).

## Outputs
- Updated `bsctl/static/resources/constants.yaml` with the new version.
- Matching changelog entry documenting the bump (future edits go through the Update Changelog Skill).
