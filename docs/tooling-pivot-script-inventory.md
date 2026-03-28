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

## Batch Classification Results

### Batch `#288` Results

| Coverage pattern | File count | Proposed target | Priority | Owner | Replacement issue | Notes |
| --- | ---: | --- | --- | --- | --- | --- |
| `shared-scripts/alias/**/*.sh` | 43 | `chezmoi` | high | `@mrlunchbox777` | `#280` | User-level aliases move to dotfiles-managed shell layer |
| `shared-scripts/basic-setup/*.sh` | 5 | `legacy-shim` | high | `@mrlunchbox777` | `#280` | Keep during migration; deprecate once bootstrap path is replaced |
| `shared-scripts/cheatsheet/*.sh` | 1 | `chezmoi` | medium | `@mrlunchbox777` | `#280` | User command/help surface belongs with dotfiles UX |
| `shared-scripts/general/*.sh` | 19 | `chezmoi` | medium | `@mrlunchbox777` | `#280` | General shell utilities move to dotfiles layer |
| `shared-scripts/general/command-installed.sh` | 1 | `legacy-shim` | high | `@mrlunchbox777` | `#160` | Explicit temporary compatibility utility |
| `shared-scripts/general/get-basic-setup-dir.sh` | 1 | `legacy-shim` | high | `@mrlunchbox777` | `#277` | Tied to legacy repo layout |
| `shared-scripts/general/get-shared-scripts-dir.sh` | 1 | `legacy-shim` | high | `@mrlunchbox777` | `#277` | Tied to legacy repo layout |
| `shared-scripts/string/*.sh` | 2 | `legacy-shim` | medium | `@mrlunchbox777` | `#122` | Keep while positional/compatibility updates are in progress |

Status: `#288` complete.

### Batch `#289` Results

| Coverage pattern | File count | Proposed target | Priority | Owner | Replacement issue | Notes |
| --- | ---: | --- | --- | --- | --- | --- |
| `shared-scripts/k8s/*.sh` | 18 | `legacy-shim` | high | `@mrlunchbox777` | `#281` | Active migration/pilot area; keep temporarily with deprecation path |
| `shared-scripts/network/*.sh` | 5 | `chezmoi` | medium | `@mrlunchbox777` | `#280` | Host/user network helpers fit dotfiles layer |
| `shared-scripts/docker/*.sh` | 3 | `chezmoi` | medium | `@mrlunchbox777` | `#280` | Local developer maintenance scripts |
| `shared-scripts/wsl/*.sh` | 2 | `legacy-shim` | high | `@mrlunchbox777` | `#284` | WSL/Windows interop migration track |

Status: `#289` complete.

### Batch `#290` Results

| Coverage pattern | File count | Proposed target | Priority | Owner | Replacement issue | Notes |
| --- | ---: | --- | --- | --- | --- | --- |
| `shared-scripts/environment/validation.sh` | 1 | `legacy-shim` | high | `@mrlunchbox777` | `#283` | Current install validation path remains during transition |
| `shared-scripts/environment/os-type.sh` | 1 | `chezmoi` | medium | `@mrlunchbox777` | `#280` | Generic host helper for local scripts |
| `shared-scripts/environment/arch-type.sh` | 1 | `chezmoi` | medium | `@mrlunchbox777` | `#280` | Generic host helper for local scripts |
| `shared-scripts/environment/curl-commands/*.sh` | 13 | `retire` | medium | `@mrlunchbox777` | `#283` | Replace broad curl-install model with policy in mise/devbox/chezmoi |
| `shared-scripts/package-management/*.sh` | 1 | `retire` | high | `@mrlunchbox777` | `#283` | Broad package-manager abstraction is out of target model |
| `shared-scripts/git/*.sh` | 3 | `chezmoi` | low | `@mrlunchbox777` | `#280` | User-level git helpers/config bootstrap |
| `shared-scripts/bin/*` | 89 | `legacy-shim` | medium | `@mrlunchbox777` | `#279` | Wrapper command entrypoints retained for compatibility during migration; remove/replace in WS6 cleanup |

Status: `#290` complete.

### Batch `#291` Results

| Coverage pattern | File count | Proposed target | Priority | Owner | Replacement issue | Notes |
| --- | ---: | --- | --- | --- | --- | --- |
| `shared-scripts/big-bang/*.sh` | 15 | `legacy-shim` | medium | `@mrlunchbox777` | `#294` | Domain-specific operational scripts; keep as shim until explicit migration/retirement under dedicated tracker |
| `shared-scripts/big-bang/bin/.gitkeep` | 1 | `retire` | low | `@mrlunchbox777` | `#279` | Remove with final cleanup if no longer needed |

Status: `#291` complete.

## Coverage Verification

Verification snapshot used for WS2 execution:

- Batch `#288`: 70 files classified
- Batch `#289`: 28 files classified
- Batch `#290`: 20 path entries covered (16 files + `bin` wrapper inventory)
- Batch `#291`: 16 files classified
