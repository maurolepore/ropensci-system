---
type: Concept
status: draft
title: software-review repository - the venue
description: The ropensci/software-review GitHub repository where submissions live as issue threads - templates, labels, bot comment templates, and the review lifecycle.
tags: [ropensci, software-review, github]
sources:
  - id: blog
    title: Editorial Automation blog post (2022-05-31)
    resource: ropensci/roweb3/content/blog/2022-05-31-chatops-review-system-github/index.md
  - id: config
    title: buffy production responder config (ropensci branch)
    resource: https://github.com/ropensci-org/buffy/blob/ropensci/config/settings-production.yml
  - id: repo-files
    title: Local clone listing (.github/ISSUE_TEMPLATE, .buffy/templates, README.Rmd)
    resource: ropensci/software-review
generated: { by: opencode/kimi-k3, at: 2026-10-23T00:18:04Z }
---

## Summary

[ropensci/software-review](https://github.com/ropensci/software-review) is where every submission happens: one GitHub issue per package, created from a structured issue template, with labels tracking progress and the issue body holding machine-editable metadata in HTML-comment variables (e.g. `<!--editor--> ... <!--end-editor-->`) that [buffy](./buffy.md) reads and fills.[^blog]

## Issue templates (`.github/ISSUE_TEMPLATE/`)[^repo-files]

- `A-submit-software-for-review.md` - standard submission
- `B-submit-a-presubmission-inquiry.md` - pre-submission inquiry
- `F-submit-statistical-software-for-review.md` - stats submission (adds the `stats` track)
- `C-bug-or-feature-request.md` - process feedback
- Spanish and Portuguese variants (`D-`, `E-`, `H-`, `I-`, `J-` prefixes)

Template placeholders feed the automation: the production buffy config validates `author1` (Submitting Author), `repourl` (Repository), `submission-type`, `editor`, `language`, and `reviewers-list`, warning when empty.[^config]

## Bot comment templates (`.buffy/templates/`)[^repo-files]

`approved.md`, `badge.md`, `goodpractice.md`, `reminder.md`, `welcome.md` - the texts the bot posts at each lifecycle step (e.g. `welcome.md` on submission, `approved.md` on acceptance).

## Lifecycle

Labels (from production config):[^config]

1. `0/presubmission` or `0/editorial-team-prep` - intake
2. `1/editor-checks` - an editor is assigned (`@ropensci-review-bot assign @name as editor`)
3. `2/seeking-reviewer(s)` - editor searches for reviewers
4. `3/reviewer(s)-assigned` - reviewers registered (`add @name to reviewers`); due dates tracked with reminders
5. `4/review(s)-in-awaiting-changes` - reviews submitted
6. `5/awaiting-reviewer(s)-response` - author responding
7. `6/approved` - accepted (badge minted, author invited to the org, repo transfer finalized)

The `README.Rmd` (which generates `README.md`) renders the current editor/team list from the Airtable review database via the `airtabler` package.[^repo-files]

## Related

- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - system overview
- [buffy](./buffy.md) - the bot acting on this repo

[^blog]: Source `blog` - see frontmatter `sources`.
[^config]: Source `config` - see frontmatter `sources`.
[^repo-files]: Source `repo-files` - see frontmatter `sources`.