# Tooling Pivot WIP: Labels, Epics, and Issue Triage

This WIP document is the execution companion for [`docs/tooling-pivot-migration-plan.md`](tooling-pivot-migration-plan.md).

It contains three things:

1. Ready-to-run label commands
2. Draft parent tracking issues (WS1-WS5)
3. First-pass mapping of current open issues to keep/supersede/close actions

## 1) Label Commands

`gh` must be authenticated before running these commands.

```bash
gh auth status
```

Create or update migration labels:

```bash
gh label create "track/pivot-migration" --color "1D76DB" --description "Tracks migration to chezmoi/mise/devbox" || gh label edit "track/pivot-migration" --color "1D76DB" --description "Tracks migration to chezmoi/mise/devbox"
gh label create "area/chezmoi" --color "0E8A16" --description "Dotfiles and shared script migration" || gh label edit "area/chezmoi" --color "0E8A16" --description "Dotfiles and shared script migration"
gh label create "area/mise" --color "5319E7" --description "Runtime and tool version management" || gh label edit "area/mise" --color "5319E7" --description "Runtime and tool version management"
gh label create "area/devbox" --color "FBCA04" --description "Project-local reproducible environments" || gh label edit "area/devbox" --color "FBCA04" --description "Project-local reproducible environments"
gh label create "area/legacy-basic-setup" --color "BFD4F2" --description "Legacy compatibility and transition work" || gh label edit "area/legacy-basic-setup" --color "BFD4F2" --description "Legacy compatibility and transition work"
gh label create "status/pilot" --color "C2E0C6" --description "Pilot migration in progress" || gh label edit "status/pilot" --color "C2E0C6" --description "Pilot migration in progress"
gh label create "status/migrated" --color "0E8A16" --description "Migration completed" || gh label edit "status/migrated" --color "0E8A16" --description "Migration completed"
gh label create "status/deprecated" --color "D93F0B" --description "Deprecated path; replacement available" || gh label edit "status/deprecated" --color "D93F0B" --description "Deprecated path; replacement available"
```

Optional helper labels for triage workflow:

```bash
gh label create "action/retarget" --color "0052CC" --description "Keep issue and retarget to pivot architecture" || gh label edit "action/retarget" --color "0052CC" --description "Keep issue and retarget to pivot architecture"
gh label create "action/supersede" --color "B60205" --description "Replace with a new migration issue" || gh label edit "action/supersede" --color "B60205" --description "Replace with a new migration issue"
gh label create "action/close-out-of-scope" --color "6A737D" --description "Out of scope after pivot decision" || gh label edit "action/close-out-of-scope" --color "6A737D" --description "Out of scope after pivot decision"
```

## 2) Parent Tracking Issue Drafts (WS1-WS5)

Copy/paste each body into `gh issue create`.

### WS1 Parent Issue

Title:

```text
track: WS1 foundation for tooling pivot (chezmoi + mise baseline)
```

Body:

```markdown
## Objective
Stand up the baseline architecture for the tooling pivot: dotfiles via chezmoi and runtime management via mise.

## Plan Reference
`docs/tooling-pivot-migration-plan.md` (WS1)

## Scope
- Pick/create canonical dotfiles repo
- Define bootstrap entrypoint
- Add baseline `mise` config
- Define shared script bin path and conventions
- Document install and rollback

## Out of Scope
- Broad package manager abstraction expansion
- Full migration of all legacy scripts

## Child Tasks
- [ ] Dotfiles repo structure and bootstrap script
- [ ] Add global `mise` config and tool list
- [ ] Document shared scripts path conventions
- [ ] Add onboarding docs and rollback docs

## Exit Criteria
- New machine setup succeeds with chezmoi + mise baseline
- Shared scripts execute from managed path
```

### WS2 Parent Issue

Title:

```text
track: WS2 classify shared-scripts and map migration targets
```

Body:

