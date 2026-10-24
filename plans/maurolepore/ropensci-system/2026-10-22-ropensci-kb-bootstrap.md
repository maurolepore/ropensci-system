---
type: Plan
status: stable
---

# rOpenSci Knowledge Base Bootstrap — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn this working directory into an Open Knowledge Format (OKF v0.2) knowledge base for rOpenSci, with the software peer-review infrastructure architecture as its first content, source repos cloned under `ORG/REPO` directories, and an `AGENTS.md` hierarchy orienting future agents.

**Architecture:** One OpenKnowledge project at the working-directory root (`ok init` + `ok seed --pack okf`). Knowledge lives in OKF `concepts/` docs with YAML frontmatter and standard Markdown links. Content is grounded in three source classes: (1) locally cloned repos, (2) official docs fetched read-only from the web, (3) live deployment ground truth from read-only `heroku`/`gh` commands. An `AGENTS.md` hierarchy (root → org → key repos) records structure and conventions.

**Tech Stack:** `ok` CLI 0.70.4, OKF v0.2, `gh` CLI (authed), `heroku` CLI (authed as `accounts@ropensci.org`), Markdown + YAML frontmatter, Mermaid for diagrams.

**Spec:** User request of 2026-10-22: this directory is a knowledge base for all things rOpenSci (particularly software peer review); `ORG/REPO` layout mapping to GitHub orgs; OKF format via `ok` CLI; first content = peer-review infrastructure architecture per the chatops blog post, roreviewapi docs, buffy docs, and ropensci-review-tools readthedocs; cloning welcome; missing orgs may be added; read-only on external resources, writes allowed locally; write `AGENTS.md` at root and (if useful) in org/repo dirs.

## Global Constraints

- No `git commit`/`push` or other git mutations anywhere (user must ask explicitly).
- External resources are strictly read-only: `webfetch`, `gh api` GETs, `heroku apps:info|config:json` etc.
- Never record secret values (Heroku config vars: record names only, values redacted).
- Every non-reserved `.md` doc gets parseable frontmatter with a non-empty `type` (OKF floor).
- Reserved filenames `index.md`/`log.md` stay lowercase; only the root `index.md` declares `okf_version: "0.2"`.
- Standard Markdown links (no `[[wiki-links]]`) for portability.
- Docs cite canonical `ropensci*` GitHub URLs even where the local clone is a `maurolepore` fork.

## Review Focus

- **Stale docs:** external docs (blog 2022, readthedocs) may lag the repos — every concept records `provenance` source URLs + retrieval date 2026-10-22.
- **Fork drift:** local `dev_guide`, `roweb3`, `software-review-private` are `maurolepore` forks — docs must not present fork state as canonical; cite upstream.
- **Secrets leakage:** Heroku/Airtable tokens exist in this environment — docs and AGENTS.md must contain config-var names only.
- **Token budget:** the research phase reads 5+ large doc sites — distill via parallel subagents (≤400 lines returned each), never paste raw docs into the KB.
- **`ropensci/lyh970817/`** is a stray non-repo directory (no remote) — document it in the org AGENTS.md as not-a-repo; do not delete.

---

### Task 1: Initialize the OpenKnowledge project

**Files:**
- Create: `.ok/` (via CLI), `.opencode/skills/open-knowledge/` (project-local skill, if installer detects the dir)
- Modify: root `index.md`, `concepts/getting-started.md` (seeded)

**Interfaces:**
- Produces: an OK-initialized root that Tasks 4–5 write OKF docs into; `ok lint`/`ok audit` usable in Task 6.

- [ ] **Step 1: Run `ok init` in the WD root**
  Note which agent dirs it detects; if none, `mkdir -p .opencode/skills` and re-run so the project-local skill lands for future opencode sessions.
- [ ] **Step 2: Run `ok seed --pack okf`**
  Expected: `index.md` with `okf_version: "0.2"`, `concepts/getting-started.md`, OKF plugin enabled, `okf-knowledge-base` project skill.
- [ ] **Step 3: Verify**
  Run: `ok status`; `ls .ok/ concepts/`
  Expected: `.ok/` exists, seed files present.

### Task 2: Clone missing peer-review-infra repos

**Files:**
- Create: `ropensci-review-tools/{pkgcheck,pkgcheck-action,autotest,srr,pkgstats,dashboard,ropensci-review-tools}/`
- Create: `ropensci-org/pkgreviewr/`

**Interfaces:**
- Produces: local ground truth Task 4 docs cite as `ORG/REPO` paths.

- [ ] **Step 1: Clone (parallel, shallow history ok — full clone for grep-ability)**

```bash
gh repo clone ropensci-review-tools/pkgcheck ropensci-review-tools/pkgcheck
gh repo clone ropensci-review-tools/pkgcheck-action ropensci-review-tools/pkgcheck-action
gh repo clone ropensci-review-tools/autotest ropensci-review-tools/autotest
gh repo clone ropensci-review-tools/srr ropensci-review-tools/srr
gh repo clone ropensci-review-tools/pkgstats ropensci-review-tools/pkgstats
gh repo clone ropensci-review-tools/dashboard ropensci-review-tools/dashboard
gh repo clone ropensci-review-tools/ropensci-review-tools ropensci-review-tools/ropensci-review-tools
gh repo clone ropensci-org/pkgreviewr ropensci-org/pkgreviewr
```

