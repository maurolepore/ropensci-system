---
description: maurolepore's personal command-line tooling for working with rOpenSci's software-review infrastructure - shell aliases and helper scripts hosted in this KB's tools/ directory. Not official rOpenSci infrastructure.
sources:
  - id: aliases
    title: tools/aliases.zsh (this repo)
    resource: /Users/maurolepore/git/ropensci-system/tools/aliases.zsh
  - id: bot-commands-script
    title: tools/bin/ro-bot-commands
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-bot-commands
  - id: zshrc
    title: dotfiles zshrc (PATH + sourcing)
    resource: /Users/maurolepore/git/dotfiles/zshrc
  - id: project-script
    title: tools/bin/ro-project-item-add
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-project-item-add
  - id: project-delete-script
    title: tools/bin/ro-project-item-delete
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-project-item-delete
  - id: project-sync-script
    title: tools/bin/ro-project-sync
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-project-sync
  - id: alert-script
    title: ro-bot-alert-if-down script
    resource: /Users/maurolepore/git/bin/ro-bot-alert-if-down
  - id: jobs-script
    title: tools/bin/ro-jobs
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-jobs
  - id: editors-status-script
    title: tools/bin/ro-editors-status
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-editors-status
  - id: commits-monthly-script
    title: tools/bin/ro-commits-monthly
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-commits-monthly
  - id: server-check-script
    title: tools/bin/ro-server-check-gh-pat
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-server-check-gh-pat
  - id: copy-script
    title: tools/bin/ro-server-copy
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-server-copy
  - id: copy-check-script
    title: tools/bin/ro-server-copy-check-gh-pat
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-server-copy-check-gh-pat
  - id: pull-env-script
    title: tools/bin/ro-server-pull-env-to-tmp
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-server-pull-env-to-tmp
  - id: summarize-thread-template
    title: tools/bin/ro-learn-summarize-thread
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-learn-summarize-thread
  - id: pre-submission-conversion-template
    title: tools/bin/ro-learn-full-to-pre-submission-conversion
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-learn-full-to-pre-submission-conversion
  - id: my-thread-summary-style-template
    title: tools/bin/ro-learn-my-thread-summary-style
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-learn-my-thread-summary-style
  - id: checklist-onboard-editor-template
    title: tools/bin/ro-checklist-onboard-editor
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-checklist-onboard-editor
  - id: checklist-offboard-editor-template
    title: tools/bin/ro-checklist-offboard-editor
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-checklist-offboard-editor
  - id: checklist-editor-template
    title: tools/bin/ro-checklist-editor
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-checklist-editor
  - id: checklist-blog-new-editor-template
    title: tools/bin/ro-checklist-blog-new-editor
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-checklist-blog-new-editor
  - id: checklist-rotate-gh-pat-in-server-template
    title: tools/bin/ro-checklist-rotate-gh-pat-in-server
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-checklist-rotate-gh-pat-in-server
  - id: pattern-stats-template
    title: tools/bin/ro-pattern-stats-need-pre-submission
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-pattern-stats-need-pre-submission
  - id: pattern-short-history-template
    title: tools/bin/ro-pattern-short-history
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-pattern-short-history
  - id: pattern-unstable-repo-template
    title: tools/bin/ro-pattern-unstable-repo
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-pattern-unstable-repo
  - id: learn-checklist-for-any-role-template
    title: tools/bin/ro-learn-checklist-for-any-role
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-learn-checklist-for-any-role
  - id: new-script
    title: tools/bin/ro-new
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-new
title: Personal ops tooling (ro-*)
status: draft
tags:
  - ropensci
  - software-review
  - personal
  - unofficial
  - ops
  - cli
type: Concept
---

## Summary

maurolepore's personal tools. They are not part of official rOpenSci infrastructure; for the official system see [Software peer-review infrastructure architecture](./software-peer-review-architecture.md). Use `which <name>` to locate a tool[^zshrc].

## Tools

