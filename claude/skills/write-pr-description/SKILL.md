---
name: write-pr-description
description: Write or rewrite a GitHub pull request description in a short, reviewer-focused structure — the problem, the solution in broad strokes, the details a reviewer needs (risks, decisions, trade-offs), and any steps needed to roll the change out. Use whenever drafting, writing, updating or rewriting a PR description or body, including before `gh pr create` or `gh pr edit --body`.
---

Write the PR description for a human reviewer who has not seen the work.
Its job is to let them understand what changed and why within a minute,
and to point their attention at what deserves it. Every sentence must be
worth reading; when in doubt, cut it.

## Gather

- The full diff against the base branch and the commit messages, not
  just the latest commit. Describe what the PR does as a whole now, not
  how it got there.
- The linked ticket (Linear/GitHub issue), if any, for the why.
- The repo's PR template (`.github/pull_request_template.md` or similar).
  If one exists, fill its required sections and fit the structure below
  into it rather than replacing it.
- An existing description, when updating: keep what is still accurate
  and correct what is not.

## Structure

```markdown
## Problem
<Why this change is needed: the problem, gap or goal, and its impact.
1–3 sentences.>

## Solution
<What the PR does about it, in broad strokes: the approach and the main
moving parts, not a file-by-file list. 1–5 sentences or short bullets.>

## Details
- <Risk, decision, trade-off or other point the reviewer should know>
- …

## Rollout
- [ ] <Step needed before, during or after merging>
- …

<Ticket reference, e.g. "Fixes EXP-123", if one exists>
```

- **Problem** states the motivation in terms of behaviour or outcomes
  (what users, the system or developers can't do, or what goes wrong),
  not in terms of code.
- **Solution** explains the shape of the change so the diff makes sense
  when read. Name a component, function or file only where it helps the
  reviewer orient. Leave out anything the diff already makes obvious.
- **Details** holds only what a reviewer would want to know but can't
  easily see in the diff, for example:
  - risks: behaviour changes, backwards compatibility, performance;
  - decisions and trade-offs: an alternative that was considered and
    why it was rejected, or a known limitation accepted on purpose;
  - where to look closely, or what can be skimmed (e.g. generated or
    mechanical changes);
  - how the change was verified, when that isn't obvious from the tests
    in the diff;
  - follow-ups deliberately left out of scope.

  Omit the section entirely if nothing qualifies. Don't pad it.
- **Rollout** is a checklist of what has to happen for the change to
  ship safely beyond merging and the normal deploy, so nothing is
  forgotten at merge time, for example:
  - merge or deploy order relative to other PRs or services;
  - migrations, backfills or one-off scripts to run;
  - config, secrets, environment variables or feature flags to set;
  - infrastructure or third-party setup;
  - checks to make after deploy, and how to roll back if it isn't
    trivial.

  Each item is a concrete action (`- [ ]`), checked off (`- [x]`) once
  done, with the PR or ticket it depends on linked. Omit the section
  entirely if merging and the normal deploy are all it takes.

## Style

- Short. A typical description fits on one screen; a small PR may need
  only two or three sentences in total. Length follows the change's
  conceptual weight, not its line count.
- Plain, precise language. Simple words, short sentences, one idea per
  bullet. Accuracy over salesmanship: no "robust", "seamless",
  "comprehensive", and no claims the diff doesn't back up.
- No filler: no restating the title, no summary of every file touched,
  no list of commits, no generic testing boilerplate ("ran the tests"),
  no empty or "N/A" sections.
- Neutral and impersonal: describe the change, not the author ("This
  adds…", "Adds…", not "I added…").
- Markdown that renders well on GitHub: `##` headings, `-` bullets,
  backticks for identifiers.
- Keep any attribution footer that other instructions require, after
  the content.

## Title

If the PR title is also being written, make it a short imperative
summary of the change (e.g. "Let admins hide order types from
reports"), following the repo's conventions such as a ticket-ID prefix.

## Review before using

Reread the draft as the reviewer would and cut every sentence that
doesn't change what they understand or check. Confirm each claim
against the diff.
