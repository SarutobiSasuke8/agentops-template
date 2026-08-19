#!/usr/bin/env bash
# Smoke-test the Bash init path from a temp copy of this template.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_root="$(cd "$script_dir/.." && pwd)"
temp_parent="$(mktemp -d "${TMPDIR:-/tmp}/vibe-template-init-test.XXXXXX")"
temp_root="$temp_parent/repo"

cleanup() {
    rm -rf "$temp_parent"
}
trap cleanup EXIT

assert_contains() {
    local file="$1" expected="$2" label="$3"
    if ! grep -qF -- "$expected" "$file"; then
        echo "Missing expected $label: $expected" >&2
        exit 1
    fi
}

copy_template() {
    local destination="$1"
    mkdir -p "$destination"
    tar \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='reports' \
        -C "$source_root" -cf - . | tar -C "$destination" -xf -
}

copy_template "$temp_root"

bash "$temp_root/scripts/init.sh" \
    --non-interactive \
    --project-name "Bootstrap Smoke Project" \
    --project-type "Node app" \
    --vibe "A small verified fork that feels ready to build from." \
    --primary-user "Solo builder" \
    --install "npm install" \
    --run "npm run dev" \
    --test "npm test" \
    --lint "npm run lint" \
    --build "npm run build" \
    --primary-agent "codex" \
    --current-stage "prototype" \
    --personas-tier "full"

agents="$temp_root/AGENTS.md"
assert_contains "$agents" 'Project name: `Bootstrap Smoke Project`' "project name"
assert_contains "$agents" 'Project type: `Node app`' "project type"
assert_contains "$agents" 'Primary agent: `codex`' "primary agent"
assert_contains "$agents" 'Primary user: `Solo builder`' "primary user"
assert_contains "$agents" 'Current stage: `prototype`' "current stage"
assert_contains "$agents" "A small verified fork that feels ready to build from." "product goal"
assert_contains "$agents" "npm install" "install command"
assert_contains "$agents" "npm run dev" "run command"
assert_contains "$agents" "npm test" "test command"
assert_contains "$agents" "npm run lint" "lint command"
assert_contains "$agents" "npm run build" "build command"

brief="$temp_root/docs/PROJECT_BRIEF.md"
assert_contains "$brief" "Bootstrap Smoke Project is a Node app project." "generated project brief summary"
assert_contains "$brief" "Primary user: Solo builder" "generated project brief user"

readme="$temp_root/README.md"
assert_contains "$readme" "# Bootstrap Smoke Project" "generated README title"
assert_contains "$readme" "npm install" "generated README install command"
assert_contains "$readme" "AGENTS.md" "generated README agent contract pointer"
assert_contains "$readme" "Built from the AgentOps Template" "generated README provenance"

config="$temp_root/agentops.config.yml"
assert_contains "$config" 'name: "Bootstrap Smoke Project"' "AgentOps config project name"
assert_contains "$config" 'type: "Node app"' "AgentOps config project type"
assert_contains "$config" 'primaryUser: "Solo builder"' "AgentOps config primary user"
assert_contains "$config" 'mode: "full-agentic"' "AgentOps config full mode"
assert_contains "$config" 'test: "npm test"' "AgentOps config test command"

todo="$temp_root/TODO.md"
assert_contains "$todo" "Working queue for Bootstrap Smoke Project" "generated TODO stub"

roadmap="$temp_root/ROADMAP.md"
assert_contains "$roadmap" "Medium-term direction for Bootstrap Smoke Project" "generated ROADMAP stub"

index="$temp_root/Session Logs/_Session Logs Index.md"
assert_contains "$index" "Add one row per session log" "reset session log index"
if grep -qF "Obsidian" "$index"; then
    echo "Session log index still contains template-author residue" >&2
    exit 1
fi

stamp="$temp_root/.vibe-template-version"
expected_version="$(tr -d '\r\n[:space:]' < "$source_root/VERSION")"
if [[ ! -f "$stamp" ]]; then
    echo "Missing .vibe-template-version stamp" >&2
    exit 1
fi
actual_version="$(tr -d '\r\n[:space:]' < "$stamp")"
if [[ "$actual_version" != "$expected_version" ]]; then
    echo "Version stamp mismatch: expected $expected_version, got $actual_version" >&2
    exit 1
fi

bash "$temp_root/scripts/check-agent-docs.sh"
bash "$temp_root/scripts/check-agent-docs.sh" --strict
bash "$temp_root/scripts/check-agent-behavior.sh"

