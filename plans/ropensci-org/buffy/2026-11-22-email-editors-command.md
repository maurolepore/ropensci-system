---
type: Plan
status: draft
---

# Email Editors Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bot command `@ropensci-review-bot email editors <message>` that actually sends `<message>` as email to the editorial board (e.g. a vacation notice, or just `Test`), with the existing sandbox redirect to the maintainers' test address.

**Architecture:** A new `GET /email_editors` endpoint in [roreviewapi](../../../concepts/roreviewapi.md) reuses the existing Gmail sender and AirTable/GitHub editor fetch, but deliberately does **not** create a volunteer-search record (no click tokens, no EiC notification). [buffy](../../../concepts/buffy.md) needs only one config block: its existing `external_service` responder already supports a capture group in the command string and maps `match_data_1` into a query parameter, so no Ruby code changes are needed.

**Tech Stack:** R/plumber + gmailr + callr + testthat (roreviewapi); YAML config + RSpec (buffy). Two separate local branches/PRs because they are separate git repos; roreviewapi first, buffy second.

**Spec:** User request 2026-11-22 in this session: "send emails to all editors, e.g. to notify the system is on vacations", "actually sending an email", "from ropenscilabs/statistical-software-review ... sends an email to a different account owned by maintainers", "check and plan that for a local PR".

## Verified context (checked 2026-11-22, not assumptions)

- `ping editors` is wired in `ropensci-org/buffy/config/settings-production.yml:254-266` to `GET https://reviewbot.ropensci.org/send_search`; the endpoint is `ropensci-review-tools/roreviewapi/inst/plumber.R:258-295`.
- The email body is currently hard-coded: `gmail_send_batch()` at `roreviewapi/R/editor-search.R:358-386` builds the volunteer-invitation HTML; `gmail_send()` at line 228-238 sends it. There is no way to supply custom text today.
- Recipients come from `get_editor_emails()` (`R/editor-search.R:82-114`): it queries **one** GitHub team, `editors` or `stats-editors`, chosen by `stats_checker(repo, issue_id)`. "All editors" therefore needs both teams fetched and de-duplicated.
- Sandbox redirect is real and already tested: `R/editor-search.R:561-573` swaps recipients and the notify address to `reviewtools@ropensci.org` whenever the org part of `repo` is `ropenscilabs`; `tests/testthat/test-editor-search.R:136-165` pins it. The address is the rOpenSci **reviewtools Google Group** maintained by the tooling maintainers (`tools/aliases.zsh:12`, [personal-ops-tooling](../../../concepts/personal-ops-tooling.md)).
- buffy can pass arbitrary command text without code changes: `ExternalServiceResponder` interpolates `command` verbatim into `@event_regex` (`app/responders/external_service_responder.rb:11`); `Responder#locals` exposes captures as `match_data_1` (`app/lib/responder.rb:179-210`); `ExternalServiceWorker` maps them with `mapping: {message: match_data_1}` (`app/workers/external_service_worker.rb:23-25`). `spec/responders/external_service_responder_spec.rb:89-96` already proves a `(.*)` command plus `example_invocation` works.
- Ruby test environment: use the Docker Ruby 4.0.2 path from the [Buffy Development Environment plan](./2026-10-24-buffy-dev-environment.md); do not use system Ruby 2.6.10 and do not edit `Gemfile.lock`.

## Global Constraints

- Command syntax is exactly `@ropensci-review-bot email editors <message>`; the message is free text and is required. `Test` is a valid message and sends an email whose subject and body are `Test`.
- Recipients for a `ropensci/*` invocation are the union of GitHub teams `ropensci/editors` and `ropensci/stats-editors`, de-duplicated case-insensitively and filtered with the existing `is_valid_email()`.
- A `ropenscilabs/*` invocation sends **only** to `reviewtools@ropensci.org` — same rule, same address as `send_search()`. No other recipient override in v1.
- Subject = first line of the message truncated to 100 characters; body = the full message, HTML-escaped with newlines as `<br>`. Sent from `GMAIL_SENDER` via the existing `gmail_send()`, one call per recipient with a 0.1 s pause.
- No search record, recipient token, click link, or EiC notification is created. This is a plain announcement, not a volunteer search.
- Endpoint requires the shared `secret` token, exactly like `/send_search`; the command is additionally restricted to buffy's `editors` team via `only: editors`.
- No pushes: run `git checkout -b` / commit locally in each clone, and push only after explicit approval (repo `AGENTS.md`).
- Existing uncommitted work is not ours: `roreviewapi` has a modified `vignettes/admin-setup.Rmd`, `buffy` has a modified `Gemfile.lock` and untracked `setup.sh`, `buffy-wiki` has a modified `opencode.json`. Do not stage, edit, or revert those files.