| Tool | Type | Description |
| --- | --- | --- |
| `ro-bot-alert-if-down` | script in the owner's `~/git/bin/`, outside this repo[^alert-script] | Health-check the review API. The [roreviewapi](./roreviewapi.md) plumber API has no route at `/`, so a healthy server answers HTTP 404 at the root; the script treats `404` as UP and anything else as down. |
| `ro-bot-commands` | script in this repo's `tools/bin/`[^bot-commands-script] | Print the list of `@ropensci-review-bot` chat-ops commands with a one-line description of each. |
| `ro-bot-releases` | alias[^aliases] | List the [buffy](./buffy.md) Heroku app's releases, newest first - check when buffy last deployed. |
| `ro-commits-monthly` | script in this repo's `tools/bin/`[^commits-monthly-script] | Print a text histogram of the Git commit count per month for the current Git repository, including zero-commit months; `--commits-per-dot NUM` (or a positional `NUM`) marks one dot per NUM commits (default 1). |
| `ro-editors-status` | script in this repo's `tools/bin/`[^editors-status-script] | List the members of the ropensci reviewtools Slack channel with their Slack status, alphabetized; `--unavailable` shows only members whose Slack status is `unavailable`. Reads the `SLACK_TOKEN` environment variable. |
| `ro-email` | alias[^aliases] | Print the reviewtools@ropensci.org address and the reviewtools Google Group URL. |
| `ro-gh-review` | alias[^aliases] | Run a `gh` command against the [software-review repository](./software-review-repo.md), e.g. `ro-gh-review issue list`. |
| `ro-gh-review-meta` | alias[^aliases] | Run a `gh` command against the software-review-meta repository, e.g. `ro-gh-review-meta issue list`. |
| `ro-jobs` | script in this repo's `tools/bin/`[^jobs-script] | Run every routine job as one sweep, e.g. a morning check. Runs `ro-bot-alert-if-down` and `ro-project-sync` for real; a failing job does not stop the remaining jobs, and the exit status is non-zero if any job failed so a scheduler can alert. Ends with a one-line summary, `system OK\|DOWN \| added N issues and M PRs`, where the count covers the items `ro-project-sync` actually added. |
| `ro-meet-me` | alias[^aliases] | Copy Mauro's Google Calendar booking link to the clipboard. |
| `ro-new` | script in this repo's `tools/bin/`[^new-script] | Scaffold a new `ro-*` command with `ro-new <command-name>`: creates `tools/bin/ro-<command-name>` as an executable bash script containing an empty `RO_TEMPLATE_EOF` heredoc. Rejects invalid names and refuses to overwrite an existing command. |
| `ro-project-browse` | alias[^aliases] | Open the ropensci GitHub Project board (project 12) in a web browser. |
| `ro-project-item-add` | script in this repo's `tools/bin/`[^project-script] | Bulk-add every open issue of a GitHub repository to the ropensci GitHub Project board (project 12). Usage: `ro-project-item-add <owner/repo>`. |
| `ro-project-item-delete` | script in this repo's `tools/bin/`[^project-delete-script] | Remove every project-board item of a GitHub repository from the ropensci GitHub Project board (project 12). Only the board entry is deleted; the underlying issue is untouched. Usage: `ro-project-item-delete <owner/repo>`. |
| `ro-project-query` | alias[^aliases] | List the ropensci GitHub Project (project 12) items matching a filter query, e.g. `ro-project-query "assignee:@me is:issue"`. |
| `ro-project-status` | alias[^aliases] | Show the Status of the items assigned to you in the current iteration - runs `ro-project-query` with the default query `assignee:@me iteration:@current`. |
| `ro-project-sync` | script in this repo's `tools/bin/`[^project-sync-script] | Add every open issue and pull request of every repository already represented on the ropensci GitHub Project board (project 12), skipping anything already on the board; ends with a count of the items actually added. `--dry-run` prints the report without mutating. |
| `ro-server` | alias[^aliases] | SSH into the Digital Ocean droplet that hosts roreviewapi (reviewbot.ropensci.org). |
| `ro-server-check-gh-pat` | script in this repo's `tools/bin/`[^server-check-script] | Print each expected result, run it, and assert PASS/FAIL for read-only checks that the GitHub PAT used by the roreviewapi container is valid, belongs to `ropensci-review-bot`, can read the rOpenSci editors team, and can write to `ropensci/software-review` issues and `ropensci-review-tools/roreviewapi` (gh-pages). Run on the droplet with `sudo bash /tmp/ro-server-check-gh-pat` from the project directory; exits non-zero if any check fails, and changes nothing. |
| `ro-server-copy` | script in this repo's `tools/bin/`[^copy-script] | Copy a local file to the roreviewapi droplet with `scp`, preserving mode and timestamps. Usage: `ro-server-copy <file> [server-destination]`; with no destination the file lands in `/tmp/` on the server. |
| `ro-server-copy-check-gh-pat` | script in this repo's `tools/bin/`[^copy-check-script] | Copy `ro-server-check-gh-pat` from this repo's `tools/bin/` to `/tmp/` on the roreviewapi droplet, preserving its executable mode. Takes no arguments. |
| `ro-server-pull-env-to-tmp` | script in this repo's `tools/bin/`[^pull-env-script] | Download the roreviewapi `.env` from the droplet to a dated file in local `/tmp/` with `scp` (read-only on the server; contents are never printed). Creates the file with mode 0600, refuses to overwrite an existing destination, and removes partial files on failure. Takes no arguments; `RO_SERVER_ENV_DATE_FORMAT` defaults to `%Y-%d-%m` (set to `%Y-%m-%d` for ISO). |
| `ro-url-airtable-eic-rotation` | alias[^aliases] | Print the Airtable view URL used for the EiC rotation. |

