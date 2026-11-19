---
name: Offboarding checklist for an editor
about: Offboarding checklist for [name]
type: Skill
---

<!-- For discoverability please use the title: "Offboarding checklist for [name]" -->

Details of the departing editor

- Details that bring you here:
- GitHub handle:
- Slack handle:
- Record on Airtable:
- Last day:
- Full or guest editor:
- Other roles they hold: staff / EiC rotation / stats editor

Useful links

- [Offboarding an editor](https://devguide.ropensci.org/softwarereview_editor_management.html#offboarding-an-editor)
- [Pausing an editor](https://devguide.ropensci.org/softwarereview_editor_management.html#pause-editor) - for a break, not a departure. It is reversible and touches neither `team.json` nor `alumnus`.

<!-- start of hidden block

WARNING: This section is hidden but public. Do not write sensitive information.

Where this checklist lives

- `ropensci/software-review-meta` is public, and the issue title names the person and the departure. Create the issue only once the departure is public, typically with the newsletter. Until then keep the checklist locally or in a private channel.

What this checklist leaves out

- Reassigning their open submissions, revoking credentials, mailing lists, calendars, and bot configuration. None are offboarding steps; a submission that needs a new editor is ordinary editing work, handled on its issue.
- Removing their organization membership, their community Slack account, or their reviewer record.

Where the steps come from

- The dev guide's offboarding section. The deployed page can lag the source: `softwarereview_editor_management.Rmd` carries the Airtable `Emeritus` step, which the live page may not show yet.
- The lists' behaviour comes from `scripts/airtable-get-data.R`, duplicated in `ropensci/dev_guide` and `ropensci/software-review`: the past-editors list is the subset of editor-labelled reviewers whose label matches `Emeritus`.

end of hidden block -->

----

- [ ] Thank them for their work.
  - [ ] Send it where they announced the departure, or by email if they told you privately.

- [ ] Inform the rOpenSci community manager or another staff member, so the newsletter announces the departure and thanks them.

- [ ] Slack: remove them from the private `editors-only` channel, and from the editors Slack team.
  - [ ] Post a friendly explanation in `editors-only` when removing them.
  - [ ] Confirm they are gone from the channel member list.

- [ ] GitHub: remove them from the [`editors` team](https://github.com/orgs/ropensci/teams/editors/members), and from the sub-team they belong to.
  - [ ] [`stats-editors`](https://github.com/orgs/ropensci/teams/stats-editors/members) for stats editors.
  - [ ] Leave their organization membership alone. The dev guide removes the team only; alumni often keep reviewing and commenting.

- [ ] Update ["team.json" on the website](https://github.com/ropensci/roweb3/blob/main/data/team/team.json).
  - [ ] Rename `roles` to `past_roles`, and move only `"editor"` into it. Roles they still hold (`"staff"`, `"co-founder"`, ...) stay in a `roles` array alongside it.
  - [ ] Add `"alumnus": true` right after `past_roles`. The dev guide writes `alumnus: "true"`, but every alumnus entry in the file uses the JSON boolean; follow the file.
  - [ ] Edit the entry in place. Past offboarding PRs flip these two fields and leave the array order alone.
  - [ ] Open a PR titled like the past ones, e.g. `move @<handle> from editors to alumnus; thank you so very much!`
  - [ ] Check the [rOpenSci software-review page](https://ropensci.org/software-review/) after the merge; this file drives it.

- [ ] Remove their access to the Airtable workspace.
  - [ ] From the "interface" view, pull down the main menu at top-left and enter "View Data".
  - [ ] Click the "Share" button at top right, then "People with access".
  - [ ] Tick the checkbox on the left of the editor, then "Remove 1 collaborator".
  - [ ] Confirm they no longer appear under "People with access".

- [ ] Change their "editor" label in the Airtable ["reviewers-prod" table](https://airtable.com/app8dssb6a7PG6Vwj/tblIBMYXKsF4DwhEW) to `Emeritus`.
  - This is the step that moves them from the current editors list to the past-editors list. Clearing the field instead drops them from both.
  - Guest editors have a record here too, labelled `Guest editor`; the same change applies.
  - Do it early: both lists rebuild once a day.

- [ ] The next day, confirm both generated lists changed.
  - [ ] [Dev guide, "Software Peer Review" chapter](https://devguide.ropensci.org/softwarereview_intro.html) - source `softwarereview_intro.Rmd`.
  - [ ] [software-review README](https://github.com/ropensci/software-review/blob/main/README.md) - source `README.Rmd`.
  - [ ] Both are rebuilt from the Airtable data daily, so a same-day check proves nothing.
