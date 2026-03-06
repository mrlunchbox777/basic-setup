#! /usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Missing required file: $path"
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || fail "Missing required directory: $path"
}

require_heading() {
  local file="$1"
  local heading="$2"
  if ! LC_ALL=C grep -Eq "^${heading//\//\\/}$" "$file"; then
    fail "Missing heading '${heading}' in ${file}"
  fi
}

main() {
  require_file "${ROOT}/AGENTS.md"
  require_dir "${ROOT}/.agents"
  require_file "${ROOT}/.agents/README.md"
  require_file "${ROOT}/.agents/instructions.md"
  require_dir "${ROOT}/.agents/skills"

  # Ensure SKILL.md files live only under .agents/skills/**/SKILL.md
  mapfile -t unauthorized_skills < <(find "${ROOT}" -type f -name "SKILL.md" \
    ! -path "${ROOT}/.agents/skills/*/SKILL.md" \
    ! -path "${ROOT}/.git/*" \
    ! -path "${ROOT}/submodules/*")
  if (( ${#unauthorized_skills[@]} )); then
    printf "ERROR: Found SKILL.md outside .agents/skills/*/SKILL.md:\n" >&2
    printf " - %s\n" "${unauthorized_skills[@]}" >&2
    exit 1
  fi

  mapfile -t skills < <(find "${ROOT}/.agents/skills" -type f -name "SKILL.md")
  if (( ${#skills[@]} == 0 )); then
    fail "No skills found under .agents/skills/**/SKILL.md"
  fi

  for skill in "${skills[@]}"; do
    require_heading "$skill" "## Owner/Contact"
    require_heading "$skill" "## Purpose"
    require_heading "$skill" "## When to use"
    require_heading "$skill" "## Prerequisites"
    require_heading "$skill" "## Inputs"
    require_heading "$skill" "## Required context"
    require_heading "$skill" "## Steps"
    require_heading "$skill" "## Outputs"
  done
}

main "$@"
