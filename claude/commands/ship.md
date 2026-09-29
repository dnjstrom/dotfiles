---
description: Run the full research → plan → validate → implement → review pipeline for a piece of work, keeping Linear/GitHub in sync throughout.
argument-hint: <topic, ticket ID, or feature to work on>
---

Work through the following pipeline for: $ARGUMENTS

1. **Research** — invoke the `research-primer` subagent on this topic. Wait
   for its primer before moving on.
2. **Plan** — using the primer, draft an implementation plan (native plan
   mode). Do not start implementing yet.
3. **Validate** — invoke the `plan-validator` subagent on the drafted plan.
   Report its verdict, assumptions, risks, and missing decisions plainly,
   and revise the plan if it says "needs revision." If it surfaced anything
   worth recording against a Linear ticket or GitHub PR, invoke `admin` to
   draft the update, show the draft, and only re-invoke `admin` in send
   mode if it's explicitly approved.
4. **Pause for approval** — present the (possibly revised) plan and stop.
   Do not implement until it's explicitly approved.
5. **Implement** — once approved, implement the plan normally.
6. **Review** — invoke the `code-reviewer` subagent on the resulting diff.
   Report blockers and suggestions; apply fixes for anything agreed on.
7. **Pause for manual review** — present the final diff/summary and stop.
   Do not run `git push`, do not force-push, and do not create or update a
   GitHub PR via `gh pr create`/`gh pr edit --add-...` (opening a PR pushes
   the branch) until this has been explicitly approved. This applies
   regardless of permission mode and even if earlier steps ran unattended —
   nothing reaches the remote before this checkpoint.
8. **Sync** — only after the push/PR has been explicitly approved and done,
   invoke `admin` to draft the Linear ticket and GitHub PR updates
   (what was actually built, remaining to-dos, follow-ups). Present the
   draft in full and only re-invoke `admin` in send mode — with the exact
   approved content — once it's explicitly approved. Nothing gets posted to
   Linear or GitHub without that explicit sign-off, same as the push gate
   above.

Give a short update at each numbered step. If a step doesn't apply (e.g. no
Linear ticket exists for this work), say so explicitly rather than skipping
it silently.
