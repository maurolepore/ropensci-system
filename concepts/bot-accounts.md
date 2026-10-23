---
type: Concept
status: draft
title: bot accounts - ropensci-review-bot vs ropenscibot
description: Two GitHub User accounts, neither owning public repos - ropensci-review-bot is the current chat-ops bot face addressed by review commands, ropenscibot is the 2016 onboarding-era bot now used as the badges service git identity.
tags: [ropensci, software-review, bots, github]
sources:
  - id: gh-review-bot
    title: GitHub API user object for ropensci-review-bot (fetched 2026-10-23)
    resource: https://api.github.com/users/ropensci-review-bot
  - id: gh-ropenscibot
    title: GitHub API user object for ropenscibot (fetched 2026-10-23)
    resource: https://api.github.com/users/ropenscibot
  - id: onboarding-redirect
    title: GitHub API redirect chain for repos/ropensci/onboarding (fetched 2026-10-23)
    resource: https://api.github.com/repos/ropensci/onboarding
  - id: chatops-blog
    title: Editorial Automation chat-ops blog post (2022-05-31)
    resource: https://ropensci.org/blog/2022/05/31/chatops-review-system-github/
  - id: devguide-editor
    title: rOpenSci dev guide - Editor's responsibilities (bot commands)
    resource: ropensci/dev_guide/softwarereview_editor.Rmd
  - id: devguide-cheatsheet
    title: rOpenSci dev guide - bot command cheatsheet
    resource: ropensci/dev_guide/bot_cheatsheet.Rmd
  - id: buffy-install
    title: buffy installation docs (bot credential requirements)
    resource: ropensci-org/buffy/docs/installation.md
  - id: badges-workflow
    title: badges gh-pages deploy git identity (badges.yml)
    resource: ropensci-org/badges/.github/workflows/badges.yml
  - id: dashboard-reviews
    title: dashboard review-event parsing (bot assignment comments used)
    resource: ropensci-review-tools/dashboard/R/reviews.R
  - id: doc-grep
    title: GitHub-clone-wide grep for "ropenscibot" across dev_guide/, statistical-software-review-book/, roreviewapi/, software-review/ (zero matches, 2026-10-23)
    resource: ropensci/dev_guide
generated: { by: opencode/glm-5.3-flash-free, at: 2026-10-23T01:53:43Z }
---

## Summary

- The two GitHub URLs are **profile pages of User accounts, not repos** - both accounts own **0 public repos and 0 public gists**.[^gh-review-bot] [^gh-ropenscibot]
- `ropensci-review-bot` (created 2021-01-19) is the **bot face of today's software peer review**, addressed by commands in ropensci/software-review issue threads.[^gh-review-bot] [^devguide-editor]
- `ropenscibot` (created 2016-05-30) is the **legacy bot from the era when submission threads lived in ropensci/onboarding** - a URL that the GitHub API now resolves via redirect to ropensci/software-review.[^gh-ropenscibot] [^onboarding-redirect] Its only observable current use is as the **git identity of badges gh-pages deploys**.[^badges-workflow]

So there is nothing to "use" at either URL themselves: the URLs are profiles. The actual machinery lives in org repos ([buffy](./buffy.md), [software-review](./software-review-repo.md), [badges](./badges-service.md), [roreviewapi](./roreviewapi.md)).

## ropensci-review-bot - the current bot face

- Account facts: created 2021-01-19, bio "Bot for rOpenSci Software Peer-Review", profile blog link points at the 2022 chat-ops blog post.[^gh-review-bot] [^chatops-blog]
- How it acts: the account is the "visible" bot face; human-typed issue-comment commands are addressed to it, and the real work is done by [buffy](./buffy.md), a Ruby app deployed on Heroku, acting via a "Personal" access token configured for that bot account.[^chatops-blog] The buffy install docs require the PAT scopes `public_repo`, `repo:invite`, `read:org`, `read:user`, and admin permission on the review repositories for the bot user.[^buffy-install]
- Commands documented in current guides: `check package`, `check srr`, `approve`, `assign @username as editor`, `assign @username as reviewer`, `add @username as reviewer`, `seeking reviewers`, `put on hold`, `out-of-scope`, `ping editors`, and `finalize transfer of <package-name>`.[^devguide-editor] [^devguide-cheatsheet]
- The editorial dashboard uses this actor's "assigned" / "added" comments to detect editor and reviewer assignments - it does not exclude bot comments (`ropensci-review-tools/dashboard/R/reviews.R:347-350`).[^dashboard-reviews]

## ropenscibot - legacy identity, now a badges committer

- Account facts: created 2016-05-30, bio "I'm the bot for rOpenSci - making ropensci/onboarding run smoother & other things", company `@ropensci`, 0 public repos, profile last updated 2023-04-17.[^gh-ropenscibot]
- The bio references `ropensci/onboarding`, which the GitHub API now resolves via a moved-permanently redirect to `ropensci/software-review` - the review venue of record today.[^gh-ropenscibot] [^onboarding-redirect]
- Current observable use: the badges service's gh-pages deploy commits with `git-config-name: ropenscibot` and email `accounts+ropenscibot@ropensci.org` (`ropensci-org/badges/.github/workflows/badges.yml:47-48`), so published badge updates appear authored by ropenscibot.[^badges-workflow]
- ropenscibot is not referenced as a command target in any of the current review docs in this knowledge base's clones (dev guide, statistical software review book, roreviewapi, software-review).[^doc-grep]

## Related

- [Software peer-review infrastructure architecture](./software-peer-review-architecture.md) - the system overview
- [buffy - the editorial bot](./buffy.md) - the app that acts behind the ropensci-review-bot face
- [software-review repository](./software-review-repo.md) - where commands are typed
- [roreviewapi](./roreviewapi.md) - the API behind check commands
- [badges service](./badges-service.md) - the commits ropenscibot authors

[^gh-review-bot]: Source `gh-review-bot` - see frontmatter `sources`.
[^gh-ropenscibot]: Source `gh-ropenscibot` - see frontmatter `sources`.
[^onboarding-redirect]: Source `onboarding-redirect` - see frontmatter `sources`.
[^chatops-blog]: Source `chatops-blog` - see frontmatter `sources`.
[^devguide-editor]: Source `devguide-editor` - see frontmatter `sources`.
[^devguide-cheatsheet]: Source `devguide-cheatsheet` - see frontmatter `sources`.
[^buffy-install]: Source `buffy-install` - see frontmatter `sources`.
[^badges-workflow]: Source `badges-workflow` - see frontmatter `sources`.
[^dashboard-reviews]: Source `dashboard-reviews` - see frontmatter `sources`.
[^doc-grep]: Source `doc-grep` - see frontmatter `sources`.
