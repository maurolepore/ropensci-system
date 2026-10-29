---
type: Plan
---

# Sync all open issues and PRs into ropensci project 12

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One script that adds every open issue *and* pull request from every repo already represented on the ropensci project board #12, skipping anything the board already contains — cheap to re-run, never double-adds.

**Architecture:** A new bash script, `tools/bin/ro-project-item-sync`. It takes one `gh project item-list` snapshot (both its repo-scope and its already-present URLs come from that single call), then, per repo, diffs the repo's open issues + PRs against that snapshot and calls `gh project item-add` only for the difference. A `--dry-run` mode prints the same report without mutating the board.

**Tech Stack:** bash (`set -euo pipefail`, same style as the existing `ro-project-item-add`/`-delete`), `gh` v2 CLI, `jq`.

**Spec:** User request in this session, 2026-10-28: "add all open issues and PRs across all repos in the project number 12 of the --owner ropensci … optimized to avoid needless calls for items that are already in the project board".

## Global Constraints

- Project is fixed by constants, same as the sibling scripts: `PROJECT_NUMBER=12`, `PROJECT_OWNER="ropensci"`.
- `gh issue list` does **not** return PRs (verified in session: ropensci-org/buffy has 4 open PRs, 0 in `gh issue list`). Issues and PRs must come from two calls.
- Dedup key is the item's content URL: `https://github.com/<owner>/<repo>/(issues|pull)/<number>`.
- Items with `content == null` (draft issues, org cards) are skipped — no repo, no content URL, nothing to sync.
- The `--dry-run` report prints each to-add URL under its repo line: the exact URLs the apply branch will pass to `gh project item-add`, for eyeballing before a mutating run.
- The `tools/bin/` scripts have no flags beyond positional args; `--dry-run` must be the only flag here.
- Never a bare `gh api` call; stick to named `gh` subcommands, matching sibling scripts.

## Review Focus

- **Repo not currently on the board** (zero existing items — e.g. all its items were deleted): expected to be excluded from scope, because repo scope is derived from the board snapshot. Documented behavior, not a bug.
- **Project grows past the snapshot limit (-L 2000)**: e.g. item #2001 silently missing from the snapshot → script thinks it's absent and re-adds it. Expect a guard that aborts (or warns loudly) instead of silently trusting a truncated snapshot. Test: assert the snapshot's item count is below the limit in Task 1's verification.
- **Re-running after a successful apply**: second run must report "0 to add" for every repo (idempotency). Pinned in Task 3.
- **Open issues count vs board**: a repo whose open issues all live on the board already must produce **zero** `item-add` calls — the whole point of the optimization. Pinned by the dry-run diff in Task 1.
- **Draft / null-content items**: snapshot contains items with no `content`; expected to be skipped without crashing and without contributing repos to the scope. Pinned in Task 1.

---

### Task 1: `tools/bin/ro-project-item-sync` skeleton, `--dry-run` end-to-end

**Files:**
- Create: `tools/bin/ro-project-item-sync`

**Interfaces:**
- Consumes: `gh project item-list`, `gh issue list`, `gh pr list` output shapes as pinned below.
- Produces: bash script, no args printed to stdout; consumed by Task 2 (the apply branch) — the `--dry-run` guard variable and the per-repo `to_add` list are the extension points.

- [ ] **Step 1: Write the script skeleton with --dry-run, before the apply branch**

Behavior (lines are the decisions; the wiring between them is ordinary bash):

1. Reject any argument other than `--dry-run`; with it, export a guard (e.g. `DRY_RUN=1`) that Task 2's apply branch checks.
2. Snapshot: `gh project item-list 12 --owner ropensci -L 2000 --format json` — one call. From it:
   - existing URLs: `.items[] | select(.content != null) | .content.url`, collected into a file (dedup set).
   - item count guard: if `.items | length` >= 2000, abort with a README-line that the snapshot limit was hit.
   - repo scope (nwo): `.items[] | select(.content != null) | .content.repository`, unique.
3. Per repo (looping that unique list):
   - open issues: `gh issue list --repo "$repo" --state open --limit 1000 --json url --jq '.[].url'`
   - open PRs: `gh pr list --repo "$repo" --state open --limit 1000 --json url --jq '.[].url'`
   - union, uniq, then subtract the existing-URL set (`grep -vxF -f` against the snapshot file; tolerate empty output with `|| true`).
   - report line per repo, exact format:
     `printf '%s: %d open, %d on board, %d to add\n' "$repo" ...`
   - URLs that `item-add` would receive, one per line, indented under the repo report line.
   - `--dry-run`: do **not** call `gh project item-add`; the report (counts + URLs) is the deliverable.

- [ ] **Step 2: Verify read-only behavior with --dry-run**

