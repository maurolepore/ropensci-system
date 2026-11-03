---
type: Skill
---

# Mauro's EiC rotation-start summary: how to write the comment

Turn the output of the thread analysis (the `### Current Status` /
`### Summary of Events` / `### Next Steps` format produced by the
`summarize-thread` skill) into a comment written in Mauro Lepore's
(GitHub: `@maurolepore`) voice, ready to paste on the rOpenSci
`ropensci/software-review` GitHub issue. Do not post it: the human
reviews and pastes.

**Evidence.** Counts below derive from 40 real summary comments in his EiC
archive: 28 rotation-start comments, 12 rotation-end/handover comments,
across the 2023-02, 2025-02–05 and 2026-05–08 rotations. Length: 21–188
words, median 54, mean 79 (no fixed length; content drives it). Where a
count is over all 40 comments it is marked "/40"; rotation-start-only
counts are "/28" (the form this guide writes). Claims with thin support
are flagged low-confidence. A further ~300 EiC comments across 83 issues
were skimmed for what he writes in other comment types, which the
summary must *not* imitate.

## What he decides to write

1. **Open by dating his rotation and, usually, the sweep.** Every
   rotation-start comment states the rotation is starting (28/28). Most
   name the sweep of open issues as the reason he is here:
   "I'm reviewing all open issues and noting what I see" (9/28), or a
   variant "record what I see / leaving a short note to myself of what
   I see" (11/28 including "noting" variants). Exact openers:
   - "this is to mark the start of my EiC rotation" (18/28, sometimes
     "my **new** EiC rotation" or "just to mark the start", and in 2026
     he switches to "Hi @…, this is to mark the start of my new EiC rotation."
   - "Today starts my rotation as EiC" (5/28)
   - "I just started my EiC rotation" (4/28), "I'm starting my EiC
     rotation" (1/28)
   Agree with these formulas and their wording; don't paraphrase them.

2. **State the snapshot in "I see" sentences — one per fact, one actor
   per sentence.** "I see" appears 41 times in 27/40 comments. Each
   observation names the actor with their exact `@handle` and carries at
   most one fact:

   > * @bbolker was the original editor but @noamross took over.
   > (489-2)

   > - You addressed both reviews in December.
   > - @dill approved on 2026-02-17.
   > - @nicholasjclark hasn't responded yet.
   > (615-2)

3. **Ask exactly one operational question, addressed by name.** 14/40
   comments contain a question; it is always directed at a specific
   person (the author, reviewer, or editor who currently holds the ball)
   and asks for intent or readiness — never rhetorical, never a survey
   of options:

   > @helske, could you confirm once more whether you'd like us to keep
   > moving? (489-4)

   > I just started my EiC rotation and I see your review was due on
   > 23-November-2024. Are you still able to review? (615-1)

   He never asks two people different questions in one sentence; when
   several people must act, he steps through them one bullet each
   (632-1, 4 checked-box bullets, one per reviewer).

4. **State his own next actions with "I'll …".** 17/40 use an "I'll"
   commitment — reset the clock, ping on Slack, email, share with the
   editorial board, step back:

   > I'll ping you on Slack and email and look forward to hearing from
   > you within a month. (637-3)

5. **Quote policy verbatim when the next action follows from the
   policy.** 9/40 comments include a devguide URL and verbatim
   blockquote (11 quoted policy lines). He introduces it neutrally —
   "our policy (pasted below) states …", "For context, our policy
   says:" — separates it with a `---` line (5/40), and adds the source
   URL after the quote (sometimes talked-through inline, e.g.
   `> — https://devguide…`). Never paraphrase the policy.

6. **Link the load-bearing comment, mark the rest prose.** 8/40 contain
   a same-issue permalink; the anchor word is `[here]`, `[this
   response]`, or a date `[on Nov 10, 2024]`, and the URL is the full
   `…#issuecomment-<id>`. He does not number-references or footnote;
   one fact, one link, only where the reader would otherwise have to
   scroll.

7. **Say when there is nothing to do — and mean it.** When all is on
   track he writes the snapshot plus a one-line signal and stands down:
   "I'll step back." (7/28), "I'll step back and let things flow.
   Thanks!" (596-1, 676-1). No invented drama, no list of "potential
   risks".

8. **Absorb the cost of delays that are rOpenSci's.** When the wait was
   the regulatory side's fault he says so plainly and apologizes
   ("Sorry to jump in", "sorry" 4/40; "Apologies for the delay" in the
   2026 batch):

   > @helske I conclude the delays re not on your part. I'm sorry.
   > (489-2)

9. **Acknowledge stated intent, then name the tension factually.** When
   both "the author wants to continue" and "time has passed" are true,
   he names the conflict without blame:

   > The intent on both sides points to removing the `holding` label.
   > But the responsiveness on both sides suggests keeping it. That's
   > the tension I'd like to resolve. (489-4)

10. **Softland any closure with an empathy line.** Where staying or
    resuming is fully acceptable he says so explicitly: "I totally
    understand things can change …" (5/40, e.g. 615-1, 656-1, 637-1).

11. **Close with warmth, briefly.** Some thanks appears in 23/40
    comments; the exact greeting he repeats is "Thanks for sharing your
    work with the rOpenSci community." (9/20 rotation-start comments in
    the wider 2026 archive, e.g. 704, 713, 714) or "Thanks for your
    patience." (4/40). Rotation-end comments (out of scope here) also
    close "I look forward to working with you again whenever it's a
    good time" (5/40, all end-form).

