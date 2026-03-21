# Tooling Pivot Script Inventory

This document is the WS2 inventory and classification source for `shared-scripts/`.

Related issues:

- WS2 parent: `#275`
- WS2 rubric/template child: `#287`
- WS2 batch children: `#288`, `#289`, `#290`, `#291`
- Coordination: `#285`

## Classification Rubric

Each script is classified into one target:

- `chezmoi`: user-level scripts, aliases, and local shell workflows that belong in dotfiles.
- `devbox`: project-scoped workflows that should be reproducible per repo.
- `legacy-shim`: keep temporarily in `basic-setup` for compatibility during migration.
- `retire`: remove after confirming low/no value or redundant behavior.

## Mapping Rules

- If script is primarily personal shell UX and machine setup, prefer `chezmoi`.
- If script is tightly coupled to a single project environment, prefer `devbox`.
- If script is still required for active migration/pilot workflows, use `legacy-shim` with a planned replacement.
- If script duplicates platform-native tooling or is unused, mark `retire` with rationale.

## Inventory Table Template

Use one row per script.

| Script path | Group | Current purpose | Proposed target | Priority | Owner | Replacement issue | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `shared-scripts/example.sh` | `general` | one-line purpose | `chezmoi` | `high` | `@owner` | `#000` | migration/deprecation notes |

## Batch Coverage

| Batch issue | Scope |
| --- | --- |
| `#288` | `alias`, `basic-setup`, `cheatsheet`, `general`, `string` |
| `#289` | `k8s`, `network`, `docker`, `wsl` |
| `#290` | `environment`, `package-management`, `git`, `bin` |
| `#291` | `big-bang` |
