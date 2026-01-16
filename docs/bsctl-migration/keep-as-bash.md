# Scripts to Keep as Bash

## Overview

These scripts should remain as bash due to complexity, system-level operations, or platform-specific requirements. They are working well in their current form and migration would provide minimal benefit.

## Stats

- **Total Scripts**: ~33 (25% of all scripts)
- **Reason**: Complex, system-level, or platform-specific

## Categories

### Environment Installation Scripts (16 scripts)

These scripts perform system-level installations and modifications. They work well as bash and migrating would be risky and provide minimal benefit.

**`environment/curl-commands/go.sh`**
- **Lines**: ~200-300
- **Reason**: Downloads and installs Go, system-level operations
- **Risk**: High - modifies PATH, environment variables

**`environment/curl-commands/yq.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs yq
- **Risk**: Medium - binary installation

**`environment/curl-commands/awscli.sh`**
- **Lines**: ~200-250
- **Reason**: AWS CLI installation, complex dependencies
- **Risk**: High - system-level package management

**`environment/curl-commands/k9s.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs k9s
- **Risk**: Medium - binary installation

**`environment/curl-commands/helm.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs Helm
- **Risk**: Medium - binary installation

**`environment/curl-commands/kubectl.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs kubectl
- **Risk**: Medium - binary installation

**`environment/curl-commands/ohmyzsh.sh`**
- **Lines**: ~200-250
- **Reason**: Installs oh-my-zsh, modifies shell config
- **Risk**: High - shell configuration changes

**`environment/curl-commands/kpt.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs kpt
- **Risk**: Medium - binary installation

**`environment/curl-commands/tldr.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs tldr
- **Risk**: Medium - binary installation

**`environment/curl-commands/terraform.sh`**
- **Lines**: ~200-250
- **Reason**: Downloads and installs Terraform
- **Risk**: Medium-High - binary installation, version management

**`environment/curl-commands/nvm.sh`**
- **Lines**: ~200-250
- **Reason**: Installs Node Version Manager
- **Risk**: High - shell configuration, environment management

**`environment/curl-commands/code.sh`**
- **Lines**: ~200-250
- **Reason**: Installs VS Code
- **Risk**: High - application installation

**`environment/curl-commands/k3d.sh`**
- **Lines**: ~150-200
- **Reason**: Downloads and installs k3d
- **Risk**: Medium - binary installation

**`environment/validation.sh`**
- **Lines**: ~250-300
- **Reason**: Complex environment validation, many dependencies
- **Risk**: Medium - checks system state

**`environment/arch-type.sh`**
- **Lines**: ~100-150
- **Reason**: Detects architecture type
- **Note**: Could migrate but low priority

**`environment/os-type.sh`**
- **Lines**: ~100-150
- **Reason**: Detects OS type
- **Note**: Could migrate but low priority

### Platform-Specific Scripts (2 scripts)

**`wsl/is-on-wsl.sh`**
- **Lines**: ~100-150
- **Reason**: WSL-specific detection
- **Note**: Platform-specific, niche use case

**`wsl/copy-kube-dir-to-windows.sh`**
- **Lines**: ~150-200
- **Reason**: WSL-Windows interop, complex path handling
- **Risk**: Medium - cross-platform file operations

### Package Management (1 script)

**`package-management/upgrade-all.sh`**
- **Lines**: ~200-250
- **Reason**: Multiple package managers (apt, brew, yum, etc.)
- **Risk**: High - system-level package operations
- **Note**: Very platform-specific

### Complex General Utilities (3 scripts)

**`general/identify-shell-function.sh`**
- **Lines**: ~15
- **Reason**: Simple, works well
- **Note**: Could migrate but very low priority

**`general/how.sh`**
- **Lines**: ~150-200
- **Reason**: Complex script introspection
- **Note**: Interacts with bash internals

**`general/how-function.sh`**
- **Lines**: ~150-200
- **Reason**: Bash function introspection
- **Note**: Bash-specific functionality

