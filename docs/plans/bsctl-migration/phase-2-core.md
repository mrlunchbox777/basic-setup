# Phase 2: Core Functionality Migration

## Overview

Complete the migration of core `basic-setup` functionality and add utility commands for string and git operations.

## Stats

- **Total Scripts**: 9
- **Difficulty**: EASY to MEDIUM
- **Estimated Effort**: 1-2 weeks
- **Impact**: HIGH (core functionality)

## Categories

### Basic-Setup Commands (5 scripts)

#### ✅ Already Migrated
- `basic-setup/add-general-rc.sh` → `bsctl basic-setup add-general-rc`

#### 🔲 To Migrate

**`basic-setup/init.sh`** → `bsctl basic-setup init`
- **Lines**: ~150-200
- **Purpose**: Initialize basic-setup installation
- **Complexity**: MEDIUM
- **Dependencies**: File I/O, git operations, environment setup
- **Implementation Notes**:
  - Clone/update repository
  - Set up directory structure
  - Initialize submodules
  - Create necessary symlinks

**`basic-setup/list-scripts.sh`** → `bsctl basic-setup list`
- **Lines**: ~50-100
- **Purpose**: List all available scripts
- **Complexity**: EASY
- **Dependencies**: Directory traversal
- **Implementation Notes**:
  - Recursively find all .sh files
  - Categorize by directory
  - Format output nicely
  - Add filtering options

**`basic-setup/set-env.sh`** → `bsctl basic-setup set-env`
- **Lines**: ~100-150
- **Purpose**: Set environment variables for basic-setup
- **Complexity**: MEDIUM
- **Dependencies**: Environment variable management
- **Implementation Notes**:
  - Load from .env files
  - Export variables
  - Validate required variables
  - Handle defaults

**`basic-setup/update.sh`** → `bsctl basic-setup update`
- **Lines**: ~100-150
- **Purpose**: Update basic-setup to latest version
- **Complexity**: MEDIUM
- **Dependencies**: Git operations, version checking
- **Implementation Notes**:
  - Check current version
  - Pull latest changes
  - Update submodules
  - Run any migration scripts
  - Update bsctl binary

### String Utilities (2 scripts)

**`string/trim-whitespace.sh`** → `bsctl string trim`
- **Lines**: ~50-80
- **Purpose**: Trim whitespace from string
- **Complexity**: EASY
- **Dependencies**: String manipulation
- **Implementation Notes**:
  - Trim leading whitespace
  - Trim trailing whitespace
  - Option to trim both
  - Support for stdin/args

**`string/trim-end.sh`** → `bsctl string trim-end`
- **Lines**: ~50-80
- **Purpose**: Trim characters from end of string
- **Complexity**: EASY
- **Dependencies**: String manipulation
- **Implementation Notes**:
  - Specify characters to trim
  - Support stdin/args
  - Handle empty strings

### Git Utilities (3 scripts)

**`git/submodule-update-all.sh`** → `bsctl git submodule-update-all`
- **Lines**: ~100-150
- **Purpose**: Update all git submodules recursively
- **Complexity**: MEDIUM
- **Dependencies**: Git operations
- **Implementation Notes**:
  - Find all submodules
  - Update recursively
  - Handle errors gracefully
  - Show progress

**`git/github-repo-versions.sh`** → `bsctl git github-repo-versions`
- **Lines**: ~150-200
- **Purpose**: List versions/releases for GitHub repositories
- **Complexity**: MEDIUM
- **Dependencies**: GitHub API, HTTP requests
- **Implementation Notes**:
  - Use GitHub API
  - Parse repository URLs
  - List tags/releases
  - Format output

**`git/add-basic-setup-gitconfig.sh`** → `bsctl git add-gitconfig`
- **Lines**: ~100-150
- **Purpose**: Add basic-setup git configuration
- **Complexity**: EASY-MEDIUM
- **Dependencies**: Git config manipulation, file I/O
- **Implementation Notes**:
  - Read gitconfig template
  - Merge with existing config
  - Add includes to .gitconfig
  - Validate configuration

## Command Structure

```
bsctl
├── basic-setup
│   ├── add-general-rc (✅ DONE)
│   ├── init          (🔲 TODO)
│   ├── list          (🔲 TODO)
│   ├── set-env       (🔲 TODO)
│   └── update        (🔲 TODO)
├── string
│   ├── trim          (🔲 TODO)
│   └── trim-end      (🔲 TODO)
└── git
    ├── submodule-update-all  (🔲 TODO)
    ├── github-repo-versions  (🔲 TODO)
    └── add-gitconfig         (🔲 TODO)
```

## Implementation Priority

