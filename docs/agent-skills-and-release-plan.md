# Agent Skills And Release Pipeline Plan

This document proposes two focused workstreams before continuing broader pivot execution:

1. Expand baseline agent skills for issue/PR operations.
2. Add a basic release pipeline that creates a tag and GitHub release.

## Workstream A: Agent Skills Expansion

### Parent Tracker

- Issue: #295 (`feature: track agent skills baseline expansion`)
- Goal: Establish practical, reusable skills for day-to-day repository operations.

### Scope

- Add foundational operational skills (issue management, review response, PR hygiene, triage).
- Add documentation for when to use each skill and expected outputs.
- Ensure guardrails for potentially destructive actions (for example, closing issues).

### Child Issues

#### 1) #297 `skill: manage-issues workflow`

Acceptance criteria:

- Can create, update, close, and reopen issues with rationale.
- Supports labels, assignees, milestones, and issue links.
- Includes safe behavior notes for closing/reopening.

#### 2) #298 `skill: review-response workflow`

Acceptance criteria:

- Pulls review threads and summarizes actionable feedback.
- Classifies comments as actionable, non-actionable, or clarification needed.
- Applies updates and posts structured response comments with file references.

#### 3) #299 `skill: PR hygiene assistant`

Acceptance criteria:

- Checks semantic title, labels, checklist completion, and required docs/version updates.
- Produces a concise ready-to-merge status summary.

#### 4) #300 `skill: issue triage and retargeting`

Acceptance criteria:

- Applies label-based triage actions.
- Supports supersede/retarget/close templates.
- Normalizes issue references in docs where navigation is important.

#### 5) #302 `docs: skills usage guide`

Acceptance criteria:

- Documents each new skill with when-to-use and when-not-to-use guidance.
- Includes at least one example invocation per skill.

### Optional Follow-Ons (Included)

- #303 `skill: ws-status-sync` (sync tracker issue status from docs).
- #301 `skill: release-notes-draft` (summarize merged changes since last tag).

## Workstream B: Basic Release Pipeline

### Parent Tracker

- Issue: #296 (`feature: track basic release pipeline`)
- Goal: Manual, predictable release flow that creates a tag and GitHub release.

### Scope

- Add a `workflow_dispatch` release workflow.
- Validate version/changelog consistency before tag/release.
- Create annotated tag and GitHub release notes from changelog entry.

### Child Issues

#### 1) #307 `workflow: release-dispatch scaffold`

Acceptance criteria:

- Adds `.github/workflows/release.yml` with `workflow_dispatch`.
- Inputs include `version`, `prerelease`, and optional `target_commitish`.

#### 2) #305 `release validation step`

Acceptance criteria:

- Validates semantic version format.
- Validates `bsctl/static/resources/constants.yaml` version matches workflow input.
- Validates top `CHANGELOG.md` entry matches workflow input.

#### 3) #304 `tag creation + push`

Acceptance criteria:

- Creates annotated tag `vX.Y.Z`.
- Fails with clear message when tag already exists.

#### 4) #306 `GitHub release creation`

Acceptance criteria:

- Creates release using `gh release create` or API.
- Uses matching changelog section body for release notes.
- Supports prerelease toggle.
- Fails release creation when changelog parsing fails.

#### 5) #308 `docs: release runbook`

Acceptance criteria:

- Documents prerequisites, dispatch inputs, and expected outcomes.
- Includes failure handling and rollback notes for mistaken tags/releases.

### Optional Hardening (Included)

- #310 require all required checks on `main` before release.
- #309 attach build artifacts.
- #311 improve strict changelog parsing diagnostics while preserving hard-fail behavior.

## Issue Creation Sequence

1. Parent trackers created: #295 and #296.
2. Child issues created and linked in issue bodies to their parent tracker.
3. Labels applied using repository issue templates (`kind/feature`, `kind/chore`, + `status/triage`).
4. Execute in this order:
   - Agent skills: manage-issues -> review-response -> PR hygiene -> triage -> docs.
   - Release pipeline: scaffold -> validation -> tag/release -> runbook.

## Suggested Labels

- `track/agents`
- `track/release`
- `changes/workflow`
- `changes/documentation`
- `kind/feature`

## Recommended First Sprint

1. `skill: manage-issues`
2. `skill: review-response workflow`
3. `workflow: release-dispatch scaffold`
4. `docs: release runbook`
