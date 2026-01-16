# Phase 4: Advanced & Complex Scripts Migration

## Overview

Migrate advanced and domain-specific scripts. These are more complex and may require careful consideration about whether to migrate or keep as bash.

## Stats

- **Total Scripts**: 20
- **Difficulty**: MEDIUM to HIGH
- **Estimated Effort**: 2-4 weeks
- **Impact**: LOW to MEDIUM (less frequently used)

## Categories

### Docker Operations (3 scripts)

**`docker/remove-containers.sh`** → `bsctl docker remove-containers`
- **Lines**: ~150-200
- **Purpose**: Remove Docker containers with filtering
- **Complexity**: MEDIUM
- **Dependencies**: Docker client
- **Implementation Notes**:
  - Use Docker Go SDK
  - Filter by status, name, etc.
  - Bulk operations
  - Confirmation prompts

**`docker/clear.sh`** → `bsctl docker clear`
- **Lines**: ~150-200
- **Purpose**: Clear stopped containers and unused images
- **Complexity**: MEDIUM
- **Dependencies**: Docker client
- **Implementation Notes**:
  - Remove stopped containers
  - Remove dangling images
  - Optional: remove volumes
  - Show space reclaimed

**`docker/full-clear.sh`** → `bsctl docker full-clear`
- **Lines**: ~150-200
- **Purpose**: Complete Docker cleanup (aggressive)
- **Complexity**: MEDIUM
- **Dependencies**: Docker client
- **Implementation Notes**:
  - Remove all containers
  - Remove all images
  - Remove all volumes
  - Remove all networks
  - Multiple confirmations
  - Dry-run mode

### Big-Bang Operations (15 scripts)

**Note**: These are domain-specific for Big Bang Kubernetes platform. Consider keeping some as bash or making them optional add-ons.

**`big-bang/export-registry-credentials.sh`** → `bsctl bigbang export-registry-credentials`
- **Lines**: ~100-150
- **Purpose**: Export registry credentials for Big Bang
- **Complexity**: MEDIUM
- **Dependencies**: kubectl, secrets management

**`big-bang/helm-login.sh`** → `bsctl bigbang helm-login`
- **Lines**: ~150-200
- **Purpose**: Login to Big Bang Helm registry
- **Complexity**: MEDIUM
- **Dependencies**: helm, authentication

**`big-bang/docker-login.sh`** → `bsctl bigbang docker-login`
- **Lines**: ~150-200
- **Purpose**: Login to Big Bang Docker registry
- **Complexity**: MEDIUM
- **Dependencies**: docker, authentication

**`big-bang/helm-install.sh`** → `bsctl bigbang helm-install`
- **Lines**: ~200-250
- **Purpose**: Install Big Bang via Helm
- **Complexity**: HIGH
- **Dependencies**: helm, kubectl, complex configuration

**`big-bang/install-flux-wrapper.sh`** → `bsctl bigbang install-flux`
- **Lines**: ~150-200
- **Purpose**: Install Flux for Big Bang
- **Complexity**: MEDIUM-HIGH
- **Dependencies**: flux CLI, kubectl

**`big-bang/k3d-dev-wrapper.sh`** → `bsctl bigbang k3d-dev`
- **Lines**: ~250-300
- **Purpose**: Set up k3d cluster for Big Bang development
- **Complexity**: HIGH
- **Dependencies**: k3d, kubectl, helm, complex setup

**`big-bang/dogfood-prep.sh`** → `bsctl bigbang dogfood-prep`
- **Lines**: ~200-250
- **Purpose**: Prepare environment for Big Bang dogfooding
- **Complexity**: HIGH
- **Dependencies**: Multiple tools and configurations

**`big-bang/override-gen.sh`** → `bsctl bigbang override-gen`
- **Lines**: ~200-250
- **Purpose**: Generate Big Bang override values
- **Complexity**: HIGH
- **Dependencies**: YAML manipulation, templates

**`big-bang/dev-env.sh`** → `bsctl bigbang dev-env`
- **Lines**: ~250-300
- **Purpose**: Set up complete Big Bang development environment
- **Complexity**: HIGH
- **Dependencies**: Many tools and configurations