### Cheatsheet (1 script)

**`cheatsheet/run.sh`**
- **Lines**: ~300-400
- **Reason**: Complex interactive cheatsheet system
- **Note**: Works well as bash, low priority to migrate

### Very Complex Scripts (5-10 scripts)

Scripts over 300 lines that involve:
- Complex orchestration
- Multiple tool interactions
- Platform-specific operations
- Significant bash-specific features

Examples:
- Complex Big-Bang setup scripts
- Multi-step environment configurations
- Advanced debugging utilities

## Why Keep These as Bash?

### 1. System-Level Operations
- Installing binaries system-wide
- Modifying system PATH and environment
- Managing package managers
- Requires root/sudo access
- Platform-specific package management

**Risk of Migration**: Breaking system installations

### 2. Shell Configuration
- Modifying .bashrc, .zshrc, etc.
- Setting up shell environments
- Interactive shell features

**Risk of Migration**: Breaking user shell setups

### 3. Complex Dependencies
- Orchestrating multiple tools
- Handling various OS/distro differences
- Fallback mechanisms for missing tools

**Effort**: Very high, minimal benefit

### 4. Platform-Specific Code
- WSL-specific operations
- Mac-specific operations
- Linux distro-specific operations

**Effort**: Would need extensive platform testing

### 5. Working Well Already
- Scripts are stable
- Users are familiar with them
- Low bug rate
- Good documentation

**Benefit**: Minimal gain from migration

## Alternative Approach: Improve Bash Scripts

Instead of migrating, consider improving these scripts:

### 1. Better Error Handling
```bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures
trap cleanup EXIT  # Cleanup on exit
```

### 2. Better Documentation
- Add more comments
- Improve help messages
- Document prerequisites
- Add examples

### 3. Better Testing
- Add shellcheck
- Create test suite
- Test on multiple platforms

### 4. Better Structure
- Extract common functions
- Reduce code duplication
- Improve readability

### 5. Wrapper from bsctl (Optional)
```go
// Allow running bash scripts through bsctl for consistency
bsctl env install go
bsctl env install kubectl
// etc.
```

This gives users a consistent interface without rewriting everything.

## Hybrid Approach

For some scripts, consider a hybrid approach:

### Example: kubectl Installation
```go
// bsctl/cmd/env/install_kubectl.go
func installKubectl() error {
    // Use Go for:
    // - Detecting OS/arch
    // - Downloading binary
    // - Verifying checksum
    
    // Keep in bash:
    // - System-level installation
    // - PATH modification
    // - Package manager integration (if needed)
    
    // Call bash script for final steps
    return executeBashScript("environment/curl-commands/kubectl.sh")
}
```

This approach:
- Uses Go for safe operations (download, verify)
- Uses bash for risky operations (system modification)
- Provides better error handling
- Maintains proven bash code for system changes

## Recommendations

### Keep as Pure Bash
1. All `environment/curl-commands/*.sh` scripts
2. `package-management/upgrade-all.sh`
3. Complex shell configuration scripts
4. Platform-specific scripts (WSL)
5. Very complex orchestration scripts (>300 lines)

### Improve Instead of Migrate
1. Add shellcheck to CI
2. Add better error handling
3. Improve documentation
4. Add tests where possible
5. Standardize script structure

### Optional: Create Wrappers
```go
bsctl env install <tool>
bsctl env validate
bsctl package upgrade-all
```

These wrappers can:
- Provide unified interface
- Add progress indicators
- Improve error messages
- Keep proven bash code

## Summary

**~33 scripts (25%)** should remain as bash because:

1. **System-level operations** - Risky to migrate
2. **Platform-specific** - High maintenance burden
3. **Working well** - Low benefit from migration
4. **Complex orchestration** - High effort, minimal gain

**Better approach**: Improve the bash scripts themselves rather than migrating them.

## Related Documentation

- See [migration-overview.md](./migration-overview.md) for full migration strategy
- See individual phase documents for scripts that should be migrated
