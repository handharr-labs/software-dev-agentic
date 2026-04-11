# Agentic Performance Report — Issue #53

> Date: 2026-04-11
> Evaluated: 2026-04-11 — findings merged into journey/01-token-optimization.md; fixes applied in commits 735c376 and 691ae64
> Session: 92f4a123-134d-46c5-8df6-1b34f1e7c20b
> Branch: main (pushed to feat/issue-053-admin-configurable-form-fields-dynamic-sheet-sync at commit)
> Duration: ~779 min (2026-04-10T18:28:14.545Z → 2026-04-11T07:27:38.177Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 7/10 | Good | No orchestrator spawned; inline execution of a large multi-layer feature adds coordination risk |
| D2 · Worker Invocation | 5/10 | Fair | Explore agents used correctly but no implementation workers spawned for a 44-file, 5-layer feature |
| D3 · Skill Execution | 8/10 | Good | No skills called; issue-worker agent served as workflow entry point per CLAUDE.md convention |
| D4 · Token Efficiency | 5/10 | Fair | read_grep_ratio 6.8 (P7 violation) and 2 duplicate reads offset an excellent 97.5% cache hit ratio |
| D5 · Routing Accuracy | 5/10 | Fair | Session ran entirely on `main`; feature branch only materialised at push time, not before implementation |
| D6 · Workflow Compliance | 5/10 | Fair | issue-worker and specific git add correct; work on `main` throughout session violates branching rule |
| D7 · One-Shot Rate | 9/10 | Excellent | Zero rejected tools; user/assistant turn ratio 0.76; only 2 duplicate reads causing minor deduction |
| **Overall** | **6.3/10** | **Fair** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 390 |
| Cache creation | 575,970 |
| Cache reads | 22,304,636 |
| Output tokens | 160,686 |
| **Billed approx** | **737,046** |
| Cache hit ratio | 97.5% |
| Avg billed / turn | ~3,412 |

## Tool Usage

| Tool | Calls |
|---|---|
| Read | 41 |
| Edit | 38 |
| Write | 27 |
| Bash | 14 |
| Glob | 8 |
| Grep | 6 |
| Agent | 4 |
| ToolSearch | 1 |
| AskUserQuestion | 1 |
| ExitPlanMode | 1 |

Read:Grep ratio: 6.8 (target < 3 — high ratio signals full-file reads over targeted search)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Agent: issue-worker | Create GitHub issue for dynamic form fields feature | ✓ Correct workflow entry per CLAUDE.md |
| Agent: Explore | Explore Apps Script integration and current sheet structure | ✓ Appropriate read-only exploration |
| Agent: Explore | Explore admin UI, company settings, and feature structure patterns | ✓ Appropriate read-only exploration |
| Agent: Explore | Explore career page form, data models, and existing field types | ✓ Appropriate read-only exploration |

No skill calls recorded.

## Findings

### What went well
- Cache performance was outstanding at 97.5%, keeping billed tokens well-controlled for a session spanning 13+ hours.
- Zero rejected tool calls indicates clean, confident execution with no permission or validation friction.
- The issue-worker was invoked first before any implementation work, satisfying the mandatory CLAUDE.md workflow precondition.
- `git add` used explicit file paths rather than `-A` or `.`, following the project's staging hygiene rule.
- Three targeted Explore agents were used to gather context before writing any code, showing disciplined read-before-write behaviour.
- User/assistant turn ratio of 0.764 is below the 0.8 correction threshold, indicating the session ran with relatively low rework.

### Issues found
- **[D5, D6]** Session `git_branch` is `main` — the entire implementation (44 write paths, 216 assistant turns) happened on `main` before the feature branch was pushed. CLAUDE.md's issue rule states `fix/`|`feat/` branches should be used for work; the branch should have been checked out immediately after issue-worker created it, not just at push time.
- **[D4]** `read_grep_ratio` of 6.8 exceeds the P7 threshold of 6. With 41 Read calls vs 6 Grep calls, several files were read in full when targeted search would have sufficed. Likely candidates: `Code.gs` (read twice, large Apps Script file), `Step1ProfileFormOrganism.tsx` (read twice), and structural files like `container.server.ts` and `applicationFormSchema.ts` that were referenced only for single values.
- **[D4]** Two duplicate reads: `apps-script/Code.gs` and `Step1ProfileFormOrganism.tsx` each read twice — suggests mid-session context loss or re-verification rather than a first-read being cached and referenced.
- **[D2]** A 44-file feature spanning domain entities, data layer, presentation layer, server actions, Apps Script, and tests was executed entirely inline. Per P9, a `feature-orchestrator` coordinating `backend-orchestrator` and presentation workers would have provided better isolation and reduced the risk of cross-layer errors. The `ExitPlanMode` call confirms a plan existed; workers would have executed that plan more safely.
- **[D4]** Average billed tokens per turn of ~3,412 falls in the Fair band (2K–5K), driven primarily by the large output volume (160,686 tokens) from writing 44 files inline rather than distributing work to isolated workers.

## Recommendations

1. **Check out the feature branch immediately after issue-worker** — The branch `feat/issue-053-...` was created by issue-worker but the session continued on `main`. Add an explicit `git checkout <branch>` step right after issue-worker completes. This is the single highest-compliance fix.
2. **Use Grep instead of Read for structural discovery** — For large files like `Code.gs`, `applicationFormSchema.ts`, and `container.server.ts`, use `Grep` with a targeted pattern to find the relevant section rather than reading the whole file. This directly addresses the 6.8 read_grep_ratio.
3. **Spawn a feature-orchestrator for multi-layer features** — When a task touches more than 3 architectural layers (domain + data + presentation + infra like Apps Script), spawn a `feature-orchestrator` to delegate to `backend-orchestrator` and presentation workers. This session was large enough (44 files, ~13 hours) that orchestration would have reduced inline context accumulation and duplicate reads.
4. **Avoid re-reading files already read by Explore agents** — The Explore agents read `Code.gs` and `Step1ProfileFormOrganism.tsx`; the parent session re-read them. Pass the Explore agent's findings as structured summaries to the implementation phase rather than re-opening files.
