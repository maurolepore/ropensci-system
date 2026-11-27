---
type: Plan
---

# Per-repo codebase wikis — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the remaining in-scope clones a focused, source-grounded codebase wiki so the review system has a one-level-deeper overview than the curated KB provides.

**Architecture:** Keep the two-layer shape of [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md): curated OKF KB above, one OpenKnowledge wiki per repo below. Each wiki lives on a `wiki` branch in a sibling worktree nested inside the KB tree, is pushed only to the `mine` fork, and is authored via OK MCP while source is read with native tools. This plan adds no new machinery — it applies the recipe proven on [buffy](https://github.com/maurolepore/buffy/blob/wiki/wiki/OVERVIEW.md), [roreviewapi](https://github.com/maurolepore/roreviewapi/blob/wiki/wiki/OVERVIEW.md), and [software-review](https://github.com/maurolepore/software-review/blob/wiki/wiki/OVERVIEW.md).

**Tech Stack:** git worktrees + `pre-push` hooks, `gh` CLI, `ok` CLI (`codebase-wiki` pack), OpenKnowledge MCP, GitHub forks.

**Spec:** [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md) plus the repo matrix below.

## Status (2026-11-27)

**A fresh agent picks up here: Task A — `ropensci-review-tools/dashboard`.**

- Done: preflight/canonical setup; `ropensci/software-review` wiki ([OVERVIEW](https://github.com/maurolepore/software-review/blob/wiki/wiki/OVERVIEW.md), 14 pages + log, `public/standard`, source snapshot `7cd3ef2`); KB inventory updated. Its fork is `maurolepore/software-review` (the earlier `onboarding` name was renamed on 2026-11-26).
- Remaining: 12 repos — see [Current wikis](../../../concepts/codebase-wiki-setup.md#current-wikis), the live list; this plan's checkboxes below are the task queue.
- Completed detail lives in git history, not the queue: wiki commits `67416b5` then `e84a113`; KB commits `27deca7`, `4502a2a`, `9e3ee47`, `0498127`. Do not recreate the software-review wiki.

## Global Constraints

- Preconditions: `gh`, `git`, `ok` CLI, and a running OpenKnowledge server.
- Reuse the recipe in [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md) verbatim; do not redesign the wiki shape, pack, or branch/remote model.
- Every wiki: `wiki/OVERVIEW.md` with `profile: public/standard` and `source_commit` stamped from **the source snapshot actually read** (the worktree checkout created from `origin/main`), never from a feature-branch checkout in the code clone; `wiki/log.md` with one dated entry per generate/refresh run; folders `architecture/`, `modules/`, `flows/`, `concepts/`, `guides/` using the pack templates.
- Generation request: "Generate the codebase wiki, audience public, depth standard." Append the repo-specific focus from the matrix.
- Source references in `public` profile use GitHub blob URLs to the **upstream** repo; no local paths, secrets, tokens, or internal infrastructure details.
- Wiki markdown is authored only via OK MCP with the worktree's absolute path as `cwd`; source code is read with native tools **from the worktree checkout**.
- Remote convention: `origin` = upstream, `mine` = `git@github.com:maurolepore/<repo>.git`, branch `wiki`, worktree `<org>/<repo>-wiki/`. If `gh repo fork` reports an existing fork, verify its parent with `gh api repos/<fork> --jq .parent.full_name` before reusing it.
- Guard hook is copied as-is from `ropensci-org/buffy/.git/hooks/pre-push`; `core.hooksPath` is set to an **absolute** path per clone; `branch.wiki.pushRemote = mine`. Carry over the global `commit-msg` hook by symlink.
- Fork creation and force-restarting the shared OK server are remote/local-service mutations: ask the user before doing either.
- No tracked files change inside code clones (git config and hooks only); no feature branches go to `mine`; `wiki` never goes to `origin`.
- Every agent commit carries `Co-Authored-By: Hy4 flash Free (OpenCode) <noreply@opencode.ai>`.
- Reconcile the [Current wikis](../../../concepts/codebase-wiki-setup.md#current-wikis) table after each repo; commit the KB working tree in the same task.

## Review Focus

- **Nested OK project resolution:** `ok init` inside the worktree can resolve the enclosing KB project. Test: `.ok/config.yml` exists before `ok init`; OK MCP calls with the worktree as `cwd` read the worktree, not the KB root.
- **Global hooksPath disables the guard:** a global `core.hooksPath` silently skips `.git/hooks`. Test: `git config --get core.hooksPath` is absolute per clone, and dry-run wrong pushes are rejected.
- **Fork/upstream inversion:** `ropensci/dev_guide` and `ropensci/roweb3` currently have `origin` = `maurolepore/<repo>.git` and `upstream` = `ropensci/<repo>.git`. Test: rename remotes to convention (Task D) before setup.
- **Freshness provenance:** a false `source_commit` makes incremental refresh silently keep stale pages. Test: frontmatter equals the commit whose source you read (worktree HEAD at generation), not the code clone's HEAD; a dated `wiki/log.md` entry exists.
- **Public-profile leakage:** internal paths, tokens, or upstream-vs-fork URL mistakes. Test: `ok audit` in the worktree and `grep -R '/Users/|localhost|token|secret' wiki/` returns nothing.

## Repo matrix

Existing wikis — **read, do not recreate**: `ropensci-org/buffy`, `ropensci-review-tools/roreviewapi`, `ropensci/software-review`.

| Wave | Repo | Generation focus | Status / exception |
| --- | --- | --- | --- |
| 1 | `ropensci/software-review` | `README.Rmd` editor list from Airtable via `airtabler`; issue-template `editor` variable; `.buffy/templates` | done 2026-11-26 |
| 1 | `ropensci-review-tools/dashboard` | Airtable + GitHub-issue read path; editor load/views | **next** |
| 2 | `ropensci-org/badges` | Badge minting on approval; status inputs | pending |
| 2 | `ropensci-review-tools/pkgcheck` | Check pipeline behind `/editorcheck` | pending |
| 2 | `ropensci-review-tools/pkgstats` | Stats extraction consumed by pkgcheck/srr | pending |
| 2 | `ropensci-review-tools/srr` | Statistical-standards checks behind `/srrcheck` | pending |
| 3 | `ropensci-review-tools/pkgcheck-action` | Author-side GitHub Action wrapping pkgcheck | pending |
| 3 | `ropensci-review-tools/ropensci-review-tools` | How the org's readthedocs site bundles repo docs | pending; mostly docs, keep depth standard |
| 4 | `ropensci/dev_guide` | Editorial process/policy source | pending; remote inversion |
| 4 | `ropensci/roweb3` | Site source of the chat-ops blog post | pending; remote inversion |
| 4 | `ropensci/software-review-meta` | Meta issues/projects for the program | pending; thin repo |
| 4 | `ropensci/statistical-software-review-book` | Stats review procedures | pending; book source |
| 4 | `ropenscilabs/statistical-software-review` | Sandbox used to test editorial tooling | pending; thin repo |

Out of scope: `ropensci-org/pkgreviewr` (relevant to reviewer work but not cloned). Add it later only if actively worked on, per the lazy-setup rule.

## Canonical per-repo recipe

Run once per repo, substituting `<org>/<repo>` and the focus phrase from the matrix.

1. **Setup.** Ask the user to approve the fork. Then, from the KB root:

   ```bash
   gh repo fork <org>/<repo> --clone=false
   git -C <org>/<repo> fetch origin main
   git -C <org>/<repo> branch wiki origin/main
   git -C <org>/<repo> worktree add /Users/maurolepore/git/ropensci-system/<org>/<repo>-wiki wiki
   git -C <org>/<repo> remote add mine git@github.com:maurolepore/<repo>.git
   ```

   Use the **absolute** worktree path: `git -C` resolves relative paths against the clone. If the fork already exists, verify its parent before reuse and use `remote set-url mine` instead of `remote add`.

2. **Nested OK project.** In the worktree: `mkdir -p .ok`, write `# OpenKnowledge project config` to `.ok/config.yml`, then `ok init` and `ok seed --pack codebase-wiki -y`. If OK MCP calls with the worktree `cwd` fail with a content-ownership collision, the parent KB server has not excluded the new worktree: ask before `ok stop --force`, restart the KB server with `ok start --no-open-browser`, then start a server in the worktree.

3. **Source snapshot.** Record `git -C <org>/<repo>-wiki rev-parse HEAD` (the `origin/main` snapshot) **before** any wiki commit. Read source from that worktree with native tools.

4. **Generate.** In a session rooted at the worktree, ask: "Generate the codebase wiki, audience public, depth standard. Focus: `<matrix focus>`." Author all wiki markdown via OK MCP, prefixing doc paths with `wiki/` so folder templates resolve. Stamp `profile: public/standard` and the recorded `source_commit` in `wiki/OVERVIEW.md`; append one dated entry to `wiki/log.md`.

5. **Verify.** `ok audit` on the worktree (0 errors); link-graph check (OVERVIEW links every page); `grep -R '/Users/|localhost|token|secret' wiki/` finds nothing; tracked files in the code clone unchanged.

6. **Guard hook.** Copy `ropensci-org/buffy/.git/hooks/pre-push` into `<org>/<repo>/.git/hooks/`, symlink the global `commit-msg` hook there, set `core.hooksPath` to that absolute directory and `branch.wiki.pushRemote mine`. Dry-runs: `wiki → origin` rejected, feature → `mine` rejected, `wiki → mine` passes.

7. **Back up and reconcile.** Commit the wiki worktree (`docs: add codebase wiki`, with the co-author trailer), push `mine/wiki`, verify `git ls-remote mine refs/heads/wiki` and that upstream has no `wiki` ref. Move the repo's row in [Current wikis](../../../concepts/codebase-wiki-setup.md#current-wikis) from pending to live, pointing to `https://github.com/maurolepore/<repo>/blob/wiki/wiki/OVERVIEW.md`, and commit the KB working tree with the same trailer.

---

### Task A: Wave 1 — `ropensci-review-tools/dashboard`

- [ ] Run the [canonical recipe](#canonical-per-repo-recipe) for `ropensci-review-tools/dashboard` with focus "Airtable + GitHub-issue read path; editor load/views". Current state: upstream-only clone, no fork, no `wiki` branch.

### Task B: Wave 2 — core pipeline packages

- [ ] Run the recipe for `ropensci-org/badges`, `ropensci-review-tools/pkgcheck`, `ropensci-review-tools/pkgstats`, `ropensci-review-tools/srr` with their matrix focus phrases.

### Task C: Wave 3 — peripheral code and docs aggregation

- [ ] Run the recipe for `ropensci-review-tools/pkgcheck-action` and `ropensci-review-tools/ropensci-review-tools` with their matrix focus phrases.

### Task D: Wave 4 — process/docs repos and remote exceptions

- [ ] Normalize remotes for `ropensci/dev_guide` and `ropensci/roweb3`: `git remote rename origin mine`, `git remote rename upstream origin` in each; verify `origin` = upstream and `mine` = fork before setup. Their forks already exist — skip `gh repo fork`.
- [ ] Run the recipe for those two plus `ropensci/software-review-meta`, `ropensci/statistical-software-review-book`, `ropenscilabs/statistical-software-review`. Thin repos may produce smaller wikis, but `OVERVIEW.md`, `log.md`, and stamped frontmatter are mandatory.

### Task E: Final verification

- [ ] Inventory: `git -C <org>/<repo> worktree list` for all 15 repos and `git ls-remote mine refs/heads/wiki` for each fork. Expected: 15 `-wiki` worktrees on disk, 15 `wiki` refs on forks, none upstream.
- [ ] KB consistency: `ok audit` on the KB; [Current wikis](../../../concepts/codebase-wiki-setup.md#current-wikis) matches the inventory exactly, 0 pending.

---

## 2026-11-26 addendum: stamp the snapshot you actually read

The original Task 2 expected `source_commit = git -C <clone> rev-parse HEAD`, which is wrong when the clone checkout is on a feature branch. The software-review clone was on `mauro` (15 commits behind `origin/main`), so the first generation read stale source while stamping the newer snapshot — the final review caught this as Critical. Ten pages were regenerated from the stamped snapshot (`e84a113`); a source-accuracy check went RED→GREEN. The corrected rule is in Global Constraints and the canonical recipe above. The SDD ledger from that run was deleted after the review; the record is in git history, not a live ledger.

## 2026-11-27 addendum: install the guard hook by symlink, not by copy

The canonical recipe (step 6) and Global Constraints above still say the guard hook is "copied as-is from `ropensci-org/buffy/.git/hooks/pre-push`". That installation detail is superseded: the script now lives once, versioned, at `scripts/wiki-pre-push` in this KB, and each clone's `.git/hooks/pre-push` is an ABSOLUTE symlink to it.

- Why: the script was already repo-generic (it derives both worktrees from `git rev-parse --git-common-dir` and the remote coordinates from the clone's own config), so the per-clone copies were pure duplication that could drift.
- What stays: `core.hooksPath` remains an absolute, per-clone path, and the `commit-msg` symlink is untouched. No global `core.hooksPath` - that is the failure mode that silently disabled the guard in the first place.
- Applied 2026-11-27 to the four live wikis (buffy, roreviewapi, software-review, dashboard), with dry-runs re-verified: `wiki -> origin` rejected, feature -> `mine` rejected, `wiki -> mine` passes.
- Two remote gaps surfaced while smoke-testing and were fixed: the buffy clone had no `mine` remote (added; the fork already existed), and `maurolepore/roreviewapi` had been deleted (re-forked). The new roreviewapi fork still needs a first real `git push mine wiki` to restore its backup.
