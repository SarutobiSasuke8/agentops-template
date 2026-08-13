# Worked Example: Feature Planning Council Run

A narrow council run using the smallest set of personas that covers the risk. This is the most common way to use the council day to day: a scoped question, three or four lenses, one synthesized answer.

The transcript below is illustrative. Your output will differ; the shape should not.

## The situation

You are two weeks into a fork of this template (a habit-tracking web app, per the sample brief in [`PROJECT_BRIEF.example.md`](PROJECT_BRIEF.example.md)). You are considering adding streak-freeze tokens, a retention feature, before the first public release. You want a decision, not code.

## What you type

```text
/council Should we add streak-freeze tokens before the first public release, or ship without them?
```

## What happens

1. The conductor reads `personas/agent-council-protocol.md` and `AGENTS.md`.
2. This is a strategy and scope question, so the routing table selects **Head of Product**, **Research Scout**, and **Delivery Lead**. It does not invoke all eleven roles for a narrow question.
3. In Claude Code, those three personas launch as parallel subagents from `.claude/agents/` (see [`../SUBAGENTS.md`](../SUBAGENTS.md)). Each receives a self-contained prompt: the mission, the relevant files (`docs/PROJECT_BRIEF.md`, `ROADMAP.md`, `TODO.md`), and the compact persona report format.
4. The conductor synthesizes the three reports into one council report. You never see three separate persona essays.

## Illustrative output

```text
1. Verdict
Ship without streak-freeze tokens. Medium-high confidence.

2. Council Read
- Product: freezes reward retained users; you have no retained users yet.
  First release should prove the core loop, not soften it.
- Research: comparable habit apps added freeze mechanics after product-market
  fit, not before. No evidence it drives day-one adoption.
- Delivery: adding it now touches the streak model, storage schema, and two
  screens. Estimated one extra week against a release that is otherwise ready.

3. Key Findings
1. The feature protects a metric (streak retention) that does not exist yet.
2. Schema changes now would be cheap; screens and edge cases are the real cost.
3. Nothing in the current release blocks adding freezes later.

4. Decisions
- Do: ship the release as scoped.
- Defer: streak freezes to the first post-launch iteration.
- Do now (cheap insurance): leave room in the streak data model for a
  freeze concept so the later migration is trivial.

5. Action Plan
1. Add a ROADMAP.md entry for streak freezes under "post-launch".
2. Note the data-model allowance in docs/PROJECT_BRIEF.md constraints.
3. Proceed with the release checklist.

6. Open Questions
- None blocking.

7. Project Residue
- ROADMAP.md entry (created), TODO.md item for the schema allowance (created).
```

## Notes

- The routing table lives in [`../../personas/agent-council-protocol.md`](../../personas/agent-council-protocol.md). For strategy and scope questions it suggests Product, Research, and Delivery, optionally Growth and Data.
- If subagents are unavailable (Cursor, Codex, Gemini, Copilot), the same personas are applied sequentially in-context from the persona files. Same report, slower path.
- "Project residue" is the part most people skip and should not: decisions that never land in `ROADMAP.md`, `TODO.md`, or a session log get relitigated a week later.
