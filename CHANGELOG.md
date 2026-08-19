# Changelog

All notable changes to this project should be documented here.

The version recorded in `VERSION` is the template's own version, not the version of any project that forks it. This file follows [Keep a Changelog](https://keepachangelog.com/) loosely and uses semantic versioning.

## [Unreleased]

### Added

- Canonical cross-platform `npm run check` covering the workspace build, CLI tests, init smoke tests, agent-doc alignment, agent-behavior validation, and design-contract checks.
- Bash parity for the agent-behavior check and a small platform dispatcher used by local checks and CI.
- Minimal-tier init coverage alongside the existing standard/full smoke cases, plus stronger generated-fork readiness assertions.

### Changed

- Public positioning, the GitHub repository, and the private root package are now **AgentOps Template**. The `vibe` CLI alias and `.vibe-template-version` marker remain compatible with existing clones and generated forks.
- Template CI now runs the canonical check on Linux and Windows without assuming an application framework; generated projects still opt into their own stack-specific quality workflow.
- Root package metadata now declares its MIT license, supported Node/npm engines, repository links, issue tracker, homepage, and discovery keywords.
- README now distinguishes [Meta-Agent-OS](https://github.com/SarutobiSasuke8/Meta-Agent-OS) as the methodology upstream from AgentOps Template's repository execution layer.

## [0.3.0] - 2026-07-31

Reunifies two diverged lines of the template: the published v0.2.0 (persona subagents, self-enforcing drift check, fork-ready init) and a local line that built the `agentops` CLI, the agentic runtime layer, and the design-system contract. Both feature sets now live in one history.

### Added

- **agentops CLI** (`packages/cli`, TypeScript): `check`, `design check`, `design tokens`, `health`, `doctor`, `status`, `next`, `start`, `complete`, `block`, `maintenance`, and `init` operate the markdown scaffold without hidden state. Tests run via `npm test`.
- **Agentic runtime layer**: `Agent State/` (run state + agent-executable task queue), `Memory/` (project facts, decisions, failures, open questions), `QA/` (test plan, QA report template, regression log, agent behavior checks), plus `docs/AGENT_EXECUTION_LOOP.md`, `docs/AGENT_TOOL_REGISTRY.md`, and `docs/AGENT_PERMISSION_GATES.md`. Validated by `scripts/check-agent-behavior.ps1`.
- **Design system contract**: `DESIGN.md` owns visual language, interaction states, and responsive behavior; `agentops design` validates it and exports CSS variables. Reference implementation in `examples/reference-ui/`.
- **Quality ratchet**: `docs/QUALITY_RATCHET.md` — every behavior change should leave a durable signal.
- **Workflow packs**: `workflows/` for first vertical slice, reviews, security review, handoffs, retros, release prep, session logging, and TODO triage.
- **Template operating docs**: `docs/TEMPLATE_MODES.md` (lite / standard / full-agentic), `docs/TEMPLATE_HEALTH.md`, `docs/TEMPLATE_UPGRADE_STRATEGY.md`, `docs/ADAPTERS.md`, `docs/COMMAND_REFERENCE.md`, and `Templates/PROJECT_IGNITION_TEMPLATE.md`.
- **Scheduled maintenance**: `.github/workflows/agent-maintenance.yml` runs the read-only maintenance check weekly and uploads a JSON report artifact.
- `.gitattributes` line-ending normalization.

### Changed

- `AGENTS.md` now carries the runtime layer, design system, and quality ratchet sections on top of the v0.2.0 contract.
- CI (`.github/workflows/agent-docs.yml`) also triggers on runtime/CLI paths and runs the CLI test suite.
- The drift-check pair (`check-agent-docs.sh` / `.ps1`) remains the v0.2.0 parity implementation; richer structural validation is the CLI's job (`agentops check`).

### Removed

- Per-persona slash commands (`/product`, `/cto`, `/qa`, `/security`, `/code-review`, `/research`) — superseded by the v0.2.0 persona subagents plus `/council` and `/review`.
- `examples/PROJECT_BRIEF.example.md` — superseded by the richer `docs/examples/PROJECT_BRIEF.example.md`.

## [0.2.0] - 2026-06-09

Persona subagents, a self-enforcing drift check, and a clean-fork init. The headline: the persona council now runs as parallel, isolated, read-only Claude Code subagents instead of one model role-playing eleven voices.

### Added

- **Persona subagents** (`.claude/agents/`): one Claude Code subagent per persona, all read-only. Wrappers load the persona file from `personas/` or `personas/optional/` at runtime, so the tier system needs no extra configuration. New guide: `docs/SUBAGENTS.md` (what subagents are, why they beat in-context role-play for review work, when not to use them, how to add your own).
- **Parallel council**: `/council` fans the routed personas out as parallel subagents and synthesizes one report; `/review` dispatches `code-reviewer` + `qa-acceptance-tester` the same way. The council protocol now documents both execution modes (parallel subagents in Claude Code, sequential in-context elsewhere) and a compact persona report format.
- **Drift-check hook**: a `PostToolUse` hook in `.claude/settings.json` (`scripts/hooks/post-edit-drift-check.sh`) runs the drift check automatically whenever Claude Code edits an agent instruction file, with failures fed back as blocking feedback.
- **Fork-ready init output**: init now generates a project `README.md`, starter `TODO.md` and `ROADMAP.md`, and a reset session-log index, so a fork no longer ships the template's own README, queue, roadmap, and log history.
- **Session-log mode**: init now asks whether session logs are local-only (default) or committed, and adjusts `.gitignore` for the committed mode (recommended for teams and cloud agents); `--session-logs` / `-SessionLogs` answers non-interactively. Tradeoffs documented in `docs/SESSION_LOGGING.md`.
- **Drift-check coverage**: subagent frontmatter validation (name matches filename, description present), required core subagents, and a slash-command sync check (every `.claude/commands/*.md` must be listed in `AGENTS.md`).
- Frontmatter `description` on every slash command for discoverability in Claude Code's command menu.

### Fixed

- `/review`, `/council`, and the council protocol no longer break when init demotes personas to `personas/optional/` — all references now resolve either location.
- `AGENTS.md` slash-command list was missing `/drift-check` and `/handoff`; now listed and enforced by the drift check.
- Session-log index shipped with the template author's own log entries and themes; now reset to a portable starter (and init resets it in forks).
- Canonical docs referenced only the PowerShell drift-check script; both script paths are now shown everywhere.
- README described skills as "Anthropic-hosted scripts"; corrected.
- Init no longer regenerates the project brief on re-runs without `--force`.
- Removed `Edit` / `Write` / `NotebookEdit` from the project `ask` permission rules: project-level `ask` overrides the user's own permission mode, so the old config forced an approval prompt on every file edit regardless of auto-accept settings. Risky operations (`git push`, `git commit`, `rm`, web access) remain gated; the new drift-check hook covers agent-doc edits after the fact.

## [0.1.0] - 2026-05-08

First public template release. The repo is now stable enough that a stranger can fork it, run init, pass the drift check, and start a real project without author guidance.

### Added

- Canonical agent contract in `AGENTS.md`, with thin adapters for Claude (`CLAUDE.md`), Codex (`CODEX.md`), Gemini (`GEMINI.md`), Copilot (`.github/copilot-instructions.md`), and Cursor (`.cursor/rules/vibe-coding-core.mdc`).
- 11-persona council (3 core + 8 optional) under `personas/`, with the orchestration protocol in `personas/agent-council-protocol.md`.
- Three-tier persona setup: `minimal` (Product, CTO, QA), `standard` (adds Code Reviewer, Design Director, Delivery Lead), `full` (all 11). The init script demotes the personas the chosen tier does not keep into `personas/optional/`.
- Init scripts (`scripts/init.ps1` and `scripts/init.sh`) that prompt for project identity, vibe, commands, primary agent, stage, and personas tier, then fill placeholders and run the drift check.
- Drift-check scripts (`scripts/check-agent-docs.ps1` and `scripts/check-agent-docs.sh`) with standard and `--strict` modes, configurable adapter line cap, and a documented exemption list.
- Init smoke tests (`scripts/test-init.ps1` and `scripts/test-init.sh`) covering the `full` and `standard` tiers; both run in CI on every PR via `.github/workflows/agent-docs.yml`.
- Public-facing docs: `README.md`, `docs/WHY.md` (philosophy), `docs/FAQ.md` (common questions), `docs/SETUP_CHECKLIST.md` (manual fallback path), `docs/RELEASE_CHECKLIST.md`, `docs/CLI_ROADMAP.md`.
- Internal agent docs: `docs/AGENT_OPERATING_PRINCIPLES.md`, `docs/AGENT_ALIGNMENT.md`, `docs/PERSONA_COUNCIL.md`, `docs/PROJECT_BRIEF.md`, `docs/RALPH_LOOP.md`, `docs/RIPER_WORKFLOW.md`, `docs/SESSION_LOGGING.md`.
- Worked example brief at `docs/examples/PROJECT_BRIEF.example.md` (Sparkbar) so forkers know what "filled in" looks like.
- Claude Code scaffolding under `.claude/`: settings with read-only Bash defaults and slash commands `/brief`, `/spec`, `/council`, `/review`, `/session-log`, `/drift-check`, `/handoff`, `/todo-triage`, `/retro`.
- Session memory: append-only `Session Logs/` with `_Session Logs Index.md`, the template `Templates/SESSION_LOG_TEMPLATE.md`, and the policy in `docs/SESSION_LOGGING.md`.
- Release spine: `VERSION` file, this changelog, and `docs/RELEASE_CHECKLIST.md`.
- Upgrade-detection marker: init stamps `.vibe-template-version` in the fork root, recording the template version the fork was initialized from. Future CLI tooling will use this to suggest migrations.
- PR template (`.github/pull_request_template.md`) matching the AGENTS.md handoff format.

### Verified

- Fresh clone -> `./scripts/init.sh` -> `./scripts/check-agent-docs.sh` passes.
- Initialized fork -> `./scripts/check-agent-docs.sh --strict` passes.
- Both init smoke tests exercise `full` and `standard` tiers and verify persona demotion.
- CI runs both drift checks and both init tests on every PR.

### Known limitations

- No CLI yet -- everything is shell scripts and Markdown. The CLI roadmap (`docs/CLI_ROADMAP.md`) describes the split point for future tooling.
- No automatic upgrade path between template versions. Forks track template changes manually for now.
- Stack-agnostic by design -- the template ships no language or framework code.

[Unreleased]: https://github.com/SarutobiSasuke8/agentops-template/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/SarutobiSasuke8/agentops-template/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/SarutobiSasuke8/agentops-template/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/SarutobiSasuke8/agentops-template/releases/tag/v0.1.0
