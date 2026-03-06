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

check_frontmatter() {
  local file="$1"
  local expected_name="$2"
  if ! head -n1 "$file" | grep -q "^---"; then
    fail "Missing frontmatter start in ${file}"
  fi
  # Ensure there is a matching closing frontmatter delimiter.
  if ! awk 'NR>1 && /^---$/ {exit 0} END{exit 1}' "$file"; then
    fail "Missing frontmatter end in ${file}"
  fi
  local frontmatter
  frontmatter="$(awk 'BEGIN{in_block=0} /^---/{if(in_block){exit}else{in_block=1;next}} in_block{print}' "$file")"
  [[ -n "$frontmatter" ]] || fail "Missing frontmatter content in ${file}"
  local name desc
  name="$(printf "%s\n" "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -n1)"
  desc="$(printf "%s\n" "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -n1)"
  [[ -n "$name" ]] || fail "Missing frontmatter field 'name' in ${file}"
  [[ -n "$desc" ]] || fail "Missing frontmatter field 'description' in ${file}"
  [[ "$name" == "$expected_name" ]] || fail "Frontmatter name '${name}' does not match directory '${expected_name}' in ${file}"
  if ((${#desc} > 1024)); then
    fail "Description exceeds 1024 characters in ${file}"
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
    skill_dir="$(dirname "$skill")"
    skill_name="$(basename "$skill_dir")"
    check_frontmatter "$skill" "$skill_name"
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
