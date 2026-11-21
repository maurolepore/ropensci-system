---
description: maurolepore's personal command-line tooling for working with rOpenSci's software-review infrastructure - shell aliases and helper scripts hosted in this KB's tools/ directory. Not official rOpenSci infrastructure.
sources:
  - id: aliases
    title: tools/aliases.zsh (this repo)
    resource: /Users/maurolepore/git/ropensci-system/tools/aliases.zsh
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
  - id: summarize-thread-skill
    title: tools/skills/summarize-thread.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/summarize-thread.md
  - id: pre-submission-conversion-skill
    title: tools/skills/pre-submission-conversion.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/pre-submission-conversion.md
  - id: my-thread-summary-style-skill
    title: tools/skills/my-thread-summary-style.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/my-thread-summary-style.md
  - id: onboard-editor-skill
    title: tools/skills/onboard-editor.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/onboard-editor.md
  - id: offboard-editor-skill
    title: tools/skills/offboard-editor.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/offboard-editor.md
  - id: editor-checklist-skill
    title: tools/skills/editor-checklist.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/editor-checklist.md
  - id: checklist-blog-new-editor-skill
    title: tools/skills/checklist-blog-new-editor.md
    resource: /Users/maurolepore/git/ropensci-system/tools/skills/checklist-blog-new-editor.md
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
| `ro-bot-releases` | alias[^aliases] | List the [buffy](./buffy.md) Heroku app's releases, newest first - check when buffy last deployed. |
| `ro-commits-monthly` | script in this repo's `tools/bin/`[^commits-monthly-script] | Print a text histogram of the Git commit count per month for the current Git repository, including zero-commit months; `--commits-per-dot NUM` (or a positional `NUM`) marks one dot per NUM commits (default 1). |
| `ro-editors-status` | script in this repo's `tools/bin/`[^editors-status-script] | List the members of the ropensci reviewtools Slack channel with their Slack status, alphabetized; `--unavailable` shows only members whose Slack status is `unavailable`. Reads the `SLACK_TOKEN` environment variable. |
| `ro-email` | alias[^aliases] | Print the reviewtools@ropensci.org address and the reviewtools Google Group URL. |
| `ro-gh-review` | alias[^aliases] | Run a `gh` command against the [software-review repository](./software-review-repo.md), e.g. `ro-gh-review issue list`. |
| `ro-gh-review-meta` | alias[^aliases] | Run a `gh` command against the software-review-meta repository, e.g. `ro-gh-review-meta issue list`. |
| `ro-jobs` | script in this repo's `tools/bin/`[^jobs-script] | Run every routine job as one sweep, e.g. a morning check. Runs `ro-bot-alert-if-down` and `ro-project-sync` for real; a failing job does not stop the remaining jobs, and the exit status is non-zero if any job failed so a scheduler can alert. Ends with a one-line summary, `system OK\|DOWN \| added N issues and M PRs`, where the count covers the items `ro-project-sync` actually added. |
| `ro-meet-me` | alias[^aliases] | Copy Mauro's Google Calendar booking link to the clipboard. |
| `ro-project-browse` | alias[^aliases] | Open the ropensci GitHub Project board (project 12) in a web browser. |
| `ro-project-item-add` | script in this repo's `tools/bin/`[^project-script] | Bulk-add every open issue of a GitHub repository to the ropensci GitHub Project board (project 12). Usage: `ro-project-item-add <owner/repo>`. |
| `ro-project-item-delete` | script in this repo's `tools/bin/`[^project-delete-script] | Remove every project-board item of a GitHub repository from the ropensci GitHub Project board (project 12). Only the board entry is deleted; the underlying issue is untouched. Usage: `ro-project-item-delete <owner/repo>`. |
| `ro-project-query` | alias[^aliases] | List the ropensci GitHub Project (project 12) items matching a filter query, e.g. `ro-project-query "assignee:@me is:issue"`. |
| `ro-project-status` | alias[^aliases] | Show the Status of the items assigned to you in the current iteration - runs `ro-project-query` with the default query `assignee:@me iteration:@current`. |
| `ro-project-sync` | script in this repo's `tools/bin/`[^project-sync-script] | Add every open issue and pull request of every repository already represented on the ropensci GitHub Project board (project 12), skipping anything already on the board; ends with a count of the items actually added. `--dry-run` prints the report without mutating. |
| `ro-server` | alias[^aliases] | SSH into the Digital Ocean droplet that hosts roreviewapi (reviewbot.ropensci.org). |
| `ro-url-airtable-eic-rotation` | alias[^aliases] | Print the Airtable view URL used for the EiC rotation. |

