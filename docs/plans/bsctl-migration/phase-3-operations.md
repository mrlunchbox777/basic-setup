# Phase 3: Operations Scripts Migration

## Overview

Migrate operational utility scripts for network information and Kubernetes operations. These provide valuable functionality for day-to-day development and operations tasks.

## Stats

- **Total Scripts**: 23
- **Difficulty**: MEDIUM
- **Estimated Effort**: 2-3 weeks
- **Impact**: MEDIUM (useful operational tools)

## Categories

### Network Utilities (5 scripts)

**`network/my-local-ip.sh`** → `bsctl network local-ip`
- **Lines**: ~100-150
- **Purpose**: Get local IP address
- **Complexity**: MEDIUM
- **Dependencies**: Network interfaces, platform-specific commands
- **Implementation Notes**:
  - Cross-platform implementation
  - Handle multiple interfaces
  - IPv4 and IPv6 support
  - Filter by interface type

**`network/my-public-ip.sh`** → `bsctl network public-ip`
- **Lines**: ~100-150
- **Purpose**: Get public IP address
- **Complexity**: EASY-MEDIUM
- **Dependencies**: HTTP requests to IP services
- **Implementation Notes**:
  - Query external services (ifconfig.me, ipify.org, etc.)
  - Fallback to multiple services
  - Timeout handling
  - Cache results briefly

**`network/my-default-route.sh`** → `bsctl network default-route`
- **Lines**: ~100-150
- **Purpose**: Get default network route
- **Complexity**: MEDIUM
- **Dependencies**: Platform-specific routing table access
- **Implementation Notes**:
  - Parse routing tables
  - Cross-platform (Linux, Mac, Windows)
  - Show gateway IP
  - Handle multiple defaults

**`network/my-mac.sh`** → `bsctl network mac-address`
- **Lines**: ~100-150
- **Purpose**: Get MAC address
- **Complexity**: MEDIUM
- **Dependencies**: Network interface access
- **Implementation Notes**:
  - Get MAC for specific interface
  - Handle multiple interfaces
  - Cross-platform
  - Format output consistently

**`network/my-default-network-device.sh`** → `bsctl network default-device`
- **Lines**: ~100-150
- **Purpose**: Get default network device/interface
- **Complexity**: MEDIUM
- **Dependencies**: Network configuration
- **Implementation Notes**:
  - Find active default interface
  - Cross-platform detection
  - Handle wireless vs wired
  - Show interface properties

### Kubernetes Utilities (18 scripts)

#### Selection & Context (2 scripts)

**`k8s/kubectl-select-namespace.sh`** → `bsctl k8s select-namespace`
- **Lines**: ~150-200
- **Purpose**: Interactively select kubectl namespace
- **Complexity**: MEDIUM
- **Dependencies**: kubectl, interactive UI
- **Implementation Notes**:
  - List available namespaces
  - Interactive selection (use promptui or similar)
  - Update kubectl context
  - Show current namespace

**`k8s/kubectl-select-context.sh`** → `bsctl k8s select-context`
- **Lines**: ~150-200
- **Purpose**: Interactively select kubectl context
- **Complexity**: MEDIUM
- **Dependencies**: kubectl, interactive UI
- **Implementation Notes**:
  - List available contexts
  - Interactive selection
  - Switch context
  - Show current context

#### Pod Operations (9 scripts)

**`k8s/get-pod-shell.sh`** → `bsctl k8s pod-shell`
- **Lines**: ~150-200
- **Purpose**: Get shell access to a pod
- **Complexity**: MEDIUM
- **Dependencies**: kubectl exec
- **Implementation Notes**:
  - Find pods by name/label
  - Interactive pod selection if multiple
  - Auto-detect shell (bash, sh, etc.)
  - Handle multi-container pods

**`k8s/get-pod-logs.sh`** → `bsctl k8s pod-logs`
- **Lines**: ~150-200
- **Purpose**: Get logs from a pod
- **Complexity**: MEDIUM
- **Dependencies**: kubectl logs
- **Implementation Notes**:
  - Support follow mode
  - Multi-container support
  - Timestamp options
  - Tail lines option