## Review Focus

1. Empty / whitespace-only message → reject with a clear error, send nothing, post a failure comment. Test: Task 1, "rejects an empty message".
2. Editors in both teams, including one in both and one with an invalid address → de-duplicated, valid-only recipient list. Test: Task 1, "fetches both editor teams once each".
3. `ropenscilabs/statistical-software-review` invocation → exactly `reviewtools@ropensci.org`, never the team lists. Test: Task 1, "redirects sandbox repos to the test address".
4. Multiple recipients / Gmail failure → no SQLite rows left behind and a useful error comment on the issue. Test: Task 1 "sender failure is reported" + Task 2 "posts failure comment".
5. Message containing `&`, `<`, `>`, quotes, or newlines → escaped in the HTML body, subject still the first line. Test: Task 1, "escapes HTML and uses the first line as subject".

---

### Task 1: Core email function (roreviewapi)

**Files:**

- Modify: `ropensci-review-tools/roreviewapi/R/editor-search.R` (add four internal functions after `send_search_and_post()`, around line 715)
- Test: `ropensci-review-tools/roreviewapi/tests/testthat/test-editor-search.R` (append `test_that` blocks; reuse `local_notify_cache()`, `email_fetcher`, `gmail_send_mock` helpers at lines 1-34)

**Interfaces:**

- Consumes: `get_editor_emails(base, stats)` and `is_valid_email()` (internal, lines 82-119); `gmail_send(to, subject, html_body)` (internal, line 228).
- Produces: `email_editors(message, repo, fetcher = NULL, sender = NULL)` returning `list(sent = integer, recipients = character)`; internal `get_all_editor_emails()`, `gmail_send_custom_batch()`, `html_escape()`. Later tasks rely on `email_editors()` only.

- [ ] **Step 1: Write failing tests** in `tests/testthat/test-editor-search.R`:

```r
test_that ("email_editors rejects an empty message", {
    expect_error (email_editors ("  ", "ropensci/software-review"), "non-empty")
    expect_error (email_editors (NA_character_, "ropensci/software-review"), "non-empty")
})

test_that ("email_editors fetches both editor teams once each", {
    called <- list ()
    fetcher <- function (base_id, stats) {
        called[[length (called) + 1L]] <<- stats
        if (stats) c ("b@example.com", "A@example.com") else c ("a@example.com", "bad-address")
    }
    sent <- NULL
    sender <- function (emails, subject, html_body) {
        sent <<- list (emails = emails, subject = subject, html_body = html_body)
        lapply (emails, function (x) list (id = x))
    }
    result <- email_editors ("Notice & <update>\nsecond line",
        "ropensci/software-review", fetcher = fetcher, sender = sender)
    expect_equal (called, list (FALSE, TRUE))
    expect_equal (result$sent, 2L)
    expect_equal (sent$emails, c ("a@example.com", "b@example.com"))
    expect_equal (sent$subject, "Notice & <update>")
    expect_match (sent$html_body, "Notice &amp; &lt;update&gt;<br>second line")
})

test_that ("email_editors redirects sandbox repos to the test address", {
    called <- FALSE
    fetcher <- function (base_id, stats) { called <<- TRUE; c ("a@example.com") }
    sent_to <- NULL
    sender <- function (emails, subject, html_body) { sent_to <<- emails; list (list (id = "x")) }
    result <- email_editors ("Test", "ropenscilabs/statistical-software-review",
        fetcher = fetcher, sender = sender)
    expect_equal (sent_to, "reviewtools@ropensci.org")
    expect_equal (result$sent, 1L)
    expect_false (called, info = "team lists must not be fetched for sandbox repos")
})

test_that ("email_editors sender failure is reported", {
    fetcher <- function (base_id, stats) "a@example.com"
    expect_error (
        email_editors ("Test", "ropensci/software-review", fetcher = fetcher,
            sender = function (emails, subject, html_body) stop ("Gmail is down")),
        "Gmail is down"
    )
})
```