## Prompt templates

Each prompt script in `tools/bin/` embeds its text in a quoted heredoc and prints it to stdout, so it works from any directory with no separate template file to keep in sync. Naming follows `ro-learn-<name>` (`ro-learn-full-to-pre-submission-conversion` for the `pre-submission-conversion` text, named after its input format, and `ro-learn-checklist-for-any-role`), `ro-checklist-<name>` (`ro-checklist-editor`, `ro-checklist-blog-new-editor`, `ro-checklist-onboard-editor`, `ro-checklist-offboard-editor`, and `ro-checklist-rotate-gh-pat-in-server`), and `ro-pattern-<name>` (`ro-pattern-stats-need-pre-submission`, `ro-pattern-short-history`, `ro-pattern-unstable-repo`) - ready to paste or to feed a prompt to an agent.

| Template | Description |
| --- | --- |
| `my-thread-summary-style`[^my-thread-summary-style-template] | Turn the `summarize-thread` thread analysis into an EiC rotation-start summary comment written in Mauro Lepore's (GitHub `@maurolepore`) own voice, derived with evidence counts from 40 of his real EiC comments - ready to paste on the issue, but never posted: the human reviews and pastes. |
| `summarize-thread`[^summarize-thread-template] | Analyze a software-review GitHub thread into `Current Status` (from issue labels), `Summary of Events`, and `Next Steps` (action, responsible actor, timeframe), with exact dates for milestones. It refuses to guess when the page has hidden comments behind a "Load more" pagination control, and requires expanding them first. |
| `pre-submission-conversion`[^pre-submission-conversion-template] | Populate a pre-submission-inquiry template (EN, ES, or PT) from the raw first comment of a full-submission issue. |
| `pattern-stats-need-pre-submission`[^pattern-stats-template] | Ready-to-paste quote from the stats dev guide that all statistical software submissions should begin with a pre-submission enquiry, with its source URL; printed by `ro-pattern-stats-need-pre-submission`. |
| `pattern-short-history`[^pattern-short-history-template] | Ready-to-paste comment for a submission whose repo has a short history: flags instability and the need for a stable branch, links the code-frequency graph, and puts the submission on hold with bot reminders every 3 months up to 1 year; printed by `ro-pattern-short-history`. |
| `pattern-unstable-repo`[^pattern-unstable-repo-template] | Ready-to-paste quote from the dev guide asking the author to keep the branch unchanged during review apart from hot fixes, so reviewers assess a stable version; printed by `ro-pattern-unstable-repo`. |
| `checklist-onboard-editor`[^checklist-onboard-editor-template] | Onboarding checklist for a new guest or full editor - the details to collect, the links used at each step, the full-editor and guest-editor setup items (each split into Invite and Confirm sub-tasks), and a hidden TODO block for items to send in one email. |
| `checklist-offboard-editor`[^checklist-offboard-editor-template] | Offboarding checklist for an editor who is leaving, mirroring the dev guide - thank them, tell staff so the newsletter announces the departure, remove them from the "editors-only" channel and the GitHub editors team, edit `team.json`, remove Airtable access and relabel them "Emeritus" there, then check the generated editor lists the next day. |
| `checklist-editor`[^checklist-editor-template] | Ready-to-paste editor-checks comment for a submission issue: the required dev-guide checkboxes for the author to address or justify, a request to keep the `mlNN` tag sequence and the branch stable, a note that AI must not write the posted comments, and a hidden TODO block of Mauro's review commands. |
| `checklist-blog-new-editor`[^checklist-blog-new-editor-template] | Details to collect from a new editor for their welcome blog post - full name and preferred spelling, headshot, links, the date they joined, a bio, and a quote about why they joined; links to the 2024 editors post as an example. |
| `checklist-rotate-gh-pat-in-server`[^checklist-rotate-gh-pat-in-server-template] | Checklist for rotating the GitHub PAT used in the roreviewapi server's `.env` - create and test a new token, update the `.env` and restart the service, notify staff, and revoke the old token; printed by `ro-checklist-rotate-gh-pat-in-server`. |
| `learn-checklist-for-any-role`[^learn-checklist-for-any-role-template] | Prompt for a terse, action-oriented workflow checklist for any rOpenSci role based strictly on one dev-guide URL - required R and bot commands, deadlines, and direct links in sequence, optional background and style nits in a separate tail section, output escaped for pasting into a GitHub issue; printed by `ro-learn-checklist-for-any-role`. |

