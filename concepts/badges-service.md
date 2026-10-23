---
type: Concept
status: draft
title: Badges service
description: How rOpenSci's software-review badges work - the ropensci-org/badges repo served at badges.ropensci.org and the roreviewapi /badge endpoint that mints them on approval.
tags: [ropensci, software-review, badges]
sources:
  - id: badges-repo
    title: ropensci-org/badges repository (CNAME, svgs/, pkgsvgs/, update_badges.R)
    resource: ropensci-org/badges
  - id: config
    title: buffy production responder config (ropensci branch)
    resource: https://github.com/ropensci-org/buffy/blob/ropensci/config/settings-production.yml
  - id: endpoints
    title: roreviewapi API Endpoints vignette
    resource: ropensci-review-tools/roreviewapi/vignettes/endpoints.Rmd
generated: { by: opencode/kimi-k3, at: 2026-10-23T00:18:04Z }
---

## Summary

Review-status badges are SVGs served from **badges.ropensci.org**, backed by the [ropensci-org/badges](https://github.com/ropensci-org/badges) repository (the `CNAME` file and `gh-pages` branch indicate GitHub Pages hosting).[^badges-repo]

## Details

- `svgs/` holds the grade badges (e.g. `bronze-v0.1.svg`, `gold-v0.2.svg`, plus a champions-program badge); `pkgsvgs/` holds per-package badges.[^badges-repo]
- `update_badges.R` regenerates `pkgsvgs/` by walking all `ropensci/software-review` issues through the GitHub GraphQL API (R `gh` package); `check-registry.R` cross-checks against the package registry.[^badges-repo]
- In the live workflow, [buffy](./buffy.md)'s approval responder calls [roreviewapi](./roreviewapi.md)'s `GET /badge` endpoint (with `repo`, `repourl`, `issue_id`, and the shared secret) when a submission is approved, and posts the review repo's `.buffy/templates/badge.md` / `approved.md` templates.[^config]
- Editors can verify a package README carries its badge with the bot command `check readme` (also wired to `/badge`).[^config]
- For stats submissions, badge grades (bronze/silver/gold, e.g. label `6/approved-bronze-v0.0.1`) are read via roreviewapi's `/stats_badge` endpoint and changed with the bot's `mint` command.[^endpoints]

## Related

- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - system overview
- [software-review repository](./software-review-repo.md) - the venue whose issues drive badge state

[^badges-repo]: Source `badges-repo` - see frontmatter `sources`.
[^config]: Source `config` - see frontmatter `sources`.
[^endpoints]: Source `endpoints` - see frontmatter `sources`.