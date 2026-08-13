# Worked Example: Refactor Review With /review

A review pass over real changes using the `code-reviewer` and `qa-acceptance-tester` subagents. This is the "spend one subagent verifying" pattern recommended in [`../SUBAGENTS.md`](../SUBAGENTS.md): implement in the main conversation, then get an independent read before committing.

The transcript below is illustrative. Your output will differ; the shape should not.

## The situation

You have just refactored a storage module: extracted a `persistence` layer from three components that each talked to `localStorage` directly. The diff touches five files and is uncommitted. It works when you click around, but "works when I click around" is not a review.

## What you type

```text
/review
```

No arguments needed: the command inspects `git diff` for uncommitted work (or `git diff HEAD~1`, or a range you name).

## What happens

1. The conductor identifies the diff in scope.
2. It launches two subagents in parallel: `code-reviewer` (wrapping `personas/code-reviewer-maintainability.md`) and `qa-acceptance-tester` (wrapping `personas/qa-acceptance-tester.md`).
3. Each subagent is read-only by construction: its tool set omits Edit and Write. It reads the diff and the surrounding files in its own context window, so twenty files of reading never floods your main conversation.
4. The conductor synthesizes both reports into one review, findings first.

## Illustrative output

```text
Review of uncommitted diff (5 files, +214 / -167)

1. Correctness risks
- HIGH: persistence.load() returns null on parse failure, but
  HabitList still destructures the result. Pre-refactor code had a
  try/catch here; it did not survive the extraction.
- MEDIUM: two components previously read localStorage on every render;
  the new layer caches at module load. Stale reads are now possible if
  another tab writes. Acceptable if single-tab is an accepted constraint;
  document it either way.

2. Missing states
- The empty-store first-run path renders a blank list with no
  affordance. Pre-refactor code seeded a demo habit.

3. Acceptance gaps
- QA: no behaviour check covers "data survives reload". That is the
  entire promise of this refactor. Add one before calling it done.

4. Follow-up items
- The migration shim for the old storage key can be deleted in a
  release or two; add a dated TODO.

Verdict: sound refactor, one real bug (the null destructure), one
missing behaviour check. Fix both before committing.
```

## After the review

The subagents surface findings; they never edit your code. You fix the null-handling bug and add the reload behaviour check in the main conversation, then commit. If the change was risky or decision-heavy, `/session-log` records what happened and why.

## Notes

- `/review` is the two-persona shortcut. For refactors with architectural weight, run `/council` instead: the routing table sends implementation work to CTO, Code Reviewer, QA, and Ops, optionally AEGIS.
- Read-only reviewers are a deliberate constraint, not a limitation: a reviewer that cannot "helpfully fix" your code cannot quietly widen the change. See the Surgical Changes discussion in [`../SUBAGENTS.md`](../SUBAGENTS.md).
