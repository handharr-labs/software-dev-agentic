---
name: auditor-arch-check
description: Audit a feature's code against the platform's layer dependency rules and invariants.
user-invocable: false
allowed-tools: Read, Glob, Grep
knowledge_scope: engineering
---

Audit the specified feature against `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` knowledge docs.

## Steps

1. **List patterns** — `kms_query(text="architecture naming conventions dependency rules layer invariants", platform={platform}, discipline="engineering", n_results=5)` to get architecture patterns and rules. **Fallback** if no results: Read `kms/knowledge-sources/engineering/{platform}-standard-architecture.md` and collect `## Dependency Rule` and `### Layer Invariants` (or `## Layer Invariants`) sections for each layer
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
