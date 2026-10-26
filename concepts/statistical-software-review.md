---
type: Concept
status: draft
title: statistical-software-review - the sandbox
description: The ropenscilabs/statistical-software-review GitHub repository - rOpenSci's legacy sandbox for testing editorial tooling; not a review venue (submissions go to ropensci/software-review).
tags:
  - ropensci
  - software-review
  - sandbox
  - github
  - legacy
sources:
  - id: repo
    title: Repository README (local clone)
    resource: ropenscilabs/statistical-software-review/README.md
  - id: repo-github
    title: ropenscilabs/statistical-software-review (canonical)
    resource: https://github.com/ropenscilabs/statistical-software-review
  - id: blog
    title: Editorial Automation chat-ops blog post (2022-05-31)
    resource: ropensci/roweb3/content/blog/2022-05-31-chatops-review-system-github/index.md
  - id: editor-search
    title: R/editor-search.R (test-repo mail redirect)
    resource: ropensci-review-tools/roreviewapi/R/editor-search.R
generated:
  by: opencode/glm-5.3-flash-free
  at: 2026-10-25T19:45:54-06:00
---

## Summary

[ropenscilabs/statistical-software-review](https://github.com/ropenscilabs/statistical-software-review) is rOpenSci's legacy sandbox repository: submissions of statistical software now go to the [software-review repository](./software-review-repo.md), and the sandbox is "used only for internal testing of tools and workflows".[^repo]

## Details

- **Not a review venue.** Its README says statistical-software submissions "may now be made directly to the main `software-review` repository" - this repo retains the role it had before that move.[^repo]
- **Why a sandbox exists.** The chat-ops setup described in the 2022 blog post creates a test review repository - "a copy of your production review repository so you can experiment without bothering serious watchers", carrying the same issue/PR templates and labels as production. [buffy](./buffy.md) changes are tried there first; rOpenSci's test review repository is this repo.[^blog]
- **Wired into [roreviewapi](./roreviewapi.md).** Editor search emails issued from any `ropenscilabs/*` repository go to a test address (`reviewtools@ropensci.org`) instead of editors or the EiC, so sandbox experiments cannot reach real editors.[^editor]

## Related

- [software-review repository](./software-review-repo.md) - where real submissions go
- [buffy](./buffy.md) - the bot this sandbox exists to test
- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - system overview

[^repo]: Source `repo` - see frontmatter `sources`.
[^blog]: Source `blog` - see frontmatter `sources`.
[^editor]: Source `editor-search` - see frontmatter `sources`.
