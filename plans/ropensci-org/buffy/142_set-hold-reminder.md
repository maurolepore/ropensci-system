---
type: Plan
status: draft
---

# Set Hold Reminders Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a chat-ops command `@ropensci-review-bot set hold reminders to @user` that overrides who the on-hold reminder pings (workflow 3 from ropensci-org/buffy#142).

**Architecture:** The new responder stores the target username as a value in the issue body (`<!--hold-reminders-->@user<!--end-hold-reminders-->`), using buffy's established body-marks pattern (`update_or_add_value`, same as `set_due_date`). The existing `OnHoldReminderWorker` reads that value **at fire time** and pings it instead of the command invoker — so overrides apply even to reminders scheduled before the command ran, with no Sidekiq surgery.

**Tech Stack:** Ruby, Sidekiq, RSpec. No new dependencies.

**Prerequisites:** `Gemfile.lock` pins Ruby 4.0.2 / bundler 4.0.6, but this machine's system Ruby is 2.6.10 with no version manager (rbenv/rvm/asdf/mise all absent as of 2026-10-24). Every `bundle exec rspec` step below requires the project Ruby available first — sort this out (or agree on an alternate way to run the suite) before starting Task 1.

**Spec:** [issuecomment-6383702611](https://github.com/ropensci-org/buffy/issues/142#issuecomment-6383702611), workflow 3:

> - I invoke `put on hold`
> - I see the bot's reply: "... Reminders will ping `@maurolepore`" because Assignee is empty
> - I invoke `set hold reminders to @adamhsparks`
> - I see the bot's reply: "Reminders will ping `@adamhsparks`"
> - Later, when `@adamhsparks` gets the reminder, he invokes `set hold reminder to @maelle`
> - He sees the bot's reply: "Reminders will ping `@maelle`"

Scope: workflow 3 **only**. The fallback when no override is set stays the current behavior (ping the invoker); workflows 1 (default to assignee) and 2 (announce target in the `put on hold` reply) from the same comment are explicitly out of scope.

## Global Constraints

- Success reply copy, verbatim from spec: ``Reminders will ping `@username` `` (username includes the `@`).
- Command syntax must accept both `set hold reminders to @user` and singular `set hold reminder to @user` (spec uses both).
- Follow the existing rOpenSci responder pattern: `keyname`, `define_listening` (`@event_action` + `@event_regex`), `process_message`, `default_description`, `default_example_invocation` (see `app/responders/ropensci/on_hold_responder.rb`, `set_due_date_responder.rb`).
- Body value name is exactly `hold-reminders`; stored content is the username **with** `@` (e.g. `@maelle`).
- `on_hold_label` coupling: production configures the label (if at all) under `ropensci_on_hold`, but the new responder reads its **own** `on_hold_label` param (default `"holding"`). Today nothing customizes it so both are `"holding"`. If ops ever sets a custom label, it must be set under **both** keynames or the new command will wrongly reply "This submission is not on hold" — the docs page (Task 1, Step 6) must say this.
- The worker must keep its existing guards and message shape: `"<target>: Please review the holding status"`.
- No git mutations (commits, branches, push) without explicit user approval — repo `AGENTS.md`. Commit steps below run only after the user confirms.
- Local branch is `ropensci` (production config lives here); all edits happen on this branch's working tree.

## Review Focus

1. Command invoked on an issue **not** on hold → reply a clear error, store nothing (Task 1, spec case "not on hold").
2. Target without `@` (e.g. `set hold reminders to maelle`) → reply a format error, store nothing (Task 1, spec case "bad username").
3. Repeated invocations → last command wins; `update_or_add_value` overwrites the existing marks in place (Task 1, happy-path expectation pins the call; `update_or_add_value` itself is covered by `spec/actions_spec.rb`).
4. Reminder fires with override present → pings the override, not the invoker (Task 2, new spec).
5. Reminder fires without override — or with an **empty** override (manually emptied body marks) → byte-identical current behavior, `@#{context.sender}` (Task 2, updated existing spec + empty-value example).

---

### Task 1: `SetHoldRemindersResponder`

**Files:**
- Create: `app/responders/ropensci/set_hold_reminders_responder.rb`
- Test: `spec/responders/ropensci/set_hold_reminders_responder_spec.rb`
- Modify: `config/settings-production.yml` (insert after the `ropensci_on_hold:` block, currently lines 183-185)
- Modify: `config/settings-development.yml` (insert after the `ropensci_on_hold:` block, currently lines 35-37)
- Create: `docs/responders/ropensci/set_hold_reminders.md`
- Modify: `docs/available_responders.md` (toctree, next to `responders/ropensci/on_hold`, line 58)

**Interfaces:**
- Consumes: `Actions#update_or_add_value(value_name, text)`, `Actions#issue_body_has?`, `GitHub#issue_labels`, `GitHub#username?` (all already mixed into `Responder`).
- Produces:
  - Command regex `/\A@#{bot_name} set hold reminders? to:? (\S+)\s*\z/i` — capture group 1 is the raw target string.
  - Issue-body value `hold-reminders` containing `@username` — Task 2 reads exactly this.
  - Settings keyname `ropensci_set_hold_reminders` with optional param `on_hold_label` (default `"holding"`).

- [ ] **Step 1: Write the failing spec**

Create `spec/responders/ropensci/set_hold_reminders_responder_spec.rb` modeled on `spec/responders/ropensci/on_hold_responder_spec.rb` (same `before` block: `settings = { env: {bot_github_user: "ropensci-review-bot"} }`, `described_class.new(settings, {})`; in `#process_message` use `disable_github_calls_for(@responder)` and an `OpenStruct` context like the model spec).

Cases:

```ruby
describe "listening" do
  it "should listen to new comments" do
    expect(@responder.event_action).to eq("issue_comment.created")
  end

  it "should define regex" do
    expect(@responder.event_regex).to match("@ropensci-review-bot set hold reminders to @adamhsparks")
    expect(@responder.event_regex).to match("@ropensci-review-bot set hold reminder to @maelle")
    expect(@responder.event_regex).to match("@ropensci-review-bot set hold reminders to: @maelle  \r\n")
    expect(@responder.event_regex).to_not match("@ropensci-review-bot set hold reminders to @maelle. More text")
    expect(@responder.event_regex).to_not match("@ropensci-review-bot set hold reminders")
  end
end
```

```ruby
describe "#process_message" do
  # before: disable_github_calls_for(@responder); context OpenStruct(issue_id: 32, repo: "openjournals/testing", sender: "the-editor", ...)
  # @msg = "@ropensci-review-bot set hold reminders to @adamhsparks"
  # CRITICAL: `@match_data` is only set by the dispatch path (`Responder#responds_to?`), never by calling
  # `process_message` directly — so the before block MUST set it (pattern: set_due_date_responder_spec.rb:43):
  #   @responder.match_data = @responder.event_regex.match(@msg)

  it "should store the target in the issue body and confirm" do
    expect(@responder).to receive(:issue_labels).and_return(["holding"])
    expect(@responder).to receive(:update_or_add_value).with("hold-reminders", "@adamhsparks")
    expect(@responder).to receive(:respond).with("Reminders will ping `@adamhsparks`")
    @responder.process_message(@msg)
  end

  it "should respect a custom on_hold_label param" do
    @responder.params[:on_hold_label] = "submission-paused"
    expect(@responder).to receive(:issue_labels).and_return(["submission-paused"])
    expect(@responder).to receive(:update_or_add_value).with("hold-reminders", "@adamhsparks")
    expect(@responder).to receive(:respond).with("Reminders will ping `@adamhsparks`")
    @responder.process_message(@msg)
  end

  it "should refuse when the issue is not on hold" do
    expect(@responder).to receive(:issue_labels).and_return(["approved"])
    expect(@responder).to_not receive(:update_or_add_value)
    expect(@responder).to receive(:respond).with("This submission is not on hold")
    @responder.process_message(@msg)
  end

  it "should refuse a target without @" do
    msg = "@ropensci-review-bot set hold reminders to adamhsparks"
    @responder.match_data = @responder.event_regex.match(msg)
    expect(@responder).to receive(:issue_labels).and_return(["holding"])
    expect(@responder).to_not receive(:update_or_add_value)
    expect(@responder).to receive(:respond).with("Can't set hold reminders: please use the `@username` form, e.g. `@ropensci-review-bot set hold reminders to @maelle`")
    @responder.process_message(msg)
  end
end
```

- [ ] **Step 2: Run spec to verify it fails**

Run: `bundle exec rspec spec/responders/ropensci/set_hold_reminders_responder_spec.rb`
Expected: FAIL — `uninitialized constant Ropensci::SetHoldRemindersResponder`

- [ ] **Step 3: Implement `app/responders/ropensci/set_hold_reminders_responder.rb`**

Mirror `set_due_date_responder.rb` structure. Decisions already made (implementer writes the bodies):

- `keyname :ropensci_set_hold_reminders`
- `define_listening`: `@event_action = "issue_comment.created"`, `@event_regex = /\A@#{bot_name} set hold reminders? to:? (\S+)\s*\z/i`
- `process_message(message)`: `target = @match_data[1]`, then guards **in this order**:
  1. `issue_labels.include?(on_hold_label)` else `respond("This submission is not on hold")` + return
  2. `username?(target)` else `respond("Can't set hold reminders: please use the \`@username\` form, e.g. \`@#{bot_name} set hold reminders to @maelle\`")` + return
  3. `update_or_add_value("hold-reminders", target)` then `respond("Reminders will ping \`#{target}\`")`
- `on_hold_label`: `params[:on_hold_label] || "holding"`
- `default_description`: `"Set who is pinged by on-hold reminders"`
- `default_example_invocation`: `"@#{@bot_name} set hold reminders to @username"`

- [ ] **Step 4: Run spec to verify it passes**

Run: `bundle exec rspec spec/responders/ropensci/set_hold_reminders_responder_spec.rb`
Expected: PASS (all examples)

- [ ] **Step 5: Register the responder in both settings files**

In `config/settings-production.yml` and `config/settings-development.yml`, add directly below the `ropensci_on_hold` block, matching its indentation:

```yaml
    ropensci_set_hold_reminders:
      only: editors
```

Verify by parsing both edited files the same way Sinatra's `config_file` does (the RSpec suite only ever loads `settings-test.yml` — `spec_helper.rb:8` pins `RACK_ENV=test` — so the suite will NOT catch a broken production/development YAML):

Run: `ruby -rerb -ryaml -e 'ARGV.each { |f| YAML.load(ERB.new(File.read(f)).result) }' config/settings-production.yml config/settings-development.yml && echo PARSE-OK`
Expected: `PARSE-OK` (no exception). Then `bundle exec rspec` for the full suite as usual.

- [ ] **Step 6: Add docs page and toctree entry**

Create `docs/responders/ropensci/set_hold_reminders.md` following `docs/responders/ropensci/on_hold.md` structure: title `ROpenSci :: Set hold reminders`, one-paragraph purpose ("lets an editor choose who the on-hold reminder pings, overriding the default of pinging whoever invoked `put on hold`"), `## Listens to` with `@botname set hold reminders to @username`, `## Settings key` `ropensci_set_hold_reminders`, `## Params` documenting optional `:on_hold_label:` (default **holding**) **with an explicit note that if set it must match the `on_hold_label` configured for `ropensci_on_hold`** (see Global Constraints), plus a one-line known limitation that the target is only checked for the `@username` form, not validated against GitHub (`username?` at `app/lib/github.rb:265` only checks the leading `@`). `## Example` yaml with `only: editors`. Skip the `## In action` screenshot (none exists yet). Add `responders/ropensci/set_hold_reminders` to the toctree in `docs/available_responders.md` next to the `on_hold` entry.

Verify: `grep -n "set_hold_reminders" docs/available_responders.md` returns the entry.

- [ ] **Step 7: Commit (only after user approves the git mutation)**

```bash
git add app/responders/ropensci/set_hold_reminders_responder.rb \
        spec/responders/ropensci/set_hold_reminders_responder_spec.rb \
        config/settings-production.yml config/settings-development.yml \
        docs/responders/ropensci/set_hold_reminders.md docs/available_responders.md
git commit -m "add set hold reminders responder (workflow 3 of #142)"
```

---

### Task 2: `OnHoldReminderWorker` honors the override

**Files:**
- Modify: `app/workers/ropensci/on_hold_reminder_worker.rb` (lines 11)
- Test: `spec/workers/ropensci/on_hold_reminder_worker_spec.rb`

**Interfaces:**
- Consumes: issue-body value `hold-reminders` produced by Task 1, via `Actions#issue_body_has?("hold-reminders")` and `Actions#read_value_from_body("hold-reminders")` (mixed into `BuffyWorker` via `Actions`). Value includes the `@`.
- Produces: reminder comment `"<target>: Please review the holding status"` where `<target>` is the body value when present, else `"@#{context.sender}"` (unchanged fallback).

- [ ] **Step 1: Update existing spec for the new internal call, then add the failing override spec**

In `spec/workers/ropensci/on_hold_reminder_worker_spec.rb`: the worker will now call `issue_body_has?`, which hits `issue_body` and would blow up on the existing doubles. In the top-level `before` block add:

```ruby
allow(@worker).to receive(:issue_body_has?).with("hold-reminders").and_return(false)
```

This keeps all three existing examples exercising the **fallback** path unchanged. Then add the new example inside `describe "perform"`:

```ruby
it "should ping the user set via the hold-reminders body value" do
  expect(@worker).to receive(:issue).and_return(double(state: "open"))
  expect(@worker).to receive(:issue_labels).and_return(["holding"])
  allow(@worker).to receive(:issue_body_has?).with("hold-reminders").and_return(true)
  expect(@worker).to receive(:read_value_from_body).with("hold-reminders").and_return("@maelle")

  expect(@worker).to receive(:respond).with("@maelle: Please review the holding status")

  @worker.perform(@locals, @params)
end

it "should fall back to the invoker when the hold-reminders value is empty" do
  expect(@worker).to receive(:issue).and_return(double(state: "open"))
  expect(@worker).to receive(:issue_labels).and_return(["holding"])
  allow(@worker).to receive(:issue_body_has?).with("hold-reminders").and_return(true)
  expect(@worker).to receive(:read_value_from_body).with("hold-reminders").and_return("")

  expect(@worker).to receive(:respond).with("@editor: Please review the holding status")

  @worker.perform(@locals, @params)
end
```

- [ ] **Step 2: Run spec to verify the new example fails**

Run: `bundle exec rspec spec/workers/ropensci/on_hold_reminder_worker_spec.rb`
Expected: the override example FAILS with `expected: ("@maelle: Please review the holding status"), got: ("@editor: Please review the holding status")`; the three existing examples PASS. The empty-value example PASSES immediately (it characterizes the fallback, which equals current behavior) — it must still pass after Step 3.

- [ ] **Step 3: Implement the override in `app/workers/ropensci/on_hold_reminder_worker.rb`**

Replace line 11 (`respond("@#{context.sender}: Please review the holding status")`) with a target computed after the two existing guards, falling back when the stored value is empty (e.g. someone manually emptied the marks):

```ruby
override = issue_body_has?("hold-reminders") ? read_value_from_body("hold-reminders") : ""
target = override.empty? ? "@#{context.sender}" : override
respond("#{target}: Please review the holding status")
```

- [ ] **Step 4: Run specs to verify everything passes**

Run: `bundle exec rspec spec/workers/ropensci/on_hold_reminder_worker_spec.rb` then `bundle exec rspec`
Expected: PASS (all examples, full suite green)

- [ ] **Step 5: Commit (only after user approves the git mutation)**

```bash
git add app/workers/ropensci/on_hold_reminder_worker.rb spec/workers/ropensci/on_hold_reminder_worker_spec.rb
git commit -m "on-hold reminder pings user set via 'set hold reminders' (close workflow 3 of #142)"
```
