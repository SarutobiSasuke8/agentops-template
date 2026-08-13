# Worked Example: Full Council Orchestration

How a full-council run is actually orchestrated: parallel subagent fan-out, self-contained prompts, and conductor synthesis. Read this one to understand the machinery; the other two examples ([feature planning](council-feature-planning.md), [refactor review](council-code-refactor.md)) show the everyday narrow runs.

The transcript below is illustrative. Your output will differ; the shape should not.

## When a full council is warranted

Full audits and major planning only. The routing table in [`../../personas/agent-council-protocol.md`](../../personas/agent-council-protocol.md) is explicit: do not invoke every role for a narrow task. A full run launches up to eleven subagents, each of which re-reads the contract and the brief, so token cost multiplies. Use it for release readiness, repo audits, and direction-setting.

## What you type

```text
/council
```

With no arguments, `/council` runs a full project review: the conductor loads `docs/PROJECT_BRIEF.md`, `ROADMAP.md`, and `TODO.md`, then routes through all relevant council roles.

## The orchestration, step by step

### 1. Mission intake

Before any fan-out, the conductor establishes: the goal, the file set in scope, whether the work is read-only, the desired output, constraints, success criteria, and which risks demand which personas. This comes straight from the Mission Intake section of the protocol.

### 2. Parallel fan-out

The conductor launches the selected personas as parallel subagents in a single message. Sequence matters only for synthesis, not execution: independent personas run simultaneously; only **Delivery Lead**, which consumes the others' output, runs after them.

Every prompt must be self-contained because subagents cannot see the conversation. A real fan-out prompt to one persona looks like this:

```text
You are reviewing the project for a full council audit.

Mission: assess release readiness of the current state of this repo.
Success criteria: a go/no-go input from your lens, with evidence.
In scope: docs/PROJECT_BRIEF.md, ROADMAP.md, TODO.md, QA/, and the
current state of the source tree.

Return the compact persona report format:
- Persona and one-line verdict with confidence
- Top findings (3-5, ordered by severity, with evidence)
- Risks or constraints other personas must respect
- Recommendation (do / defer / reject, with the smallest credible path)
```

The same mission text goes to every persona; the lens differs because each subagent loads its own persona file from `personas/` (or `personas/optional/` if init demoted it).

### 3. Conflict resolution

Reports come back disagreeing. That is the point. The conductor resolves conflicts in the protocol's fixed order: `AGENTS.md` and explicit user instructions first, then safety and source quality, then product value, then correctness, then delivery momentum, then polish. Disagreements are named, not smoothed over:

```text
Disagreement: Growth wants a public changelog page in this release.
CTO warns it adds a content pipeline the team will not maintain.
Decision: defer. Reason: correctness and momentum outrank launch polish
(conflict order 4 and 5 over 6). Residual risk: launch post has no
canonical page to link; acceptable.
```

### 4. Synthesis

The user sees exactly one council report in the seven-part format: Verdict, Council Read, Key Findings, Decisions, Action Plan, Open Questions, Project Residue. Never a stack of eleven persona essays; the protocol lists that as its first anti-pattern.

## Fallback without subagents

Codex, Cursor, Gemini, and Copilot ignore `.claude/agents/`. In those tools the conductor applies the persona files sequentially in-context, in the council sequence order, using each persona's section as an internal checklist, and synthesizes the same report. Same output shape, no parallelism.

## Notes

- The subagent-to-persona mapping table lives in [`../SUBAGENTS.md`](../SUBAGENTS.md).
- All shipped subagents are read-only: a council advises, the main conversation implements.
- Handoff rules (who passes what to whom) are defined in the protocol and matter most for Delivery Lead, whose final plan is only as good as the inputs it was handed.
