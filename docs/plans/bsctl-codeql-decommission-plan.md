# bsctl and CodeQL Decommission Plan (#320)

## Goal

Retire remaining `bsctl` Go CLI and CodeQL dependencies without breaking release/version/changelog automation.

## Scope

- In scope: dependency inventory, replacement mapping, phased migration sequencing, and validation gates for safe removal.
- Out of scope in this planning pass: deleting `bsctl/` or removing workflows directly.

## Dependency Inventory (Initial)

| Area | Current dependency | Why it exists today | Replacement target | Removal gate |
| --- | --- | --- | --- | --- |
| Release candidate workflow | `.github/workflows/release.yml` reads `resources/version.yaml` (legacy fallback to `bsctl/static/resources/constants.yaml` during transition) | Version source for candidate metadata | Complete cutover to root-level version source | Candidate workflow passes with no `bsctl` path usage |
| Docs bump workflow | `.github/workflows/docs-bump.yaml` invokes `bsctl/scripts/workflows/docs-bump_*` | Enforces version/changelog divergence and date checks | Promote scripts to root-level workflow scripts (or equivalent maintained path) | Docs-bump checks pass using replacement scripts |
| Dependabot autobump | `.github/workflows/dependabot-autobump.yaml` invokes `bsctl/scripts/workflows/dependabot-autobump_*` and stages `resources/version.yaml` (plus legacy constants during transition) | Automates patch bump + changelog update for dep PRs | Update to replacement version source + script paths | Dependabot autobump PR succeeds without `bsctl` references |
| Action validator and agents validate | Workflows call scripts in `bsctl/scripts/workflows/*` | Existing script organization | Relocate scripts to neutral location (for example `scripts/workflows/`) | Validation workflows remain green after path migration |
| Code scanning | `.github/workflows/codeql.yaml` scans Go | Security coverage for Go code under `bsctl/` | Re-scope/remove CodeQL after supported-language coverage decision | `bsctl` removal complete and security coverage documented |
| Label automation | `.github/labeler.yaml` maps `bsctl/**/*` to change labels | Surfacing path-based impact in PRs | Replace with new paths or retire mapping if no longer needed | Label behavior remains correct after path removals |
| Agent guidance and skills | `AGENTS.md`, `.agents/skills/*.md`, docs reference `resources/version.yaml` (legacy mention only for transition) | Instructions aligned with current version source | Update docs to new source-of-truth path | No remaining mandatory guidance references to retired path |

## Proposed Phases

### Phase A: Version-source decoupling

- Introduce replacement version source path outside `bsctl/`.
- Update release candidate and docs/dependabot workflows to read new path.
- Keep old path temporarily mirrored only if required during transition.

### Phase B: Script-path migration

- Move workflow helper scripts out of `bsctl/scripts/workflows/`.
- Update all workflow call sites to the new script locations.
- Validate behavior parity in CI.

### Phase C: CodeQL decision and transition

- Confirm post-Go supported language set and required scanning coverage.
- Re-scope or remove `.github/workflows/codeql.yaml` accordingly.
- Document rationale and replacement security posture.

### Phase D: `bsctl/` retirement

- Remove remaining `bsctl/` tree once dependencies and references are eliminated.
- Clean docs/labels/skills references.
- Verify CI and release automation remain green.

## Acceptance Mapping to Issue #320

- Inventory and replacement map: covered by this document and follow-up updates.
- Version/docs-bump/dependabot decoupling: Phase A + Phase B.
- Go-specific CI and CodeQL retirement: Phase C.
- Full `bsctl/` removal with green CI: Phase D.

## Immediate Next Steps

1. Confirm the replacement version source file and ownership.
2. Draft implementation PR for Phase A (smallest possible change set).
3. Queue Phase B path migration after Phase A lands.
