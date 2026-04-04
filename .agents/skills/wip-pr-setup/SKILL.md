---
name: wip-pr-setup
description: Sets up a working branch/PR flow for in-progress changes (branch, remote, PR attempt, docs bump, and label sync) while optionally keeping local edits uncommitted.
---

# WIP PR Setup Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Standardize the setup flow for starting implementation work with branch management, PR linkage, docs bump validation, and issue/PR status label sync.

## When to use
- Starting a new tracked implementation issue.
- Preparing a branch and PR shell before final commits are ready.
- Moving issue/PR state to `status/doing` at work start.

## Prerequisites
- Tools: `git`, `gh` CLI authenticated.
- Target issue exists.
- Working tree state is known before branch creation.

## Inputs
- Target issue number(s) for linkage (for example `#307`, parent tracker).
- New branch name.
- PR title/body draft.
- Whether local edits should remain uncommitted/unpushed.
- Whether to create a minimal bootstrap commit (for example, whitespace-only `CHANGELOG.md`) when PR creation is blocked by zero diff.

## Required context
- Repository docs/version bump requirements (`bsctl/static/resources/constants.yaml`, `CHANGELOG.md`).
- Label conventions and sync rules from `sync-labels` skill.
- Whether GitHub can create a PR for the branch yet (must have commits ahead of base).

## Steps
1. Create local branch and push upstream tracking branch.
2. Attempt to create PR with `Relates #...` references.
3. If PR creation fails because no commits differ from base, either:
   - report the block and continue local work setup, or
   - if requested, create and push a minimal bootstrap commit (for example, whitespace-only `CHANGELOG.md`) to unblock PR creation.
4. Apply requested local edits without committing if specified.
5. Run docs bump validation and update version/changelog when required.
6. Reopen/annotate related issue when process continuity is needed.
7. Sync labels to `status/doing` for issue and PR (if PR exists); for issue-only state, update issue labels only.
8. Return a concise checklist of what was completed and what is pending (for example, PR creation blocked pending first commit).

## Safety Rules
- Do not commit/push local code edits when user requested local-only changes.
- If creating a bootstrap commit, keep it minimal/non-functional and clearly call out that it is a PR bootstrap commit.
- Do not auto-close related issues unless explicitly requested.
- Use `Relates #...` wording to avoid accidental issue closure.

## Outputs
- Branch created locally and remotely.
- PR created when possible, otherwise explicit reason it is not yet creatable.
- Local change set prepared and validated.
- Issue/PR labels synchronized to active work state.