Run: `tools/bin/ro-project-item-sync --dry-run`
Expected: each in-scope repo (from the board snapshot) is listed with a per-repo count line, and every URL printed under a repo is a well-formed issue/PR URL (`/issues/` or `/pull/`) that no other repo line repeats; exits 0. Spot-check two repos against manual `gh` commands: for `ropensci-org/buffy`, "open" >= 24 and "to add" <= "open"; pick one repo whose every open item is already on the board, expect "to add" = 0 for it.

Run: `gh project item-list 12 --owner ropensci -L 2000 --format json --jq '.items | length'` before and after the dry-run; the count is unchanged, and confirming no `item-add` mutation occurred (no `item-add` appears on the board's "activity").

- [ ] **Step 3: Commit**

```bash
git add tools/bin/ro-project-item-sync
git commit -m "feat(tools): add ro-project-item-sync (dry-run) for ropensci project 12"
```

### Task 2: Apply branch + idempotency proof

**Files:**
- Modify: `tools/bin/ro-project-item-sync` (in place of the `--dry-run` guard branch)

**Interfaces:**
- Consumes: Task 1's guard variable and per-repo `to_add` list.
- Produces: the script's final behavior — mutating exactly the items its dry-run report promised.

- [ ] **Step 1: Wire item-add into the non-dry-run branch**

For each URL in `to_add` (skip entirely when the list is empty): `gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$url"`. Then **requires explicit user confirmation first** — this mutates remote state, per repo rules; the run must be prefaced with the dry-run report from Task 1 Step 2 (same numbers expected).

Run without `--dry-run`, after the user OKs it.

- [ ] **Step 2: Verify board count and idempotency**

Run: `gh project item-list 12 --owner ropensci -L 2000 --format json --jq '.items | length'`
Expected: count increased by exactly the sum of per-repo "to add" from the dry run.

Run again, as `tools/bin/ro-project-item-sync --dry-run`:
Expected: every repo reports "to add" = 0 (nothing left over).

```bash
git add tools/bin/ro-project-item-sync
git commit -m "feat(tools): ro-project-item-sync apply mode (deduped item-add)"
```

### Task 3: Document in the KB (end-of-task rule)

**Files:**
- Modify: `concepts/personal-ops-tooling.md` (inventory table) — OKF markdown, edit via OK MCP tools only (`exec` for read, `edit`/`write` for changes), never native tools.

- [ ] **Step 1: Add a one-sentence row describing `ro-project-item-sync`**

Read the concept doc with `exec("cat concepts/personal-ops-tooling.md")`, then edit the inventory table: name + one-sentence behavior, alphabetical position, plus a footnote for the source file per the doc's conventions.

- [ ] **Step 2: Lint + commit the doc**

Run: `ok lint` (expect clean)

```bash
git add concepts/personal-ops-tooling.md
git commit -m "docs(personal-ops-tooling): register ro-project-item-sync"
```

---

### Addendum 2026-10-28 — execution record

Executed via subagent-driven development directly on the KB working tree (commits: plan 510499c, Task 1 1fd4f93 + fix 8149467, Task 2 091c4ac, Task 3 481efb3, plus a doc-format cleanup). Tasks 1-3 are done and reviewed; this addendum records where execution departed from the plan text.

1. **No git worktree.** Tasks ran directly on the KB repo main branch, one commit per task, per AGENTS.md: the KB itself is the working tree, and its convention overrides the executor skill worktree default.
2. **The real apply run is the user manual step.** Plan Task 2 Step 1 (run without the flag, after the user OKs it) and its idempotency re-run were deliberately not executed by agents; the apply branch was verified code-level only, through a gh shim that logs item-add calls without mutating GitHub (28 calls logged, none real). Corrected detail: the Review Focus line "idempotency - pinned in Task 3" is wrong; the idempotency check lives in Task 2 Step 2, and per this addendum it is the user manual run that proves it.
3. **Scope is repos represented on the board**: a repo with zero board items is invisible to this tool by design.
4. **Known bounded failure mode (ruled during execution):** project item-list output carries no archived-state field, so an open issue whose item was deliberately archived on the board is invisible to the snapshot and may be re-added (GitHub returns the existing item rather than creating a duplicate).

**How to run the manual apply** — take a fresh baseline; the plan item-count references have already drifted, the board moves under this tool:

```bash
ro-project-sync --dry-run    # eyeball per-repo counts + the exact URLs to add
gh project item-list 12 --owner ropensci -L 2000 --format json --jq ".items | length"  # baseline board count
ro-project-sync              # the real run; prints the same report, then item-add per URL
gh project item-list 12 --owner ropensci -L 2000 --format json --jq ".items | length"  # expect: baseline + dry-run total
```

Then re-run ro-project-sync --dry-run: every repo must report 0 to add. That re-run is the idempotency proof in place of plan Task 2 Step 2, on a real run.

### Addendum 2026-10-28 — rename

`tools/bin/ro-project-item-sync` is now `tools/bin/ro-project-sync` (user request); the run commands above use the new name. References above the execution addendum keep the name in force at the time.
