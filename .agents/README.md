# Agents Instructions
Last updated: 2026-03-06

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
- Skills must reside under `.agents/skills/**/SKILL.md`.
- Additional instruction files should live under `.agents/` when needed.

## Skills index
- Version Bump: `.agents/skills/version-bump/SKILL.md`
- Update Changelog: `.agents/skills/update-changelog/SKILL.md`
- Manifest: `.agents/skills/manifest.md`

## Expectations for SKILL.md
- Include: name/purpose, when to use/trigger, required context/prerequisites, steps, and expected outputs.
- Keep links relative (e.g., `../other-skill/SKILL.md`) and avoid external dependencies unless noted in context.
