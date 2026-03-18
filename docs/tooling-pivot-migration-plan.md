# Tooling Pivot Migration Plan

This document defines the migration plan from `basic-setup` as a broad package-manager wrapper to a layered model based on:

- `chezmoi` for dotfiles and shared scripts
- `mise` for runtime/tool version management
- `devbox` for project-local reproducible environments (when needed)

Use this plan as the source of truth for issue triage, new issue creation, implementation order, and deprecation work.

## Execution Tracking

Active issue threads for this plan:

- Coordination (sister issue): `#285`
- WS1 Foundation: `#274`
- WS2 Classification: `#275`
- WS3 Pilot migration: `#276`
- WS4 Backlog execution: `#277`
- WS5 Deprecation: `#278`
- WS6 Cleanup: `#279`

Current implementation tracks created from this plan:

- Baseline shell/tooling profile: `#280`
- K8s/operator workstation profile: `#281`
- Optional media/comms profile: `#282`
- Replace package-manager/index abstraction policy: `#283`
- Windows/WSL interop track: `#284`

## Decision

We are pivoting from broad wrapper orchestration to a focused, composable stack.

- Keep Git as the backing store for scripts/configuration.
- Preserve useful existing scripts during migration.
- Stop expanding broad package-manager abstraction features.

## Goals And Non-Goals

### Goals

- Reduce maintenance burden while preserving useful workflows.
- Improve reproducibility and onboarding speed.
- Migrate high-value scripts into maintainable homes (dotfiles, `mise`, or `devbox`).
- Keep a clear and auditable migration trail in issues and PRs.

### Non-Goals

- Rebuilding a new general-purpose bootstrap framework.
- Supporting every platform/package manager equally from day one.
- Migrating every script immediately.

## Target Architecture

- **Dotfiles Repo (`chezmoi`)**
  - Shell config, editor config, aliases, user-level scripts, machine templates.
  - Shared scripts installed to a managed bin path (for example `~/.local/bin`).
- **Runtime Layer (`mise`)**
  - Language and tool versions (`go`, `node`, `python`, `kubectl`, etc.).
  - Global baseline in dotfiles, optional per-project overrides.
- **Project Layer (`devbox`)**
  - Project dependencies and reproducible shells where isolation is valuable.
  - Applied selectively, not mandatory for every repo.
- **Legacy Layer (`basic-setup`)**
  - Temporary migration glue and compatibility wrappers only.
  - Scope ratchets down over time.

## Workstreams

### WS1: Foundation

- Create or choose the canonical dotfiles repo and bootstrap entrypoint.
- Add `mise` baseline config in dotfiles.
- Define default bin path and script organization.
- Document install and rollback steps.

Exit criteria:

- New machine can install dotfiles and `mise` baseline successfully.
- Shared scripts execute from the managed bin path.

### WS2: Script Inventory And Classification

Classify scripts in `shared-scripts/` into:

- **Migrate to dotfiles**: user-level scripts/aliases/functions.
- **Convert to project-local (`devbox`)**: repo-specific workflows.
- **Keep temporarily in `basic-setup`**: critical compatibility scripts.
- **Retire**: unused/duplicative scripts.

Exit criteria:

- Every script has a classification issue linked to this plan.

### WS3: Pilot Migration

- Migrate 5-10 high-usage scripts first.
- Add smoke tests for migrated commands.
- Capture migration docs and known caveats.

Exit criteria:

- Pilot users can run migrated workflows end-to-end.
- No critical regressions for pilot scripts.

### WS4: Backlog Execution

- Migrate in batches by script category.
- Keep compatibility shims where practical.
- Close or supersede legacy issues as work lands.

Exit criteria:

- Priority scripts are migrated or intentionally retired.
- Open issues are aligned with the new architecture.

### WS5: Deprecation

- Freeze new broad-wrapper features.
- Announce deprecation timelines for legacy commands.
- Remove low-value compatibility code once replacements are stable.

Exit criteria:

- `basic-setup` has a clearly reduced scope and support statement.

### WS6: Post-Migration Cleanup

- Remove obsolete workflows, docs, and scripts that only supported the old broad-wrapper model.
- Remove stale issue templates, labels, and automation paths that no longer apply.
- Update contributor docs to reflect the steady-state architecture.
- Validate that references to removed legacy paths are gone from README/docs/workflows.

Exit criteria:

- Legacy-only workflows/docs/scripts are removed or archived with explicit rationale.
- Repository docs and automation reflect only the supported post-pivot model.

## Issue Management Plan

### Labels To Add

- `track/pivot-migration`
- `area/chezmoi`
- `area/mise`
- `area/devbox`
- `area/legacy-basic-setup`
- `status/pilot`
- `status/migrated`
- `status/deprecated`

### Triage Rules For Existing Issues

For each open issue, choose one action:

1. **Keep and retarget**
   - Still valuable under new model.
   - Add new labels and update acceptance criteria.
2. **Supersede**
   - Replace with a migration-tracked issue.
   - Link old issue to new issue, then close old issue.
3. **Close as out-of-scope**
   - Only relevant to broad wrapper expansion.
   - Close with rationale and pointer to this plan.

Rule of thumb:

- If it increases broad abstraction breadth, close/supersede.
- If it improves reproducibility or core daily workflows, keep/retarget.

### New Issue Template (Copy/Paste)

```markdown
## Context
Part of tooling pivot migration plan: docs/tooling-pivot-migration-plan.md

## Problem
<what hurts today>

## Target Layer
- [ ] chezmoi (dotfiles/scripts)
- [ ] mise (runtime/tool versions)
- [ ] devbox (project environment)
- [ ] legacy basic-setup compatibility shim

## Proposed Change
<implementation approach>

## Acceptance Criteria
- [ ] Behavior documented
- [ ] Automated or smoke-tested
- [ ] Backward-compatibility note added (or explicit break approved)
- [ ] Follow-up cleanup task created if shim is temporary

## Links
- Parent tracking issue: #<id>
- Related legacy issue(s): #<id>
```

### Epic/Tracking Issue Structure

Create one parent issue per workstream with:

- Objective
- Out-of-scope list
- Child issue checklist
- Exit criteria copied from this plan

## Execution Timeline (Suggested)

- **Weeks 1-2**: WS1 foundation + labels + tracking issues.
- **Weeks 3-4**: WS2 classification and triage of existing open issues.
- **Weeks 5-6**: WS3 pilot migration and stabilization.
- **Weeks 7+**: WS4 batch migration, then WS5 deprecation steps.
- **Final hardening window**: WS6 cleanup and repository simplification.

Adjust pace based on contributor bandwidth; do not skip triage and classification.

## Pull Request Requirements For Migration Work

- Link to parent tracking issue and relevant child issue.
- State target layer (`chezmoi`/`mise`/`devbox`/legacy shim).
- Include migration/rollback notes.
- Update docs when behavior changes.

## Completion Criteria For The Pivot

The pivot is complete when:

- High-value workflows no longer depend on broad wrapper abstraction.
- `basic-setup` scope is documented as migration glue or intentionally narrowed utility.
- New issues predominantly target `chezmoi`/`mise`/`devbox` layers.
- Legacy-only workflows/docs/automation from the broad-wrapper model are cleaned up.
