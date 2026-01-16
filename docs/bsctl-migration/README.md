# bsctl Migration Documentation

This directory contains documentation for migrating bash scripts from `shared-scripts/` to Go-based `bsctl` commands.

## Documents

- **[migration-overview.md](./migration-overview.md)** - High-level overview of the migration strategy and progress
- **[phase-1-aliases.md](./phase-1-aliases.md)** - Phase 1: Alias scripts migration (43 scripts)
- **[phase-2-core.md](./phase-2-core.md)** - Phase 2: Core functionality migration (9 scripts)
- **[phase-3-operations.md](./phase-3-operations.md)** - Phase 3: Operational utilities migration (23 scripts)
- **[phase-4-advanced.md](./phase-4-advanced.md)** - Phase 4: Advanced/complex scripts (20 scripts)
- **[keep-as-bash.md](./keep-as-bash.md)** - Scripts that should remain as bash

## Quick Stats

- **Total Scripts**: 133
- **Can Migrate**: ~80-100 scripts (60-75%)
- **Already Migrated**: 1 script
- **Should Keep as Bash**: ~33 scripts (25%)

## Related Issues

- Issue #180: Move more scripts to golang
- PR #191: Initial migration work (test infrastructure and workflows)

## Getting Started

1. Read the [migration-overview.md](./migration-overview.md) for context
2. Choose a phase to work on
3. Follow the implementation guidelines in each phase document
4. Create issues/PRs for individual migrations or groups of related scripts