## What he omits (and the analysis must too)

- **No thread retrospective.** 0/28 rotation-start comments retell the
  history. Only 2–3 dated facts that justify the next step survive
  (e.g. "You confirmed in February 2025 that you intend to continue",
  489-4). Older summaries are linked, not re-summarized ("I summarized
  the situation 3 months ago here", 556-3).
- **No bot / pkgcheck detail.** 0/40 comments report bot-check,
  linter, or R CMD check output. The bot is mentioned once (615-3), and
  only to state the closing command. Check detail belongs to a comment
  of a different type; the summary never re-grades the package.
- **No scaffolding labels.** He never writes "Action Required:",
  "Responsible Actor:", "Target Deadline:" or prints the label string
  `` "0/editorial-team-prep" ``; 0/40 headings, 0/40 bold text
  (`**`), 0 numbered lists, 0 tables. Deadlines surface only as policy
  time ("within a month", "we're approaching the 1-year mark", 713) or
  as his own offer ("Would you be available to respond … between May
  12-23?", 681-2). Translating the analysis's "Responsible Actor" means
  @mentioning that person in a normal sentence.
- **No background education.** He explains the process only when the
  specific next step depends on it (the two things a reviewer may do,
  489-1; "using this template", 632). He does not re-teach the pipeline,
  restate what rOpenSci is, or affirm the package's merit beyond a
  short nod ("Thanks a lot for your efforts in meeting our standards.",
  546-1).
- **No doubt-words.** Uncertainty is stated as an observation, not a
  hedge: "it's a bit unclear who's acting as the handling editor"
  (489-3), "the formal review seems pending" (556-2). Not "might
  possibly be", "it is advisable to consider".
- **No meta-commentary**: no references to "this summary is based on",
  no closing signature, no issue number/package name (they are the
  issue).

## How he phrases and formats

- **Person and tense.** First-person singular for what he does and
  sees; "we/our" only for rOpenSci-wide policy and house rules (19/40
  contain "we/our"). Present tense for the snapshot, past tense only for
  dated facts, polite modals ("could", "would", "let's") for the ask.
- **Greeting.** opens with "Dear @<author-handle>[ and @<other-handle>],"
  (25/40; sometimes the author gets a full "Dear" and later @mentions in
  body follow bare `[email protected]`). The 2026 batch alternates
  `Hi @<handle>,` and once `Hola @Rodotasso,`. When the group is the
  audience he greets "Dear all," (671-2, 660-2) or skips the greeting
  entirely (615-3, 769-1). Typo variants in the archive ("Deal all",
  671-2) are accidental — never imitate them, but don't over-polish the
  casual cadence either.
- **Paragraph skeleton.** greeting (optional) → 1 line announcing the
  rotation/sweep → snapshot in prose or bullets → the single question
  and/or my "I'll" commitments → optional policy quote block → one
  warm closing line. Typically 2–5 short paragraphs; bullets appear in
  only about half the comments (44 bullet lines over the corpus) — if
  facts can be one short paragraph, don't bullet them.
- **Links and mentions.** exact GitHub handles with `@`, people named
  once each, handles inside parentheticals for roles:
  "Reviewer 1 (@kingaa) shared informal feedback long ago" (489-4).
  Link text is plain words, never a bare URL in mid-sentence
  unless it *is* the object (the policy URL and the two-summary 489-3
  bullet list).
- **Signature phrases (evidence counts).** "this is to mark the start
  of my EiC rotation" 18/28 · "I'm reviewing all open issues and noting
  what I see" family 11/28 · "I'll step back" 7/28 · "could you please
  let us know…" 5/40 · "Thanks for sharing your work with the rOpenSci
  community." 9/20 (2026 batch) · "I totally understand things can
  change …" 5/40 · "Thanks for your patience." 4/40 · "no pressure"
  plus "let us know so we decide how to move forward" (615-1) · "I look
  forward to working with you again whenever it's a good time"
  (5/40, end-form only). Emoji is rare (2/40; 🤞 💯) — at most one.
- **Informality.** lowercase after an em-dash, "lil", contracted
  negative verbs are fine; a typo never is. (low-confidence: these
  cadence details come from the wider EiC archive, not the 40-summary
  corpus.)

## Transformation instructions (from the analysis to the comment)

1. **Read off, then throw away the template.** Use the analysis only as
   a fact source. Do not reproduce its headings (`Current Status`,
   `Summary of Events`, `Next Steps`), bold labels, label string, or
   the three-part bullet trio.
2. **Pin down the ball.** From "Current Status" + the latest activity,
   decide who holds the ball now and the single next action. This
   determines the one question and the one-to-three "I'll" commitments.
   If nobody waits — the action is Mauro's own — write the snapshot and
   step back instead of manufacturing a question.
3. **Compute time only to trigger policy.** Convert elapsed-time facts
   into their policy consequence: holding close to 1 year → warn, not
   blame; no-response past the window → quote policy and state the
   action. Drop all other timestamps. Dated facts survive only as
   "You confirmed in <Month Year> that you …" or "… was due on
   <date>".
4. **Write the opener.** "Dear @<author>, this is to mark the start of
   my EiC rotation." + (if relevant) "I'm reviewing all open issues and
   noting what I see:" Use one of the four formulas from What-he-writes
   #1 — not a paraphrase.
5. **Compress the events into at most 3–5 "I see" bullets** (or 1–2
   sentences if fewer). One actor per bullet; keep @handles exact; add
   a permalink only for the observed prior action that motivates the
   ask (author response, prior summary, contact intent) — formatted
   `[here](full URL)` or `[on <date>](full URL)`. Drop everything else:
   bot check detail, label housekeeping (unless the whole point, i.e.
   "the labels suggest … but they are both done", 632-1), and color
   commentary.
6. **Convert "Next Steps" into people, not fields.** Replace
   "Responsible Actor" with a direct @mention; replace "Action
   Required" with a question ("Are you still able to review?", "could
   you please let us know if you intend to resume or stay on hold?");
   keep at most one ask per person. Replace "Target Deadline" with
   either a policy statement or a signed offer from Mauro himself.
7. **Add the policy block if the action is policy-driven.** `---` line
   → URL line → indented verbatim quote. If it is not policy-driven,
   omit entirely — do not cite policy "for completeness".
8. **Close in one warm line** that names the person's contribution:
   "Thanks for sharing your work with the rOpenSci community." /
   "Thanks for your patience." / "Thanks!" — plus "I'll step back"
   if he is stepping back. At most one emoji, usually none.
9. **Quota check before output.** Total ≤ ~190 words, typically ~50–80;
   no heading, no bold, no table, no numbered list, no signature; every
   fact conveyed is in the analysis (never invent); every question is
   answerable by one @mentioned person.

**Negative list (AI-speak he never uses):** "I hope this message finds
you well" · "I would like to inform you/advise" · "Please do not
hesitate to reach out" (his phrasing is "please do touch base" only
when closure looms) · "Rest assured" · "as per our policy" · "I want
to ensure transparency" · "delve/leverage/robust" · "As an AI" ·
apologizing structurally ("I apologize for any inconvenience caused")
— he apologizes for a named fault with "Sorry/I apologize for the
delay" in the same plain register · "TL;DR" · "Here's the breakdown" ·
"Key takeaways" · starting bullets with bolded labels.

## Worked example

**Before** (condensed thread analysis, summarize-thread format):

````
### Current Status

**`3/reviewer(s)-assigned`**

### Summary of Events

- Submitted 2025-11-19; bot checks passed 2025-11-19.
- Two reviewers (@dill, @nicholasjclark) submitted reviews in
  November 2025 (logged with the bot, times 12h and 18h).
- Author addressed both reviews in December 2025.
- @dill approved on 2026-02-17 using the template.
- @nicholasjclark has not responded to the author's response for
  ~10 weeks.
- @noamross contacted @nicholasjclark by email last week.

### Next Steps

* **Action Required:** @nicholasjclark to approve or request further
  changes.
* **Responsible Actor:** Reviewer @nicholasjclark.
* **Target Deadline / Timeframe:** ~10 weeks since the author's
  response; no formal deadline applies because an active reviewer is
  providing substantial feedback (policy permits proceeding).
````

**After** (the actual comment he posted, verbatim — issue 615, 2026-05-03):

````
Dear @osorensen, this is to mark the start of my new EiC rotation.
Thank you for the thorough revisions back in December, and thanks @dill
for the approval.

A brief summary of what I see:
- You addressed both reviews in December.
- @dill approved on 2026-02-17.
- @nicholasjclark hasn't responded yet.

I know @noamross has been trying to reach out via email recently, so the
submission is in good hands and moving forwards as indicated in our dev
guide:

> If the reviewer has already submitted their primary review, and
> another reviewer is active and providing substantial feedback, the
> editor can proceed with the review process, and should take the role
> of the absent reviewer in determining if the authors' changes are
> sufficient.
> — https://devguide.ropensci.org/editorguide#during-review

Thanks!
````

What changed: headings and label scaffolding are gone; the bot-check
line is dropped; the two reviewer roles collapse into @handles; the
"Action Required" field becomes a dangling fact plus the reassurance
that an editor already holds it; "Target Deadline" becomes a policy
quote; the tone stays first person, present tense, with the closing
"Thanks!" — all in ~110 words of bullet-per-fact, plain sentences.
