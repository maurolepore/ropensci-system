---
name: Offboarding checklist for an editor
about: Offboarding checklist for [name]
type: Skill
---

<!-- For discoverability please use the title: "Offboarding checklist for [name]" -->

Details of the departing editor

- GitHub handle:
- Author page: https://ropensci.org/author/<name-lastname>/

Useful links

- [Offboarding an editor](https://devguide.ropensci.org/softwarereview_editor_management.html#offboarding-an-editor)

----

- [ ] Thank them for their work!

- [ ] Meet or chat with at least one [staff member of the software peer-review project](https://ropensci.org/software-review/) for a retrospective:
  - What went well?
  - What didn't go so well?
  - How can we improve?

- [ ] Inform rOpenSci community manager or other staff members, to ensure our newsletter will announce their departure, and thank them.

- [ ] Remove them from the "editors-only" channel.

- [ ] Remove them from https://github.com/orgs/ropensci/teams/editors/members and sub-team.

- [ ] Update "team.json" on website by replacing "roles" with "past_roles", and adding new field, `alumnus: "true"`.

- [ ] Remove their access to the Airtable workspace.
  - [ ] From the "interface" view, pull down main menu at top-left and enter "View Data".
  - [ ] Click "Share" button on top right, and then "People with access".
  - [ ] Click checkbox on left on editor to be removed, and "Remove 1 collaborator".

- [ ] Change their "editor" label in the Airtable "reviewers-prod" data to "Emeritus".

- [ ] The (past-)editors lists in both the dev_guide chapter introducing software review and the software-review README are automatically populated from the AirTable data. Updates are run daily, so check a day after AirTable updates to ensure both have been updated.
