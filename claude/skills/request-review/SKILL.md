---
name: request-review
description: Draft a Slack message that requests reviews on one or more open PRs for a Linear ticket, in the format used in #mission-experience-internal, show it for approval, and post it to that channel once Daniel approves. Use when asked to request reviews, announce PRs for review, or write a review-request Slack message.
argument-hint: [Linear ticket ID] [PR URLs…]
---

Request reviews for: $ARGUMENTS

## Destination

#mission-experience-internal (Slack channel ID `C0BSM9QAUUF`), unless
Daniel names another channel.

## Gather

- The Linear ticket: its ID, title and URL.
- Each PR: repo, number and URL, and what it does. Read the PR title and
  description (`gh pr view <url> --json title,body`) rather than guessing.

## Format

```
:pr-opened: *<Ticket title>* [<TICKET-ID>](<Linear issue URL>)
- <What the PR does> [<repo>#<number>](<PR URL>)
- <What the PR does> [<repo>#<number>](<PR URL>)
```

Example:

```
:pr-opened: *Visible order types and statuses* [EXP-927](https://linear.app/demaai/issue/EXP-927/visible-order-types-and-statuses)
- Lets admins change which order types and statuses count in their reports [dema-api#1515](https://github.com/demaai/dema-api/pull/1515)
- Shows the setting on a new read-only Settings page [dema-app#2244](https://github.com/demaai/dema-app/pull/2244)
- Counts orders by type and status, including orders the setting hides [statistics-api#1535](https://github.com/demaai/statistics-api/pull/1535)
```

Rules:

- **First line:** `:pr-opened:`, then the ticket title in bold with
  single asterisks (`*…*`, Slack bold). Only the title is bold. The
  ticket ID follows as a Markdown link, with no parentheses or colon.
- **One bullet per PR** (`-`, an unordered list), with no leading repo
  name. Each bullet says in plain words what the PR does for its users,
  starting with a capitalised verb ("Lets…", "Shows…", "Counts…"). Keep
  it to one short clause, with no implementation detail (no field,
  scope or function names).
- **PR tag at the end** of each bullet: `[<repo>#<number>](<PR URL>)`.
  The description itself is plain text, not a link, and no raw URLs
  appear.
- **Links use Markdown** (`[text](url)`), not Slack's `<url|text>`.
- **No mentions** of reviewers or anyone else, and no extra lines: no
  "Background:" line, no notes on dependencies or merge order, no
  judgements about the PRs (e.g. "short and self-contained"), and no
  "reviews welcome".

## Approve

Show the draft in a fenced code block, name the destination channel, and
ask whether to send it. Send nothing until Daniel explicitly approves
this draft. If Daniel asks for changes, revise and show the new draft
again; approval of an earlier version does not carry over.

## Send (only after explicit approval)

Post the approved text unchanged with `slack_send_message` to the
destination channel (for a channel other than the default, find its ID
with `slack_search_channels`). Don't schedule it or save it as a Slack
draft instead. Report back with the link to the posted message.
