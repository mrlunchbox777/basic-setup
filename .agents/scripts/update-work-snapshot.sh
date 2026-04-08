#! /usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: .agents/scripts/update-work-snapshot.sh [--context "..."] [--goal "..."]

Updates the managed section of .agents/work-snapshot.local.md.
If --context/--goal are omitted, existing values are preserved when present.
EOF
}

context_override=""
goal_override=""

while [ "$#" -gt 0 ]; do
    case "$1" in
    --context)
        if [ "$#" -lt 2 ]; then
            echo "Error: --context requires a value" >&2
            exit 1
        fi
        context_override="${2:-}"
        shift 2
        ;;
    --goal)
        if [ "$#" -lt 2 ]; then
            echo "Error: --goal requires a value" >&2
            exit 1
        fi
        goal_override="${2:-}"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "Error: Unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
done

repo_root="$(git rev-parse --show-toplevel)"
snapshot_file="${repo_root}/.agents/work-snapshot.local.md"

branch="$(git -C "${repo_root}" rev-parse --abbrev-ref HEAD)"
updated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

existing_goal=""
existing_context=""
if [ -f "${snapshot_file}" ]; then
    existing_goal="$(awk '/^- goal: / {sub(/^- goal: /, ""); print; exit}' "${snapshot_file}" || true)"
    existing_context="$(awk '/^- context: / {sub(/^- context: /, ""); print; exit}' "${snapshot_file}" || true)"
fi

goal="${goal_override:-$existing_goal}"
context_line="${context_override:-$existing_context}"

if [[ "${goal}" == *$'\n'* ]] || [[ "${goal}" == *$'\r'* ]]; then
    echo "Error: --goal must be a single line" >&2
    exit 1
fi

if [[ "${context_line}" == *$'\n'* ]] || [[ "${context_line}" == *$'\r'* ]]; then
    echo "Error: --context must be a single line" >&2
    exit 1
fi

if [ -z "${goal}" ]; then
    goal="Set this with --goal \"...\"."
fi

if [ -z "${context_line}" ]; then
    context_line="Updated via script; add a one-line note with --context \"...\" when needed."
fi

issue="n/a"
if [[ "${branch}" =~ -([0-9]+)$ ]]; then
    issue="#${BASH_REMATCH[1]}"
fi

pr="n/a"
pr_state="n/a"
pr_mergeable="n/a"
pr_review="n/a"
pr_number=""
pr_url=""

if command -v gh >/dev/null 2>&1; then
    pr_data="$(gh pr view --json number,url,state,mergeable,reviewDecision --template '{{if .number}}{{.number}}{{"\t"}}{{.url}}{{"\t"}}{{.state}}{{"\t"}}{{.mergeable}}{{"\t"}}{{.reviewDecision}}{{end}}' 2>/dev/null || true)"
    if [ -n "${pr_data}" ]; then
        IFS=$'\t' read -r pr_number pr_url pr_state pr_mergeable pr_review <<EOF
${pr_data}
EOF
    fi

    if [ -n "${pr_number}" ] && [ "${pr_number}" != "null" ]; then
        pr="#${pr_number}"
    fi
    if [ -n "${pr_url}" ] && [ "${pr_url}" != "null" ] && [ "${pr}" != "n/a" ]; then
        pr="${pr} ${pr_url}"
    fi
fi

managed_block=$(cat <<EOF
<!-- managed:start -->
# Work Snapshot (Local)

- branch: ${branch}
- issue: ${issue}
- pr: ${pr}
- goal: ${goal}
- context: ${context_line}
- pr_state: ${pr_state}
- pr_mergeable: ${pr_mergeable}
- pr_review: ${pr_review}
- updated_at: ${updated_at}
<!-- managed:end -->
EOF
)

manual_block=$(cat <<'EOF'

## Manual Notes
- done:
  -
- current_state:
  -
- next:
  1.
EOF
)

if [ ! -f "${snapshot_file}" ]; then
    printf '%s\n%s\n' "${managed_block}" "${manual_block}" >"${snapshot_file}"
    echo "Created ${snapshot_file}"
    exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to update ${snapshot_file}" >&2
    exit 1
fi

python3 - "${snapshot_file}" "${managed_block}" "${manual_block}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
managed = sys.argv[2]
manual = sys.argv[3]
text = path.read_text(encoding="utf-8") if path.exists() else ""

start = "<!-- managed:start -->"
end = "<!-- managed:end -->"

if start in text and end in text:
    before, rest = text.split(start, 1)
    _, after = rest.split(end, 1)
    after = after.lstrip("\n")
    if not after.strip():
        after = manual.strip("\n") + "\n"
    else:
        after = after.rstrip("\n") + "\n"
    if before:
        new_text = before + managed + "\n" + after
    else:
        new_text = managed + "\n" + after
else:
    tail = text.strip("\n")
    if tail:
        new_text = managed + "\n\n" + tail + "\n"
    else:
        new_text = managed + "\n" + manual.strip("\n") + "\n"

path.write_text(new_text, encoding="utf-8")
PY

echo "Updated ${snapshot_file}"
