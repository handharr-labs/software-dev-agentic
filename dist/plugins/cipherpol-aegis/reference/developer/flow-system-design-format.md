# Flow System Design Document Format

> Author: Puras Handharmahua · 2026-06-13
> Related: developer-sysdesign-consolidate-worker.md (writer)

Single source of truth for the "Flow System Design" document — written by `developer-sysdesign-consolidate-worker` (Step 4), consolidating multiple Screen System Design documents (see `screen-system-design-format.md`) into one. Currently terminal output surfaced to the user.

---

## Schema

```markdown
# {FlowName} — Flow System Design

> Screens: {comma-separated screen names}  
> Platform: {platform}  
> Date: {today}

---

## 1. Flow Overview

### Screens in This Flow

| Screen | Entry Point | Summary |
|---|---|---|
| {ScreenName} | `{entry_file}` | {one-line purpose from Feature Context} |

### User Journey

*{2–4 sentences describing how a user navigates through these screens and what they accomplish.}*

---

## 2. API Design (Unified)

### HTTP Endpoints

| Screen(s) | Method | Endpoint | Request | Response |
|---|---|---|---|---|
| {screen or "Shared"} | {method} | `{path}` | `{RequestDto or —}` | `{ResponseDto or —}` |

*(Mark endpoints used by more than one screen as "Shared".)*

### Real-time / WebSocket

{Combined WebSocket channels and event types across all screens. Write `None found.` if absent.}

---

## 3. Data Model (Unified)

### Shared Domain Entities

*(Entities referenced by more than one screen)*

```
{ClassName}
  - {field}: {type}
```

### Screen-Specific Entities

*(Entities unique to one screen)*

**{ScreenName}:**
```
{ClassName}
  - {field}: {type}
```

### Shared DTOs

```
{DtoName}
  - {field}: {type}
```

### Request / Input Types

*(All request/input types across screens)*

```
{InputClassName}  [{ScreenName}]
  - {field}: {type}
```

---

## 4. High-Level Design (Combined)

```
{ScreenName1}                      {ScreenName2}
┌──────────────────────┐           ┌──────────────────────┐
│ Presentation         │           │ Presentation         │
│ {ScreenClass1}       │           │ {ScreenClass2}       │
│ {BlocClass1}         │           │ {BlocClass2}         │
└──────────┬───────────┘           └──────────┬───────────┘
           │                                  │
           └────────────┬─────────────────────┘
                        │
        ┌───────────────▼──────────────────────┐
        │ Domain                               │
        │ {UseCase1}   {UseCase2}   {UseCase3} │
        │    └── {SharedRepositoryInterface}   │
        └───────────────┬──────────────────────┘
                        │
        ┌───────────────▼──────────────────────┐
        │ Data                                 │
        │ {SharedRepositoryImpl}               │
        │   → {RemoteDataSource}               │
        │   → {LocalDataSource}                │
        └──────────────────────────────────────┘
```

*(Adapt diagram to the actual number of screens and shared/separate components found.)*

---

## 5. Cross-Screen Data Flow

*(One subsection per transition. Skip if screens are independent with no shared state.)*

### {ScreenName1} → {ScreenName2}

```
{TriggerAction in Screen1}
  → navigate to {ScreenName2} with {PassedData}
      → {ScreenName2} initializes {UseCase} with {PassedData}
```

*{Describe what data or context is passed between screens and how it is used.}*

---

## 6. Screen Index

| Screen | System Design File | Entry Point |
|---|---|---|
| {ScreenName} | [{filename}]({relative path}) | `{entry_file}` |
```

---

## Section Contracts

| Section | Required | Written by | Read by | Purpose |
|---|---|---|---|---|
| Header metadata (`> Screens:`, `> Platform:`, `> Date:`) | always | consolidate-worker | user | Identifies which screens and platform the flow covers, and when it was generated |
| `## 1. Flow Overview` | always | consolidate-worker | user | Summarizes the screens involved and the end-to-end user journey through the flow |
| `## 2. API Design (Unified)` | always | consolidate-worker | user | Deduplicated endpoint inventory across the flow, with shared endpoints flagged |
| `## 3. Data Model (Unified)` | always | consolidate-worker | user | Shows which entities/DTOs are shared vs screen-specific, clarifying coupling |
| `## 4. High-Level Design (Combined)` | always | consolidate-worker | user | Single layer diagram showing how screens connect through shared domain/data components |
| `## 5. Cross-Screen Data Flow` | always | consolidate-worker | user | Documents navigation transitions and data passed between screens |
| `## 6. Screen Index` | always | consolidate-worker | user | Quick links from the flow doc back to each screen's individual system design |
