# AgentOps Template

A forkable, repo-native operating layer for AI-assisted software projects. It aligns Claude Code, Codex, Cursor, Gemini, and Copilot to one governed contract, gives agents explicit state and permission boundaries, and prevents forks from shipping half-configured.

Beyond the operating contract, the template ships an agentic runtime layer (`Agent State/`, `Memory/`, `QA/`), a durable design-system contract (`DESIGN.md`), and the `agentops` CLI (`packages/cli`) that validates, operates, and maintains all of it.

> **Rename status:** the product name is now **AgentOps Template**. The GitHub repository, private root package name, `vibe` CLI alias, and `.vibe-template-version` marker keep their existing names until a coordinated GitHub rename and migration; existing clones and generated forks remain compatible.

## Quickstart

```bash
# 1. Create a new repo from this template (GitHub "Use this template").
# 2. Clone it, then run:
./scripts/init.sh        # macOS / Linux / git-bash on Windows
./scripts/init.ps1       # Windows PowerShell
```

The init script prompts for project name, vibe, install/run/test/lint/build commands, primary agent, and personas tier (`minimal` / `standard` / `full`) -- then fills placeholders, demotes the personas the chosen tier doesn't keep, and runs the drift check. Re-run anytime with `--force` (or `-Force`).

Prefer the manual path? Follow [`docs/SETUP_CHECKLIST.md`](docs/SETUP_CHECKLIST.md).

Verify the template itself with one cross-platform command:

```bash
npm ci
npm run check
```

`npm run check` builds and tests the AgentOps CLI, smoke-tests initialized forks in all three persona tiers, validates agent docs and behavior scaffolding, and checks the design contract. It does not guess the generated project's application stack; `.github/workflows/quality.yml.example` remains the opt-in home for application lint, tests, and builds.

## Relationship to Meta-Agent-OS

