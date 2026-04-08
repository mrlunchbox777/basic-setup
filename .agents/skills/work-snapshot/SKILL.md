---
name: work-snapshot
description: Updates a compact local handoff snapshot of current branch/PR/work state in a git-ignored file for fast session resume.
---

# Work Snapshot Skill

## Owner/Contact
- Repo maintainers (e.g., @mrlunchbox777).

## Purpose
Keep a small, durable, local-only handoff note so work can resume quickly without relying on full chat history.

## When to use
- At the start of a working session (refresh current state).
- After major milestones (conflict resolution, docs bump, checks rerun, review updates).
- Before ending a session.

## Prerequisites
- `git` is available.
- Optional: `gh` authenticated to include PR state fields.

## Inputs
- Optional one-line context via `--context "..."`.
- Optional one-line goal via `--goal "..."`.

## Required context
- Snapshot file path: `.agents/work-snapshot.local.md` (git ignored).
- Updater script: `.agents/scripts/update-work-snapshot.sh`.

## Steps
1. Run `.agents/scripts/update-work-snapshot.sh` to refresh managed fields.
2. If needed, pass one-line updates:
   - `.agents/scripts/update-work-snapshot.sh --context "..."`
   - `.agents/scripts/update-work-snapshot.sh --goal "..."`
3. Add or refine short bullets under `## Manual Notes` for done/current_state/next.
4. Keep notes concise and action-oriented (no long transcripts).

## Safety Rules
- Do not store secrets/tokens/credentials in the snapshot.
- Keep this file local-only; it is intentionally git ignored.
- Keep context to one line unless detail is strictly needed for handoff.

## Outputs
- Updated `.agents/work-snapshot.local.md` with fresh branch/issue/PR/status metadata and timestamp.
- Short manual notes suitable for quick resume.
