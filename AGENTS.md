---
type: AgentGuide
title: AGENTS.md - rOpenSci knowledge base
description: Orientation and working rules for agents in this OKF knowledge base.
---

# AGENTS.md - rOpenSci knowledge base

This directory is a **knowledge base for all things rOpenSci**, particularly the [software peer-review program](https://ropensci.org/software-review/). It is an [OpenKnowledge](https://openknowledge.ai) project in **Open Knowledge Format (OKF) v0.2**.

## Layout

- `index.md` - bundle root (declares `okf_version`), the entry point.
- `concepts/` - curated knowledge, one concept per file. Start at [software-peer-review-architecture](concepts/software-peer-review-architecture.md).
- `plans/<owner>/<repo>/` - implementation plans, one plan per unit of work (typically one GitHub issue or PR): the path mirrors the GitHub repo where the work happens (`plans/maurolepore/ropensci-system/` for this KB, `plans/ropensci-org/buffy/` for the buffy clone). Issue/PR-plans are named after the git branch they implement, typically GitHub's suggested-branch format `<number>_<slug>.md` (e.g. `plans/ropensci-org/buffy/142_set-hold-reminder.md`) - the numeric prefix still makes the `gh` handle recoverable; repo-wide plans use `YYYY-MM-DD-<topic>.md`. Plans are working documents: they are committed to git but are not curated concepts and carry no `sources` requirement.
- `<org>/<repo>/` - cloned GitHub repositories (`ropensci/`, `ropensci-org/`, `ropensci-review-tools/`, `ropenscilabs/`). These are **reference material**, excluded from the knowledge graph via `.okignore`. Read them with native tools (`read`/`grep`); never add or edit files inside them - no personal `AGENTS.md` bridges or other local-only files: shared repos must contain only shared content. Repo-specific facts already live in `concepts/`.
- `<org>/<repo>-wiki/` - git worktrees of the clones on a dedicated `wiki` branch, each its own OpenKnowledge project holding an agent-authored **codebase wiki** (`wiki/`), pushed to the user's fork (`mine` remote), never upstream. Code-level "how" questions should read these wikis first. To add one for a new repo follow the [setup recipe](concepts/codebase-wiki-setup.md); to work a feature on any cloned repo, follow the [working-a-feature workflow](concepts/codebase-wiki-setup.md#working-a-feature-eg-buffy142) (manage here, code in the clone, document in the wiki worktree).
  - `ropenscilabs/statistical-software-review/` - the test/sandbox review repository used to try out editorial tooling (buffy) without touching production; referenced in the 2022 chatops blog post's "initial preparation / installation steps" ([live issues](https://github.com/ropenscilabs/statistical-software-review/issues)).

## Repos, wikis, and remotes (applies to every clone)

For any cloned repo `<org>/<repo>` that has a codebase wiki, the convention is the same everywhere:

- The **wiki worktree is always at `<org>/<repo>-wiki/`** — a git worktree of the clone on the dedicated `wiki` branch; it holds the OpenKnowledge codebase-wiki project (`wiki/`).
- The **fork remote is always `mine`** = `git@github.com:maurolepore/<repo>.git`.
- **Push rules:** in the code worktree (`<org>/<repo>/`), push only approved feature branches to `origin` (upstream) and PR there; in the wiki worktree (`<org>/<repo>-wiki/`), push only the `wiki` branch to `mine`. Conversely, `wiki` never goes to `origin`, and feature branches never go to `mine`.
- Both worktrees share one remote config, so a **`pre-push` hook installed in the clone enforces the rules in every worktree**: `mine` only ever receives `refs/heads/wiki`, `origin` never does. On violation it rejects the push and prints the correct command to run. Point the repo's `core.hooksPath` at `.git/hooks` with an ABSOLUTE path (a global `core.hooksPath` such as `~/.config/git/hooks` otherwise silently disables `.git/hooks`, and a relative one breaks in worktrees) and keep any global hooks (e.g. a `commit-msg`) reachable there. `branch.wiki.pushRemote = mine` additionally makes a bare `git push` on the wiki branch correct by default.
- Setup/refresh recipes and the working-a-feature loop: [codebase-wiki-setup](concepts/codebase-wiki-setup.md).
- Current wikis live in the concept doc's table; add wikis lazily, only for actively worked repos.

## Keeping the KB true (end-of-task rule — part of finishing)

Documentation debt is this KB's default failure mode, so updating the docs is part of the task itself: whenever your task changes anything the docs below describe, update them **in the same turn**, before the final commit:

1. **`AGENTS.md`** (root and org-level files in the KB tree) — layout, conventions, structure
2. **`index.md`** — concept list, Conventions section
3. **`plans/**` — plans are working documents; reconcile with a dated addendum when a completed task departs from or supersedes a plan's design (never silently rewrite history)
4. **Concept "current" tables** (e.g. the wikis table in [codebase-wiki-setup](concepts/codebase-wiki-setup.md)) — instance lists

If a doc truly cannot be updated now, leave `(TODO: needs reconcile — <date>)` in it and surface that in your summary. This rule binds every agent working in this tree, including sessions rooted inside the clones (it reaches them through the parent `AGENTS.md` chain), for both KB markdown and clone-adjacent changes.

## Git model

- The KB repo tracks curated content and plans (`index.md`, `concepts/`, `plans/`, `AGENTS.md`, `.gitignore`, `.okignore`, `scripts/`). The `<org>/` clone dirs are **gitignored** - clones are independent repos and never enter KB history.
- Re-materialize clones on a fresh checkout with `scripts/clone-repos.sh`.
- Working from inside a clone: every clone carries its own `AGENTS.md` bridge pointing back here (KB root = two levels up) with a summary of how that repo fits the big picture, and the cross-repo working rules.

## Working in this repo (tool rules)

- **Markdown in `index.md`, `concepts/`, and `plans/` is in OK scope**: read/write it ONLY via the OpenKnowledge MCP tools (`exec`, `write`, `edit`, `search`, `lint`, `audit`). The project-local `open-knowledge` skill is the authoritative contract - load it before touching markdown. Never use native file tools on in-scope `.md`.
- **Markdown inside `<org>/<repo>/` clones is out of scope** (`.gitignore`) - native tools are fine there.
- **OKF rules**: every concept doc needs frontmatter with a non-empty `type` (use `type: Concept`); record provenance in `sources` (with `id`s + `[^id]` footnotes in the body); timestamps are ISO 8601 with explicit UTC offset; standard Markdown links, no wiki-links.
- **Grounding**: every factual claim cites a source in frontmatter `sources` - prefer paths into the local clones plus the canonical URL. Do not fabricate; mark gaps as `(TODO: needs source)`.
- **Secrets**: never record secret values (tokens, keys). Config-var NAMES only, values redacted.

## Boundaries

- **External resources are read-only**: web fetch, `gh api` GETs, `heroku apps:info|config:json|logs` are fine; never mutate remote state.
- **No git mutations** (`commit`, `push`, branch changes in clones) unless the user explicitly asks. Exception: the KB repo's own working tree must be **committed immediately as you finish each task** - don't leave changes uncommitted when the task ends, or that work spills into some other agent's task.
- **Agent commits credit the agent as co-author**: every commit made by an agent MUST include the agent's details as a `Co-Authored-By` trailer in the commit message, using the agent's model + harness identity and a no-reply address, e.g. `Co-Authored-By: GLM-5.3-Flash (OpenCode) <noreply@z.ai>`. Human commits are unaffected.
- New orgs/repos may be cloned into their `<org>/` directory when relevant (`gh repo clone <org>/<repo> <org>/<repo>`).

## Useful commands

- `ok lint` / `ok audit` - validate markdown + links after edits.
- `ok seed --list-packs` / `ok start` - OK tooling.
- `heroku apps:info radiant-garden-91913` - live buffy deployment (read-only).

## Status

First content pass (2026-10-22): software peer-review infrastructure architecture (see `concepts/`). See the bootstrap plan at `plans/maurolepore/ropensci-system/2026-10-22-ropensci-kb-bootstrap.md`.
