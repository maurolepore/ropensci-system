---
type: Concept
status: draft
title: buffy - the editorial bot
description: The Ruby chat-ops bot (fork of openjournals/buffy) that listens to software-review webhooks and orchestrates the whole review workflow; deployed on Heroku.
tags: [ropensci, software-review, infrastructure, buffy, heroku]
sources:
  - id: blog
    title: Editorial Automation blog post (2022-05-31)
    resource: ropensci/roweb3/content/blog/2022-05-31-chatops-review-system-github/index.md
  - id: install
    title: buffy installation docs
    resource: ropensci-org/buffy/docs/installation.md
  - id: config
    title: Production responder config (ropensci branch)
    resource: https://github.com/ropensci-org/buffy/blob/ropensci/config/settings-production.yml
  - id: responders-tree
    title: Responder source files (origin/ropensci app/responders/)
    resource: https://github.com/ropensci-org/buffy/tree/ropensci/app/responders
  - id: heroku
    title: Live Heroku ground truth read 2026-10-23 (values redacted)
    resource: https://dashboard.heroku.com/apps/radiant-garden-91913
generated: { by: opencode/kimi-k3, at: 2026-10-23T00:18:04Z }
---

## Summary

**buffy** is an editorial bot generator created by the Journal of Open Source Software ([openjournals/buffy](https://github.com/openjournals/buffy)), also used by JuliaCon, pyOpenSci, and SciPy.[^blog] rOpenSci runs a fork, [ropensci-org/buffy](https://github.com/ropensci-org/buffy), whose production configuration lives on the **`ropensci` branch** (the default `main` branch carries upstream JOSS config - do not mistake it for production).[^config]

## How it works

1. GitHub webhooks on the review repository send `issues` and `issue_comment` events to the app's `/dispatch` path (content type `application/json`, secret = `BUFFY_GH_SECRET_TOKEN`).[^install]
2. buffy matches comment text against regular expressions of **responders** registered in `config/settings-production.yml`.
3. Matched responders run their actions: edit the issue body's HTML-template variables, switch labels, post comments (from `.buffy/templates/` in the review repo), call external APIs, update Airtable, or invite users to the GitHub org.[^blog][^config]
4. Background jobs run through **Redis**; `cloc` (installed via a Heroku buildpack) supports the repo-checks responder.[^install]

## Deployment (live ground truth, 2026-10-23)

- Heroku app **`radiant-garden-91913`** (owner `accounts@ropensci.org`, region us, stack heroku-24), web + worker dynos, addon `heroku-redis:mini`.[^heroku]
- Config var names (values redacted): `BUFFY_BOT_GH_USER`, `BUFFY_GH_ACCESS_TOKEN`, `BUFFY_GH_SECRET_TOKEN`, `AIRTABLE_API_KEY`, `AIRTABLE_BASE_ID`, `PKGCHECK_TOKEN` (shared secret for roreviewapi calls), `REDIS_URL`, `CUSTOM_RUBY_VERSION`, `RACK_ENV`, `WEB_CONCURRENCY`, `LANG`.[^heroku]
- The bot's GitHub identity is [@ropensci-review-bot](https://github.com/ropensci-review-bot); its personal access token needs at least `public_repo`, `repo:invite`, `read:org`, `read:user`, and the account needs admin on the review repositories.[^install]

## rOpenSci custom responders

Custom Ruby responders live in `app/responders/ropensci/` on the `ropensci` branch:[^responders-tree]

- `submit_review_responder.rb` / `submit_author_response_responder.rb` - reviews and author responses, label transitions
- `seeking_reviewers_responder.rb` - mark a submission as seeking reviewers
- `reviewers_due_date_responder.rb` / `set_due_date_responder.rb` - review deadlines
- `approve_responder.rb` - approval (badge service call, `6/approved` label)
- `mint_responder.rb` - mint/change stats badge grades (e.g. bronze)
- `invite_package_author_responder.rb` / `finalize_transfer_responder.rb` - org invitation and repo transfer after acceptance
- `on_hold_responder.rb` - put a submission on hold (`on_hold_days: 90`)

External-service responders in the config wire commands to [roreviewapi](./roreviewapi.md) endpoints at `https://reviewbot.ropensci.org`: `check package` -> `/editorcheck`, `similar packages` -> `/pkgmatch`, `check srr` -> `/srrcheck`, `ping editors` -> `/send_search`, `check readme` -> `/badge`.[^config]

## Operations notes

- Test changes against a **test review repository** with the same templates and labels, not production.[^blog]
- The rOpenSci fork documents its custom responders at <https://buffy-ropensci.readthedocs.io/en/latest/> (rOpenSci responders are listed at the bottom).[^blog]
- Heroku app must be always-on (not sleeping) to receive webhooks; logs via `heroku logs --app radiant-garden-91913`.[^blog]

## Related

- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - system overview
- [roreviewapi](./roreviewapi.md) - the API buffy calls
- [software-review repository](./software-review-repo.md) - where buffy listens

[^blog]: Source `blog` - see frontmatter `sources`.
[^install]: Source `install` - see frontmatter `sources`.
[^config]: Source `config` - see frontmatter `sources`.
[^responders-tree]: Source `responders-tree` - see frontmatter `sources`.
[^heroku]: Source `heroku` - see frontmatter `sources`.