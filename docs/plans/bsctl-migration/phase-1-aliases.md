# Phase 1: Alias Scripts Migration

## Overview

Migrate the 43 alias scripts from `shared-scripts/alias/` to `bsctl` commands. These are the easiest wins - mostly 1-line wrappers around existing commands.

## Stats

- **Total Scripts**: 43
- **Difficulty**: EASY
- **Estimated Effort**: 1-2 weeks
- **Impact**: HIGH (removes 33% of scripts)

## Categories

### Docker Aliases (2 scripts)
- `alias/docker/dk.sh` → `bsctl alias docker dk` or embed in docker commands
- `alias/docker/dkc.sh` → `bsctl alias docker dkc`

### General Aliases (7 scripts)
- `alias/general/ll.sh` → `bsctl alias general ll`
- `alias/general/grepr.sh` → `bsctl alias general grepr`
- `alias/general/tg.sh` → `bsctl alias general tg`
- `alias/general/tf.sh` → `bsctl alias general tf`
- `alias/general/bsc.sh` → `bsctl alias general bsc`
- `alias/general/guid.sh` → `bsctl alias general guid`

### Kubernetes Aliases (33 scripts)

#### K8s Config (6 scripts)
- `alias/k8s/config/kc.sh` → `bsctl alias k8s config kc`
- `alias/k8s/config/kcc.sh` → `bsctl alias k8s config kcc`
- `alias/k8s/config/kcv.sh` → `bsctl alias k8s config kcv`
- `alias/k8s/config/kcuc.sh` → `bsctl alias k8s config kcuc`
- `alias/k8s/config/kcsc.sh` → `bsctl alias k8s config kcsc`
- `alias/k8s/config/kcgc.sh` → `bsctl alias k8s config kcgc`

#### K8s Get (10 scripts)
- `alias/k8s/get/kg.sh` → `bsctl alias k8s get kg`
- `alias/k8s/get/kga.sh` → `bsctl alias k8s get kga`
- `alias/k8s/get/kgc.sh` → `bsctl alias k8s get kgc`
- `alias/k8s/get/kgd.sh` → `bsctl alias k8s get kgd`
- `alias/k8s/get/kgds.sh` → `bsctl alias k8s get kgds`
- `alias/k8s/get/kgj.sh` → `bsctl alias k8s get kgj`
- `alias/k8s/get/kgn.sh` → `bsctl alias k8s get kgn`
- `alias/k8s/get/kgns.sh` → `bsctl alias k8s get kgns`
- `alias/k8s/get/kgp.sh` → `bsctl alias k8s get kgp`
- `alias/k8s/get/kgr.sh` → `bsctl alias k8s get kgr`
- `alias/k8s/get/kgs.sh` → `bsctl alias k8s get kgs`

#### K8s Describe (10 scripts)
- `alias/k8s/describe/kd.sh` → `bsctl alias k8s describe kd`
- `alias/k8s/describe/kdc.sh` → `bsctl alias k8s describe kdc`
- `alias/k8s/describe/kdd.sh` → `bsctl alias k8s describe kdd`
- `alias/k8s/describe/kdds.sh` → `bsctl alias k8s describe kdds`
- `alias/k8s/describe/kdj.sh` → `bsctl alias k8s describe kdj`
- `alias/k8s/describe/kdn.sh` → `bsctl alias k8s describe kdn`
- `alias/k8s/describe/kdns.sh` → `bsctl alias k8s describe kdns`
- `alias/k8s/describe/kdp.sh` → `bsctl alias k8s describe kdp`
- `alias/k8s/describe/kdr.sh` → `bsctl alias k8s describe kdr`
- `alias/k8s/describe/kds.sh` → `bsctl alias k8s describe kds`

#### K8s Misc (6 scripts)
- `alias/k8s/misc/ka.sh` → `bsctl alias k8s misc ka`
- `alias/k8s/misc/ke.sh` → `bsctl alias k8s misc ke`
- `alias/k8s/misc/kl.sh` → `bsctl alias k8s misc kl`
- `alias/k8s/misc/kmk.sh` → `bsctl alias k8s misc kmk`
- `alias/k8s/misc/kr.sh` → `bsctl alias k8s misc kr`
- `alias/k8s/misc/krm.sh` → `bsctl alias k8s misc krm`

