---
type: Plan
---

# Per-repo codebase wikis — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the 13 in-scope clones a focused, source-grounded codebase wiki so the review system has a one-level-deeper overview than the curated KB provides.

**Architecture:** Keep the two-layer shape of [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md): curated OKF KB above, one OpenKnowledge wiki per repo below. Each wiki lives on a `wiki` branch in a sibling worktree nested inside the KB tree, is pushed only to the `mine` fork, and is authored via OK MCP while source is read with native tools. This plan adds no new machinery — it applies the recipe proven on [buffy](https://github.com/maurolepore/buffy/blob/wiki/wiki/OVERVIEW.md) and [roreviewapi](https://github.com/maurolepore/roreviewapi/blob/wiki/wiki/OVERVIEW.md).

**Tech Stack:** git worktrees + `pre-push` hooks, `gh` CLI, `ok` CLI (`codebase-wiki` pack), OpenKnowledge MCP, GitHub forks.

**Spec:** [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md) plus the repo matrix below.

## Global Constraints

- Preconditions: `gh`, `git`, `ok` CLI, and a running OpenKnowledge server.
- Reuse the recipe in [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md) verbatim; do not redesign the wiki shape, pack, or branch/remote model.
- Every wiki: `wiki/OVERVIEW.md` with `profile: public/standard` and a `source_commit` stamped from the clone's HEAD; `wiki/log.md` with one dated entry per generate/refresh run; folders `architecture/`, `modules/`, `flows/`, `concepts/`, `guides/` using the pack templates.
- Generation request: "Generate the codebase wiki, audience public, depth standard." Append the repo-specific focus from the matrix.
- Source references in `public` profile use GitHub blob URLs to the **upstream** repo; no local paths, secrets, tokens, or internal infrastructure details.
- Wiki markdown is authored only via OK MCP with the worktree's absolute path as `cwd`; source code is read with native tools.
- Remote convention: `origin` = upstream, `mine` = `git@github.com:maurolepore/<repo>.git`, branch `wiki`, worktree `<org>/<repo>-wiki/`.
- Guard hook is copied as-is from `ropensci-org/buffy/.git/hooks/pre-push`; `core.hooksPath` is set to an **absolute** path per clone; `branch.wiki.pushRemote = mine`. Carry over the global `commit-msg` hook by symlink.
- Fork creation is a remote mutation: do not run `gh repo fork` until the user explicitly approves it.
- No tracked files change inside code clones (git config and hooks only); no feature branches go to `mine`; `wiki` never goes to `origin`.
- Every agent commit carries `Co-Authored-By: Hy4 flash Free (OpenCode) <noreply@opencode.ai>`.
- Reconcile the "Current wikis" table in [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md) at the end of each wave; commit the KB working tree in the same task.

## Review Focus

- **Nested OK project resolution:** `ok init` inside the worktree can resolve the enclosing KB project. Test: `.ok/config.yml` exists before `ok init`; `ok config` from the worktree reports the worktree, not the KB root (Task 1).
- **Global hooksPath disables the guard:** a global `core.hooksPath` silently skips `.git/hooks`, which previously let `wiki` reach upstream. Test: `git config --get core.hooksPath` is absolute per clone, and dry-run wrong pushes are rejected (Tasks 2–5).
- **Fork/upstream inversion:** `ropensci/dev_guide` and `ropensci/roweb3` currently have `origin` = `maurolepore/<repo>.git` and `upstream` = `ropensci/<repo>.git`, the reverse of the recipe. Test: rename remotes to convention and verify `git remote -v` before setup (Task 5).
- **Freshness provenance:** a missing `source_commit` stamp or log entry silently breaks the incremental refresh mode. Test: frontmatter equals `git rev-parse HEAD` and a dated `wiki/log.md` entry exists after each generation (Tasks 2–5).
- **Public-profile leakage:** internal paths, tokens, or upstream-vs-fork URL mistakes in a public wiki. Test: `ok audit` in the worktree and `grep -R '/Users/|localhost|token|secret' wiki/` returns nothing (Tasks 2–5).

## Repo matrix

Existing wikis — **read, do not recreate**: `ropensci-org/buffy`, `ropensci-review-tools/roreviewapi`.

| Wave | Repo | Generation focus | Exception |
| --- | --- | --- | --- |
| 1 | `ropensci/software-review` | `README.Rmd` editor list from Airtable via `airtabler`; issue-template `editor` variable; `.buffy/templates` | — |
| 1 | `ropensci-review-tools/dashboard` | Airtable + GitHub-issue read path; editor load/views | — |
| 2 | `ropensci-org/badges` | Badge minting on approval; status inputs | — |
| 2 | `ropensci-review-tools/pkgcheck` | Check pipeline behind `/editorcheck` | — |
| 2 | `ropensci-review-tools/pkgstats` | Stats extraction consumed by pkgcheck/srr | — |
| 2 | `ropensci-review-tools/srr` | Statistical-standards checks behind `/srrcheck` | — |
| 3 | `ropensci-review-tools/pkgcheck-action` | Author-side GitHub Action wrapping pkgcheck | — |
| 3 | `ropensci-review-tools/ropensci-review-tools` | How the org's readthedocs site bundles repo docs | Mostly docs; keep depth standard |
| 4 | `ropensci/dev_guide` | Editorial process/policy source | Remote inversion — rename remotes |
| 4 | `ropensci/roweb3` | Site source of the chat-ops blog post | Remote inversion — rename remotes |
| 4 | `ropensci/software-review-meta` | Meta issues/projects for the program | Thin repo; wiki may be small |
| 4 | `ropensci/statistical-software-review-book` | Stats review procedures | Book source; keep depth standard |
| 4 | `ropenscilabs/statistical-software-review` | Sandbox used to test editorial tooling | Thin repo; wiki may be small |

Out of scope: `ropensci-org/pkgreviewr` (relevant to reviewer work but not cloned). Add it later only if actively worked on, per the lazy-setup rule.

---

### Task 1: Preflight and canonical setup procedure

**Files:**

- Modify: local git config and hooks only (no tracked files)
- Modify: `concepts/codebase-wiki-setup.md` (Current wikis table)

**Interfaces:**

- Consumes: the recipe in `concepts/codebase-wiki-setup.md`
- Produces: `SETUP(org/repo)` — the exact command sequence in Step 4 below — plus a truthful Current wikis table. Tasks 2–5 call it with one repo at a time.

- [ ] **Step 1: Record the baseline for all 13 repos**

Run:

```bash
for d in <the 13 repos from the matrix>; do
  printf '%s: ' "$d"
  git -C "$d" remote | tr '\n' ','
  git -C "$d" branch --list wiki
  git -C "$d" config --get core.hooksPath
done
```

Expected (observed 2026-11-26): no `mine` remote, no `wiki` branch or worktree, and every `core.hooksPath` is the global `~/.config/git/hooks`. If any repo already has a wiki, skip it and note the fact.

- [ ] **Step 2: Resolve the two remote-inversion exceptions**

Run `git -C ropensci/dev_guide remote -v` and `git -C ropensci/roweb3 remote -v`. Expected: `origin` = `maurolepore/<repo>.git`, `upstream` = `ropensci/<repo>.git`. In Task 5, rename them (`git remote rename origin mine`, `git remote rename upstream origin`) **before** calling `SETUP`, then re-run `git remote -v` to confirm `origin` = upstream and `mine` = fork.

- [ ] **Step 3: Obtain approval for fork creation**

Ask the user to approve creating the 11 missing forks (all matrix repos except `dev_guide` and `roweb3`, whose forks already exist). Expected: explicit approval before Step 4 of any wave runs `gh repo fork`.

- [ ] **Step 4: Fix the canonical `SETUP(org/repo)` sequence**

Run from the KB root, substituting `<org>/<repo>`; skip `gh repo fork` when the fork already exists:

```bash
gh repo fork <org>/<repo> --clone=false
git -C <org>/<repo> fetch origin main
git -C <org>/<repo> branch wiki origin/main
git -C <org>/<repo> worktree add <org>/<repo>-wiki wiki
git -C <org>/<repo> remote add mine git@github.com:maurolepore/<repo>.git

cd <org>/<repo>-wiki
mkdir -p .ok && printf '# OpenKnowledge project config\n' > .ok/config.yml
ok init
ok seed --pack codebase-wiki -y

cd /Users/maurolepore/git/ropensci-system
cp ropensci-org/buffy/.git/hooks/pre-push <org>/<repo>/.git/hooks/pre-push
chmod +x <org>/<repo>/.git/hooks/pre-push
ln -s ~/.config/git/hooks/commit-msg <org>/<repo>/.git/hooks/commit-msg
git -C <org>/<repo> config core.hooksPath "$PWD/<org>/<repo>/.git/hooks"
git -C <org>/<repo> config branch.wiki.pushRemote mine
```

Expected: `git -C <org>/<repo> worktree list` shows the `-wiki` worktree; `git -C <org>/<repo> remote -v` shows `origin` = upstream and `mine` = fork; `git -C <org>/<repo> config --get core.hooksPath` is absolute; `ok config` from the worktree resolves to that worktree.

- [ ] **Step 5: Reconcile the Current wikis table**

Via OK MCP, edit `concepts/codebase-wiki-setup.md` so the table lists both existing wikis (buffy and roreviewapi) and the 13 pending repos grouped by wave. Commit the KB working tree:

```bash
git -C /Users/maurolepore/git/ropensci-system add concepts/codebase-wiki-setup.md
git -C /Users/maurolepore/git/ropensci-system commit -m "kb: reconcile codebase-wiki inventory" -m "Co-Authored-By: Hy4 flash Free (OpenCode) <noreply@opencode.ai>"
```

Expected: the table shows 2 existing + 13 pending; no stale claims.

---

### Task 2: Wave 1 — `ropensci/software-review` and `ropensci-review-tools/dashboard`

**Files:**

- Create: `ropensci/software-review-wiki/wiki/**`, `ropensci-review-tools/dashboard-wiki/wiki/**`
- Modify: KB Current wikis table

**Interfaces:**

- Consumes: `SETUP(org/repo)` from Task 1
- Produces: two wikis with stamped `OVERVIEW.md`, append-only `log.md`, and guarded remotes

- [ ] **Step 1: Run `SETUP` for `ropensci/software-review`**

Expected: all Step 4 checks from Task 1 pass.

- [ ] **Step 2: Generate its wiki**

In a session rooted at `ropensci/software-review-wiki/`, ask: "Generate the codebase wiki, audience public, depth standard. Focus: how `README.Rmd` renders the editor list from Airtable via `airtabler`, the issue-template `editor` variable, and `.buffy/templates`."

Expected: `wiki/OVERVIEW.md` has `profile: public/standard` and `source_commit` = `git -C ropensci/software-review rev-parse HEAD`; `wiki/log.md` has one dated entry; all five section folders exist.

- [ ] **Step 3: Verify the wiki**

Run `ok audit` with `cwd` = the worktree, `grep -R '/Users/\|localhost\|token\|secret' wiki/`, and `git -C ropensci/software-review status --short`.

Expected: audit shows no errors; grep finds nothing; tracked clone files unchanged.

- [ ] **Step 4: Smoke-test the guard hook**

Run `git -C ropensci/software-review-wiki push --dry-run origin wiki` (expected: rejected by hook) and `git -C ropensci/software-review push --dry-run mine HEAD:refs/heads/guard-test` (expected: rejected by hook). Then `git -C ropensci/software-review-wiki push --dry-run mine wiki` (expected: passes).

- [ ] **Step 5: Commit and back up the wiki**

```bash
git -C ropensci/software-review-wiki add -A
git -C ropensci/software-review-wiki commit -m "docs: add codebase wiki" -m "Co-Authored-By: Hy4 flash Free (OpenCode) <noreply@opencode.ai>"
git -C ropensci/software-review-wiki push -u mine wiki
```

Expected: `mine/wiki` updated; upstream untouched.

- [ ] **Step 6: Repeat Steps 1–5 for `ropensci-review-tools/dashboard`** with focus "the Airtable + GitHub-issue read path and editor load/views".

- [ ] **Step 7: Update the KB table and commit**

Mark both repos as having wikis in `concepts/codebase-wiki-setup.md`; commit the KB working tree with the co-author trailer.

---

### Task 3: Wave 2 — core pipeline packages

**Files:**

- Create: `ropensci-org/badges-wiki/wiki/**`, `ropensci-review-tools/{pkgcheck,pkgstats,srr}-wiki/wiki/**`
- Modify: KB Current wikis table

**Interfaces:**

- Consumes: `SETUP(org/repo)` from Task 1
- Produces: four wikis for the check/badge pipeline

- [ ] **Step 1: Run Steps 1–5 of Task 2 for each of the four repos**, substituting the repo and using the focus phrases from the matrix.
- [ ] **Step 2: Verify all four** with the Task 2 Step 3 checks and the guard dry-runs.
- [ ] **Step 3: Update the KB table and commit** the KB working tree with the co-author trailer.

---

### Task 4: Wave 3 — peripheral code and docs aggregation

**Files:**

- Create: `ropensci-review-tools/pkgcheck-action-wiki/wiki/**`, `ropensci-review-tools/ropensci-review-tools-wiki/wiki/**`
- Modify: KB Current wikis table

**Interfaces:**

- Consumes: `SETUP(org/repo)` from Task 1
- Produces: two wikis

- [ ] **Step 1: Run Steps 1–5 of Task 2 for each repo**, using the matrix focus phrases; keep `ropensci-review-tools/ropensci-review-tools` at depth standard even though it is mostly docs.
- [ ] **Step 2: Verify both** with the Task 2 Step 3 checks and the guard dry-runs.
- [ ] **Step 3: Update the KB table and commit** the KB working tree with the co-author trailer.

---

### Task 5: Wave 4 — process/docs repos and remote exceptions

**Files:**

- Create: five `<org>/<repo>-wiki/wiki/**` worktrees from the matrix
- Modify: `ropensci/dev_guide` and `ropensci/roweb3` local git config only
- Modify: KB Current wikis table

**Interfaces:**

- Consumes: `SETUP(org/repo)` from Task 1
- Produces: five wikis; remote conventions normalized for the two inverted repos

- [ ] **Step 1: Normalize remotes for the two exceptions**

Run `git -C ropensci/dev_guide remote rename origin mine`, `git -C ropensci/dev_guide remote rename upstream origin`, and the same two commands for `ropensci/roweb3`. Expected: `git remote -v` in each shows `origin` = `ropensci/<repo>.git` and `mine` = `maurolepore/<repo>.git`; no fetch/push performed.

- [ ] **Step 2: Run Steps 1–5 of Task 2 for all five repos**, skipping `gh repo fork` (forks already exist for the first two) and using the matrix focus phrases. Thin repos may produce smaller wikis, but `OVERVIEW.md`, `log.md`, and the stamped frontmatter are mandatory.

- [ ] **Step 3: Verify all five** with the Task 2 Step 3 checks and the guard dry-runs.

- [ ] **Step 4: Update the KB table to its final state and commit** the KB working tree with the co-author trailer. Expected: 15 wikis listed (2 existing + 13 new), 0 pending.

---

### Task 6: Final verification

**Files:** none

**Interfaces:**

- Consumes: all wikis from Tasks 2–5
- Produces: a single pass/fail statement covering all 15 wikis

- [ ] **Step 1: Inventory check**

Run `git -C <org>/<repo> worktree list` for all 15 repos and `git ls-remote mine refs/heads/wiki` for each fork.

Expected: 15 `-wiki` worktrees on disk and 15 `wiki` refs on the forks; no `wiki` ref on any upstream.

- [ ] **Step 2: KB consistency check**

Run `ok audit` on the KB and compare the Current wikis table to the inventory.

Expected: no audit errors; table rows match the on-disk and remote state exactly.

---

## 2026-11-26 addendum: stamp the snapshot you actually read

Task 2's literal expectation "source_commit = `git -C <clone> rev-parse HEAD`" is wrong when the clone checkout is on a feature branch. Here the clone was on `mauro` (15 commits behind `origin/main`), so the first wiki generation read stale source while stamping the newer snapshot — the final review caught this as Critical.

Rule for the remaining waves: generate from the same checkout you stamp. Create the `wiki` worktree from `origin/main`, read source code from that worktree with native tools, and stamp that source snapshot's commit. Do not read source from the code clone unless its HEAD equals the stamp. `source_commit` is a source-snapshot anchor, not the wiki branch HEAD (which advances with each wiki commit). See the final-review entry in this plan's SDD ledger for the corrected pages and verification.
