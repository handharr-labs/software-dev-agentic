---
name: arch-check-conventions
description: Audit a set of agent or skill files against software-dev-agentic conventions and docs/evaluation/01-token-optimization.md fixes. Returns structured findings per file.
user-invocable: false
tools: Read, Glob, Grep
---

Audit the provided files against the conventions below. Return findings grouped by file.

## Agent Checklist

For each `.md` agent file:

**Frontmatter (required fields)**
- [ ] `name` present
- [ ] `description` present and specific enough for routing
- [ ] `model` present — `haiku` for mechanical workers (domain, data, test), `sonnet` for strategists and reasoning-heavy workers
- [ ] `tools` present

**Strategists** (files with `agents:` frontmatter field)
- [ ] `agents:` field lists only workers it actually spawns
- [ ] Body passes only file path lists between phases — never file contents
- [ ] No Phase 2 codebase reads on behalf of workers

**Workers** (files without `agents:` frontmatter field)
- [ ] `## Search Rules` section present with Grep-before-Read rule
- [ ] `## Extension Point` section present at end of file
- [ ] No reference doc reads that say "Read ... completely"
- [ ] All `Reference:` lines use Grep-first pattern
- [ ] Any `Reference:` line that lists multiple files also mentions `reference/index.md` as the discovery fallback (Fix F)

**Core agents** (files under `lib/core/agents/`) — Platform-Agnosticism
- [ ] Body contains no hardcoded platform-specific file paths — no `src/domain/`, `src/data/`, `src/presentation/`, `Talenta/Module/`, `lib/`, `app/`
- [ ] Body contains no platform framework references used as rules — no `React`, `Next.js`, `RxSwift`, `UIKit`, `BLoC`, `axios`, `next-safe-action`
- [ ] Body contains no platform language-specific syntax used as rules — no `'use client'`, `'use server'`, `readonly` (TypeScript), `BehaviorRelay`
- [ ] Platform-specific knowledge is delegated to a skill (`related_skills` field), not embedded inline

How to check: `Grep` the file for any of the above patterns. A match in the body (outside of a `related_skills` reference or a comment acknowledging the skill) is a Critical violation.

> **Why:** `lib/core/` agents are consumed by all platforms via symlink. Platform-specific rules embedded in a core worker silently mislead workers on other platforms (iOS, Flutter) that call the same agent.

**All agents**
- [ ] Filename follows `<domain>-strategist.md` or `<domain>-worker.md` convention
- [ ] If in a persona subdir (`builder/`, `debugger/`, `tracker/`, `auditor/`), the persona assignment is correct

## Skill Checklist

For each `SKILL.md` skill file:

**Frontmatter (required fields)**
- [ ] `name` present
- [ ] `description` present
- [ ] `user-invocable: false` present (or omitted only for user-facing skills)

**Reference doc reads**
- [ ] No step says `Read .claude/reference/... completely`
- [ ] Any step reading a reference doc uses `Grep` for section keyword first
- [ ] All referenced file paths match actual filenames in `lib/platforms/<platform>/reference/` or `lib/core/reference/`

**Templates** (any `template.md` file inside a skill directory)
- [ ] No explanatory/instructional comments that duplicate what `SKILL.md` already says (Fix G)
- [ ] Comments that remain are code generation hints — they tell Claude *what value to put here*, not *how the skill works*

How to check: `Read` the template file; flag any comment that explains the skill's purpose or usage rather than guiding value substitution.

**Naming**
- [ ] Skill directory name follows `<layer>-<action>-<target>` convention
- [ ] Layer prefix matches the agent that calls it (`domain-`, `data-`, `pres-`, `test-`, `debug-`, `review-`)

## Contract Reference Schema Check

For each `lib/platforms/<platform>/reference/contract/` directory being audited, verify all 8 files contain their required canonical heading keywords. Required keywords are defined in `docs/contract/builder-auditor-schema.md`.

**How to check:** For each file, `Grep` for pattern `^## .*<keyword>` within that file. A keyword must appear as a substring of a `##` heading — `###` or deeper does not satisfy the requirement.

| File | Required keywords |
|---|---|
| `domain.md` | `Entities`, `Repository`, `Use Cases`, `Domain Errors` |
| `data.md` | `DTOs`, `Mappers`, `Data Sources`, `Repository Impl` |
| `presentation.md` | `State`, `Shared Component Paths` |
| `navigation.md` | `Route Constants` OR `Navigator` OR `Coordinator` (at least one) |
| `di.md` | `DI Principles` |
| `testing.md` | `Test Pyramid`, `Repository Tests`, `Mapper Tests` |
| `error-handling.md` | `Error Flow`, `Error Types`, `Error Mapping`, `Error UI` |
| `utilities.md` | `StorageService`, `DateService`, `Logger`, `Null Safety` |

Severity: **Critical** — a missing required keyword means core agents cannot reliably Grep for that concept on this platform, breaking cross-platform portability.

## Reference Doc Section Line-Count Check

For each reference doc file being audited (`lib/platforms/<platform>/reference/**/*.md`, `lib/core/reference/**/*.md`), verify every `##` section heading carries a valid integer line-count comment.

**How to check:** `Grep` for `^## ` in the file. For each match, verify the heading line matches the pattern `^## .+ <!-- \d+ -->`. A heading that matches `^## .+ <!-- [^0-9] -->` or has no `<!--` at all is a violation.

**Why:** Agents use the Grep-first pattern to read exactly one section: grep the heading → extract `<!-- N -->` → `Read(file, offset=heading_line, limit=N)`. A missing or non-integer `<!-- N -->` forces the agent to read the entire file, burning tokens and violating the Search Protocol.

Severity: **Warning** — the section is readable but forces a full-file Read instead of a targeted section Read.

## Prompt Clarity Check

For each agent file, flag instructions that are likely to cause bad decisions at runtime:

- [ ] No instruction says "create the X" without specifying interface vs implementation
- [ ] No step spans two CLEAN layers without an explicit stop condition
- [ ] No two rules in the same file contradict each other
- [ ] Failure paths are specified — agent knows what to do when a precondition fails

How to check: Read the agent body and look for vague scope, missing boundaries, or contradicting rules.

> **For deeper analysis:** When a perf-worker report scores D1, D2, D3, or D7 below 7, run `prompt-debug-worker` with the report + the agent file. The static checks here catch structural issues; `prompt-debug-worker` catches reasoning failures.

Severity: Warning for any prompt clarity finding.

## Severity Levels

- **Critical** — missing required frontmatter field, broken reference path, "Read completely" violation, platform-specific content in a `lib/core/agents/` file
- **Warning** — wrong model for worker type, missing Search Rules, missing Extension Point, missing `reference/index.md` discovery hint on multi-file Reference lines, explanatory comments in template files
- **Info** — naming convention deviation, description could be more specific

## Output Format

Return raw findings — do not format into a report. `arch-generate-report` handles formatting.

```
FILE: <path>
  [CRITICAL] <rule> — <specific violation>
  [WARNING]  <rule> — <specific violation>
  [INFO]     <rule> — <specific violation>
PASS: <path>  (no findings)
```
