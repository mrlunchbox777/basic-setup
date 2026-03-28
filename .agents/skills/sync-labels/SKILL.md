---
name: sync-labels
description: Synchronizes issue and PR labels (kind, priority, status, changes) using repo rules and observes CI-managed size labels; use when triaging, implementing, or preparing review.
---

# Sync Labels Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Keep issue and PR labels aligned with repository conventions and current workflow state.

## When to use
- After creating a new issue or PR.
- After meaningful scope changes (new files, refactor, added bug fix/security work).
- Before requesting review and before merge.

## Prerequisites
- Tools: `gh` CLI authenticated for issues and pull requests.
- Label families exist in the repository (`kind/*`, `priority/*`, `status/*`, `changes/*`, `size/*`).

## Inputs
- Target issue number, PR number, or linked issue+PR pair.
- Optional explicit status intent (`status/triage`, `status/doing`, `status/review`) when user is intentionally transitioning state.
- Optional priority override signal only when user explicitly declares security/CVE urgency.

## Required context
- Semantic type definitions from `.github/semantic.yml`.
- File-to-label mapping rules from `.github/labeler.yaml`.
- Current labels and `updatedAt` values for target issue/PR to resolve status precedence.

## Managed Label Families
- `kind/*`
- `priority/*`
- `status/*`
- `changes/*`
- `size/*` (PR only; do not set manually before CI applies it)

## Source Rules

### 1) Changes labels
- If there is a linked PR: derive `changes/*` from files actually changed in the PR.
- If there is no PR yet: derive `changes/*` from files intended by the issue scope/body.
- Follow repository mapping in `.github/labeler.yaml`.

### 2) Kind labels
- PR kind is derived from semantic definitions in `.github/semantic.yml` types:
  - `feature` -> `kind/feature`
  - `bug` -> `kind/bug`
  - `chore` -> `kind/chore`
  - `documentation` -> `kind/chore`
  - `attribution` -> `kind/attribution`
- Issue kind is valid if it is one of:
  - `kind/feature`, `kind/bug`, `kind/chore`, `kind/support`, `kind/attribution`
- `kind/support` is issue-template-only and has no direct semantic PR type equivalent.
- If issue and PR kind differ, stop and raise to user for manual resolution.
- Never auto-convert `kind/support` to another kind.

### 3) Priority labels
- Apply based on impact importance:
  - CVE/security vulnerability work -> `priority/1`
  - Bug fix work -> `priority/2`
  - Feature work -> `priority/3`
  - Chore/documentation/support maintenance -> `priority/4`
  - Nice-to-have cleanup/refactor-only -> `priority/5`
- If both issue and PR exist, use highest priority implied by either scope.

### 4) Size labels
- Size labels are controlled by PR CI via the `size-label` job in `.github/workflows/labeler.yaml`.
- Never add or override `size/*` before CI has run.
- For issue sync, do not copy `size/*` from PR to issue.

### 5) Status labels
- New issue starts as `status/triage`.
- Active implementation is `status/doing`.
- Ready for review is `status/review`.
- When both issue and PR exist and statuses differ, use the most recently updated artifact as source-of-truth and sync the other.

### 6) Conflict examples
- Example conflict: issue `kind/support` + PR semantic `feature` -> stop and ask user which kind/workflow should be canonical.

## Steps
1. Identify target artifact(s): issue only, PR only, or linked issue+PR.
2. Collect current labels on both artifacts.
3. Determine managed labels from rules above.
4. Remove stale labels within managed families (except PR `size/*` not set by this skill).
5. Apply computed labels to issue and PR (respecting family-specific rules).
6. If kind mismatch or ambiguous priority/status is detected, stop and ask user to resolve.
7. Post a short sync comment summarizing what changed and why.

## Safety Rules
- Do not modify non-managed labels.
- Do not guess kind when semantic signal is conflicting; escalate to user.
- Do not set PR `size/*` labels manually.

## Outputs
- Issue/PR labels synchronized across managed families.
- Short summary including:
  - labels added
  - labels removed
  - unresolved conflicts requiring user decision