- [ ] **Step 2: Run the tests to confirm they fail**

Run: `cd ropensci-review-tools/roreviewapi && Rscript -e 'devtools::test(filter = "editor-search")'`
Expected: failures for `email_editors` not found.

- [ ] **Step 3: Implement the four internal functions** in `R/editor-search.R`

Signatures and behaviour (bodies are yours, constrained by the tests):

```r
html_escape <- function(x)                              # @noRd; & < > " '
get_all_editor_emails <- function(airtable_base_id, fetcher = NULL)  # @noRd; c(fetcher(base, FALSE), fetcher(base, TRUE)), trimws, drop NA/empty/invalid via is_valid_email(), unique on tolower()
gmail_send_custom_batch <- function(emails, subject, html_body, sender = NULL)  # @noRd; lapply(emails, sender(email, subject, html_body)); Sys.sleep(0.1) between sends; invisible(resps)
email_editors <- function(message, repo, fetcher = NULL, sender = NULL)         # @export; see below
```

`email_editors()` details: validate `message` is a single non-NA string with `nzchar(trimws())`; `subject <- substr(strsplit(message, "\\r?\\n")[[1]][[1]], 1L, 100L)`; `html_body <- paste0("<p>", gsub("\\r?\\n", "<br>", html_escape(message)), "</p>")`; set `is_test_repo <- dirname(repo) == "ropenscilabs"`; for a test repo use `"reviewtools@ropensci.org"`, otherwise `get_all_editor_emails(Sys.getenv("AIRTABLE_BASE_ID"), fetcher = fetcher)`; default `sender` to `gmail_send_custom_batch`, `fetcher` to the namespace `get_editor_emails`; error if no valid recipients; return `list(sent = length(emails), recipients = emails)`. Do not touch `send_search()` or its DB tables.

- [ ] **Step 4: Regenerate docs and exports**

Run: `cd ropensci-review-tools/roreviewapi && Rscript -e 'devtools::document()'`
Expected: `NAMESPACE` gains `export(email_editors)`, `man/email_editors.Rd` created.

- [ ] **Step 5: Run the tests to confirm they pass**

Run: `cd ropensci-review-tools/roreviewapi && Rscript -e 'devtools::test(filter = "editor-search")'`
Expected: all pass, including the five pre-existing `send_search` tests.

- [ ] **Step 6: Commit locally (no push)**

```bash
cd ropensci-review-tools/roreviewapi
git add R/editor-search.R NAMESPACE man/email_editors.Rd tests/testthat/test-editor-search.R
git commit -m "feat: add email_editors() to mail all editors"
```

Stage only those paths; `vignettes/admin-setup.Rmd` is not ours.

### Task 2: Endpoint and background wrapper (roreviewapi)

**Files:**

- Modify: `ropensci-review-tools/roreviewapi/R/editor-search.R` (add `email_editors_and_post()` after new Task 1 functions)
- Modify: `ropensci-review-tools/roreviewapi/inst/plumber.R` (add `/email_editors` after `/send_search`, around line 296)
- Modify: `ropensci-review-tools/roreviewapi/vignettes/editorsearch.Rmd` (add endpoint to "Editor search endpoints", around line 174)
- Test: `ropensci-review-tools/roreviewapi/tests/testthat/test-editor-search.R` (append two `test_that` blocks)

**Interfaces:**

- Consumes: `email_editors(message, repo, ...)` from Task 1; `post_to_issue(cmt, repo, issue_id)`; `stdout_stderr_cache(repourl)`; `is_user_authorized(secret)`.
- Produces: `email_editors_and_post(message, repo, issue_id, poster = roreviewapi::post_to_issue, ...)` returning the comment invisibly; `GET /email_editors` taking `message`, `repo`, `repourl`, `issue_id`, `secret`.

- [ ] **Step 1: Write failing tests** for the wrapper:

```r
test_that ("email_editors_and_post posts a success comment", {
    posted <- NULL
    poster <- function (cmt, repo, issue_id) posted <<- list (cmt, repo, issue_id)
    email_editors_and_post ("Test", "ropensci/software-review", 99L,
        poster = poster, fetcher = function (b, stats) "a@example.com",
        sender = function (emails, subject, html_body) lapply (emails, function (x) list (id = x)))
    expect_equal (posted[[2]], "ropensci/software-review")
    expect_equal (posted[[3]], 99L)
    expect_match (posted[[1]], "1 editor")
})

test_that ("email_editors_and_post posts failure comment", {
    posted <- NULL
    poster <- function (cmt, repo, issue_id) posted <<- cmt
    email_editors_and_post ("", "ropensci/software-review", 99L, poster = poster)
    expect_match (posted, ":x: Sending the editor email failed")
    expect_match (posted, "non-empty")
})
```

