---
description: maurolepore's PERSONAL, UNOFFICIAL command-line tooling for working with rOpenSci's software-review infrastructure - shell aliases and helper scripts hosted in this KB's tools/ directory (plus the ro-bot-alert-if-down script). NOT official rOpenSci infrastructure.
sources:
  - id: aliases
    title: tools/aliases.zsh (this repo)
    resource: /Users/maurolepore/git/ropensci-system/tools/aliases.zsh
  - id: zshrc
    title: dotfiles zshrc lines 193-194 (PATH + sourcing)
    resource: /Users/maurolepore/git/dotfiles/zshrc
  - id: project-script
    title: tools/bin/ro-project-add-items (verbatim contents)
    resource: /Users/maurolepore/git/ropensci-system/tools/bin/ro-project-add-items
  - id: alert-script
    title: ro-bot-alert-if-down script (verbatim contents)
    resource: /Users/maurolepore/git/bin/ro-bot-alert-if-down
  - id: bin-repo
    title: maurolepore's bin repository (git history)
    resource: /Users/maurolepore/git/bin
type: Concept
title: Personal ops tooling (ro-*) - personal and unofficial
status: draft
tags:
  - ropensci
  - software-review
  - personal
  - unofficial
  - ops
  - cli
---
## Summary

**This tooling is PERSONAL and UNOFFICIAL.** Everything on this page is maintained by [maurolepore](https://github.com/maurolepore) for his own day-to-day operations against rOpenSci's software-review infrastructure. It is **not part of, endorsed by, or documented by rOpenSci** - for the official system see [Software peer-review infrastructure architecture](./software-peer-review-architecture.md).

Since 2026-10-24 the shell tooling lives in **this repo's `tools/` directory** rather than in the dotfiles repo. The dotfiles `zshrc` puts `ropensci-system/tools/bin` on `PATH` and sources `ropensci-system/tools/aliases.zsh` directly.[^zshrc] The tooling consists of three shell aliases plus two helper scripts, operating on the [buffy](./buffy.md) Heroku app and on [roreviewapi](./roreviewapi.md) with its Digital Ocean droplet.

## Details

### Shell aliases (`tools/aliases.zsh`)

Defined in this KB repo, sourced by the dotfiles `zshrc`:[^aliases]

| Alias | Expansion | Purpose |
| --- | --- | --- |
| `ro-server` | `ssh mauro@167.99.34.163` | SSH into the Digital Ocean droplet that hosts roreviewapi (reviewbot.ropensci.org) |
| `ro-bot-releases` | `heroku releases -a radiant-garden-91913` | List the [buffy](./buffy.md) Heroku app's releases, newest first - check when buffy last deployed |
| `ro-meet-me` | echo the booking-link URL, pipe to `pbcopy` | Copy Mauro's Google Calendar booking link to the clipboard |

Historical names: `ro-server` was previously named `ro-do` in the dotfiles, and `ro-bot-releases` previously lived there too (it has kept its name through the move).

### `tools/bin/ro-project-add-items`

Bulk-adds every open issue of a GitHub repository to the ropensci GitHub Project board (project 12):

```bash
#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Check if repository argument is provided
if [ -z "${1:-}" ]; then
  echo "Usage: $0 <owner/repo>"
  echo "Example: $0 ropenscilabs/statistical-software-review"
  exit 1
fi

REPO="$1"
PROJECT_NUMBER=12
PROJECT_OWNER="ropensci"
```

(see the script file for the full `gh issue list` / `gh project item-add` loop)[^project-script]

### `ro-bot-alert-if-down` (~/git/bin)

Formerly `ro-alert-if-bot-is-down` - renamed 2026-10-23 to group with the other `ro-bot-*` commands.[^bin-repo] This one still lives outside `tools/`, in the owner's `bin` directory; it health-checks the review API:[^alert-script]

```bash
#!/usr/bin/env bash

URL="https://reviewbot.ropensci.org"
status=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [[ "$status" != "404" ]]; then
    echo -e "reviewbot is down"
    exit 1
fi
```

**Operational insight:** the [roreviewapi](./roreviewapi.md) plumber API has no route at `/`, so a healthy server answers HTTP 404 at the root. The script therefore treats `404` as UP and anything else as down (prints `reviewbot is down`, exits 1).[^alert-script]

## Related

- [roreviewapi](./roreviewapi.md) - the droplet-hosted plumber API these tools operate on
- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - the official system this tooling is NOT part of

[^aliases]: Source `aliases` - see frontmatter `sources`.
[^zshrc]: Source `zshrc` - see frontmatter `sources`.
[^project-script]: Source `project-script` - see frontmatter `sources`.
[^alert-script]: Source `alert-script` - see frontmatter `sources`.
[^bin-repo]: Source `bin-repo` - see frontmatter `sources`.