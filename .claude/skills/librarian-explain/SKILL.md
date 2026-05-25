---
name: librarian-explain
description: Explain a feature from its Feature Doc — read-only, no file written. Supports --aspect and --for flags.
user-invocable: true
allowed-tools: Read, Glob, AskUserQuestion
---

## Arguments

`$ARGUMENTS` — feature name or Feature Doc path. Optional flags:
- `--aspect=data-flow | hld | artifacts | api | gotchas` (default: full summary)
- `--for=engineer | non-engineer` (default: engineer)

## Steps

### 1 — Resolve Feature Doc path

If `$ARGUMENTS` contains a `.md` file path → use it directly.

Otherwise, glob for the feature by name:

```
.claude/reference/feature-docs/<name>.md
.claude/reference/feature-docs/**/<name>.md
```

If not found, glob for all available docs and show the list:

```
.claude/reference/feature-docs/**/*.md
```

Ask the user which feature they meant via `AskUserQuestion`.

### 2 — Read Feature Doc

Read the resolved path in full.

### 3 — Parse flags

Extract `--aspect` and `--for` values from `$ARGUMENTS`. Defaults: full summary, engineer audience.

### 4 — Explain

Produce the explanation inline (no file write, no agent spawn):

- `--for=engineer` (default): include class names, layer terminology, architectural patterns.
- `--for=non-engineer`: strip class names and layer terminology. Explain in plain language — what the feature does, how data moves, what can go wrong.
- `--aspect` specified: focus only on that section. Quote the relevant section header and explain only its content.
- No `--aspect`: structured summary covering all non-empty sections in order.

Present explanation directly in the conversation. End with a one-line reminder of the Feature Doc path for reference.

### Examples

```
/librarian-explain time-off
/librarian-explain time-off --aspect=data-flow
/librarian-explain live-attendance/clock-in-out --for=non-engineer
/librarian-explain .claude/reference/feature-docs/overtime.md --aspect=gotchas
```
