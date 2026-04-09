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
| Docs bump workflow | `.github/workflows/docs-bump.yaml` invokes `scripts/workflows/docs-bump_*` | Enforces version/changelog divergence and date checks | Keep scripts in root-level workflow script location | Docs-bump checks pass using replacement scripts |
| Dependabot autobump | `.github/workflows/dependabot-autobump.yaml` invokes `scripts/workflows/dependabot-autobump_*` and stages `resources/version.yaml` (plus legacy constants during transition) | Automates patch bump + changelog update for dep PRs | Keep script paths and finalize legacy-version cleanup later | Dependabot autobump PR succeeds without `bsctl` references |
| Action validator and agents validate | Workflows call scripts in `scripts/workflows/*` | Existing script organization | Keep scripts in neutral location | Validation workflows remain green after path migration |
| Code scanning | `.github/workflows/codeql.yaml` scans Go | Security coverage for Go code under `bsctl/` | Replace Go-focused CodeQL with shell-focused/static checks (`shellcheck`, `shfmt -d`, `actionlint`/`action-validator`, optional targeted `semgrep`) before removing CodeQL | CodeQL retirement approved and replacement checks are green in CI |
| Label automation | `.github/labeler.yaml` maps `bsctl/**/*` to change labels | Surfacing path-based impact in PRs | Replace with new paths or retire mapping if no longer needed | Label behavior remains correct after path removals |
| Agent guidance and skills | `AGENTS.md`, `.agents/skills/*.md`, docs reference `resources/version.yaml` (legacy mention only for transition) | Instructions aligned with current version source | Update docs to new source-of-truth path | No remaining mandatory guidance references to retired path |

## Proposed Phases

### Phase A: Version-source decoupling

- Introduce replacement version source path outside `bsctl/`.
- Update release candidate and docs/dependabot workflows to read new path.
- Keep old path temporarily mirrored only if required during transition.

### Phase B: Script-path migration

- Workflow helper scripts are now in `scripts/workflows/`; keep call sites aligned.
- Update all workflow call sites to the new script locations.
- Validate behavior parity in CI.

### Phase C: CodeQL decision and transition

- Confirm post-Go supported language set and required scanning coverage.
- Introduce replacement static checks for current repo surface:
  - `shellcheck` for shell script correctness and safety.
  - `shfmt -d` for shell formatting enforcement.
  - `actionlint` (alongside existing `action-validator`) for workflow validation.
  - Optional: targeted `semgrep` rules for shell/workflow security patterns if signal-to-noise is acceptable.
- Re-scope or remove `.github/workflows/codeql.yaml` only after replacement checks are enforced in CI.
- Document rationale and replacement security posture.

Current status:

- Added `.github/workflows/static-checks.yaml` scaffolding for `shellcheck`, `shfmt -d`, and `actionlint`.

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

1. Validate `.github/workflows/static-checks.yaml` in CI and tune file targeting/exclusions for stable signal.
2. Reassess CodeQL scope and retire/re-scope `.github/workflows/codeql.yaml` once replacement checks are stable.
3. Update issue #320 acceptance checkboxes as Phase C milestones complete.
