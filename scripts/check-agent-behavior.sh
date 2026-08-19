#!/usr/bin/env bash
# Bash twin of check-agent-behavior.ps1 for Linux/macOS and stack-agnostic CI.
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/.." && pwd)"
errors=()

add_error() { errors+=("$1"); }

required_files=(
  "Agent State/agent-state.md"
  "Agent State/task-queue.md"
  "Memory/project-facts.md"
  "Memory/decisions.md"
  "Memory/failures.md"
  "Memory/open-questions.md"
  "docs/AGENT_EXECUTION_LOOP.md"
  "docs/AGENT_TOOL_REGISTRY.md"
  "docs/AGENT_PERMISSION_GATES.md"
  "QA/AGENT_BEHAVIOR_CHECKS.md"
)

for file in "${required_files[@]}"; do
  [[ -f "$root/$file" ]] || add_error "Missing agentic runtime file: $file"
done

assert_contains() {
  local file="$1"
  shift
  [[ -f "$root/$file" ]] || return
  for marker in "$@"; do
    grep -qiF -- "$marker" "$root/$file" || add_error "$file missing marker: $marker"
  done
}

assert_contains "docs/AGENT_EXECUTION_LOOP.md" "plan" "act" "observe" "Verify" "Stop Conditions"
assert_contains "docs/AGENT_TOOL_REGISTRY.md" "safe" "approval-needed" "forbidden" "Commit changes" "deploy"
assert_contains "docs/AGENT_PERMISSION_GATES.md" "deleting files" "deploying" "spending money" "sending external messages"
assert_contains "AGENTS.md" "Agentic Runtime Layer" "Agent State/agent-state.md" "docs/AGENT_TOOL_REGISTRY.md" "docs/AGENT_PERMISSION_GATES.md"

if [[ ${#errors[@]} -gt 0 ]]; then
  echo "Agent behavior check failed:" >&2
  for error in "${errors[@]}"; do
    echo " - $error" >&2
  done
  exit 1
fi

echo "Agent behavior scaffold is present."
