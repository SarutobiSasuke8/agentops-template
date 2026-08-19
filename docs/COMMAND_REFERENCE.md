# Command Reference

## Current Scripts

### `npm run check`

Canonical cross-platform verification for the AgentOps Template itself. It runs the stable template-owned checks only:

- workspace build
- AgentOps CLI unit tests
- generated-fork init smoke tests for minimal, standard, and full tiers
- agent-doc alignment
- agent-behavior scaffold validation
- design-contract validation

It deliberately does not infer or run a generated project's application-specific commands. Forks activate `.github/workflows/quality.yml.example` once their real stack is known.

### `./scripts/check-agent-docs.ps1`

Validates the repo-level agent operating layer.

Useful options:

```powershell
./scripts/check-agent-docs.ps1
./scripts/check-agent-docs.ps1 -Strict
```

The check covers required files, required headings, adapter markers, adapter line caps, subagent frontmatter, and the AGENTS.md slash-command listing. A bash twin (`./scripts/check-agent-docs.sh`) behaves identically. Richer structural validation (design contract, runtime scaffold, private template leaks) lives in `agentops check`.

### `./scripts/check-agent-behavior.ps1`

Validates the agentic runtime scaffold:

- `Agent State/`
- `Memory/`
- `docs/AGENT_EXECUTION_LOOP.md`
- `docs/AGENT_TOOL_REGISTRY.md`
- `docs/AGENT_PERMISSION_GATES.md`
- `QA/AGENT_BEHAVIOR_CHECKS.md`

Run it after changing tool permissions, state files, memory conventions, or execution-loop rules.
A bash twin (`./scripts/check-agent-behavior.sh`) provides the same validation on Linux and macOS.

## Planned CLI

### `agentops check`

Cross-platform version of the current validation script. It should support human-readable output, JSON output, strict mode, and CI-friendly exit codes.

### `agentops init`

Initialize a repo from the template by filling the main project placeholders.

```bash
agentops init \
  --name "Recipe Ledger" \
  --type "web app" \
  --primary-user "home cooks" \
  --stage "prototype" \
  --goal "Help home cooks save reliable recipes and rebuild grocery lists." \
  --package-manager "npm" \
  --install "npm install" \
  --dev "npm run dev" \
  --test "npm test" \
  --lint "npm run lint" \
  --build "npm run build" \
  --mode "standard" \
  --desired-vibe "calm, fast, and trustworthy" \
  --adapt-design "Use the default DESIGN.md and tighten density for operational screens."
```

The command updates:

- `AGENTS.md`
- `docs/PROJECT_BRIEF.md`
- `DESIGN.md`
- `agentops.config.yml`
- `Agent State/agent-state.md`
- `Agent State/task-queue.md`
- `Memory/project-facts.md`
- `Memory/decisions.md`

The first version is deliberately non-interactive so agents and CI can use it predictably.

### `agentops design check`

Validate the root `DESIGN.md` contract.

```bash
agentops design check
agentops design check --json
```

The check verifies required design sections, core color roles, component tokens, and the links between `DESIGN.md`, `docs/PROJECT_BRIEF.md`, and the Design Director persona.

### `agentops design tokens`

Export CSS custom properties from `DESIGN.md`.

```bash
agentops design tokens
agentops design tokens --out src/styles/design-tokens.css
```

Use this as the first bridge from design contract to implementation. Stack-specific token generation can be added later once the project chooses Tailwind, CSS modules, vanilla-extract, shadcn/ui, or another UI layer.

### `agentops health`

Show one template health dashboard.

```bash
agentops health
agentops health --json
```

Health summarizes agent doc alignment, runtime readiness, design contract status, setup placeholders, command configuration, and session memory.

### `agentops sync`

Regenerate generated adapter sections from `AGENTS.md` while preserving custom sections.

### `agentops doctor`

Report current agentic readiness and the next useful action from `Agent State/` and `Memory/`.

```bash
agentops doctor
agentops doctor --json
agentops doctor --root ./some-project
```

The doctor command checks runtime files, summarizes current goal, active task, next ready task, blockers, verification status, and suggests the next action for a single-orchestrator agent run.

### `agentops status`

Show all task IDs currently found in `Agent State/task-queue.md`.

```bash
agentops status
agentops status --json
```

### `agentops next`

Show the current active task, task waiting for verification, or next ready task.

```bash
agentops next
agentops next --json
```

### `agentops start`

Move a ready task to active and update `Agent State/agent-state.md`.

```bash
agentops start
agentops start A-002
```

### `agentops complete`

Move the active task to done. A verification note is required.

```bash
agentops complete --verification "npm test passed"
```

### `agentops block`

Move the active task to blocked. A reason is required.

```bash
agentops block --reason "Needs API key"
```

### `agentops maintenance`

Run the first safe autonomous maintenance check. This command is read-only: it reports readiness and next actions without moving tasks or editing files.

```bash
agentops maintenance
agentops maintenance --json
agentops maintenance --no-tests
agentops maintenance --out reports/agent-maintenance.json
npm run maintenance
npm run maintenance:quick
npm run maintenance:report
```

The maintenance check runs:

- `agentops doctor`
- task status inspection
- next-task lookup
- agent docs validation
- agent behavior scaffold validation
- `npm test` when `package.json` exists, unless `--no-tests` is used

Use `--out <path>` to write the full JSON report as an artifact. The scheduled GitHub workflow writes `reports/agent-maintenance.json` and uploads it as `agent-maintenance-report`.
