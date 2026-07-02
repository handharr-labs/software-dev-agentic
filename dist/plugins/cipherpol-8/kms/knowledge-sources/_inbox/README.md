# `_inbox/` — the low-friction contribution on-ramp

Drop a **loose markdown file here** to contribute knowledge without learning the canonical directory tree or facet vocabulary.

## How to contribute

1. Write a markdown file with `##` sections (one concept per `##`). A title and a sentence of context help.
2. Optionally add a hint in frontmatter — anything you know:
   ```yaml
   ---
   platform: flutter
   discipline: engineering
   layer: data
   ---
   ## Repository error mapping
   ...
   ```
   You don't have to get any of this right — leave it out and the classifier infers it.
3. Save it anywhere under `_inbox/`.
4. Run `/kms-contribute` (optionally `/kms-contribute <file>` or with a free-text hint).

## What happens next

`kms-classify-worker` reads your draft, infers the full canonical facets
(`platform`, `project`, `discipline`, `layer`, `owner`, `area`, `artifact`),
and writes a **normalized file at its canonical path** with proper frontmatter —
you review that as a normal git diff / PR, then run `/kms-seed` to index it.

## Why this exists

`_inbox/` is **never seeded directly** — the seeder only traverses
`universal/`, `platform/`, and `projects/`. Drafts here are staging only; they
become knowledge nodes once classified and moved to a canonical path. This keeps
the strict, retrieval-friendly structure without making a contributor produce it
by hand. See the [redesign initiative](../../../docs/initiatives/2026-07-03-kms-knowledge-management-redesign.md).
