# Screen System Design Document Format

> Author: Puras Handharmahua · 2026-06-13
> Related: developer-sysdesign-extract-worker.md (writer), developer-sysdesign-consolidate-worker.md (reader)

Single source of truth for the "Screen System Design" document — written by `developer-sysdesign-extract-worker` (Step 5), parsed by `developer-sysdesign-consolidate-worker` (Step 1) to produce a Flow System Design.

---

## Schema

```markdown
# {ScreenName} — Screen System Design

> Extracted from: {screen_path}  
> Platform: {platform}  
> Date: {today}

---

## 1. Feature Context

*{1–3 sentences describing what this screen does, inferred from UseCase names and class purpose.}*

**UseCases in scope:**
- `{UseCaseName}` — {one-line purpose inferred from method name and types}
- ...

---

## 2. API Design

### HTTP Endpoints

| Method | Endpoint | Request Body | Response |
|---|---|---|---|
| {method} | `{path}` | `{RequestDto or —}` | `{ResponseDto or —}` |

*(Add rows for each endpoint found in DataSource files. Mark as `(stub)` if the implementation is mocked.)*

### Real-time / WebSocket

{Describe WebSocket channels, event types, and payload structure if found. Write `None found.` if absent.}

---

## 3. Data Model

### Domain Entities

```
{ClassName}
  - {field}: {type}
  - {field}: {type}
```

*(One block per domain entity. Omit persistence annotations.)*

### DTOs

```
{DtoName}
  - {field}: {type}    // "{json_key}" if different
```

*(One block per DTO. Note JSON key name if it differs from field name.)*

### Request / Input Types

```
{InputClassName}
  - {field}: {type}
```

*(UseCase inputs, form state, request params.)*

---

## 4. High-Level Design

```
┌─────────────────────────────────────────────────┐
│  Presentation ({platform})                      │
│  {ScreenClass}                                  │
│  {BlocClass / ViewModelClass}                   │
│    states: {State1}, {State2}                   │
│    events: {Event1}, {Event2}                   │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Domain                                         │
│  {UseCase1} → {RepositoryInterface}             │
│  {UseCase2} → {RepositoryInterface}             │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Data                                           │
│  {RepositoryImpl}                               │
│    → {RemoteDataSource}    [{API client}]       │
│    → {LocalDataSource}     [{local store}]      │
│  Mappers: {Mapper1}, {Mapper2}                  │
└─────────────────────────────────────────────────┘
```

---

## 5. Data Flow

*(One subsection per named flow. Name flows after the user action or trigger.)*

### {Flow name — e.g. "Load {ScreenName}", "Submit {FormName}", "Observe {ResourceName}"}

```
{UserAction or Trigger}
  → {ScreenClass}.{method}()
      → {BlocClass / VM}.{event or method}
          → {UseCaseName}.execute({input})
              → {RepositoryInterface}.{method}()
                  → {DataSource}.{method}()
                      → {HTTP method} {endpoint}
                  ← {ResponseDto}
              ← {DomainEntity}
          ← {StateClass.loaded(data)}
      ← UI renders {description}
```

*(If a flow is entirely local — no API call — end the trace at the local data source.)*

---

## 6. UI Stack

### State Model

| State / Property | Type | Meaning |
|---|---|---|
| `{StateName}` | `{type}` | {what it represents} |

### Component Hierarchy

```
{ScreenClass}
  ├── {ChildWidget1}  ← {state condition that shows it}
  ├── {ChildWidget2}
  └── {ChildWidget3}
```

*(Flutter: `build()` structure. iOS: ViewController hierarchy. Android: Fragment/layout hierarchy. Web: JSX tree.)*

### User Interactions

| Interaction | Triggers | Effect |
|---|---|---|
| {e.g. "Tap submit button"} | `{EventName}` | {visible result} |
```

---

## Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| Title + header metadata (screen name, entry point, platform) | always | extract-worker | consolidate-worker (Step 1) | Source for the Flow doc's "Screens in This Flow" table and Screen Index |
| `## 1. Feature Context` | always | extract-worker | consolidate-worker | One-line summary per screen, used in Flow "Screens in This Flow" |
| `## 2. API Design` | always | extract-worker | consolidate-worker | Endpoint inventory — merged/deduped into Flow `## 2. API Design (Unified)`, shared endpoints marked |
| `## 3. Data Model` | always | extract-worker | consolidate-worker | Entity/DTO/request types — split into Shared vs Screen-Specific in Flow `## 3. Data Model (Unified)` |
| `## 4. High-Level Design` | always | extract-worker | consolidate-worker | Per-screen layer diagram — combined into Flow `## 4. High-Level Design (Combined)` |
| `## 5. Data Flow` | always | extract-worker | consolidate-worker | Named flows — used to identify cross-screen transitions for Flow `## 5. Cross-Screen Data Flow` |
| `## 6. UI Stack` | always | extract-worker | consolidate-worker | Read for context; not directly re-emitted in the Flow design |
