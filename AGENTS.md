---
type: AgentGuide
title: AGENTS.md - rOpenSci knowledge base
description: Orientation and working rules for agents in this OKF knowledge base.
---

# AGENTS.md - rOpenSci knowledge base

This directory is a **knowledge base for all things rOpenSci**, particularly the [software peer-review program](https://ropensci.org/software-review/). It is an [OpenKnowledge](https://openknowledge.ai) project in **Open Knowledge Format (OKF) v0.2**.

## Layout

- `index.md` - bundle root (declares `okf_version`), the entry point.
- `concepts/` - curated knowledge, one concept per file. Start at [software-peer-review-architecture](concepts/software-peer-review-architecture.md).
- `docs/superpowers/plans/` - implementation plans for KB work.
- `<org>/<repo>/` - cloned GitHub repositories (`ropensci/`, `ropensci-org/`, `ropensci-review-tools/`). These are **reference material**, excluded from the knowledge graph via `.okignore`. Read them with native tools (`read`/`grep`); never edit them except to add an `AGENTS.md`.

## Git model

- The KB repo tracks **only curated content** (`index.md`, `concepts/`, `docs/`, `AGENTS.md`, `.gitignore`, `.okignore`, `scripts/`). The `<org>/` clone dirs are **gitignored** - clones are independent repos and never enter KB history.
- Re-materialize clones on a fresh checkout with `scripts/clone-repos.sh`.
- Working from inside a clone: every clone carries its own `AGENTS.md` bridge pointing back here (KB root = two levels up) with a summary of how that repo fits the big picture, and the cross-repo working rules.

## Working in this repo (tool rules)

- **Markdown in `index.md`, `concepts/`, `docs/` is in OK scope**: read/write it ONLY via the OpenKnowledge MCP tools (`exec`, `write`, `edit`, `search`, `lint`, `audit`). The project-local `open-knowledge` skill is the authoritative contract - load it before touching markdown. Never use native file tools on in-scope `.md`.
- **Markdown inside `<org>/<repo>/` clones is out of scope** (`.okignore`) - native tools are fine there.
- **OKF rules**: every concept doc needs frontmatter with a non-empty `type` (use `type: Concept`); record provenance in `sources` (with `id`s + `[^id]` footnotes in the body); timestamps are ISO 8601 with explicit UTC offset; standard Markdown links, no wiki-links.
- **Grounding**: every factual claim cites a source in frontmatter `sources` - prefer paths into the local clones plus the canonical URL. Do not fabricate; mark gaps as `(TODO: needs source)`.
- **Secrets**: never record secret values (tokens, keys). Config-var NAMES only, values redacted.

## Boundaries

- **External resources are read-only**: web fetch, `gh api` GETs, `heroku apps:info|config:json|logs` are fine; never mutate remote state.
- **No git mutations** (`commit`, `push`, branch changes in clones) unless the user explicitly asks.
- New orgs/repos may be cloned into their `<org>/` directory when relevant (`gh repo clone <org>/<repo> <org>/<repo>`).

## Useful commands

- `ok lint` / `ok audit` - validate markdown + links after edits.
- `ok seed --list-packs` / `ok start` - OK tooling.
- `heroku apps:info radiant-garden-91913` - live buffy deployment (read-only).

## Status

First content pass (2026-10-22): software peer-review infrastructure architecture (see `concepts/`). See the bootstrap plan at `docs/superpowers/plans/2026-10-22-ropensci-kb-bootstrap.md`.