```markdown
## Objective
Classify all scripts in `shared-scripts/` into migration target layers and create child issues.

## Plan Reference
`docs/tooling-pivot-migration-plan.md` (WS2)

## Scope
- Inventory scripts
- Classify each script: chezmoi / devbox / legacy temporary / retire
- Create child issues and cross-link legacy issues

## Out of Scope
- Implementing every migration

## Child Tasks
- [ ] Build script inventory sheet
- [ ] Classify by target layer
- [ ] Create migration child issues
- [ ] Link or supersede existing open issues

## Exit Criteria
- Every script has a documented classification and linked issue
```

### WS3 Parent Issue

Title:

```text
track: WS3 pilot migration of high-usage workflows
```

Body:

```markdown
## Objective
Migrate 5-10 high-usage workflows and validate the new model in real usage.

## Plan Reference
`docs/tooling-pivot-migration-plan.md` (WS3)

## Scope
- Select pilot workflows
- Implement migrations
- Add smoke tests
- Record caveats

## Out of Scope
- Long-tail workflows and low-value commands

## Child Tasks
- [ ] Select pilot script set
- [ ] Migrate pilot scripts
- [ ] Add smoke tests / validation
- [ ] Write migration notes and caveats

## Exit Criteria
- Pilot workflows run end-to-end
- No critical regressions for pilot users
```

### WS4 Parent Issue

Title:

```text
track: WS4 batch migration and backlog execution
```

Body:

```markdown
## Objective
Execute migration in batches and align backlog/issues to the new architecture.

## Plan Reference
`docs/tooling-pivot-migration-plan.md` (WS4)

## Scope
- Batch migrations by category
- Maintain temporary compatibility shims
- Close/supersede stale legacy issues

## Out of Scope
- Immediate removal of all legacy paths

## Child Tasks
- [ ] Migrate script categories in batches
- [ ] Add or remove compatibility shims as needed
- [ ] Update issue states and labels

## Exit Criteria
- Priority scripts migrated or intentionally retired
- Open issue backlog reflects pivot model
```

### WS5 Parent Issue

Title:

```text
track: WS5 deprecation and scope reduction for legacy basic-setup
```

Body:

```markdown
## Objective
Finalize deprecation policy for broad-wrapper behavior and narrow legacy scope.

## Plan Reference
`docs/tooling-pivot-migration-plan.md` (WS5)

## Scope
- Freeze broad-wrapper expansion
- Publish deprecation timeline and migration guidance
- Remove low-value compatibility code after replacement stabilizes

## Out of Scope
- Forced cutover without migration path

## Child Tasks
- [ ] Publish deprecation notice/timeline
- [ ] Mark deprecated commands and docs
- [ ] Remove low-value compatibility code

## Exit Criteria
- Reduced and explicit support statement for legacy `basic-setup`
```

Create them with:

```bash
gh issue create --title "track: WS1 foundation for tooling pivot (chezmoi + mise baseline)" --body-file /tmp/ws1.md --label "track/pivot-migration"
gh issue create --title "track: WS2 classify shared-scripts and map migration targets" --body-file /tmp/ws2.md --label "track/pivot-migration"
gh issue create --title "track: WS3 pilot migration of high-usage workflows" --body-file /tmp/ws3.md --label "track/pivot-migration"
gh issue create --title "track: WS4 batch migration and backlog execution" --body-file /tmp/ws4.md --label "track/pivot-migration"
gh issue create --title "track: WS5 deprecation and scope reduction for legacy basic-setup" --body-file /tmp/ws5.md --label "track/pivot-migration"
```

## 3) First-Pass Triage Mapping

Snapshot source: open issues pulled from GitHub API on 2026-03-17.

### Keep + Retarget (high-value under new model)

