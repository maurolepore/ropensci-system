---
type: Plan
status: draft
generated:
  by: "process:opencode (hy4-flash-free)"
  at: 2026-11-26T01:00:41Z
---

# Upstream Fork Sync (buffy) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the 21 upstream commits from openjournals/buffy into ropensci-org/buffy — fast-forward fork `main` and merge them into the auto-deployed `ropensci` branch through a pull request — after a risk-free rehearsal in a throwaway copy, with a triage table that identifies the current case, a behavior check for every case, and an undo checklist for each failure.

**Architecture:** Four layers with separate write targets: the triage (observed state → checklist), the throwaway copy (all experiments, deletable), the real clone `ropensci-org/buffy/` (only after explicit approval), and the remote `origin` plus Heroku (only that last stage changes what users see). Upstream `main` is synced by fast-forward; production `ropensci` is synced by a single merge commit delivered through a PR so CI runs before the auto-deploy — the pattern this repo already used for PR `#126`.

**Tech Stack:** git 2.39.5 (`git merge-tree --write-tree` available), `gh` CLI (`pr create` / `pr checks` / `pr merge` / `repo sync`), HTTPS upstream remote (public, read-only fetch), Ruby 4.0.2 / Bundler 4.0.6 via Docker, Heroku GitHub auto-deploy.

**Spec:** Maëlle Salmon's 2026-11-25 message linking [openjournals/buffy#141](https://github.com/openjournals/buffy/pull/141) and asking to update our fork. Best practice: [GitHub, "Syncing a fork"](https://docs.github.com/articles/syncing-a-fork). Local precedent: PR [#126 "Merge main"](https://github.com/ropensci-org/buffy/pull/126) and `git log --merges --grep='main' origin/ropensci`. Context: `concepts/buffy.md`, `concepts/codebase-wiki-setup.md`, `plans/ropensci-org/buffy/2026-10-24-buffy-dev-environment.md`, `plans/ropensci-org/buffy/142_set-hold-reminder.md`. rOpenSci guidance: `ropensci/roweb3/content/blog/2022-05-31-chatops-review-system-github/index.md`, `ropensci/roweb3/content/blog/2025-02-20-forks-upstream-relationship/index.md`.

## Best practice and our precedent