**`big-bang/os-prep.sh`** → `bsctl bigbang os-prep`
- **Lines**: ~200-250
- **Purpose**: Prepare OS for Big Bang
- **Complexity**: HIGH
- **Dependencies**: OS-level configurations

**`big-bang/ssh-cluster.sh`** → `bsctl bigbang ssh-cluster`
- **Lines**: ~150-200
- **Purpose**: SSH to Big Bang cluster nodes
- **Complexity**: MEDIUM
- **Dependencies**: SSH, cluster access

**`big-bang/get-repo-dir.sh`** → `bsctl bigbang get-repo-dir`
- **Lines**: ~100-150
- **Purpose**: Get Big Bang repository directory
- **Complexity**: EASY-MEDIUM
- **Dependencies**: File system operations

**`big-bang/get-cluster-ip.sh`** → `bsctl bigbang get-cluster-ip`
- **Lines**: ~100-150
- **Purpose**: Get Big Bang cluster IP
- **Complexity**: MEDIUM
- **Dependencies**: kubectl, cluster info

**`big-bang/readme-bump.sh`** → `bsctl bigbang readme-bump`
- **Lines**: ~150-200
- **Purpose**: Update Big Bang README version
- **Complexity**: MEDIUM
- **Dependencies**: File manipulation, version parsing

**`big-bang/relink-scripts.sh`** → `bsctl bigbang relink-scripts`
- **Lines**: ~150-200
- **Purpose**: Relink Big Bang scripts
- **Complexity**: MEDIUM
- **Dependencies**: Symlink management

### General Utilities (2 scripts)

**`general/diff-date.sh`** → `bsctl util diff-date`
- **Lines**: ~100-150
- **Purpose**: Calculate difference between dates
- **Complexity**: MEDIUM
- **Dependencies**: Date/time parsing
- **Implementation Notes**:
  - Parse various date formats
  - Calculate differences
  - Output in various units
  - Handle timezones

**`general/count-lines-dir.sh`** → `bsctl util count-lines`
- **Lines**: ~100-150
- **Purpose**: Count lines of code in directory
- **Complexity**: MEDIUM
- **Dependencies**: File traversal, filtering
- **Implementation Notes**:
  - Recursive directory walk
  - Filter by file type
  - Exclude patterns
  - Summary statistics

## Command Structure

```
bsctl
├── docker
│   ├── remove-containers
│   ├── clear
│   └── full-clear
├── bigbang
│   ├── export-registry-credentials
│   ├── helm-login
│   ├── docker-login
│   ├── helm-install
│   ├── install-flux
│   ├── k3d-dev
│   ├── dogfood-prep
│   ├── override-gen
│   ├── dev-env
│   ├── os-prep
│   ├── ssh-cluster
│   ├── get-repo-dir
│   ├── get-cluster-ip
│   ├── readme-bump
│   └── relink-scripts
└── util
    ├── diff-date
    └── count-lines
```

## Implementation Considerations