- [ ] **Step 2: Verify**
  Run: `for d in ropensci-review-tools/*/; do git -C "$d" remote get-url origin; done`
  Expected: 8+2 remotes resolve; no dir left empty.

### Task 3: Research external docs (5 parallel background subagents)

**Files:** none (subagents return distilled notes; Task 4 writes files)

**Interfaces:**
- Produces: five ≤400-line distilled notes blocks consumed by Task 4, each fact carrying a source URL.

- [ ] **Step 1: Dispatch subagent A** — fetch `https://ropensci.org/blog/2022/05/31/chatops-review-system-github/` (whole post incl. "initial preparation / installation steps"); distill the system components, data flow, and deployment facts.
- [ ] **Step 2: Dispatch subagent B** — fetch `https://docs.ropensci.org/roreviewapi/` README + articles (esp. `articles/editorsearch.html`); distill endpoints, auth, Google Cloud deployment, Airtable use.
- [ ] **Step 3: Dispatch subagent C** — fetch `https://buffy-ropensci.readthedocs.io/en/latest/` (all sections); distill architecture, responders, config, Heroku deployment.
- [ ] **Step 4: Dispatch subagent D** — fetch `https://ropensci-review-tools.readthedocs.io/en/latest/`; distill the tool inventory (pkgcheck, autotest, srr, pkgstats, roreviewapi, dashboard, badges…) and each tool's role in review.
- [ ] **Step 5: Dispatch subagent E** — read local `ropensci-org/buffy`, `ropensci-org/badges`, `ropensci-review-tools/roreviewapi`, `ropensci/software-review` READMEs + vignettes; distill ground-truth (entrypoints, config files, issue templates, bot commands).

### Task 4: Write OKF concept docs for the review infrastructure

**Files:**
- Modify: `index.md` (link the concepts)
- Create: `concepts/software-peer-review-architecture.md` (overview + Mermaid flow: submission issue → `@ropensci-review-bot` command → buffy (Heroku `radiant-garden-91913`) → roreviewapi (plumber) → pkgcheck → badges)
- Create: `concepts/buffy.md`
- Create: `concepts/roreviewapi.md`
- Create: `concepts/badges-service.md`
- Create: `concepts/pkgcheck-suite.md` (pkgcheck, pkgcheck-action, autotest, srr, pkgstats)
- Create: `concepts/review-dashboard.md`
- Create: `concepts/software-review-repo.md` (venue, issue templates, review lifecycle commands)
- Create: `concepts/review-infrastructure-map.md` (repo → role → deployment table)

**Interfaces:**
- Consumes: Task 3 notes; Heroku ground truth (`radiant-garden-91913` = buffy; config-var names `BUFFY_*`, `AIRTABLE_*`, `PKGCHECK_TOKEN`, `REDIS_URL`).
- Produces: the KB's first knowledge layer; docs Task 5 AGENTS.md files point to.

- [ ] **Step 1:** Write `software-peer-review-architecture.md` first (the spine); frontmatter `type: Concept`, `status: draft`, provenance block.
- [ ] **Step 2:** Write the seven remaining concept docs, each linking back to the spine; standard Markdown links; every external claim carries its source URL.
- [ ] **Step 3:** Update root `index.md` to link all concepts.

### Task 5: AGENTS.md hierarchy

**Files:**
- Create: `AGENTS.md` (root: KB purpose, OKF conventions, `ok` commands, ORG/REPO rule, read-only-external rule, secrets rule, how to add knowledge)
- Create: `ropensci/AGENTS.md`, `ropensci-org/AGENTS.md`, `ropensci-review-tools/AGENTS.md`, `ropensci-training/AGENTS.md` (what's cloned, what's missing, which repos are review-infra, notes like the `lyh970817` stray dir)
- Create: `ropensci-org/buffy/AGENTS.md`, `ropensci-review-tools/roreviewapi/AGENTS.md`, `ropensci-org/badges/AGENTS.md` (short pointers: what the repo is + link to its concept doc; untracked files inside clones)

**Interfaces:**
- Consumes: Task 4 concept paths.
- Produces: orientation for any future agent entering at any level.

- [ ] **Step 1:** Write root `AGENTS.md`.
- [ ] **Step 2:** Write the four org-level `AGENTS.md`.
- [ ] **Step 3:** Write the three repo-level `AGENTS.md`.

### 2026-10-24 addendum: codebase-wiki layer (post-bootstrap)

After this plan completed, a second layer was added beyond its scope: per-repo OpenKnowledge **codebase wikis** for the clones (first instance: `ropensci-org/buffy`, worktree `ropensci-org/buffy-wiki`, branch `wiki`, pushed to the fork remote `mine`). Notably, **Task 5's per-clone `AGENTS.md` bridges were later removed** - shared repos keep only shared content; orientation is carried by the parent `AGENTS.md` chain plus a generalized "Repos, wikis, and remotes" section at the KB root, with push misfires guarded by a repo-generic `pre-push` hook. The authoritative recipes and rationale live in `concepts/codebase-wiki-setup.md`.

### Task 6: Verify and report

- [ ] **Step 1: Lint**

Run: `ok lint`
Expected: no OKF errors (frontmatter types present, reserved names lowercase).

- [ ] **Step 2: Audit links**

Run: `ok audit`
Expected: no broken internal links.

- [ ] **Step 3: Report**
  Print final tree (2 levels), list concept docs, state follow-ups (orgs not yet covered: ropensci-books? etc.).
