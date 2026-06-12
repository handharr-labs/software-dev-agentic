> Author: Puras Handharmahua · 2026-06-12
> Related: [kms-glossary.md](kms-glossary.md) · [kms-design-principles.md](kms-design-principles.md) · [kms-conventions.md](kms-conventions.md)

Seeding strategy — how knowledge gets into the KMS. Covers source registration, change detection, failure behavior, and the agentic seeding workflow.

---

## Core Principles

### Incremental seeding via content hash

Change detection uses a SHA hash of the full document body stored as `content_hash` in metadata. Uniform across all source types — no dependency on filesystem timestamps or git. Only changed nodes are re-upserted.

### Skip-on-unavailable — never destructive

If a source path or URL is inaccessible at seed time, that source is skipped with a warning. Existing nodes from that source are never removed or overwritten. The DB is always left in a valid state.

### Source registration in `kms/sources.yaml`

All knowledge sources are registered here. The seed runner reads this manifest — it never hardcodes sources. The primary entry covers all of `kms/knowledge-sources/` in one registration:

```yaml
sources:
  - name: knowledge-sources
    type: directory
    path: kms/knowledge-sources
    owns: [theory, definition, code_pattern, rationale]
    last_seeded: 2026-06-04
```

Additional sources (codebase scans, Confluence) are registered as separate entries with their own `owns` declarations.

### `--add` auto-registers new sources

`seed_kms.py --add <path|url>` detects source type from the input, derives a name, presents the full proposed entry (name, type, owns) to the user for one confirmation, then seeds and appends to `sources.yaml`. One step, no manual yaml editing.

**Type detection rules:**

| Signal | Detected type |
|---|---|
| Local directory (no codebase markers) | `directory` |
| Local path + `pubspec.yaml` | `codebase` (flutter) |
| Local path + `package.json` | `codebase` (web) |
| Local path + `*.xcodeproj` | `codebase` (ios) |
| URL matching `confluence.` | `confluence` |
| GitHub URL | `codebase` (remote) |

---

## Seeding Architecture

```
KnowledgeSource (abstract interface)
  ├─ DirectorySource   ← primary: kms/knowledge-sources/ (path-based metadata, no frontmatter)
  ├─ CodebaseSource    ← stub: scan agent writes via kms_upsert directly
  ├─ ConfluenceSource  ← stub: pending auth + parser
  └─ MarkdownSource    ← legacy: structured files with frontmatter (kept for compatibility)
       ↓
  Unified seed runner (reads sources.yaml)
       ↓
  UpsertKnowledge use case (enforces owns, merges sections)
       ↓
  ChromaKnowledgeRepository
```

---

## Agentic Seeding Workflow

| Component | Type | Responsibility |
|---|---|---|
| `/kms-seed` | skill | User-invocable entry point |
| `kms-seed-orchestrator` | orchestrator | Reads `sources.yaml`, filters by flags, spawns workers, reports summary |
| `kms-source-detect-worker` | worker | `--add` flow — detects type, derives name, confirms entry with user |
| `kms-seed-worker` | worker | One source — accessibility check, seed, update `last_seeded` |

---

## Changelog

See git history for this file.