### Docker Commands
- Use [Docker Go SDK](https://pkg.go.dev/github.com/docker/docker)
- Handle Docker daemon connectivity
- Support both local and remote Docker
- Provide dry-run modes
- Clear progress indicators

### Big-Bang Commands
- **Consider**: Keep complex Big-Bang scripts as bash
- **Rationale**: 
  - Very domain-specific
  - Complex orchestration
  - Frequent changes to Big Bang
  - May be better maintained as bash
- **Alternative**: 
  - Migrate only the simple ones
  - Create `bsctl bigbang run-script <name>` wrapper
  - Focus on improving the bash scripts themselves

### Migration Decision Matrix

| Script | Migrate? | Reason |
|--------|----------|--------|
| Docker operations | YES | Common use case, good Go libraries |
| Big-Bang simple utils | YES | Easy wins (get-repo-dir, etc.) |
| Big-Bang complex setup | MAYBE | High effort, low benefit |
| Big-Bang dev-env | NO | Too complex, better as bash |
| Big-Bang k3d-wrapper | MAYBE | Popular but complex |
| General utilities | YES | Reusable, good additions |

## Recommended Approach

### Phase 4A: Docker Operations (High Value)
Migrate all Docker commands - clear value proposition.

### Phase 4B: Big-Bang Simple (Medium Value)
Migrate simple Big-Bang utilities:
- `get-repo-dir.sh`
- `get-cluster-ip.sh`
- `readme-bump.sh`
- `relink-scripts.sh`

### Phase 4C: General Utilities (Medium Value)
Migrate general utilities:
- `diff-date.sh`
- `count-lines-dir.sh`

### Phase 4D: Big-Bang Complex (Low Priority)
**Consider leaving as bash** or create wrapper:
```go
// bsctl/cmd/bigbang/run.go
func runBigBangScript(scriptName string, args []string) error {
    scriptPath := filepath.Join(getSharedScriptsDir(), "big-bang", scriptName)
    return executeScript(scriptPath, args)
}
```

This gives you:
- Quick access to Big-Bang scripts via bsctl
- No need to rewrite complex bash
- Easy to migrate incrementally
- Users get unified interface

## Implementation Steps

### Phase 4A: Docker Operations (1 week)

1. **Set up Docker SDK**
   ```bash
   cd bsctl
   go get github.com/docker/docker
   ```

2. **Implement commands**
   ```bash
   mkdir -p cmd/docker
   touch cmd/docker/docker.go
   touch cmd/docker/remove_containers.go
   touch cmd/docker/clear.go
   touch cmd/docker/full_clear.go
   ```

3. **Add tests**
   - Mock Docker client
   - Test filtering logic
   - Test confirmation flows

### Phase 4B-C: Utilities (1 week)

1. **Implement Big-Bang simple utilities**
2. **Implement general utilities**
3. **Add comprehensive tests**

### Phase 4D: Big-Bang Wrapper (Optional, 2-3 days)

1. **Create script runner**
   ```go
   bsctl bigbang run k3d-dev-wrapper [args...]
   ```

2. **Add script discovery**
   ```go
   bsctl bigbang list
   ```

## Testing Strategy

### Docker Commands
- Mock Docker client
- Test with fake containers/images
- Integration tests with real Docker
- Test error conditions

### Big-Bang Commands
- Mock kubectl/helm clients
- Test configuration generation
- Integration tests with k3d

### General Utilities
- Unit tests with various inputs
- Test edge cases
- Performance tests for large directories

## Deliverables

### Must Have
- [ ] `bsctl docker remove-containers`
- [ ] `bsctl docker clear`
- [ ] `bsctl docker full-clear`
- [ ] `bsctl util diff-date`
- [ ] `bsctl util count-lines`
- [ ] Tests and documentation

### Nice to Have
- [ ] Simple Big-Bang utilities (4 scripts)
- [ ] Big-Bang script wrapper
- [ ] Tests and documentation

### Optional (Consider Keeping as Bash)
- [ ] Complex Big-Bang setup scripts
- [ ] Big-Bang development environment
- [ ] Big-Bang k3d wrapper

## Estimated Timeline

### Phase 4A: Docker Operations
- Design: 1 day
- Implementation: 2-3 days
- Testing: 1-2 days
- Documentation: 1 day
- **Total: 5-7 days**

### Phase 4B: Big-Bang Simple
- Implementation: 2-3 days
- Testing: 1-2 days
- Documentation: 1 day
- **Total: 4-6 days**

### Phase 4C: General Utilities
- Implementation: 1-2 days
- Testing: 1 day
- Documentation: 0.5 days
- **Total: 2-3 days**

### Phase 4D: Big-Bang Wrapper (Optional)
- Implementation: 1-2 days
- Testing: 1 day
- **Total: 2-3 days**

**Total: 2-4 weeks** (depending on scope)

## Related Issues

- Create issue: "Phase 4A: Migrate Docker operations"
- Create issue: "Phase 4B: Migrate simple Big-Bang utilities"
- Create issue: "Phase 4C: Migrate general utilities"
- Create issue: "Phase 4D: Create Big-Bang script wrapper (optional)"

## Recommendation

Focus on **Phase 4A (Docker)** and **Phase 4C (General Utilities)** as they provide clear value. For Big-Bang scripts, consider creating a wrapper (`bsctl bigbang run`) rather than full migration, as these are complex, domain-specific, and may change frequently.
