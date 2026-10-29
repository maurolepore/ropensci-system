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
  - id: alert-script
    title: ro-bot-alert-if-down script
    resource: /Users/maurolepore/git/bin/ro-bot-alert-if-down
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

maurolepore's personal tools. They are not part of official rOpenSci infrastructure; for the official system see [Software peer-review infrastructure architecture](./software-peer-review-architecture.md). Use `which <name>` to locate a tool.

## Tools

| Tool | Type | Description |
| --- | --- | --- |
| `ro-bot-alert-if-down` | script in the owner's `~/git/bin/`, outside this repo[^alert-script] | Health-check the review API. The [roreviewapi](./roreviewapi.md) plumber API has no route at `/`, so a healthy server answers HTTP 404 at the root; the script treats `404` as UP and anything else as down. |
| `ro-bot-releases` | alias[^aliases] | List the [buffy](./buffy.md) Heroku app's releases, newest first - check when buffy last deployed. |
| `ro-meet-me` | alias[^aliases] | Copy Mauro's Google Calendar booking link to the clipboard. |
| `ro-project-browse` | alias[^aliases] | Open the ropensci GitHub Project board (project 12) in a web browser. |
| `ro-project-item-add` | script in this repo's `tools/bin/`[^project-script] | Bulk-add every open issue of a GitHub repository to the ropensci GitHub Project board (project 12). Usage: `ro-project-item-add <owner/repo>`. |
| `ro-project-item-delete` | script in this repo's `tools/bin/`[^project-delete-script] | Remove every project-board item of a GitHub repository from the ropensci GitHub Project board (project 12). Only the board entry is deleted; the underlying issue is untouched. Usage: `ro-project-item-delete <owner/repo>`. |
| `ro-project-query` | alias[^aliases] | List the ropensci GitHub Project (project 12) items matching a filter query, e.g. `ro-project-query "assignee:@me is:issue"`. |
| `ro-project-status` | alias[^aliases] | Show the Status of the items assigned to you in the current iteration - runs `ro-project-query` with the default query `assignee:@me iteration:@current`. |
| `ro-server` | alias[^aliases] | SSH into the Digital Ocean droplet that hosts roreviewapi (reviewbot.ropensci.org). |

## Related

- [roreviewapi](./roreviewapi.md) - the droplet-hosted plumber API these tools operate on
- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - the official system this tooling is not part of

[^aliases]: Source `aliases` - see frontmatter `sources`.
[^zshrc]: Source `zshrc` - see frontmatter `sources`.
[^project-script]: Source `project-script` - see frontmatter `sources`.
[^project-delete-script]: Source `project-delete-script` - see frontmatter `sources`.
[^alert-script]: Source `alert-script` - see frontmatter `sources`.
