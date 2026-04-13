# Delegation Guard Hook

> Date: 2026-04-13
> Type: Improvement
> Related: [03-worker-routing-and-validation.md](./03-worker-routing-and-validation.md)
> Sessions analysed: xpnsio split-bill-form-fix (2026-04-13, session 49b6bb81)
> Perf reports: [xpnsio-2026-04-13-49b6bb81-split-bill-form-fix](../perf-report/xpnsio-2026-04-13-49b6bb81-split-bill-form-fix.md)

## Trigger

Perf report for xpnsio split-bill-form-fix (session 49b6bb81) scored 5.0/10 (revised to 5.9/10 after correcting a false issue-worker violation). The dominant failure was D2 (Worker Invocation, 2/10): Claude edited `SplitBillFormView.tsx` inline on a `feat/*` branch without delegating to `feature-orchestrator`. This is the same recurring pattern identified in Entry 03 — the rule exists in CLAUDE.md but is not enforced at the tooling level.

The session also surfaced a secondary issue: the perf report incorrectly penalised the session for skipping `issue-worker` when the user was already on a branch from a prior session. The scoring logic needs to account for continuation sessions.

---

## Root Cause Analysis

### Why inline edits keep happening

The violation is not ignorance — Claude reads CLAUDE.md and acknowledges the rule. The failure mode is that by the time an `Edit` call is about to fire, the routing decision from CLAUDE.md is far back in context. Claude has already read the file, identified the fix, and the cognitive work is done. Delegation at that point feels like overhead.

**LLMs optimise for task completion speed, not workflow compliance.** A soft instruction in a prompt file cannot overcome that reflex. The constraint needs to live in the tooling layer.

### Why a PreToolUse hook on Edit/Write — and why not other options

Three options were evaluated:

| Option | Problem |
|--------|---------|
| Stronger CLAUDE.md wording | Already tried — same failure mode |
| Remove Edit/Write from top-level tool allowlist | Too broad — breaks perf reports, CHANGELOG, config edits |
| PreToolUse hook with branch + file path check | Precise — only blocks the intersection that matters |

The hook wins because it has access to the target file path (from tool input) and the current branch — enough to gate exactly the right case without breaking anything else.

### Why a branch-scoped flag (not session-scoped)

Initial design used `.claude/.delegated` — a session-scoped flag that feature-orchestrator sets at startup. Problem: in continuation sessions (user already on branch from prior session), the orchestrator was never re-invoked, so the flag doesn't exist. The hook would block legitimate work.

Solution: branch-scoped flag `.claude/.delegated-<branch-slug>`. Created once when orchestrator first runs on a branch. Survives all subsequent sessions on that branch. Cleaned up at Phase 5 when the feature wraps up.

---

## Changes Made

### New: `lib/core/hooks/require-feature-orchestrator.sh`

`PreToolUse` hook. Block condition: `feat/*` branch **and** file path matches a feature directory fragment **and** no branch-scoped delegation flag.

Feature directories are read from `## Feature Directories` fenced block in `CLAUDE.md` — no extra config file, one source of truth per project.

### New: `## Feature Directories` in CLAUDE templates

Added outside the managed block (so `sync.sh` doesn't reset it). iOS template uses `[AppName]` placeholder; setup scripts replace it via `--app-name` flag or interactive prompt.

### Updated: `feature-orchestrator.md`

- Added `Bash` to tools
- **Pre-flight phase**: `touch .claude/.delegated-<branch>` before gathering intent
- **Phase 5**: `rm -f .claude/.delegated-<branch>` after wrap-up

### Updated: setup scripts

- `setup-packages.sh`, `setup-symlinks.sh`: append `.claude/.delegated-*` to `.gitignore` at setup time
- `setup-packages.sh`, `setup-symlinks.sh`: `--app-name=` flag + interactive prompt for `[AppName]` replacement
- `setup-symlinks.sh`: core hooks (`lib/core/hooks/`) now linked alongside platform hooks

### Updated: `sync.sh`

Three auto-patches for existing projects on upgrade:
1. `.gitignore` — append `.claude/.delegated-*` if missing
2. `settings.local.json` — insert `require-feature-orchestrator` as first `PreToolUse` hook if missing
3. `CLAUDE.md` — append `## Feature Directories` section if missing (iOS: prompts for `[AppName]`)

Also fixed: `git pull` in submodule context (detached HEAD) → `git submodule update --remote` from project root.

### New: `lib/platforms/ios/settings-template.json`

Was missing entirely. Added with `require-feature-orchestrator` wired as `PreToolUse`.

---

## Downstream Impact

| Project | Method | Status |
|---------|--------|--------|
| xpnsio | `sync.sh` | Hook symlinked, `.gitignore` patched, `settings.local.json` patched, `CLAUDE.md` Feature Directories added |
| wehire | `sync.sh` | Same |
| talenta-ios | Manual copy | No submodule — hook copied directly, `settings.local.json` patched manually |

`settings.local.json` is gitignored in all three projects — hook is wired locally only.

---

## Perf Report Scoring Fix

The split-bill-form-fix report was revised:

- **D3** (Skill Execution): 2/10 → 5/10. `issue-worker` was not required — user was already on branch from prior session. The scorer must check whether a branch already exists before penalising for missing `issue-worker`.
- **D6** (Workflow Compliance): 3/10 → 5/10. One violation, not two.
- **Overall**: 5.0/10 → 5.9/10.
- **D2 finding**: flagged explicitly as a recurring pattern across sessions, not an isolated miss.

---

## Open Questions

1. **Hook coverage for iOS** — the `require-feature-orchestrator.sh` is platform-agnostic and works for iOS too, but iOS has no `pres-orchestrator` path guard. Should the hook also check for `pres-orchestrator` on branches matching `feature/*` (Bitbucket convention)?

2. ~~**Flag cleanup on branch delete** — the `.delegated-<branch>` flag is only cleared by Phase 5. If a feature is abandoned mid-way, the flag lingers. Low risk (it's gitignored), but worth a periodic `git branch --merged | xargs ...` cleanup in `sync.sh`.~~ **Resolved in Entry 05** — 4h TTL added; flag is now self-expiring.

3. **Continuation session detection in perf scoring** — the scorer needs a heuristic: if the branch already has commits when the session starts, `issue-worker` is not required. Could check `git log --oneline origin/main..HEAD` at session start.
