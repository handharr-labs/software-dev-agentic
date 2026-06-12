---
name: auditor-arch-check
description: Audit a feature's code against the platform's layer dependency rules and invariants.
user-invocable: false
allowed-tools: Read, Glob, Grep, mcp__cp8__kms_list, mcp__cp8__kms_fetch
knowledge_scope: engineering
---

Audit the specified feature against the {platform} standard architecture, loaded from the KMS.

## Steps

1. **Load rules** (fetch-by-topic — see `kms-conventions.md §Retrieval Protocol`):
   - `kms_list(discipline="engineering", artifact="standard-architecture", platform={platform})` — scan the TOC for `dependency_rule` and `layer_invariants` patterns across the domain, data, presentation, and error_handling topics.
   - `kms_fetch(discipline="engineering", artifact="standard-architecture", topic="<layer topic>", pattern="<dependency_rule | layer_invariants slug>", platform={platform})` — fetch each rule node found. Full rule text per layer.
   - If the TOC has no dependency_rule/layer_invariants patterns, STOP and report a KMS seed gap for `{platform}/engineering/standard-architecture` — do not guess.
2. **Grep** the feature's files for forbidden imports per each layer's dependency rule
3. **Check** each layer's invariants against the actual code
4. Report violations grouped by layer and file

## Checks

| Layer | Forbidden in that layer |
|---|---|
| Domain | Any `RepositoryImpl`, `DataSource`, `DTO`, HTTP client, DB type |
| Data | Any Presentation type, direct domain entity mutation |
| Presentation | Any `RepositoryImpl`, `DataSource`, `DTO`, mapper, HTTP client |

## Output

Report: `PASS` if no violations, or list each violation as `[Layer] file:line — rule broken`.