- **GitHub's documented flow:** add an `upstream` remote, `git fetch upstream`, merge `upstream/main` into the fork's default branch, push; the web UI's **Sync fork → Update branch** or `gh repo sync <fork> -b main` do the same for a simple fast-forward. When the update causes conflicts, GitHub asks for a PR to resolve them. A sync only updates the local copy until you push.
- **Keep the fork's default branch byte-identical to upstream.** Fork `main` is 0 ahead, so `merge --ff-only` is enough — never rebase or squash it. That keeps future upstream PRs clean.
- **Never rebase the long-lived production branch.** `ropensci` carries 252 rOpenSci-only commits; rebasing them would rewrite shared history and the SHAs Heroku has deployed. Merge upstream into it once, as a single merge commit.
- **Run CI before the deploy.** Push the merge to a branch, open a PR into `ropensci`, require green checks, then merge. This is how this repo did it before: PR `#126` (merged 2026-03-24) says it merges into `ropensci` the latest `main` including all fixes and improvements coming from upstream; git history records `73da746 Merge branch 'main' into ropensci` (2026-05-05, parents `fe1917b` + `f357243`), `d8b2781` (2026-03-26), `7f2b600`/`ac0a7f4` (2024-10-24), and others. So **yes, we have done this before** — in git/GitHub, but with no written procedure in this KB (closed in scenario 9 step 4).
- **Automated alternatives exist** (the "Pull" GitHub App / `pull.yml` can keep a fork's default branch synced automatically); none is configured here (only `.github/workflows/tests.yml`), so the manual flow below applies.
- **rOpenSci's own guidance is adjacent, not procedural.** The 2022 chat-ops post calls "keeping Buffy codebase up to date with upstream changes" a maintenance duty (`ropensci/roweb3/content/blog/2022-05-31-chatops-review-system-github/index.md:69`) and says to try commands in a test review repo after each change (same post, line 144). The 2025 fork post recommends isolating fork-specific changes in config files/variables, putting auto-generated changes in separate commits, and contributing features upstream as focused PRs (`ropensci/roweb3/content/blog/2025-02-20-forks-upstream-relationship/index.md:70-145`). Neither branch of buffy has a CONTRIBUTING file or sync doc: `git grep` over `origin/main` and `origin/ropensci` finds no instructions; the same is true of the other cloned rOpenSci repos. This plan is therefore the first written buffy-specific procedure.

## Global Constraints

- **No git mutations in the real clone, no pushes, and no external mutations without Mauro's explicit approval.** Read-only inspection and work in the throwaway copy are always allowed.
- Define `COPY=/private/var/folders/42/g2cj41t50_qg_r9yzb1tz7n40000gn/T/opencode/buffy-try` and `REPO=/Users/maurolepore/git/ropensci-system/ropensci-org/buffy`; commands below use these variables so the working directory is never ambiguous.
- Known-good SHAs: fork `main` = `f357243` (2026-05-05, also the fork point); `ropensci` = `edd00b7`; upstream `main` = `99787a1` (merge of #141); PR commit `6dd1d98`.
- Counts (verify before relying on them): fork `main` is 0 ahead / 21 behind upstream; `ropensci` is 252 ahead / 21 behind.
- `ropensci` is the production branch: every push to it auto-deploys to Heroku app `radiant-garden-91913` (1–7 min lag). `main` has no deploy attached.
- **After every push, immediately run `git ls-remote` and record the output.** Never infer push success from the exit code alone.
- Do not push `wiki` to `origin`, and do not push feature branches to `mine`. `core.hooksPath` points at an absolute local hooks dir and the pre-push hook enforces both rules.
- `mine` (maurolepore/buffy) was removed from the clone's remotes as of 2026-11-25; only `origin` remains. Re-add it only in scenario 9, with approval.
- Never record token values; config-var *names* only.
- Preserve the in-flight `142_set-hold-reminder` branch and its plan; do not reset or delete it.

## Review Focus

- **Conflict on `ropensci`:** 252 rOpenSci-only commits vs 21 upstream commits — a plausible conflict in a file rOpenSci customized. Scenario 2 pins the resolution rule, including committing the result.
- **Accidental deploy:** a push to `ropensci` deploys even if the merge was only a trial. Scenario 4 gates it behind a green PR; scenario 5 watches the release.
- **Bot side effects:** between a bad deploy and its revert, the bot may post comments, change labels/issue bodies, write to Airtable, or send org invites. Scenario 8 covers cleanup a git revert cannot do.
- **Wrong case chosen:** local undo and remote undo look alike from prose alone. The triage table decides the case from observed state *before* anything destructive.
- **Stopped bot looks healthy:** dynos scaled to zero show no errors in logs. Scenario 8 verifies `heroku ps` before reading logs.

## Triage — which case am I in? (do this first, and again after any push)

| Observed state (run the command) | Meaning | Go to |
| --- | --- | --- |
| `git -C $REPO status -sb` dirty, or `git -C $REPO rev-parse HEAD` ≠ `edd00b7` | wrong starting state — park or stop | Scenario 0 |
| `git -C $REPO rev-parse main` ≠ `f357243` | fork `main` already moved | re-verify ground truth before scenario 4 |
| `git -C $COPY merge-tree --write-tree origin/ropensci FETCH_HEAD; echo $?` → `0` | rehearsal merge is clean | Scenario 3 |
| same → `1` | rehearsal has conflicts | Scenario 2 |
| same → other exit code | tool error, not a conflict | stop and investigate |
| `git -C $REPO rev-parse -q --verify MERGE_HEAD` prints a SHA | real merge in progress | Scenario 6 step 1 |
| on `ropensci`, `HEAD` ≠ `edd00b7`, no `MERGE_HEAD` | merge committed locally | Scenario 6 step 2 (after remote check) |
| `git ls-remote origin refs/heads/main refs/heads/ropensci` → `f357243` / `edd00b7` | nothing landed remotely | Scenario 6 |
| same → `ropensci` = the bad merge SHA | bad push landed | Scenario 7, then 8 |
| `heroku releases --app radiant-garden-91913` top entry `Deploy <bad-sha>` and `heroku ps` shows web/worker up | bad code is live | Scenario 8 |

**Behavior checks — how to know the system is behaving as expected:**

| Check | Command | Expected |
| --- | --- | --- |
| Upstream commits present in the merge | `git -C $REPO merge-base --is-ancestor 99787a1 HEAD` | exit `0` |
| Upstream delta size | `git rev-list --count f357243..99787a1` | `21` |
| Test suite (copy or real clone) | Docker `bundle exec rspec` | `0 failures` |
| Remote state after push | `git ls-remote origin refs/heads/main refs/heads/ropensci` | exact recorded SHAs |
| Deploy landed | `heroku releases --app radiant-garden-91913` | `Deploy <merge-sha>` within 1–7 min, dynos up via `heroku ps` |
| Bot tolerates whitespace (end-to-end) | comment `@ropensci-review-bot  help` (two spaces) in `ropenscilabs/statistical-software-review` | normal help reply, **not** the `I'm sorry human, I don't understand that` reply from `app/responders/wrong_command_responder.rb:23` |

## Ground truth (read-only; re-verify at execution time)

| Fact | Value | How to verify |
| --- | --- | --- |
| Upstream tip | `99787a1` | `git ls-remote https://github.com/openjournals/buffy.git refs/heads/main` |
| Fork main / fork point | `f357243` | `git ls-remote origin refs/heads/main` |
| Production tip | `edd00b7` | `git ls-remote origin refs/heads/ropensci` |
| Behind / ahead | JSON `{"ahead_by":21,"behind_by":252}` — ropensci is **252 ahead / 21 behind** upstream | `gh api 'repos/ropensci-org/buffy/compare/ropensci...openjournals:main' --jq '{ahead_by,behind_by}'` |
| Whitespace fix | `6dd1d98` → merged as `99787a1` | `gh pr diff 141 --repo openjournals/buffy` |
| Webhook filter untouched on `ropensci` | no diff vs `main` | `git -C $REPO diff origin/main..origin/ropensci -- app/sinatra_ext/github_webhook_filter.rb` |
| Test command | `bundle exec rspec`, no external services | `plans/ropensci-org/buffy/2026-10-24-buffy-dev-environment.md` |
| Bot identity | `@ropensci-review-bot` (production `BUFFY_BOT_GH_USER`); help command `help` | `config/settings-production.yml`, `app/responders/help_responder.rb` |

## Scenario map (the triage table is the entry point)

```text
                    SCENARIO 0: preflight / park changes
                              │
                    SCENARIO 1: throwaway copy  (always first)
                    ├─ clean rehearsal ───────────► SCENARIO 3: tests
                    └─ conflicts ──► SCENARIO 2 ───► SCENARIO 3
                                            │
                              green in the copy
                                            ▼
                    SCENARIO 4: real clone → PR → push origin
                       ├─ before push fails ─► SCENARIO 6 (local undo)
                       └─ after push fails ──► SCENARIO 7 (git) +
                                              SCENARIO 8 (side effects)
                                            │
                                            ▼
                    SCENARIO 5: watch deploy ─► SCENARIO 9: close-out
```

---

### Scenario 0 — Preflight (read-only unless the tree is dirty)

- [ ] **Step 1: Confirm clean real clone and exact starting state**

Run: `git -C $REPO status -sb`, `git -C $REPO rev-parse HEAD`, `git -C $REPO rev-parse main`.
Expected: `## ropensci...origin/ropensci`, clean tree, `edd00b7`, `main` = `f357243`.

- [ ] **Step 2: Confirm the in-flight branch is intact**

Run: `git -C $REPO branch --list '142*'` and `git -C $REPO log --oneline -3 142_set-hold-reminder`. Expected: branch present; leave it untouched. (Do not use `git status -sb 142_set-hold-reminder` — the argument is a pathspec, not a branch.)

- [ ] **Step 3: Park dirty work if any (only if step 1 was dirty)**

Run: `git -C $REPO stash push -m "wip before upstream sync"`, save the `git status -sb` output, and re-run step 1. Expected: clean tree at `edd00b7`. Scenario 6 step 3 restores it.

- [ ] **Step 4: Confirm remotes and hook**

Run: `git -C $REPO remote -v`, `git -C $REPO config --get core.hooksPath`. Expected: only `origin`; hooksPath is the absolute path ending in `/.git/hooks` (a global `~/.config/git/hooks` entry is harmless because the local value wins).

- [ ] **Step 5: Record the known-good SHAs for the scenario 9 addendum**

Write down `f357243`, `edd00b7`, `99787a1` and the pre-stash status before anything moves.

---

### Scenario 1 — Rehearse in a throwaway copy (allowed without approval)

**Files:** `$COPY` (a new directory under the approved temp path); nothing inside the real clone.

- [ ] **Step 1: Clone the current clone into the temp dir**

Run: `git clone $REPO $COPY` (with the literal paths from Global Constraints).
Expected: checkout `ropensci` at `edd00b7`; remote `origin` points at the *local* clone (fine — nothing will be pushed from here).

- [ ] **Step 2: Fetch upstream with a read-only URL**

Run: `git -C $COPY fetch https://github.com/openjournals/buffy.git main`
Expected: 21 new commits in `FETCH_HEAD`, tip `99787a1`. No remote state changes.

- [ ] **Step 3: Probe for conflicts without touching a working tree**

Run: `git -C $COPY merge-tree --write-tree origin/ropensci FETCH_HEAD; echo $?`
Expected: exit `0` + a tree OID → scenario 3; exit `1` + conflict list → scenario 2; any other exit → stop (tool error, not a conflict). Trigger on the exit status, not only on printed file names: git 2.39's `merge-tree` can report some conflicts without a simple file list.

- [ ] **Step 4: Perform the rehearsal merge**

Run: `git -C $COPY switch -c try-sync origin/ropensci` then `git -C $COPY merge --no-ff --no-edit FETCH_HEAD`
Expected: a clean merge commit (record its SHA), or the conflicts handled in scenario 2.

- [ ] **Step 5: Inspect the merged result**

Run: `git -C $COPY merge-base --is-ancestor 99787a1 HEAD; echo $?` → `0`; `git rev-list --count f357243..99787a1` → `21`; `grep -n space_trim_message $COPY/app/sinatra_ext/github_webhook_filter.rb` → the helper is present.

- [ ] **Step 6: Proceed to scenario 3 (tests), then gate G1 for the real clone.**

---

### Scenario 2 — Conflict handling (only if scenario 1 step 3 exits 1, or scenario 4 step 4 conflicts)

- [ ] **Step 1: List the conflicting files**

Run: `git -C $COPY diff --name-only --diff-filter=U` (in the real clone use `$REPO`). For each file view the three versions: `git show :1:<file>` (base), `:2:<file>` (ours = `ropensci`), `:3:<file>` (theirs = upstream).

- [ ] **Step 2: Apply the resolution rule**

For a file with rOpenSci-specific changes (responders, `config/settings-production.yml`, custom docs): keep ours and apply only the upstream hunk by hand. For a file identical on `main` and `ropensci` (notably `app/sinatra_ext/github_webhook_filter.rb`): take theirs.

- [ ] **Step 3: Stage, sanity-check, and commit the merge**

Run: `git -C $COPY add <files>`, `git -C $COPY diff --check`, `git -C $COPY diff --cached --stat`, then **`git -C $COPY merge --continue`**. Expected: a merge commit exists; `git status` is clean. Without this step the branch is left with `MERGE_HEAD` and no commit.

- [ ] **Step 4: Record every resolution in the scenario 9 addendum with its rationale.**

- [ ] **Step 5: Resume at scenario 1 step 5 only** — do not re-run step 4 (`try-sync` already exists and a second `git merge` would refuse). Then scenario 3.

---

### Scenario 3 — Test the merged copy (Docker path, no host installs)

- [ ] **Step 1: Start a disposable container with a persistent gem volume**

Run: `docker pull ruby:4.0.2` (fallback `ruby:4.0`) and `docker volume create buffy-bundle`. Expected: `docker run --rm ruby:4.0.2 ruby -v` prints 4.0.x.

- [ ] **Step 2: Bundle and run the suite against the copy**

Run from `$COPY`:

```bash
cd $COPY
docker run --rm -v "$PWD":/app -w /app -v buffy-bundle:/usr/local/bundle ruby:4.0.2 bash -c 'apt-get update -qq && apt-get install -y -qq --no-install-recommends libicu-dev cmake pkg-config libssl-dev && gem install bundler -v 4.0.6 && bundle install && bundle exec rspec'
```

Expected tail: `0 failures`. No Redis, GitHub token, or cloc needed (test settings + WebMock + fake Sidekiq).

- [ ] **Step 3: Confirm the specific fix is exercised**

Run: `grep -n 'space-trim the message' $COPY/spec/buffy_spec.rb`. Expected: the #141 spec is present and ran in the green suite.

- [ ] **Step 4: Only on green, ask Mauro for gate G1 (mutate the real clone and push).**

---

### Scenario 4 — Real execution (requires gate G1 and gate G2)

- [ ] **Step 1: Re-run scenario 0 (including the triage table); abort on any mismatch.**

- [ ] **Step 2: Fetch upstream into the real clone without adding a persistent remote**

Run: `git -C $REPO fetch https://github.com/openjournals/buffy.git main`. Expected: `FETCH_HEAD` = `99787a1`. (`FETCH_HEAD` survives later `switch`/`merge` commands.)

- [ ] **Step 3: Fast-forward fork `main` locally — do not push yet**

Run: `git -C $REPO switch main`, `git -C $REPO merge --ff-only FETCH_HEAD`.
Expected: local `main` = `99787a1`; `git merge-base --is-ancestor 99787a1 main` exits `0`.

- [ ] **Step 4: Merge upstream into a PR branch off `ropensci` as one merge commit**

Run: `git -C $REPO switch -c merge-upstream-main ropensci`, `git -C $REPO merge --no-ff FETCH_HEAD -m "Merge upstream/main (through 99787a1) into ropensci"`.
If it conflicts, apply scenario 2 steps 1–3 in `$REPO` (resolution must be re-tested at step 6 before any push). Expected: one merge commit; record its SHA.

- [ ] **Step 5: Verify the merge content exactly**

Run: `git -C $REPO merge-base --is-ancestor 99787a1 HEAD; echo $?` → `0`; `git rev-list --count f357243..99787a1` → `21`; `grep -n space_trim_message $REPO/app/sinatra_ext/github_webhook_filter.rb` → present.

- [ ] **Step 6: Re-run the suite in the real clone**

Run from `$REPO` (same Docker command as scenario 3, with `cd $REPO`). Expected: `0 failures`. Then inspect `git -C $REPO diff Gemfile.lock`: commit genuine upstream dependency changes with the merge; restore only incidental churn with `git -C $REPO restore Gemfile.lock`. Do not push on red.

- [ ] **Step 7: Verify the hook, then push the PR branch (gate G2)**

Run: `git -C $REPO config --get core.hooksPath` and `git -C $REPO remote -v` (absolute hooks path; only `origin`), then `git -C $REPO push origin merge-upstream-main`.
Open the PR: `gh pr create --repo ropensci-org/buffy --base ropensci --head merge-upstream-main --title "Merge upstream main (through 99787a1)" --body "Bring upstream fixes (including the #141 whitespace trim) into the production branch; CI must pass before deploy."`

- [ ] **Step 8: Require green CI**

Run: `gh pr checks <n> --repo ropensci-org/buffy` (or `gh pr view <n>`). Expected: all checks pass. If red, fix on the PR branch and re-run step 6 — do not merge.

- [ ] **Step 9: Push `main`, then merge the PR — gate G2, this deploys**

Run: `git -C $REPO push origin main` then `gh pr merge <n> --repo ropensci-org/buffy --merge`.
**Direct-push alternative (only if Mauro explicitly chooses it instead of a PR):** `git -C $REPO switch ropensci && git -C $REPO merge --ff-only merge-upstream-main && git -C $REPO push origin ropensci`.

- [ ] **Step 10: Verify the pushes immediately (never trust the push exit code)**

Run: `git ls-remote origin refs/heads/main refs/heads/ropensci`. Expected `99787a1` and the recorded merge SHA. Record the output in the addendum.

- [ ] **Step 11: Re-sync local branches**

Run: `git -C $REPO fetch origin && git -C $REPO switch ropensci && git -C $REPO reset --hard origin/ropensci`, then `git -C $REPO switch main && git -C $REPO reset --hard origin/main`. Expected: `git status` clean, `HEAD` matches the remote SHA.

---

### Scenario 5 — Deploy watch (read-only commands)

- [ ] **Step 1: Confirm the remote tip**

Run: `git ls-remote origin refs/heads/ropensci`. Expected: the merge SHA from scenario 4 step 4.

- [ ] **Step 2: Watch for the new release (7-minute limit)**

Run: `heroku releases --app radiant-garden-91913`. Expected: `Deploy <merge-sha>` within ~1–7 min; `heroku ps --app radiant-garden-91913` shows `web` and `worker` up. If no matching release after 7 min, check the Heroku GitHub integration/app activity and **escalate before continuing** — do not assume success.

- [ ] **Step 3: Watch boot logs**

Run: `heroku logs --app radiant-garden-91913 --tail` (stop with Ctrl-C). Expected: clean boot, no wall errors.

- [ ] **Step 4: Smoke-test the fix in the sandbox (gate G3 — external mutation)**

In `ropenscilabs/statistical-software-review`, post exactly `@ropensci-review-bot  help` (two spaces after the bot name). Expected: the normal help reply (same as `@ropensci-review-bot help`). Failure signature: `I'm sorry human, I don't understand that` (`app/responders/wrong_command_responder.rb:23`). If it fails, go to scenario 8 immediately.

---

### Scenario 6 — Local undo (triage must confirm nothing landed remotely)

- [ ] **Step 0: Verify first**

Run `git ls-remote origin refs/heads/main refs/heads/ropensci`. Expected `f357243` / `edd00b7`. If `main` is already `99787a1` but `ropensci` is still `edd00b7`, skip to step 2 and then apply scenario 7 step 3 to rewind `main` (gate G4). If `ropensci` holds the bad merge, use scenario 7 instead.

- [ ] **Step 1: Merge still in progress → abort**

Run: `git -C $REPO rev-parse -q --verify MERGE_HEAD` (non-empty ⇒ this step) and `git -C $REPO status -sb` (use `git ls-files -u` for unmerged paths). Then `git -C $REPO merge --abort`. Expected: `git status` clean at `edd00b7`.

- [ ] **Step 2: Bad merge already committed locally → reset**

If `MERGE_HEAD` is empty and `HEAD` ≠ `edd00b7`: `git -C $REPO reset --hard ORIG_HEAD` (fallback: on `ropensci`, `git reset --hard edd00b7`; on `main`, `git reset --hard f357243`). Expected: `git rev-parse HEAD` matches the chosen restore SHA.

- [ ] **Step 3: Restore parked work (only if scenario 0 step 3 created a stash)**

Run: `git -C $REPO stash pop` and compare `git status -sb` with the output recorded in scenario 0 step 5. Expected: identical status.

- [ ] **Step 4: Verify remote is untouched**

Run: `git ls-remote origin refs/heads/main refs/heads/ropensci`. Expected: `f357243` and `edd00b7` (or `99787a1` / `edd00b7` only if `main` was intentionally pushed).

---

### Scenario 7 — Remote undo (after a bad push)

- [ ] **Step 1: Preferred — revert the merge commit**

Run: `git -C $REPO switch ropensci`, `git -C $REPO revert -m 1 <merge-sha>`, `git -C $REPO push origin ropensci`.
`-m 1` is required because the merge commit has two parents. Expected: a new commit restoring pre-merge code; the push triggers a fresh deploy with the old code. Caveat: the merge stays in history, so a later re-sync of the same 21 commits will look already-merged and needs a revert-of-the-revert.

- [ ] **Step 2: Last resort — force-rewind**

Only if the revert cannot be made: `git -C $REPO push --force-with-lease origin edd00b7:refs/heads/ropensci` (gate G4). Coordinate with Maëlle/xuanxu first: this rewrites shared history. Then immediately `git -C $REPO fetch origin ropensci && git -C $REPO reset --hard origin/ropensci` so local and remote agree.

- [ ] **Step 3: Rewind fork `main` if needed**

Run: `git -C $REPO push --force-with-lease origin f357243:refs/heads/main` (gate G4). No deploy is tied to `main`. Then `git -C $REPO fetch origin main && git -C $REPO switch main && git -C $REPO reset --hard origin/main`.

- [ ] **Step 4: Verify git state**

Run: `git ls-remote origin refs/heads/main refs/heads/ropensci` and `git -C $REPO status -sb`. Expected: intended restore SHAs, local `HEAD` equal to the remote SHA on both branches, clean tree.

- [ ] **Step 5: Verify behavior on restored code**

Re-run the Docker `bundle exec rspec` command from `$REPO` (expect `0 failures`), then the scenario 5 step 4 smoke test (expect the normal help reply). Do not close the incident until both pass.

---

### Scenario 8 — Heroku containment and side-effect cleanup (gate G4)

- [ ] **Step 1: Confirm a bad deploy is actually live**

Run `heroku releases --app radiant-garden-91913`, then `heroku releases:info <vN> --app radiant-garden-91913` and confirm `Change: Deploy <merge-sha>`; run `heroku ps --app radiant-garden-91913` to confirm `web`/`worker` are up. Do not "contain" a deploy that never happened.

- [ ] **Step 2: Contain it**

Run `heroku releases:rollback --app radiant-garden-91913`, or temporarily `heroku ps:scale web=0 worker=0 --app radiant-garden-91913` to stop webhook processing. Paused dynos make webhook deliveries fail/retry — restore them in step 5 (process types confirmed from `Procfile`: `web` and `worker`).

- [ ] **Step 3: Inventory what the bot did during the bad window**

Use `heroku logs --app radiant-garden-91913` for successful `POST /dispatch` entries and review the affected issue threads in `ropensci/software-review`. Record issue numbers and timestamps.

- [ ] **Step 4: Undo issue, label, and external state**

Remove erroneous bot comments, restore labels and issue-body markers in affected threads; correct Airtable rows in the Airtable UI; revoke mistaken org invitations in GitHub org settings. A git revert does **not** undo any of these.

- [ ] **Step 5: Restore dynos and verify behavior**

Run `heroku ps:scale web=1 worker=1 --app radiant-garden-91913` (if scaled down), then `heroku ps --app radiant-garden-91913` (both up), `heroku releases --app radiant-garden-91913` (revert/normal deploy is latest), and `heroku logs --app radiant-garden-91913 --tail` (clean boot). Re-run the scenario 5 smoke test (normal help reply) and re-check each affected issue thread, Airtable row, and invitation until all match the pre-incident state.

---

### Scenario 9 — Close-out

- [ ] **Step 1: Delete the throwaway copy**

Run: `rm -rf $COPY`, then `test ! -d $COPY`. Expected: exit `0`, no leftover experiment.

- [ ] **Step 2: Record the outcome as a dated addendum**

Append (never rewrite history): date, actual merge SHA, triage decisions, conflicts and resolutions, test result, deploy release SHA, and any rollback used.

- [ ] **Step 3: Refresh the codebase wiki (gate G5 — upstream code moved)**

In `ropensci-org/buffy-wiki/`: re-add `mine` (`git remote add mine git@github.com:maurolepore/buffy.git`), `git fetch origin main`, `git merge origin/main`, ask "Refresh the codebase wiki", commit, `git push mine wiki`. Verify with `git ls-remote mine refs/heads/wiki`. Remove `mine` again with `git remote remove mine` only if Mauro wants the clone remote-only; verify with `git remote -v`.

- [ ] **Step 4: Write the missing procedure into the KB**

The precedent exists in git/PRs but not in docs: add an upstream-sync section to `concepts/codebase-wiki-setup.md` (its "Working a feature"/"Refresh" sections assume merges into the fork, not from upstream) and link it from `concepts/buffy.md`. Record that PR `#126` is the established pattern.

- [ ] **Step 5: Commit the KB repo**

Commit only the changed KB files with the agent co-author trailer; do not push unless asked.

## Approval gates

| Gate | Action | Why |
| --- | --- | --- |
| G1 | Scenario 3 → 4 | Permission to mutate the real clone |
| G2 | Scenario 4 steps 7–10 | Pushes to `origin` (incl. PR branch and `main`) and PR merge into `ropensci` — the last one deploys |
| G3 | Scenario 5 step 4 | Posting to the sandbox repo is an external mutation |
| G4 | Scenario 6 step 0 (if `main` landed), scenarios 7 / 8 | Rewinds, force-pushes, Heroku changes, issue/Airtable/org edits |
| G5 | Scenario 9 step 3 | Wiki merge and push to `mine` |

### Referenced files

- [buffy - the editorial bot](../../../concepts/buffy.md) — fork topology, production branch, Heroku deployment contract.
- [Codebase wiki setup](../../../concepts/codebase-wiki-setup.md) — remotes, push rules, wiki refresh, working-a-feature loop.
- [Buffy Development Environment](./2026-10-24-buffy-dev-environment.md) — Docker test path, Ruby/Bundler pins.
- [Set Hold Reminders Command](./142_set-hold-reminder.md) — in-flight work to preserve.