[Meta-Agent-OS](https://github.com/SarutobiSasuke8/Meta-Agent-OS) is the methodology upstream: it helps diagnose, design, cost, and govern a multi-agent system before implementation. AgentOps Template is the execution substrate downstream: it turns those decisions into a forkable repository contract, permission gates, agent state, verification, and maintenance routines.

## Persona council in action

Three worked examples show the council doing real work, each grounded in the shipped protocol, personas, and slash commands:

- [**Feature planning**](docs/examples/council-feature-planning.md) -- a narrow `/council` run: three personas, one scope decision, project residue captured.
- [**Refactor review**](docs/examples/council-code-refactor.md) -- `/review` dispatching the read-only `code-reviewer` and `qa-acceptance-tester` subagents on an uncommitted diff.
- [**Full orchestration**](docs/examples/council-orchestration.md) -- how a full-council run fans out parallel subagents, resolves conflicts, and synthesizes one report.

The mechanics behind them: [`personas/agent-council-protocol.md`](personas/agent-council-protocol.md) (routing, sequence, report format) and [`docs/SUBAGENTS.md`](docs/SUBAGENTS.md) (when to fan out and when not to).

## What you get

- **One operating contract** -- `AGENTS.md` is canonical; `CLAUDE.md` / `CODEX.md` / `GEMINI.md` / `.github/copilot-instructions.md` / `.cursor/rules/vibe-coding-core.mdc` are thin tool-specific adapters that point at it.
- **Persona council** -- 11 reusable role prompts (Product, CTO, QA + 8 optional) and an orchestration protocol so multi-perspective work produces one synthesized report instead of eleven.
- **Persona subagents** -- every persona ships as a Claude Code subagent in `.claude/agents/`: isolated, read-only reviewers that `/council` and `/review` fan out to in parallel. See [`docs/SUBAGENTS.md`](docs/SUBAGENTS.md) for when (and when not) to use them.
- **Self-enforcing drift check** -- a `PostToolUse` hook in `.claude/settings.json` runs the drift check automatically whenever Claude Code edits an agent instruction file, so alignment does not depend on anyone remembering to run a script.
- **Project context** -- `docs/PROJECT_BRIEF.md` for the durable "what is this for" doc; see [`docs/examples/PROJECT_BRIEF.example.md`](docs/examples/PROJECT_BRIEF.example.md) for what filled-in looks like.
- **Product philosophy** -- [`docs/WHY.md`](docs/WHY.md) explains why the template exists and what problem it solves.
- **Release spine** -- `VERSION`, [`CHANGELOG.md`](CHANGELOG.md), and [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) define the path to a trustworthy public template release.
- **Session memory** -- append-only `Session Logs/` with a template, index, and clear "when to log" rule.
- **Drift check** -- `scripts/check-agent-docs.ps1` and `.sh` enforce that adapters stay slim, required headings exist, and (in `--strict` / `-Strict` mode) placeholders are replaced. CI runs the standard check on every PR; run strict locally after init in your fork. See [`docs/FAQ.md`](docs/FAQ.md#drift-check-and-strict-mode) for the full rule list.
- **Claude Code scaffolding** -- `.claude/settings.json` with read-only Bash defaults and the drift-check hook, plus slash commands `/brief`, `/spec`, `/council`, `/review`, `/session-log`, `/drift-check`, `/handoff`, `/todo-triage`, `/retro`.
- **PR template** -- matches the AGENTS.md handoff format (Change / Files / Verification / Risks / Session log).
- **Design system contract** -- `DESIGN.md` owns visual language, interaction states, and responsive behavior; `agentops design check` validates it and `agentops design tokens` exports CSS variables.
- **Agentic runtime layer** -- `Agent State/` (run state + task queue), `Memory/` (facts, decisions, failures, open questions), `QA/` (test plan, QA reports, regression log, behavior checks), and the execution-loop / tool-registry / permission-gate docs that make semi-autonomous work bounded and resumable.
- **agentops CLI** -- `agentops check | design | health | doctor | status | next | start | complete | block | maintenance | init` operate the markdown scaffold without hidden state. `.github/workflows/agent-maintenance.yml` schedules the read-only maintenance check weekly.
- **Workflow packs** -- `workflows/` covers first vertical slice, reviews, security review, handoffs, retros, release prep, session logs, and TODO triage.
- **Quality ratchet** -- `docs/QUALITY_RATCHET.md`: every behavior change should leave a durable signal (test, smoke check, eval, or documented decision).

## Conventions in 60 seconds

- Read `AGENTS.md` first. It owns the principles, operating loop, and handoff standard.
- Edit `AGENTS.md` to change agent behavior; adapters only carry tool-specific guidance and stay under 80 lines (drift check enforces this).
- Project context lives in `docs/PROJECT_BRIEF.md`. Read the example before writing your own.
- The public philosophy lives in `docs/WHY.md`; the future CLI split is tracked in `docs/CLI_ROADMAP.md`.
- Release readiness lives in `VERSION`, `CHANGELOG.md`, and `docs/RELEASE_CHECKLIST.md`.
- Multi-persona reviews use `personas/agent-council-protocol.md`.
- Meaningful sessions get a log under `Session Logs/`. See `docs/SESSION_LOGGING.md`.

## Slash commands, subagents, and skills

**Slash commands** are repo-local `.md` files in `.claude/commands/`. They run in Claude Code exactly as written and are checked into the repo, so every fork gets them automatically.

**Subagents** are repo-local `.md` files in `.claude/agents/`: separate agent instances with their own system prompt, context window, and tool restrictions. This template ships one per persona, all read-only. `/council` and `/review` fan out to them in parallel; Claude can also delegate to them on its own based on their descriptions. [`docs/SUBAGENTS.md`](docs/SUBAGENTS.md) covers the how/when/why.

**Skills** are reusable instruction packages (`SKILL.md` files from plugins, user config, or the Claude Code distribution) that Claude loads on demand. They appear in the available-skills list in Claude Code's context. Repo-local slash commands are the safer bet for "every fork should have this."

Commands in this template:

| Command | What it does |
|---|---|
| `/brief` | Summarize current project state from `AGENTS.md` and `docs/PROJECT_BRIEF.md` |
| `/spec` | Draft a feature spec before writing any code |
| `/council` | Run a persona council review on a task |
| `/review` | Review recent changes through Code Reviewer and QA lenses |
| `/session-log` | Create or append a session log entry |
| `/drift-check` | Run the agent doc alignment check |
| `/handoff` | Produce a structured handoff note for the current session |
| `/todo-triage` | Sort `TODO.md` items into Now / Soon / Parking lot with success criteria |
| `/retro` | End-of-session retrospective: what worked, what to codify in `AGENTS.md` |

Add new commands by dropping a `.md` file in `.claude/commands/`. Keep commands focused: one workflow, one output format. The `/brief` and `/handoff` commands are good models.

## FAQ

For the full FAQ see [`docs/FAQ.md`](docs/FAQ.md). The short version:

**Do I need all four agent adapters?** Keep them. They're thin (~30-40 lines each) and forks of this template are friendlier to other contributors when the tools they prefer are pre-configured.

**Do I need all 11 personas?** No. The init prompt offers three tiers: `minimal` (Product, CTO, QA -- 3), `standard` (adds Code Reviewer, Design, Delivery -- 6), and `full` (all 11). Personas not kept move to `personas/optional/`. Promote any optional persona back when its concerns become recurring.

**What if I only use Claude Code?** Same answer as the agents question: leave the others. They cost ~150 lines total and your collaborators may use them.

**Stack-agnostic?** Yes. The template's own cross-platform CI validates only the AgentOps operating layer. Add your application stack after init, then rename `quality.yml.example` to `quality.yml` in `.github/workflows/` when you have real lint/test/build commands to wire up.

## Repo shape

```text
.
+-- .claude/                       # Claude Code config, slash commands, persona subagents
+-- .cursor/rules/                 # Cursor always-on rule
+-- .github/                       # Copilot instructions, PR template, CI
+-- Agent State/                   # Active run state + agent-executable task queue
+-- Memory/                        # Durable facts, decisions, failures, open questions
+-- QA/                            # Test plan, QA reports, regression log, behavior checks
+-- docs/                          # Project brief, agent docs, examples
+-- examples/                      # Completed example artifacts (session log, reference UI)
+-- packages/cli/                  # agentops CLI (TypeScript)
+-- personas/                      # Core + optional role prompts
+-- scripts/                       # init + drift check (ps1 + sh) + behavior check
+-- Session Logs/                  # Append-only session memory
+-- Templates/                     # Session log + project ignition templates
+-- workflows/                     # Reusable workflow packs
+-- AGENTS.md                      # Canonical agent contract
+-- DESIGN.md                      # Durable design-system contract
+-- agentops.config.yml            # Template metadata for checks and upgrades
+-- VERSION                        # Template release version
+-- CLAUDE.md / CODEX.md / GEMINI.md
`-- README.md / ROADMAP.md / TODO.md / CHANGELOG.md / LICENSE
```

## Operating rhythm

- Keep `docs/PROJECT_BRIEF.md` current enough that a new agent becomes useful fast.
- Keep `DESIGN.md` current enough that a new agent can produce coherent UI without rediscovering the visual system.
- Put temporary work in `TODO.md`; promote durable direction into `ROADMAP.md`.
- Update `AGENTS.md` when repeated mistakes or repo-specific conventions appear; re-run drift check.
- Use the persona council for audits, plans, reviews, or implementation handoffs.
- Use `Agent State/` and `Memory/` for agentic work that needs resumable state; run `./scripts/check-agent-behavior.ps1` after changing the runtime scaffold.
- Use `docs/TEMPLATE_MODES.md` to choose lite, standard, or full-agentic operating weight, and `agentops health` for a single readiness dashboard.
- Capture meaningful multi-file or decision-heavy sessions in `Session Logs/`.
- After replacing template placeholders, run `./scripts/check-agent-docs.sh --strict`.
