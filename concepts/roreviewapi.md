---
type: Concept
status: draft
title: roreviewapi - the review plumber API
description: The R plumber API behind reviewbot.ropensci.org that runs pkgcheck, matches similar packages, mints badges, and sends editor-search emails; Dockerized on a Digital Ocean droplet.
tags: [ropensci, software-review, infrastructure, roreviewapi, plumber, digitalocean]
sources:
  - id: readme
    title: roreviewapi README
    resource: ropensci-review-tools/roreviewapi/README.Rmd
  - id: endpoints
    title: API Endpoints vignette
    resource: ropensci-review-tools/roreviewapi/vignettes/endpoints.Rmd
  - id: editorsearch
    title: Editor Search Emails vignette
    resource: ropensci-review-tools/roreviewapi/vignettes/editorsearch.Rmd
  - id: admin
    title: admin-setup vignette (Digital Ocean deployment)
    resource: ropensci-review-tools/roreviewapi/vignettes/admin-setup.Rmd
  - id: plumber
    title: inst/plumber.R endpoint annotations
    resource: ropensci-review-tools/roreviewapi/inst/plumber.R
generated: { by: opencode/kimi-k3, at: 2026-10-23T00:18:04Z }
---

## Summary

**roreviewapi** is a [plumber](https://www.rplumber.io/) API that generates reports on package structure and function for `@ropensci-review-bot`; it is internal tooling, not intended for general use.[^readme] It is served at `https://reviewbot.ropensci.org` from a **Digital Ocean droplet** as a Docker container (the repo ships `Dockerfile`, `docker-compose.yml`, `nginx.conf`, `restart.sh`; DNS maps the domain to the droplet IP).[^admin] [buffy](./buffy.md) calls it with a shared secret passed as the `secret` query parameter (Heroku config var `PKGCHECK_TOKEN`).

## Endpoints (all GET)[^plumber]

| Endpoint | Called by / used for |
| --- | --- |
| `/editorcheck` | Bot command `check package`: validates issue-template variables, runs `pkgcheck::pkgcheck()` as a background process, posts results to the issue[^endpoints] |
| `/editorcheck_contents` | Same checks without posting to the issue (debugging; pair with `/stdlogs`)[^endpoints] |
| `/pkgmatch` | Bot command `similar packages`: top-5 matches from rOpenSci + CRAN corpora via the pkgmatch package[^endpoints] |
| `/srrcheck` | Bot command `check srr`: standards documentation checks for stats packages |
| `/badge` | Badge creation/update on approval; `check readme` verifies the badge in the package README |
| `/send_search` | Bot command `ping editors`: emails the editorial board requesting volunteers[^editorsearch] |
| `/click/<token>` | Records a volunteer's click; token is the credential, no auth; notifies the Editor-in-Chief on first valid click[^editorsearch] |
| `/list_searches` | Lists active/inactive editor searches (needs `secret`)[^editorsearch] |
| `/deactivate_search` | Ends a search and deletes its recipient rows (called silently when an editor is assigned)[^editorsearch] |
| `/stats_badge` | Extracts the stats badge grade (e.g. `6/approved-bronze-v0.0.1`) for `mint` commands[^endpoints] |
| `/mean` | Liveness check (`mean(rnorm(n))`)[^endpoints] |
| `/log` | Last n API log entries (debugging)[^endpoints] |
| `/clear_cache` | Clears the pkgcheck results cache[^endpoints] |
| `/stdlogs` | stdout/stderr of the pkgcheck background process for a repo, hashed by git head[^endpoints] |

## Dependencies and runtime

- Built on [pkgcheck](https://github.com/ropensci-review-tools/pkgcheck) and [pkgstats](https://github.com/ropensci-review-tools/pkgstats); system requirements include `ctags`, GNU `global`, the `gh` CLI, and `dos2unix`.[^readme]
- Needs `GITHUB_TOKEN` (exactly that name - the `gh` CLI ignores `GITHUB_PAT`).[^readme]
- Caches analyzed packages under `rappdirs::user_cache_dir()/pkgcheck`.[^readme]

## Editor-search email system

- Sends from the `reviewbot@ropensci.org` alias via the **Gmail API** (`gmailr`), authorized once interactively by a maintainer's Google account; the refresh-token cache is portable to the droplet.[^editorsearch]
- Google Cloud project **`ro-auto-email`** (owned by the rOpenSci Workspace Cloud Identity org): Gmail API enabled, OAuth consent screen **Internal**, Desktop-app OAuth client, scope `gmail.send`.[^editorsearch]
- Credentials live in `/srv/roreviewapi/data/` on the droplet, bind-mounted into the container at `/data/email/`; env vars `GMAIL_SENDER`, `GMAIL_OAUTH_CLIENT_SECRET`, `GMAIL_TOKEN_CACHE`, `GMAIL_AUTH_EMAIL` are set in an untracked `.env`.[^editorsearch]
- Search state lives in a SQLite database next to that directory; the current Editor-in-Chief email is fetched from Airtable at startup and refreshed every 24 h.[^editorsearch]

## Related

- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - system overview
- [buffy](./buffy.md) - the caller of this API
- [pkgcheck suite](./pkgcheck-suite.md) - what `/editorcheck` runs

[^readme]: Source `readme` - see frontmatter `sources`.
[^endpoints]: Source `endpoints` - see frontmatter `sources`.
[^editorsearch]: Source `editorsearch` - see frontmatter `sources`.
[^admin]: Source `admin` - see frontmatter `sources`.
[^plumber]: Source `plumber` - see frontmatter `sources`.