**`k8s/get-pod-by-label.sh`** → `bsctl k8s get-pod-by-label`
- **Lines**: ~100-150
- **Purpose**: Find pods by label selector
- **Complexity**: EASY-MEDIUM
- **Dependencies**: kubectl get
- **Implementation Notes**:
  - Label selector parsing
  - Namespace filtering
  - Output formatting
  - Sort options

**`k8s/get-pod-image.sh`** → `bsctl k8s pod-image`
- **Lines**: ~100-150
- **Purpose**: Get container image for a pod
- **Complexity**: EASY-MEDIUM
- **Dependencies**: kubectl get
- **Implementation Notes**:
  - Extract image info
  - Handle init containers
  - Show all containers
  - Format output

**`k8s/get-pod-ports.sh`** → `bsctl k8s pod-ports`
- **Lines**: ~100-150
- **Purpose**: Get exposed ports for a pod
- **Complexity**: EASY-MEDIUM
- **Dependencies**: kubectl get
- **Implementation Notes**:
  - Parse container specs
  - Show all port mappings
  - Include protocols
  - Service port mapping

**`k8s/get-labels-by-name.sh`** → `bsctl k8s get-labels`
- **Lines**: ~100-150
- **Purpose**: Get labels for resources
- **Complexity**: EASY-MEDIUM
- **Dependencies**: kubectl get
- **Implementation Notes**:
  - Support multiple resource types
  - Format label output
  - Filter by namespace

**`k8s/forward-pod.sh`** → `bsctl k8s forward`
- **Lines**: ~150-200
- **Purpose**: Port forward to a pod
- **Complexity**: MEDIUM
- **Dependencies**: kubectl port-forward
- **Implementation Notes**:
  - Interactive pod selection
  - Multiple port forwarding
  - Background/foreground modes
  - Auto-cleanup on exit

**`k8s/delete-pod.sh`** → `bsctl k8s delete-pod`
- **Lines**: ~100-150
- **Purpose**: Delete pods with confirmation
- **Complexity**: EASY-MEDIUM
- **Dependencies**: kubectl delete
- **Implementation Notes**:
  - Interactive confirmation
  - Grace period options
  - Force delete option
  - Dry-run mode

**`k8s/create-pod-shell.sh`** → `bsctl k8s create-pod-shell`
- **Lines**: ~150-200
- **Purpose**: Create a debug pod with shell
- **Complexity**: MEDIUM
- **Dependencies**: kubectl run
- **Implementation Notes**:
  - Create temporary pod
  - Attach to shell
  - Auto-cleanup on exit
  - Custom image support

#### Deployment Operations (2 scripts)

**`k8s/get-deploy-image.sh`** → `bsctl k8s deployment-image`
- **Lines**: ~100-150
- **Purpose**: Get container image for deployment
- **Complexity**: EASY-MEDIUM
- **Dependencies**: kubectl get
- **Implementation Notes**:
  - Extract image from deployment
  - Show all containers
  - Update image command?

**`k8s/kubectl-restart-all-deployments.sh`** → `bsctl k8s restart-deployments`
- **Lines**: ~150-200
- **Purpose**: Restart all deployments in namespace
- **Complexity**: MEDIUM
- **Dependencies**: kubectl rollout
- **Implementation Notes**:
  - List all deployments
  - Interactive confirmation
  - Parallel vs sequential
  - Progress tracking

#### DaemonSet Operations (1 script)

**`k8s/kubectl-restart-all-daemonsets.sh`** → `bsctl k8s restart-daemonsets`
- **Lines**: ~150-200
- **Purpose**: Restart all daemonsets in namespace
- **Complexity**: MEDIUM
- **Dependencies**: kubectl rollout
- **Implementation Notes**:
  - List all daemonsets
  - Interactive confirmation
  - Progress tracking

#### Test/Debug (3 scripts)

**`k8s/create-test-pod.sh`** → `bsctl k8s create-test-pod`
- **Lines**: ~150-200
- **Purpose**: Create a test pod
- **Complexity**: MEDIUM
- **Dependencies**: kubectl run
- **Implementation Notes**:
  - Various test images (busybox, alpine, etc.)
  - Custom commands
  - Ephemeral vs persistent
  - Auto-cleanup options

**`k8s/create-test-podinfo.sh`** → `bsctl k8s create-test-podinfo`
- **Lines**: ~150-200
- **Purpose**: Create podinfo test application
- **Complexity**: MEDIUM
- **Dependencies**: kubectl apply
- **Implementation Notes**:
  - Deploy podinfo
  - Configure ports
  - Optional ingress
  - Cleanup command