## Skills

`tools/skills/` holds prompt templates, one markdown file per prompt, each printed to stdout by the matching `tools/bin/ro-learn-<name>` wrapper (`ro-learn-full-to-pre-submission-conversion` for the `pre-submission-conversion` skill, named after its input format), ready to paste or to feed a prompt to an agent.

| Skill | Description |
| --- | --- |
| `my-thread-summary-style`[^my-thread-summary-style-skill] | Turn the `summarize-thread` thread analysis into an EiC rotation-start summary comment written in Mauro Lepore's (GitHub `@maurolepore`) own voice, derived with evidence counts from 40 of his real EiC comments - ready to paste on the issue, but never posted: the human reviews and pastes. |
| `summarize-thread`[^summarize-thread-skill] | Analyze a software-review GitHub thread into `Current Status` (from issue labels), `Summary of Events`, and `Next Steps` (action, responsible actor, timeframe), with exact dates for milestones. It refuses to guess when the page has hidden comments behind a "Load more" pagination control, and requires expanding them first. |
| `pre-submission-conversion`[^pre-submission-conversion-skill] | Populate a pre-submission-inquiry template (EN, ES, or PT) from the raw first comment of a full-submission issue. |
| `onboard-editor`[^onboard-editor-skill] | Onboarding checklist for a new guest or full editor - the details to collect, the links used at each step, the full-editor and guest-editor setup items (each split into Invite and Confirm sub-tasks), and a hidden TODO block for items to send in one email. |
| `offboard-editor`[^offboard-editor-skill] | Offboarding checklist for an editor who is leaving, mirroring the dev guide - thank them, tell staff so the newsletter announces the departure, remove them from the "editors-only" channel and the GitHub editors team, edit `team.json`, remove Airtable access and relabel them "Emeritus" there, then check the generated editor lists the next day. |
| `editor-checklist`[^editor-checklist-skill] | Ready-to-paste editor-checks comment for a submission issue: the required dev-guide checkboxes for the author to address or justify, a request to keep the `mlNN` tag sequence and the branch stable, a note that AI must not write the posted comments, and a hidden TODO block of Mauro's review commands. |
| `checklist-blog-new-editor`[^checklist-blog-new-editor-skill] | Details to collect from a new editor for their welcome blog post - full name and preferred spelling, headshot, links, the date they joined, a bio, and a quote about why they joined; links to the 2024 editors post as an example. |

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
[^editors-status-script]: Source `editors-status-script` - see frontmatter `sources`.
[^summarize-thread-skill]: Source `summarize-thread-skill` - see frontmatter `sources`.
[^my-thread-summary-style-skill]: Source `my-thread-summary-style-skill` - see frontmatter `sources`.
[^pre-submission-conversion-skill]: Source `pre-submission-conversion-skill` - see frontmatter `sources`.
[^onboard-editor-skill]: Source `onboard-editor-skill` - see frontmatter `sources`.
[^offboard-editor-skill]: Source `offboard-editor-skill` - see frontmatter `sources`.
[^editor-checklist-skill]: Source `editor-checklist-skill` - see frontmatter `sources`.
[^checklist-blog-new-editor-skill]: Source `checklist-blog-new-editor-skill` - see frontmatter `sources`.