# Full keeps all 11 operating personas active.
for kept in \
    "aegis-defensive-security.md" \
    "code-reviewer-maintainability.md" \
    "cto-vibe-coding.md" \
    "data-analytics-lead.md" \
    "delivery-lead.md" \
    "design-director-vibe-coding.md" \
    "growth-launch-strategist.md" \
    "head-of-product-vibe-coding.md" \
    "ops-deployment-engineer.md" \
    "qa-acceptance-tester.md" \
    "research-scout.md"; do
    if [[ ! -f "$temp_root/personas/$kept" ]]; then
        echo "Full tier missing persona: $kept" >&2
        exit 1
    fi
done

# Standard-tier verification: demoted set should land under personas/optional/
standard_root="$temp_parent/repo-standard"
copy_template "$standard_root"

bash "$standard_root/scripts/init.sh" \
    --non-interactive \
    --project-name "Standard Tier Smoke" \
    --project-type "Web app" \
    --vibe "A standard-tier fork with the ship-it personas." \
    --primary-user "Solo builder" \
    --install "npm install" \
    --run "npm run dev" \
    --test "npm test" \
    --lint "npm run lint" \
    --build "npm run build" \
    --primary-agent "claude" \
    --current-stage "prototype" \
    --personas-tier "standard" \
    --session-logs "committed" >/dev/null

# Standard keeps Product/CTO/QA + code-reviewer + design-director + delivery-lead.
for kept in \
    "head-of-product-vibe-coding.md" \
    "cto-vibe-coding.md" \
    "qa-acceptance-tester.md" \
    "code-reviewer-maintainability.md" \
    "design-director-vibe-coding.md" \
    "delivery-lead.md"; do
    if [[ ! -f "$standard_root/personas/$kept" ]]; then
        echo "Standard tier missing kept persona: $kept" >&2
        exit 1
    fi
done

# Standard demotes the rest (security, data, growth, ops, research).
for demoted in \
    "aegis-defensive-security.md" \
    "data-analytics-lead.md" \
    "growth-launch-strategist.md" \
    "ops-deployment-engineer.md" \
    "research-scout.md"; do
    if [[ ! -f "$standard_root/personas/optional/$demoted" ]]; then
        echo "Standard tier did not demote persona: $demoted" >&2
        exit 1
    fi
    if [[ -f "$standard_root/personas/$demoted" ]]; then
        echo "Standard tier left persona in personas/ when it should have moved: $demoted" >&2
        exit 1
    fi
done

# Committed session-log mode must replace the ignore rule with the note.
assert_contains "$standard_root/.gitignore" "committed in this project" "committed session-log gitignore note"
if grep -qE '^Session Logs/\*\.md' "$standard_root/.gitignore"; then
    echo "Committed session-log mode left an active ignore rule in .gitignore" >&2
    exit 1
fi

assert_contains "$standard_root/agentops.config.yml" 'mode: "standard"' "standard AgentOps config mode"

bash "$standard_root/scripts/check-agent-docs.sh"

# Minimal-tier verification: only Product, CTO, and QA remain active.
minimal_root="$temp_parent/repo-minimal"
copy_template "$minimal_root"

bash "$minimal_root/scripts/init.sh" \
    --non-interactive \
    --project-name "Minimal Tier Smoke" \
    --project-type "CLI" \
    --vibe "A minimal generated fork with only the core decision roles." \
    --primary-user "Solo builder" \
    --install "npm install" \
    --run "npm run dev" \
    --test "npm test" \
    --lint "npm run lint" \
    --build "npm run build" \
    --primary-agent "codex" \
    --current-stage "prototype" \
    --personas-tier "minimal" >/dev/null

for kept in \
    "head-of-product-vibe-coding.md" \
    "cto-vibe-coding.md" \
    "qa-acceptance-tester.md"; do
    if [[ ! -f "$minimal_root/personas/$kept" ]]; then
        echo "Minimal tier missing kept persona: $kept" >&2
        exit 1
    fi
done

for demoted in \
    "aegis-defensive-security.md" \
    "code-reviewer-maintainability.md" \
    "data-analytics-lead.md" \
    "delivery-lead.md" \
    "design-director-vibe-coding.md" \
    "growth-launch-strategist.md" \
    "ops-deployment-engineer.md" \
    "research-scout.md"; do
    if [[ ! -f "$minimal_root/personas/optional/$demoted" ]]; then
        echo "Minimal tier did not demote persona: $demoted" >&2
        exit 1
    fi
    if [[ -f "$minimal_root/personas/$demoted" ]]; then
        echo "Minimal tier left persona active when it should be optional: $demoted" >&2
        exit 1
    fi
done

assert_contains "$minimal_root/agentops.config.yml" 'mode: "lite"' "minimal AgentOps config mode"
bash "$minimal_root/scripts/check-agent-docs.sh" --strict

echo "Bash init smoke tests passed (full, standard, minimal)."
