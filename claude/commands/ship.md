---
description: Run the full research → plan → validate → implement → review pipeline for a piece of work, keeping Linear/GitHub in sync throughout.
argument-hint: <topic, ticket ID, or feature to work on>
---

Work through the following pipeline for: $ARGUMENTS

1. **Research** — invoke the `research-primer` subagent on this topic. Wait
   for its primer before moving on. First make sure it reads current code:
   - Look for existing work: for dema, `dex ls` for a stack named after
     the ticket; elsewhere, a branch named after it (local or remote).
   - Run `git fetch` in each repo likely involved (the stack's
     worktrees, or the clones in `~/Dema.ai/repositories`), since the
     subagent runs in plan mode and may not be able to.
   - Tell the primer which ref to read per repo: the existing stack's or
     branch's ref if there is one, otherwise `origin/<default>`. Check
     the primer's "Code researched" section matches before moving on.
2. **Workspace** — set up where the work happens, using the primer to
   decide which repos it touches. For dema repos (cloned in
   `~/Dema.ai/repositories`), a `dex` stack is the preferred way to
   start; see the `dex` skill for its commands and rules, and run it
   inside `~/Dema.ai`'s environment as the global instructions describe.
   Stacks live in `~/Dema.ai/workspaces/<stack>`.
   - Check `dex ls` first and reuse a stack that already exists for this
     ticket instead of making a second one.
   - Otherwise run `dex new <TICKET-ID> <repo…> -d`, naming every repo
     the primer says the change touches, including repos dex doesn't run
     (they get a worktree too). Without a Linear ticket, use a short
     kebab-case name instead of the ID. `-d` returns once the worktrees
     exist, so planning can continue while the stack installs.
   - Move the session there. If it already runs in the stack's folder
     (`dex path <stack>`) or one of its checkouts, nothing to do.
     Otherwise switch into the main repo's worktree with `EnterWorktree`
     (`path: <stack folder>/<repo>`). If that's rejected (it only accepts
     worktrees of a repo under the launch directory), work in the stack
     with absolute paths and `git -C`, and tell the user that
     `dex cd <stack>` followed by `claude` gives a session with the whole
     stack as its cwd.
   - Never edit a primary clone in `~/Dema.ai/repositories` directly.
   - For work outside dema's repos, or if `dex` isn't available, say so
     and use the current checkout on a new branch from an up-to-date
     default branch.
   - Report the stack name, its folder, and each repo's branch.
3. **Plan** — using the primer, draft an implementation plan (native plan
   mode). Do not start implementing yet.
4. **Validate** — run the plan through a review loop (see *Review loops*
   below) with the `plan-validator` subagent. A round requests a major
   change when its verdict is "needs revision" or "needs more research";
   revise the plan (doing the extra research if asked) and validate
   again. Report each round's verdict, assumptions, risks, and missing
   decisions plainly. If it surfaced anything worth recording against a
   Linear ticket or GitHub PR, invoke `admin` to draft the update, show
   the draft, and only re-invoke `admin` in send mode if it's explicitly
   approved.
5. **Pause for approval** — present the (possibly revised) plan and stop.
   Do not implement until it's explicitly approved.
6. **Implement** — once approved, implement the plan normally.
7. **Review** — run the diff through a review loop with the
   `code-reviewer` subagent. A round requests a major change when it
   reports any blockers (verdict "net-positive with required fixes" or
   "needs rework"); fix them and review again, giving the reviewer the
   previous round's findings so it checks they were resolved instead of
   starting over. Apply agreed suggestions along the way, but
   suggestions alone don't trigger another round. Report blockers and
   suggestions each round.
8. **Pause for manual review** — present the final diff/summary and stop.
   Do not run `git push`, do not force-push, and do not create or update a
   GitHub PR via `gh pr create`/`gh pr edit --add-...` (opening a PR pushes
   the branch) until this has been explicitly approved. This applies
   regardless of permission mode and even if earlier steps ran unattended —
   nothing reaches the remote before this checkpoint.
9. **Sync** — only after the push/PR has been explicitly approved and done,
   invoke `admin` to draft the Linear ticket and GitHub PR updates
   (what was actually built, remaining to-dos, follow-ups). Present the
   draft in full and only re-invoke `admin` in send mode — with the exact
   approved content — once it's explicitly approved. Nothing gets posted to
   Linear or GitHub without that explicit sign-off, same as the push gate
   above.

## Review loops

Steps 4 and 7 loop between revising and re-reviewing until a round
requests no major changes. Count the rounds and say which one is running
("validation round 3"). If a 10th round still requests major changes,
abort the pipeline: don't start an 11th round, and don't move on to the
next step. Tell the user why the work won't settle:

- what each round asked for, one line per round
- which concerns keep coming back, or which fixes keep undoing each other
- the underlying disagreement or open decision, as far as it can be named
  (e.g. the plan's approach conflicts with a constraint, or the reviewer
  and the plan want different things)
- what would unblock it: a decision from the user, more research, or a
  smaller scope

Give a short update at each numbered step. If a step doesn't apply (e.g. no
Linear ticket exists for this work), say so explicitly rather than skipping
it silently.
