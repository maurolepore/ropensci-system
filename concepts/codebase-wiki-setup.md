---
type: Concept
status: stable
title: Codebase wiki setup (per-repo OK wikis for the clones)
description: How this knowledge base documents the cloned code repos - a two-layer model where the curated OKF KB points down to per-repo OpenKnowledge codebase wikis, and the recipe for setting one up on a new repo.
tags: [ ropensci, infrastructure, openknowledge, codebase-wiki, meta ]
sources:
  - id: ok-docs
    title: "Codebase wiki - OpenKnowledge docs"
    resource: https://openknowledge.ai/docs/workflows/codebase-wiki
  - id: buffy-wiki
    title: buffy codebase wiki (generated 2026-10-24, audience public / depth standard)
    resource: https://github.com/maurolepore/buffy/tree/wiki/wiki/OVERVIEW.md
  - id: pack-skill
    title: Codebase wiki pack skill (local)
    resource: ropensci-org/buffy-wiki/.opencode/skills/codebase-wiki/SKILL.md
generated: { by: opencode/kimi-k3, at: 2026-10-24T13:16:45-06:00 }
---

## Summary

This KB has **two layers**. The curated OKF layer (`index.md`, `concepts/`, `plans/`) answers "why / what" questions about the rOpenSci system. Code-level "how" questions are answered by **per-repo codebase wikis**: an OpenKnowledge `codebase-wiki` pack seeded into each clone we actively work on, living on a dedicated `wiki` branch that is pushed to a personal fork, never upstream.[^ok-docs] Curated concept docs cite the wiki's GitHub URLs in their `sources` when code-level detail is needed. First instance: the buffy wiki.[^buffy-wiki]

## Why this shape

- The OKF pack and the codebase-wiki pack solve different problems: curated provenance-grounded knowledge vs. a regenerable, source-anchored map of the code. Neither replaces the other.[^ok-docs]
- The wiki lives **in the same git repo as the code** (on its own branch) because the pack's freshness anchor (`source_commit` in `wiki/OVERVIEW.md`) diffs `source_commit..HEAD` - a wiki in a detached repo would diff the wrong history and silently drift.[^ok-docs]
- A dedicated `wiki` branch keeps `main` byte-identical to upstream; a **git worktree** keeps the wiki branch checked out on disk without disturbing the working clone; pushing the branch to a **personal fork** gives backup and canonical GitHub URLs for citation. Upstream is never touched.
- Setup is lazy: only repos we actively work on get a wiki.

## Recipe: add a codebase wiki for repo `<org>/<repo>`

Run from the KB root. Requires `gh`, git, and the `ok` CLI.

```bash
# 1. Fork (remote mutation - needs explicit user approval)
gh repo fork <org>/<repo> --clone=false

# 2. Branch + worktree (clone's checked-out branch is never disturbed)
git -C <org>/<repo> fetch origin main
git -C <org>/<repo> branch wiki origin/main
git -C <org>/<repo> worktree add ../<repo>-wiki wiki
git -C <org>/<repo> remote add mine git@github.com:maurolepore/<repo>.git

# 3. Make the worktree its own OK project.
#    GOTCHA: the worktree sits inside the KB's OK project tree, so `ok init`
#    resolves the ENCLOSING project. Pre-create a minimal .ok/config.yml so
#    project resolution finds the worktree first.
cd <org>/<repo>-wiki
mkdir -p .ok && printf '# OpenKnowledge project config\n' > .ok/config.yml
ok init
ok seed --pack codebase-wiki -y
```

Then ask an agent: "Generate the codebase wiki, audience public, depth standard." Rules for the generating agent:[^pack-skill]

- Author wiki markdown **only** via the open-knowledge MCP tools (`write`/`edit`/`exec`), passing the worktree's absolute path as `cwd`; read source code with native tools.
- `audience: public` = source references as GitHub blob URLs to the **upstream** repo (`https://github.com/<org>/<repo>/blob/main/...`), no secrets or internal infra.
- Stamp `source_commit` + profile in `wiki/OVERVIEW.md` frontmatter; append one dated entry to `wiki/log.md`.

```bash
# 4. Commit and back up
cd <org>/<repo>-wiki && git add -A
git commit -m "docs: add agent-authored codebase wiki (wiki/)"
git push -u mine wiki
```

## Refresh (after the upstream code moves)

```bash
cd <org>/<repo>-wiki && git merge origin/main   # bring code snapshot current
```

Then: "Refresh the codebase wiki" - the pack diffs `source_commit..HEAD` and updates only affected pages. Commit and push to `mine` again.[^ok-docs]

## Current wikis

| Repo | Wiki | Worktree | Branch pushed to |
| --- | --- | --- | --- |
| ropensci-org/buffy | [wiki/OVERVIEW.md](https://github.com/maurolepore/buffy/blob/wiki/wiki/OVERVIEW.md)[^buffy-wiki] | `ropensci-org/buffy-wiki/` | `mine/wiki` (maurolepore/buffy) |