#### K8s Root (1 script)
- `alias/k8s/k.sh` → `bsctl alias k8s k`

### Git Aliases (1 script)
- `alias/git/g.sh` → `bsctl alias git g`

## Implementation Approaches

### Option 1: Separate `bsctl alias` Command
Create a dedicated alias management system:
```go
// bsctl/cmd/alias/alias.go
bsctl alias list           // List all available aliases
bsctl alias k8s get kg     // Run the kg alias
bsctl alias install        // Install shell aliases that call bsctl
```

**Pros**: 
- Clear separation of concerns
- Easy to discover available aliases
- Can generate shell alias files

**Cons**: 
- Extra typing (3 levels deep)
- Doesn't feel native

### Option 2: Embed in Relevant Commands
Add aliases as shortcuts to existing commands:
```go
// bsctl/cmd/k8s/get.go
bsctl k8s get pods --all-namespaces  // Full command
bsctl k8s gp -A                       // Alias version
```

**Pros**: 
- More native feel
- Shorter commands
- Follows kubectl pattern

**Cons**: 
- Aliases scattered across codebase
- Harder to discover all aliases

### Option 3: Hybrid Approach (RECOMMENDED)
Generate shell alias files that users can source:
```bash
# ~/.bsctl-aliases.sh (generated)
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias ll='ls -lah'
# ... etc
```

Then provide:
```go
bsctl alias generate > ~/.bsctl-aliases.sh
bsctl alias install  // Adds source line to .bashrc/.zshrc
```

**Pros**: 
- Familiar bash alias experience
- Zero overhead (runs directly)
- Easy to customize
- Can still provide `bsctl alias list` for discovery

**Cons**: 
- Not pure Go solution
- Requires shell configuration

## Implementation Steps

1. **Create alias command structure**
   ```bash
   mkdir -p bsctl/cmd/alias
   touch bsctl/cmd/alias/alias.go
   touch bsctl/cmd/alias/generate.go
   touch bsctl/cmd/alias/install.go
   touch bsctl/cmd/alias/list.go
   ```

2. **Define alias mappings**
   - Create a data structure holding all aliases
   - Could be embedded in Go or loaded from YAML

3. **Implement generation**
   - Generate bash-compatible alias file
   - Generate zsh-compatible alias file
   - Generate fish-compatible alias file

4. **Implement installation**
   - Detect user's shell
   - Add source line to appropriate RC file
   - Verify installation

5. **Add tests**
   - Test alias generation
   - Test installation logic
   - Test detection of existing aliases

6. **Documentation**
   - Update README with alias usage
   - Add examples
   - Document how to customize

## Example Implementation

```go
// bsctl/static/resources/aliases.yaml
aliases:
  docker:
    dk: "docker"
    dkc: "docker-compose"
  general:
    ll: "ls -lah"
    guid: "uuid"
  k8s:
    k: "kubectl"
    kg: "kubectl get"
    kgp: "kubectl get pods"
    # ... etc
```

```go
// bsctl/cmd/alias/generate.go
func GenerateAliases(shell string) string {
    // Load aliases from yaml
    // Generate appropriate format for shell
    // Return alias file content
}
```

## Testing Strategy

- Unit tests for alias generation
- Unit tests for shell detection
- Integration tests for installation
- Verify generated aliases work in actual shells

## Deliverables

- [ ] `bsctl alias generate` command
- [ ] `bsctl alias install` command
- [ ] `bsctl alias list` command
- [ ] Support for bash, zsh, and fish
- [ ] Comprehensive tests
- [ ] Documentation
- [ ] Update CHANGELOG

## Estimated Timeline

- Research & Design: 1 day
- Implementation: 2-3 days
- Testing: 1-2 days
- Documentation: 1 day
- **Total: 5-7 days**

## Related Issues

- Create issue: "Migrate alias scripts to bsctl"
- Consider breaking into sub-issues by category if preferred