**`k8s/create-node-shell.sh`** → `bsctl k8s node-shell`
- **Lines**: ~200-250
- **Purpose**: Get shell access to a node (via privileged pod)
- **Complexity**: COMPLEX
- **Dependencies**: kubectl, privileged pod creation
- **Implementation Notes**:
  - Create privileged pod on node
  - Mount host filesystem
  - Interactive shell
  - Security warnings
  - Auto-cleanup

#### Advanced (1 script)

**`k8s/clear-finalizers.sh`** → `bsctl k8s clear-finalizers`
- **Lines**: ~200-250
- **Purpose**: Clear finalizers from stuck resources
- **Complexity**: COMPLEX
- **Dependencies**: kubectl patch
- **Implementation Notes**:
  - Interactive resource selection
  - Safety confirmations
  - Dry-run mode
  - Backup before clearing

## Command Structure

```
bsctl
├── network
│   ├── local-ip
│   ├── public-ip
│   ├── default-route
│   ├── mac-address
│   └── default-device
└── k8s (or kubectl)
    ├── select-namespace
    ├── select-context
    ├── pod-shell
    ├── pod-logs
    ├── get-pod-by-label
    ├── pod-image
    ├── pod-ports
    ├── get-labels
    ├── forward
    ├── delete-pod
    ├── create-pod-shell
    ├── deployment-image
    ├── restart-deployments
    ├── restart-daemonsets
    ├── create-test-pod
    ├── create-test-podinfo
    ├── node-shell
    └── clear-finalizers
```

## Implementation Priority

### High Priority (Daily Use)
1. `bsctl k8s select-namespace` - Essential for multi-namespace work
2. `bsctl k8s select-context` - Essential for multi-cluster work
3. `bsctl k8s pod-shell` - Debug pods
4. `bsctl k8s pod-logs` - View logs
5. `bsctl k8s forward` - Port forwarding

### Medium Priority (Common Operations)
6. `bsctl network local-ip` - Network info
7. `bsctl network public-ip` - Network info
8. `bsctl k8s get-pod-by-label` - Pod discovery
9. `bsctl k8s create-test-pod` - Testing
10. `bsctl k8s restart-deployments` - Operations

### Low Priority (Less Frequent)
11-23. Remaining scripts

## Implementation Considerations

### Interactive UI
- Use [promptui](https://github.com/manifoldco/promptui) or [survey](https://github.com/AlecAivazis/survey) for interactive selection
- Fall back to non-interactive mode with flags
- Support scripting mode (non-interactive)

### kubectl Integration
- Use kubectl Go client library where possible
- Fall back to exec kubectl for complex operations
- Parse kubectl output consistently
- Handle kubectl version differences

### Cross-Platform
- Network commands need OS-specific implementations
- Test on Linux, macOS, and Windows
- Use appropriate Go stdlib packages (net, os, etc.)

### Error Handling
- Clear error messages
- Suggest solutions
- Validate kubectl availability
- Check cluster connectivity

## Testing Strategy

### Network Commands
- Mock network interfaces
- Test cross-platform code paths
- Test error conditions (no network, etc.)
- Integration tests on real system

### Kubernetes Commands
- Mock kubectl client
- Test with fake kubernetes API
- Integration tests with kind/k3d
- Test namespace/context switching

## Deliverables

### Phase 3A: Network Utilities (1 week)
- [ ] All 5 network commands
- [ ] Cross-platform support
- [ ] Tests and documentation

### Phase 3B: K8s Core (1 week)
- [ ] Context/namespace selection
- [ ] Pod operations (shell, logs, forward)
- [ ] Tests and documentation

### Phase 3C: K8s Operations (1 week)
- [ ] Deployment/daemonset operations
- [ ] Test/debug utilities
- [ ] Advanced operations
- [ ] Tests and documentation

## Estimated Timeline

- Phase 3A: 5-7 days
- Phase 3B: 5-7 days
- Phase 3C: 5-7 days

**Total: 2-3 weeks**

## Related Issues

- Create issue: "Phase 3A: Migrate network utilities"
- Create issue: "Phase 3B: Migrate core k8s utilities"
- Create issue: "Phase 3C: Migrate advanced k8s operations"
