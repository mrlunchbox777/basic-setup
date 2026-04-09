# Shared-Scripts to bsctl Migration Overview

## Goal

Migrate bash scripts from `shared-scripts/` to Go-based `bsctl` CLI tool to improve:
- Maintainability and testability
- Cross-platform compatibility
- Type safety and error handling
- Performance
- Distribution (single binary vs. many bash scripts)

## Overall Stats

- **Total Scripts**: 133
- **By Complexity**:
  - Simple (≤50 lines): 44 scripts (33%)
  - Medium (51-100 lines): 8 scripts (6%)
  - Complex (>100 lines): 81 scripts (61%)

## Migration Strategy

### What to Migrate

**Can Migrate**: ~80-100 scripts (60-75%)
- High confidence: 48 scripts (aliases + simple utils)
- Medium confidence: 32 scripts (k8s, network, core)
- Low confidence: 20 scripts (complex operations)

**Should Keep as Bash**: ~33 scripts (25%)
- Environment installation scripts (system-level operations)
- Very complex domain-specific logic (>250 lines)
- Platform-specific operations (WSL, etc.)

### Migration Phases

1. **Phase 1: Quick Wins** (48 scripts, ~40%)
   - All 43 alias scripts
   - 5 simple general utilities
   - **Effort**: Low | **Impact**: High

2. **Phase 2: Core Functionality** (9 scripts, ~7%)
   - Complete basic-setup commands
   - String utilities
   - Git utilities
   - **Effort**: Medium | **Impact**: High

3. **Phase 3: Operations** (23 scripts, ~17%)
   - Network utilities
   - K8s utilities
   - **Effort**: Medium | **Impact**: Medium

4. **Phase 4: Advanced** (20 scripts, ~15%)
   - Docker operations
   - Big-Bang operations (optional)
   - **Effort**: High | **Impact**: Low-Medium

## Command Structure

Proposed `bsctl` command structure:

```
bsctl
├── basic-setup
│   ├── add-general-rc (✅ DONE)
│   ├── init
│   ├── list-scripts
│   ├── set-env
│   └── update
├── alias
│   ├── docker
│   ├── git
│   ├── k8s
│   └── general
├── util
│   ├── command-installed
│   ├── iso-date
│   ├── random
│   └── ...
├── string
│   ├── trim-whitespace
│   └── trim-end
├── network
│   ├── local-ip
│   ├── public-ip
│   ├── default-route
│   ├── mac-address
│   └── default-device
├── k8s (or kubectl)
│   ├── select-namespace
│   ├── select-context
│   ├── get-pod-shell
│   ├── forward-pod
│   └── ...
├── git
│   ├── submodule-update-all
│   ├── github-repo-versions
│   └── add-gitconfig
├── docker
│   ├── remove-containers
│   ├── clear
│   └── full-clear
└── bigbang (optional)
    └── ...
```

## Implementation Guidelines

### For Each Script Migration

1. **Analyze the bash script**
   - Understand what it does
   - Identify dependencies
   - Note any platform-specific behavior

2. **Create Go command structure**
   - Use Cobra for CLI framework (already in use)
   - Follow existing patterns in `bsctl/cmd/`
   - Add proper flag handling and validation

3. **Add comprehensive tests**
   - Unit tests for business logic
   - Integration tests where appropriate
   - Aim for 100% coverage on non-test code

4. **Update documentation**
   - Add command to help text
   - Update README if needed
   - Document any behavioral changes

5. **Maintain backward compatibility**
   - Keep original bash script until migration is verified
   - Consider creating symlinks or wrapper scripts
   - Document migration path for users

## Progress Tracking

### Completed (1 script)
- ✅ `basic-setup/add-general-rc.sh` → `bsctl basic-setup add-general-rc`

### In Progress (0 scripts)
- None currently

### Planned
- See individual phase documents for detailed lists

## Success Criteria

- All tests passing with 100% coverage (except test utilities)
- All CI/CD checks passing
- Documentation complete
- No regression in functionality
- Performance equal or better than bash versions

## Related Work

- Issue #180: Move more scripts to golang
- PR #191: Test infrastructure and workflows (✅ MERGED)

## Notes

- Not all scripts need to be migrated - keep complex system-level scripts in bash
- Prioritize high-impact, low-effort migrations first
- Group related scripts together in PRs for easier review
- Update CHANGELOG and version numbers with each migration PR
