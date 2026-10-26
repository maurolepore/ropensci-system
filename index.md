---
okf_version: "0.2"
---

# Knowledge base

Knowledge base for all things [rOpenSci](https://ropensci.org/), particularly the [software peer-review](https://ropensci.org/software-review/) program and its infrastructure.

## Software peer-review infrastructure

- [Software peer-review infrastructure architecture](./concepts/software-peer-review-architecture.md) - the system overview (start here)
- [buffy](./concepts/buffy.md) - the chat-ops bot on Heroku
- [roreviewapi](./concepts/roreviewapi.md) - the plumber API at reviewbot.ropensci.org
- [pkgcheck suite](./concepts/pkgcheck-suite.md) - automated check machinery
- [software-review repository](./concepts/software-review-repo.md) - the venue where reviews happen
- [bot accounts](./concepts/bot-accounts.md) - ropensci-review-bot vs ropenscibot
- [Badges service](./concepts/badges-service.md) - review-status SVG badges
- [Review dashboard](./concepts/review-dashboard.md) - dashboard.ropensci.org

## Personal ops tooling (unofficial)

- [Personal ops tooling (ro-*)](./concepts/personal-ops-tooling.md) - maurolepore's personal, unofficial CLI tools for the review infrastructure, hosted in this repo's `tools/` directory (NOT official rOpenSci infrastructure)

## Conventions

- [Getting started](./concepts/getting-started.md) - purpose and conventions.
- [Codebase wiki setup](./concepts/codebase-wiki-setup.md) - two-layer model: this curated KB points down to per-repo OK codebase wikis; recipe for adding one to a clone.
- Implementation plans live in `plans/<owner>/<repo>/` - one plan per unit of work (a GitHub issue or PR), with the path mirroring the repo where the work happens; see the [bootstrap plan](./plans/maurolepore/ropensci-system/2026-10-22-ropensci-kb-bootstrap.md) for an example. They are committed working documents, in OK scope, but not curated concepts.
- Cloned GitHub repositories live under `<org>/<repo>/` (e.g. `ropensci-org/buffy`); they are reference material excluded from the knowledge graph via `.okignore`, and concept docs cite them as sources. See the [architecture concept](./concepts/software-peer-review-architecture.md) for how they fit together.