### High Priority (Core User Experience)
1. `bsctl basic-setup init` - Essential for new users
2. `bsctl basic-setup update` - Essential for existing users
3. `bsctl basic-setup list` - Discovery

### Medium Priority (Nice to Have)
4. `bsctl basic-setup set-env` - Environment management
5. `bsctl git add-gitconfig` - Setup helper

### Low Priority (Utilities)
6. `bsctl string trim` - Utility function
7. `bsctl string trim-end` - Utility function
8. `bsctl git submodule-update-all` - Maintenance
9. `bsctl git github-repo-versions` - Information

## Implementation Steps

### For Each Command

1. **Analyze bash script**
   ```bash
   # Review the original script
   cat shared-scripts/basic-setup/init.sh
   # Understand dependencies and edge cases
   ```

2. **Create Go command structure**
   ```bash
   # For basic-setup commands
   touch bsctl/cmd/basic_setup/init.go
   touch bsctl/cmd/basic_setup/init_test.go
   
   # For new command groups
   mkdir -p bsctl/cmd/string
   mkdir -p bsctl/cmd/git
   ```

3. **Implement business logic**
   - Break down into testable functions
   - Use appropriate Go libraries
   - Handle errors properly
   - Add progress indicators for long operations

4. **Add comprehensive tests**
   - Unit tests for all functions
   - Integration tests where needed
   - Mock external dependencies
   - Test error conditions

5. **Update documentation**
   - Add help text
   - Update README
   - Add examples

## Testing Strategy

### Unit Tests
- Test each function independently
- Mock file system operations
- Mock Git operations
- Mock HTTP requests
- Test error handling

### Integration Tests
- Test full command execution
- Test with real file system (in temp directory)
- Test actual Git operations (in temp repo)
- Verify output format

### Edge Cases
- Empty inputs
- Missing files
- Permission errors
- Network failures
- Invalid Git repositories

## Migration Considerations

### Breaking Changes
- Document any behavioral differences from bash versions
- Provide migration guide if needed
- Consider backward compatibility flags

### Performance
- Should be as fast or faster than bash
- Add benchmarks for critical operations
- Profile and optimize if needed

### Error Handling
- Provide clear error messages
- Suggest solutions when possible
- Return appropriate exit codes

## Example Implementation

```go
// bsctl/cmd/basic_setup/init.go
package basic_setup

import (
    "fmt"
    "github.com/spf13/cobra"
    "github.com/mrlunchbox777/basic-setup/bsctl/util"
)

var initCmd = &cobra.Command{
    Use:   "init",
    Short: "Initialize basic-setup installation",
    Long: `Initialize basic-setup by cloning the repository,
setting up the directory structure, and configuring the environment.`,
    Example: `  # Initialize in default location
  bsctl basic-setup init
  
  # Initialize in custom location
  bsctl basic-setup init --dir ~/my-basic-setup`,
    RunE: runInit,
}

func init() {
    initCmd.Flags().StringP("dir", "d", "", "Installation directory")
    initCmd.Flags().BoolP("force", "f", false, "Force reinstall")
}

func runInit(cmd *cobra.Command, args []string) error {
    dir, _ := cmd.Flags().GetString("dir")
    force, _ := cmd.Flags().GetBool("force")
    
    // Implementation here
    return util.InitializeBasicSetup(dir, force)
}
```

## Deliverables

### Phase 2A: Basic-Setup Core (Priority 1)
- [ ] `bsctl basic-setup init`
- [ ] `bsctl basic-setup update`
- [ ] `bsctl basic-setup list`
- [ ] Comprehensive tests
- [ ] Documentation

### Phase 2B: Basic-Setup Utilities (Priority 2)
- [ ] `bsctl basic-setup set-env`
- [ ] `bsctl git add-gitconfig`
- [ ] Tests and documentation

### Phase 2C: String & Git Utilities (Priority 3)
- [ ] `bsctl string trim`
- [ ] `bsctl string trim-end`
- [ ] `bsctl git submodule-update-all`
- [ ] `bsctl git github-repo-versions`
- [ ] Tests and documentation

## Estimated Timeline

### Phase 2A (1 week)
- Design: 1 day
- Implementation: 3 days
- Testing: 2 days
- Documentation: 1 day

### Phase 2B (3-4 days)
- Implementation: 2 days
- Testing: 1 day
- Documentation: 0.5 days

### Phase 2C (3-4 days)
- Implementation: 2 days
- Testing: 1 day
- Documentation: 0.5 days

**Total: 2-3 weeks**

## Related Issues

- Create issue: "Phase 2A: Migrate core basic-setup commands"
- Create issue: "Phase 2B: Migrate basic-setup utilities"
- Create issue: "Phase 2C: Migrate string and git utilities"
