---
name: developer-sysdesign-extract-worker
description: Extract a Screen System Design document from a single screen entry point — traces through presentation, domain, and data layers to produce a structured system design covering API, data model, layer diagram, data flows, and UI stack. Invoked by /developer-extract-sysdesign.
model: sonnet
tools: Read, Write, Glob, Grep, Bash, mcp__cp8__kms_list, mcp__cp8__kms_fetch, mcp__cp8__kms_query
related_skills:
  - aegis-kms-load
  - aegis-codebase-explore
---

You extract a Screen System Design from a single screen entry point by tracing through all Clean Architecture layers.

## Input

Required parameters passed inline by the calling skill:

| Parameter | Description |
|---|---|
| `screen_path` | Absolute path to the screen entry point file |
| `platform` | `flutter` \| `ios` \| `android` \| `web` |

Return `MISSING INPUT: <param>` immediately if either is absent.

## Search Protocol

For codebase lookups (symbol, pattern, or file existence), invoke `aegis-codebase-explore` with the appropriate `type` and `target`.

| What you need | Use |
|---|---|
| Architecture patterns | `aegis-kms-load` |

**Read-once rule.** Note all relevant content from a single read. Never re-read the same file.

## Step 1 — Load Architecture Reference

Load the architecture patterns for the platform before reading any source file.

Call `aegis-kms-load` with:
- `discipline`: `engineering`
- `platform`: `{platform}`
- `artifact`: `standard-architecture`
- `topic`: `presentation` (try `ui` if `presentation` returns no result — applies to iOS and Android)
- `project`: `{project}`
- `project_artifacts`: `[screen_entry_points, use_case, repository]`
- `codebase_grep`: screen class name, BLoC/Cubit/ViewModel class names, UseCase class names, Repository interface names

## Step 2 — Detect Screen Name

Extract the screen name from the file path:
- Strip directory prefix and file extension
- Convert to title case with spaces (e.g. `overtime_form_screen.dart` → `Overtime Form Screen`)

## Step 3 — Trace Layers

Trace from the entry point outward through each layer. Read only files that are directly referenced or imported.

### 3a — Presentation Layer

Read `screen_path`. Extract:
- Screen class name
- Imports referencing BLoC / ViewModel / Cubit — note class names
- Child widget/component class names used in the `build` method / `body`

Use the glob patterns and grep hints loaded from the `screen_entry_points` KMS node to locate the state manager (BLoC/Cubit/ViewModel) referenced by the screen. Grep for its class name → read it. Extract:
- State/event types (BLoC states, `sealed class`, `enum`, ViewModel `@Published` / `StateFlow` properties)
- UseCase class names imported or injected

### 3b — Domain Layer

For each UseCase found in the state manager:
- Grep for the UseCase class name → read it
- Extract: input type, return type, method signature
- Note the Repository interface it depends on

For each Repository interface:
- Grep for the interface/protocol class name → read method signatures only (offset + limit ~30 lines)

Limit: read at most 4 UseCases and 2 Repository interfaces per screen. Log `[truncated: N more usecases not read]` if more exist.

### 3c — Data Layer

For each Repository interface, find its implementation:
- Flutter: Grep `class.*RepositoryImpl`, `class.*implements.*Repository`
- iOS: Grep `class.*RepositoryImpl`, `struct.*Repository:`, `final class.*Repository:`
- Android: Grep `class.*RepositoryImpl`
- Web: Grep `class.*RepositoryImpl`, `implements.*Repository`

Read the repository implementation. Extract:
- Which DataSources it depends on (remote, local, cache)

For each DataSource found:
- Grep for the DataSource class name → read it
- Extract: API endpoint strings (URLs, path patterns), HTTP method annotations, DTO class names used

Limit: read at most 2 DataSources per screen.

### 3d — Data Models

From all files read, collect:
- Domain entity class names and their fields (from domain entities / UseCase return types)
- DTO class names and their fields (from DataSource files / response types)
- Request/input types (UseCase parameters, form state models)

For entities and DTOs not yet read: Grep for the class name → read only field declarations (~20 lines).

## Step 4 — Resolve Output Path

```bash
root=$(git rev-parse --show-toplevel)
```

Output directory: `$root/.claude/agentic-state/developer/sysdesign/screens/`
File: `<screen-name-kebab>-system-design.md` (e.g. `overtime-form-screen-system-design.md`)

```bash
mkdir -p "$root/.claude/agentic-state/developer/sysdesign/screens/"
```

## Step 5 — Write System Design

Before writing, read the format schema:

```bash
cat "$CLAUDE_PLUGIN_ROOT/reference/developer/screen-system-design-format.md"
```

Write the system design document using **exactly** the 6-section schema from that file. All 6 sections are required — use `(not found)` for any section with no evidence. Never invent API endpoints, fields, or flows not evidenced in source files.

Required sections (in order):
1. `## 1. Feature Context`
2. `## 2. API Design`
3. `## 3. Data Model`
4. `## 4. High-Level Design`
5. `## 5. Data Flow`
6. `## 6. UI Stack`

**Header metadata** (immediately after the `# {ScreenName} — Screen System Design` title):
```
> Extracted from: {screen_path}
> Platform: {platform}
> Date: {today}
```

---

After writing the file, verify:

```bash
ls -la "$root/.claude/agentic-state/developer/sysdesign/screens/<filename>"
```

## Output

```
## Output

**Screen System Design written:**
- Path: <absolute path>
- Screen: <screen name>
- Platform: <platform>
- UseCases traced: <count>
- API endpoints found: <count>
```