## Related

- [roreviewapi](./roreviewapi.md) - the droplet-hosted plumber API these tools operate on
- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - the official system this tooling is not part of

[^commits-monthly-script]: Source `commits-monthly-script` - see frontmatter `sources`.
[^aliases]: Source `aliases` - see frontmatter `sources`.
[^zshrc]: Source `zshrc` - see frontmatter `sources`.
[^project-script]: Source `project-script` - see frontmatter `sources`.
[^project-delete-script]: Source `project-delete-script` - see frontmatter `sources`.
[^project-sync-script]: Source `project-sync-script` - see frontmatter `sources`.
[^alert-script]: Source `alert-script` - see frontmatter `sources`.
[^jobs-script]: Source `jobs-script` - see frontmatter `sources`.
[^server-check-script]: Source `server-check-script` - see frontmatter `sources`.
[^copy-script]: Source `copy-script` - see frontmatter `sources`.
[^copy-check-script]: Source `copy-check-script` - see frontmatter `sources`.
[^pull-env-script]: Source `pull-env-script` - see frontmatter `sources`.
[^editors-status-script]: Source `editors-status-script` - see frontmatter `sources`.
[^summarize-thread-template]: Source `summarize-thread-template` - see frontmatter `sources`.
[^my-thread-summary-style-template]: Source `my-thread-summary-style-template` - see frontmatter `sources`.
[^pre-submission-conversion-template]: Source `pre-submission-conversion-template` - see frontmatter `sources`.
[^checklist-onboard-editor-template]: Source `checklist-onboard-editor-template` - see frontmatter `sources`.
[^checklist-offboard-editor-template]: Source `checklist-offboard-editor-template` - see frontmatter `sources`.
[^checklist-editor-template]: Source `checklist-editor-template` - see frontmatter `sources`.
[^checklist-blog-new-editor-template]: Source `checklist-blog-new-editor-template` - see frontmatter `sources`.
[^checklist-rotate-gh-pat-in-server-template]: Source `checklist-rotate-gh-pat-in-server-template` - see frontmatter `sources`.
[^pattern-stats-template]: Source pattern-stats-template - see frontmatter `sources`.
[^pattern-short-history-template]: Source pattern-short-history-template - see frontmatter `sources`.
[^pattern-unstable-repo-template]: Source pattern-unstable-repo-template - see frontmatter `sources`.
[^learn-checklist-for-any-role-template]: Source learn-checklist-for-any-role-template - see frontmatter `sources`.
[^bot-commands-script]: Source `bot-commands-script` - see frontmatter `sources`.
[^new-script]: Source `new-script` - see frontmatter `sources`.
