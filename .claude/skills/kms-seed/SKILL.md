---
name: kms-seed
description: Seed the KMS ChromaDB from one or more knowledge sources. Supports seeding all available sources, a single source, a type filter, or adding and registering a new source in one step.
user-invocable: true
allowed-tools: Agent
---

## Arguments

`$ARGUMENTS` — optional flags:
- _(none)_ — seed all available sources in `kms/sources.yaml`
- `--source <name>` — seed one registered source by name
- `--type <type>` — seed all sources of a type (`markdown` | `codebase` | `confluence`)
- `--add <path|url>` — detect, register, and seed a new source in one step

## Steps

### 1 — Parse arguments

Extract flags from `$ARGUMENTS`. Pass to `kms-seed-orchestrator`.

### 2 — Spawn orchestrator

Spawn `kms-seed-orchestrator` with:

```
source_filter: <name or null>
type_filter:   <type or null>
add_target:    <path/url or null>
```

### 3 — Report

Surface the orchestrator's summary to the user.
