---
type: Concept
status: draft
title: Personal ops tooling (ro-*) - personal and unofficial
description: maurolepore's PERSONAL, UNOFFICIAL command-line tooling for working with rOpenSci's software-review infrastructure - the ro-alert-if-bot-is-down script and the ro-do shell alias. NOT official rOpenSci infrastructure.
tags: [ ropensci, software-review, personal, unofficial, ops, cli ]
sources:
  - id: alert-script
    title: ro-alert-if-bot-is-down script (verbatim contents)
    resource: /Users/maurolepore/git/bin/ro-alert-if-bot-is-down
  - id: aliases
    title: aliases.zsh line 256
    resource: /Users/maurolepore/git/dotfiles/aliases.zsh
generated: { by: opencode/kimi-k3, at: 2026-10-23T01:00:00Z }
---

## Summary

**This tooling is PERSONAL and UNOFFICIAL.** Everything on this page is maintained by [maurolepore](https://github.com/maurolepore) for his own day-to-day operations against rOpenSci's software-review infrastructure. It is **not part of, endorsed by, or documented by rOpenSci** - for the official system see [Software peer-review infrastructure architecture](./software-peer-review-architecture.md).

The tooling consists of one `ro-*` shell script plus one `ro-*` shell alias, both operating on [roreviewapi](./roreviewapi.md) and its Digital Ocean droplet.

## Details

### `ro-alert-if-bot-is-down`

The only `ro-*` file in its `bin` directory; it health-checks the review API:[^alert-script]

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

### Shell alias

Defined in the owner's dotfiles:[^aliases]

| Alias | Line | Expansion | Purpose |
| --- | --- | --- | --- |
| `ro-do` | 256 | `ssh mauro@167.99.34.163` | SSH into the Digital Ocean droplet that hosts roreviewapi (reviewbot.ropensci.org) |

## Related

- [roreviewapi](./roreviewapi.md) - the droplet-hosted plumber API these tools operate on
- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - the official system this tooling is NOT part of

[^alert-script]: Source `alert-script` - see frontmatter `sources`.
[^aliases]: Source `aliases` - see frontmatter `sources`.
