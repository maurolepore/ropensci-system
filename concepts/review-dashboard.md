---
type: Concept
status: draft
title: Software review dashboard
description: The dashboard.ropensci.org site giving editors a live overview of the review pipeline - an R package plus a quarto site from ropensci-review-tools/dashboard.
tags: [ropensci, software-review, dashboard]
sources:
  - id: readme
    title: dashboard repository README
    resource: ropensci-review-tools/dashboard/README.md
generated: { by: opencode/kimi-k3, at: 2026-10-23T00:18:04Z }
---

## Summary

The **Software Review Dashboard** at [dashboard.ropensci.org](https://dashboard.ropensci.org) gives the editorial team a live, at-a-glance view of the review pipeline (open submissions, assignment and staleness state). It is built from [ropensci-review-tools/dashboard](https://github.com/ropensci-review-tools/dashboard), which contains a local R package named `dashboard` plus a `quarto/` directory holding the website source.[^readme]

## Details

- The site is rendered and published by a GitHub Actions workflow (`publish.yaml`) using `renv` to pin dependencies.[^readme]
- The R package is installed from GitHub (`remotes::install_github("ropensci-review-tools/dashboard")`) and is not on CRAN.[^readme]
- The dashboard reads review state produced by the rest of the pipeline (GitHub issues, Airtable); it is a consumer, not a producer, of review data.

## Related

- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - system overview

[^readme]: Source `readme` - see frontmatter `sources`.