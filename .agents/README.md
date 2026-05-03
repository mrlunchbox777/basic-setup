# Agents Instructions
Last updated: 2026-05-03

## Scope
- Source of truth for agent guidance and skill locations in this repository.
- Applies to all agent runners consuming Project Agent-compatible instructions.

## Instruction locations
- Root entrypoint: `AGENTS.md`.
- Skills: `.agents/skills/<name>/SKILL.md` (Project Agent format).
- This file: `.agents/README.md` (canonical `.agents` entry).
- Pointer: `.agents/instructions.md` → this file.
- Only these paths are valid for agent instructions/skills; do not place instruction files elsewhere.

## Allowed tools and surfaces
- Follow repository standards in `AGENTS.md` (Go, Bash, testing, documentation, versioning, linting).
- Skills must reside under `.agents/skills/<name>/SKILL.md`.
- Additional instruction files should live under `.agents/` when needed.

## Response framing
- Follow the response option framing in `AGENTS.md`.
- When presenting a minimal implementation path, also offer to provide `recommended` and `full` options with clear scope and tradeoffs.

## Docs bump cadence
- If the current branch already includes a docs bump/version entry, rerun docs-bump checks after each meaningful change to avoid missing version/changelog drift.

## Work snapshot guidance
- Local handoff file: `.agents/work-snapshot.local.md`.
- Read it at session start when present to recover intent/next steps.
- Treat `updated_at` as advisory; validate with current git/PR state before acting.
- Prefer git/GitHub state as source-of-truth, and use snapshot mostly for context.
- Refresh it after major milestones and before ending a session.

## Skills index
- Version Bump: `.agents/skills/version-bump/SKILL.md`
- Update Changelog: `.agents/skills/update-changelog/SKILL.md`
- Sync Labels: `.agents/skills/sync-labels/SKILL.md`
- WIP PR Setup: `.agents/skills/wip-pr-setup/SKILL.md`
- Work Snapshot: `.agents/skills/work-snapshot/SKILL.md`
- Manifest: `.agents/skills/manifest.md`

## Expectations for SKILL.md
- Include: name/purpose, when to use/trigger, required context/prerequisites, steps, and expected outputs.
- Keep links relative (e.g., `../other-skill/SKILL.md`) and avoid external dependencies unless noted in context.
- Add YAML frontmatter per agent skills spec with `name` (matching directory) and `description` (what the skill does and when to use it).