- `#181` add test coverage (retarget to migration validation coverage)
- `#168` clean `get-pod-ports` output (retarget as k8s workflow reliability)
- `#167` support mac/windows nodes for `forward-pod` (retarget under legacy shim then migrate)
- `#166` support windows nodes for `create-test-pod-info` (retarget under legacy shim then migrate)
- `#165` support windows nodes for `create-test-pod` (retarget under legacy shim then migrate)
- `#164` support windows nodes for `create-pod-shell` (retarget under legacy shim then migrate)
- `#163` support windows nodes for `create-node-shell` (retarget under legacy shim then migrate)
- `#124` fix cheatsheet docs (retarget to current architecture docs)
- `#123` create update command (retarget to migration-aware updater messaging)
- `#122` positional params in bash scripts (merge intent with `#162`)

Recommended action for each: add `track/pivot-migration` and `action/retarget`, then edit acceptance criteria.

### Supersede (replace with focused pivot issues)

#### Supersede Group A: package manager abstraction and install index breadth

- `#169 #157 #134 #132 #130 #129 #119 #115`

Create one new issue for each concern in pivot terms:

- Runtime/tool policy in `mise`
- Project dependency policy in `devbox`
- Dotfiles package/install conventions in chezmoi

Then close originals with superseded links.

#### Supersede Group B: support package/application requests as profile catalog work

- `#170 #159 #158 #156 #155 #154 #153 #152 #151 #150 #149 #148 #147 #146 #145 #142 #141 #140 #139 #138 #137 #136 #108 #107 #106 #105 #104 #103 #102 #101 #100 #99 #98 #97 #96 #95 #94 #92 #91 #90 #89 #88 #87 #86 #85 #84 #83 #82 #81 #80 #79 #78 #77 #76 #75 #74 #73 #72 #71 #69 #68 #67 #66 #65 #64 #63 #62 #61 #42`

Create new issues by profile outcome instead of per-package-manager wrapper logic, for example:

- `profile: baseline shell/tooling`
- `profile: k8s/operator workstation`
- `profile: media/comms optional add-ons`

Then close originals with superseded links.

### Close As Out-Of-Scope (or supersede if still needed)

- `#135` reprioritize support feature requests (no longer needed as broad-wrapper planning artifact)
- `#127` optimize `kgpp` (close if command is being retired; supersede if command is in pilot set)
- `#126` handle upstream autoupdaters (close unless explicitly required by selected tooling)
- `#128` interactive install bash/git in setup script (close if bootstrap is moving to chezmoi-driven flow)
- `#125` add Windows support back (supersede if still needed for migration path)
- `#161` consolidate on true/false returns (retarget if script remains in legacy layer)
- `#160` improve command-installed (retarget if kept in migration glue)
- `#131` docs: searching packages by labels (close/supersede depending on whether labels remain central)
- `#162` positional params (supersede/merge with `#122` into one migration task)

### Triage Comment Templates

Use this when superseding:

```markdown
Thanks for opening this. This issue is being superseded by the tooling pivot plan to `chezmoi` + `mise` (+ optional `devbox`).

Plan: `docs/tooling-pivot-migration-plan.md`
Replacement issue: #<new-id>

Closing this issue as superseded so planning and implementation stay consolidated.
```

Use this when retargeting:

```markdown
Retargeting this issue to the tooling pivot plan (`docs/tooling-pivot-migration-plan.md`).

This remains valuable and will be implemented in the `<layer>` migration track with updated acceptance criteria.
```

### Bulk Command Starters

Apply labels in batches:

```bash
gh issue edit 181 168 167 166 165 164 163 124 123 122 --add-label "track/pivot-migration" --add-label "action/retarget"
gh issue edit 169 157 134 132 130 129 119 115 --add-label "track/pivot-migration" --add-label "action/supersede"
```

For long lists, use loops:

```bash
for n in 170 159 158 156 155 154 153 152 151 150 149 148 147 146 145 142 141 140 139 138 137 136 108 107 106 105 104 103 102 101 100 99 98 97 96 95 94 92 91 90 89 88 87 86 85 84 83 82 81 80 79 78 77 76 75 74 73 72 71 69 68 67 66 65 64 63 62 61 42; do
  gh issue edit "$n" --add-label "track/pivot-migration" --add-label "action/supersede"
done
```