- [ ] **Step 2: Run the tests to confirm they fail**

Run: `cd ropensci-review-tools/roreviewapi && Rscript -e 'devtools::test(filter = "editor-search")'`
Expected: failures for `email_editors_and_post` not found.

- [ ] **Step 3: Implement `email_editors_and_post()`**

Copy the `tryCatch` + `poster(cmt, repo, issue_id)` + `invisible(cmt)` shape of `send_search_and_post()` (lines 679-715), with success copy `:rocket: Email sent to N editor(s).` and failure copy starting `:x: Sending the editor email failed:`. Add roxygen `@export`, `@family email`.

- [ ] **Step 4: Add the plumber endpoint**

Add a `#* @get /email_editors` handler beside `/send_search`, with `#* @param` lines for `message`, `repo`, `repourl`, `issue_id`, `secret` and `#* @serializer text`. Body: reject unauthorized callers with the same string as `/send_search`; reject blank `message` with `"Error: 'message' is required"`; derive logfiles via `stdout_stderr_cache(repourl)` with the `_email_editors_stdout` / `_email_editors_stderr` suffixes; launch `callr::r_bg(func = roreviewapi::email_editors_and_post, args = list(message = message, repo = repo, issue_id = issue_id), stdout = ..., stderr = ..., poll_connection = TRUE, supervise = TRUE)` into a new global `ps_email_editors <<-`; return `"Sending email to editors ..."`.

- [ ] **Step 5: Document the endpoint**

In `vignettes/editorsearch.Rmd`, add a `### GET /email_editors` subsection next to `### GET /send_search` describing the five parameters, the both-teams recipient rule, the sandbox redirect, and the issue comment. Add a line to the "Verify" section: invoke `@ropensci-review-bot email editors Test` in issue 36 and confirm delivery to `reviewtools@ropensci.org`.

- [ ] **Step 6: Regenerate docs, then run the full suite**

Run: `cd ropensci-review-tools/roreviewapi && Rscript -e 'devtools::document(); devtools::test()'`
Expected: green; `NAMESPACE` also has `export(email_editors_and_post)`.

- [ ] **Step 7: Commit locally (no push)**

```bash
cd ropensci-review-tools/roreviewapi
git add R/editor-search.R inst/plumber.R NAMESPACE man tests/testthat/test-editor-search.R vignettes/editorsearch.Rmd
git commit -m "feat: add /email_editors endpoint"
```

Add only the paths you changed; do not add `vignettes/admin-setup.Rmd`.

### Task 3: Bot command (buffy, config only)

**Files:**

- Modify: `ropensci-org/buffy/config/settings-production.yml` (insert after the `editorsearch` block, line 266)
- Test: `ropensci-org/buffy/spec/responders/external_service_responder_spec.rb` (add one `it` in `describe "listening"`)
- Test: `ropensci-org/buffy/spec/workers/external_service_worker_spec.rb` (add one `it` in `describe "service request"`)

**Interfaces:**

- Consumes: `GET /email_editors?message=...&repo=...&repourl=...&issue_id=...&secret=...` from Task 2.
- Produces: the command `email editors <message>`, visible in `help` via the config `description` / `example_invocation`.

- [ ] **Step 1: Write the failing responder spec** in `spec/responders/external_service_responder_spec.rb`:

```ruby
it "should capture free-text message from the command" do
  responder = subject.new({ env: { bot_github_user: "botsci" } },
                          { name: "email-editors", command: "email editors (.*)", url: "URL" })
  expect(responder.event_regex).to match("@botsci email editors Test")
  responder.responds_to?("@botsci email editors Test")
  expect(responder.locals["match_data_1"]).to eq("Test")
end
```

- [ ] **Step 2: Write the failing worker spec** in `spec/workers/external_service_worker_spec.rb`, inside `describe "service request"` (reuses `@service`, `@locals`, `@null_response`):

