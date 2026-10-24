---
type: Guide
title: Getting started
description: Purpose and organization of this knowledge base.
status: stable
---

# Getting started

Use this knowledge base for durable concepts that people and agents can link, exchange, and reuse.

Work in progress lives as implementation plans in `plans/<owner>/<repo>/` - one plan per unit of work, typically one GitHub issue or PR. The path mirrors the GitHub repo where the work happens, so `plans/maurolepore/ropensci-system/` holds plans for this knowledge base itself. Plans are working documents: committed to git and in OK scope, but not curated concepts - no `sources` provenance is required.

Each concept needs parseable YAML frontmatter with a non-empty `type`. Use standard Markdown links so relationships remain portable to other OKF tools.

The OpenKnowledge OKF plugin warns when content may not survive a handoff to another OKF consumer. Its companion skill provides the complete authoring guidance.
