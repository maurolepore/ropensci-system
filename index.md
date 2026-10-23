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
- [Badges service](./concepts/badges-service.md) - review-status SVG badges
- [Review dashboard](./concepts/review-dashboard.md) - dashboard.ropensci.org

## Personal ops tooling (unofficial)

- [Personal ops tooling (ro-*)](./concepts/personal-ops-tooling.md) - maurolepore's personal, unofficial CLI tools for the review infrastructure (NOT official rOpenSci infrastructure)

## Conventions

- [Getting started](./concepts/getting-started.md) - purpose and conventions.
- Cloned GitHub repositories live under `<org>/<repo>/` (e.g. `ropensci-org/buffy`); they are reference material excluded from the knowledge graph via `.okignore`, and concept docs cite them as sources. See the [architecture concept](./concepts/software-peer-review-architecture.md) for how they fit together.