```ruby
it "maps match_data_1 to the message query param" do
  service = @service.merge('data_from_issue' => ['repo'], 'mapping' => { 'message' => 'match_data_1' })
  locals = @locals.merge('match_data_1' => 'Test')
  expected_params = { 'repo' => 'openjournals/tests', 'message' => 'Test' }.to_json
  expect(Faraday).to receive(:post).with(@service['url'], expected_params,
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }).and_return(@null_response)
  @worker.perform(service, locals)
end
```

- [ ] **Step 3: Run the specs to confirm they pass already**

Run (Docker Ruby 4.0.2 per the dev-environment plan): `cd ropensci-org/buffy && bundle exec rspec spec/responders/external_service_responder_spec.rb spec/workers/external_service_worker_spec.rb`
Expected: PASS. These are characterisation tests — the generic responder already supports the behaviour; they pin it before config is added. If either fails, stop and reconcile with Task Interfaces before continuing.

- [ ] **Step 4: Add the config block** to `config/settings-production.yml` after the `editorsearch` entry:

```yaml
      - email_editors:
          only:
            - editors
          command: email editors (.*)
          description: Send an arbitrary email to all editors
          example_invocation: "@ropensci-review-bot email editors Test"
          url: https://reviewbot.ropensci.org/email_editors
          method: get
          query_params:
            secret: <%= ENV['PKGCHECK_TOKEN'] %>
          data_from_issue:
            - repo
            - repourl
            - issue_id
          mapping:
            message: match_data_1
```

Do not set `silent: true` — the endpoint's background job posts the outcome comment itself; leaving the responder non-silent keeps the immediate acknowledgement.

- [ ] **Step 5: Verify config parses and re-run the full suite**

Run: `cd ropensci-org/buffy && bundle exec ruby -e 'require "yaml"; YAML.safe_load(File.read("config/settings-production.yml"), aliases: true); puts "YAML OK"' && bundle exec rspec spec`
Expected: `YAML OK` and a green suite.

- [ ] **Step 6: Commit locally (no push)**

```bash
cd ropensci-org/buffy
git add config/settings-production.yml spec/responders/external_service_responder_spec.rb spec/workers/external_service_worker_spec.rb
git commit -m "feat: add email editors command"
```

Do not add the modified `Gemfile.lock` or untracked `setup.sh`.

### Task 4: KB docs reconciliation

**Files:**

- Modify KB: `concepts/roreviewapi.md` (endpoint table + editor-email section)
- Modify KB: `concepts/buffy.md` (command -> endpoint list, line 64)
- These are the [roreviewapi](../../../concepts/roreviewapi.md) and [buffy](../../../concepts/buffy.md) "current" docs; the end-of-task rule in the root `AGENTS.md` requires updating them in the same task.

- [ ] **Step 1: Update `concepts/roreviewapi.md`** through OpenKnowledge MCP (`edit`, never native file tools): add a table row for `/email_editors` (bot command `email editors MESSAGE`, where MESSAGE is free text): emails all editors from both teams, honours the sandbox redirect, and creates no search record — place it after the `/send_search` row; add one bullet in "Editor-search email system" noting the new announcement path also honours the `ropenscilabs` redirect. Keep `sources` unchanged — both facts are grounded in the same `plumber` and `editor-search-r` sources already listed.

- [ ] **Step 2: Update `concepts/buffy.md`** through OpenKnowledge MCP: extend the command list on line 64 with `email editors` -> `/email_editors`. Add a footnote source only if the line's existing `[^config]` source does not cover the new config entry.

- [ ] **Step 3: Lint and commit the KB**

Run OpenKnowledge `audit` on `concepts` and fix any reported findings, then:

```bash
cd /Users/maurolepore/git/ropensci-system
git add concepts/roreviewapi.md concepts/buffy.md plans/ropensci-org/buffy/2026-11-22-email-editors-command.md
git commit -m "docs: plan and document email editors command" -m "Co-Authored-By: Hy4 flash Free (OpenCode) <noreply@opencode.ai>"
```

Do not add the unrelated `tools/md/.checklist-rotate-gh-pat-in-server.md.swp` untracked file.

## Execution handoff

Recommend **subagent-driven**: Task 1's function signatures are consumed by Task 2, and a bad recipient-selection mistake sends real email, so a fresh reviewer per task is worth the cost. No push until you approve the local branches.
