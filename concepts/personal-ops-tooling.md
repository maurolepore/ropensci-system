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
    title: tools/bin/ro-project-add-items
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-project-add-items
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
| `ro-project-add-items` | script in this repo's `tools/bin/`[^project-script] | Bulk-add every open issue of a GitHub repository to the ropensci GitHub Project board (project 12). Usage: `ro-project-add-items <owner/repo>`. |
| `ro-server` | alias[^aliases] | SSH into the Digital Ocean droplet that hosts roreviewapi (reviewbot.ropensci.org). |

## Related

- [roreviewapi](./roreviewapi.md) - the droplet-hosted plumber API these tools operate on
- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - the official system this tooling is not part of

[^aliases]: Source `aliases` - see frontmatter `sources`.
[^zshrc]: Source `zshrc` - see frontmatter `sources`.
[^project-script]: Source `project-script` - see frontmatter `sources`.
[^alert-script]: Source `alert-script` - see frontmatter `sources`.
