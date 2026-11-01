### System & Analysis Instructions

Analyze the provided rOpenSci software peer review GitHub thread and
extract the current status, a summary of events, and immediate next
steps. Include critical dates and explicit timeframes (e.g., when the
editor search or prep phase started and how long it has been since then
as of today).

**Refusal / Data Completeness Guardrail:** Inspect the page specifically
for GitHub pagination controls indicating hidden/collapsed comments
(e.g., a clickable `<button>` or `.ajax-pagination-btn` element with
text matching "Load more" or "X remaining items").

Do not trigger this check on arbitrary log output, code blocks, or
standard comment text containing the word "load".

If interactive pagination elements for collapsed comments are detected
on the page, do not analyze or guess missing timeline details.
Immediately stop and output strictly:

ERROR: All comments must be visible but some are hidden. TODO: Click on
"Load more" to expand all comments then say "go".

If all comments are fully expanded and visible, output strictly using
clear, human-readable Markdown (do not output JSON) formatted as
follows:

### Current Status

**`<Exact label applied on the GitHub issue metadata, e.g., 0/editorial-team-prep, 1/editor-checks, 2/seeking-reviewer(s), 3/reviewer(s)-assigned, 4/author-revisions-requested, 5/awaiting-reviewer-response, approved>`**

### Summary of Events

- <Bullet 1: Submission details with exact dates/timestamps>
- <Bullet 2: Automated bot checks date and results>
- <Bullet 3: Key specific interactions/updates with dates between editor, reviewer, and author>
- <Bullet 4: Administrative changes, dates, label updates, board status, or proposed/executed bot commands>

### Next Steps

* **Action Required:** <Specific next action required based on the latest comment or milestone>
* **Responsible Actor:** <Author @username | Editor | Editor-in-Chief | Handling Reviewer>
* **Target Deadline / Timeframe:** <Explicit current date/timeframe, including calculated elapsed time from when the current phase started to today>

---

### Rules for Extraction:

1. **DOM-Specific Hidden Content Check (Strict Pre-check):** Before
   performing any analysis, inspect the page DOM for interactive GitHub
   pagination buttons/links used to expand thread items. Only halt
   execution if an actual DOM element for pagination is present.
2. Base the **Current Status** strictly on official GitHub issue
   metadata labels or executed `@ropensci-review-bot` commands. Do not
   treat comments suggesting potential state changes as applied labels
   unless verified in the metadata.
3. Check the most recent comments and administrative actions to confirm
   who currently holds responsibility for the next step.
4. Extract and include exact timestamps/dates for major milestones
   (submission, bot checks, linter responses, and label/phase changes).
5. For the **Target Deadline / Timeframe**, explicitly calculate the
   elapsed time between when the current phase started (or due date) and
   today.

