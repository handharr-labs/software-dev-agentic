# Agentic Performance Report — Issue #99

> Date: 2026-04-19
> Session: 305f9697-7d0f-4bf4-8bde-76728e2fa0f9
> Branch: main
> Duration: ~19 min (2026-04-19T16:56:04.667Z → 2026-04-19T17:15:19.075Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 8/10 | Good | No orchestrator spawned; feature-orchestrator used correctly as fix delegate |
| D2 · Worker Invocation | 9/10 | Excellent | issue-worker → debug-worker → feature-orchestrator in correct sequence |
| D3 · Skill Execution | 8/10 | Good | CSS-only fix; no domain/data/presentation artifacts — skill calls not required |
| D4 · Token Efficiency | 5/10 | Fair | read_grep_ratio 8.0 (target < 3); globals.css read 3× |
| D5 · Routing Accuracy | 8/10 | Good | User initiated "create issue and pick up" from main — branch routing was intentional |
| D6 · Workflow Compliance | 5/10 | Fair | No PR created after fix landed; `gh pr create` absent from bash_commands |
| D7 · One-Shot Rate | 7/10 | Good | 0 rejected tools; minor re-reads on globals.css; node_modules explore was trial-and-error |
| **Overall** | **7.1/10** | **Good** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 240 |
| Cache creation | 129,905 |
| Cache reads | 2,614,353 |
| Output tokens | 45,084 |
| **Billed approx** | **175,229** |
| Cache hit ratio | 95.3% |
| Avg billed / turn | ~2,873 |

## Tool Usage

| Tool | Calls |
|---|---|
| Bash | 19 |
| Read | 8 |
| Agent | 3 |
| Glob | 2 |
| Grep | 1 |
| Edit | 1 |
| ToolSearch | 1 |
| AskUserQuestion | 1 |

Read:Grep ratio: 8.0 (target < 3 — high ratio signals full-file reads over targeted search)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Agent: issue-worker | Create GitHub issue for split-bill dropdown bug | Correct — issue tracking workflow initiated first |
| Agent: debug-worker | Debug split-bill dropdown prod bug | Correct — debug agent used before fix agent |
| Agent: feature-orchestrator | Fix split-bill dropdown background in prod | Correct — CLAUDE.md mandates feature-orchestrator for any create/update work |

## Findings

### What went well

- Worker sequencing was exemplary: issue-worker → debug-worker → feature-orchestrator is exactly the correct order for a production bug fix with issue tracking.
- Zero rejected tool calls — no plan interruptions or denied operations.
- Cache hit ratio of 95.3% kept billing lean despite a lengthy node_modules exploration phase.
- CLAUDE.md delegation rule was respected: the fix was not inlined; it was handed to feature-orchestrator.
- The root cause (Tailwind v4 `@source` scanning gap) is precisely the pattern documented in CLAUDE.md's "Known Configurations" section — the agent correctly identified and applied the prescribed fix.

### Issues found

- **[D6]** No PR was created (`gh pr create` absent from bash_commands). The user initiated this session via "create issue and pick up" from `main` — working on `main` directly was intentional. However, a PR with `Closes #99` is still the expected delivery mechanism for any fix, regardless of branching strategy.

- **[D4]** `read_grep_ratio` of 8.0 — the debug phase used 15 Bash `find`/`ls` commands to navigate node_modules (`@base-ui/react`) instead of using Grep to locate the specific symbol or CSS class. The correct approach: `Grep -r "background" node_modules/@base-ui/react/select/` narrows the target before any Read. Full directory listings of node_modules are expensive and often unnecessary.

- **[D4]** `globals.css` was read 3 times (counted in `duplicate_reads`). Given the Explore-agent rule in CLAUDE.md ("Pass Explore output as a structured path list to the next agent — never raw file contents"), the file should have been read once by debug-worker, its path passed to feature-orchestrator, and feature-orchestrator should have read it once more. A third read indicates either the orchestrator re-explored or the debug output was not passed cleanly.

> **Low score on D4?** Run `prompt-debug-worker` with this report + the agent's .md file
> to surface ambiguous instructions that caused this behavior.
> Agent file: `lib/core/agents/builder/feature-orchestrator.md`

> **Low score on D6?** Run `prompt-debug-worker` with this report + the agent's .md file
> to surface ambiguous instructions that caused this behavior.
> Agent file: `lib/core/agents/builder/feature-orchestrator.md`

## Recommendations

1. **Add a mandatory PR step in feature-orchestrator** — for any session that begins with an issue-worker spawn, feature-orchestrator should end with a `gh pr create --body "Closes #NNN"` call. The issue reference is already available from the issue-worker output. This applies even when working on `main` directly.

3. **Constrain node_modules exploration in debug-worker** — the debug-worker prompt should instruct agents to use targeted Grep patterns when diagnosing third-party library behavior rather than recursive `find`/`ls`. Example instruction: "Use `Grep -n 'pattern' path/` before listing directories in node_modules."

4. **Pass globals.css path once via structured list** — debug-worker should emit a structured exploration result (file paths only) to feature-orchestrator. This prevents the triple-read of globals.css observed here.

---

## Effort vs Billing

### Token cost breakdown

| Token type | Count | Unit price | Cost (USD) |
|---|---|---|---|
| Input | 240 | $3.00 / MTok | $0.00 |
| Cache creation | 129,905 | $3.75 / MTok | $0.49 |
| Cache reads | 2,614,353 | $0.30 / MTok | $0.78 |
| Output | 45,084 | $15.00 / MTok | $0.68 |
| **Total** | **175,229 billed-equiv** | | **~$1.95** |

Cache hit ratio of **95.3%** was the primary cost saver — without caching, the same session at full input rates would have cost approximately $8.37 (all 2,789,582 tokens billed at $3.00/MTok). The cache saved roughly **$6.42**.

### Where the tokens went

| Task | Estimated tokens | % of total | Productive? |
|---|---|---|---|
| Issue creation (issue-worker) | ~5,000 | ~3% | ✅ |
| Debug investigation — node_modules exploration | ~55,000 | ~31% | ⚠️ Overhead — excessive find/ls instead of Grep |
| Debug investigation — globals.css + ThemeProvider analysis | ~20,000 | ~11% | ✅ |
| feature-orchestrator — globals.css fix | ~15,000 | ~9% | ✅ |
| globals.css duplicate reads | ~8,000 | ~5% | ❌ Rework |
| Output generation (45k output tokens) | ~45,000 | ~26% | ✅ |
| Tooling / orchestration overhead | ~27,229 | ~16% | ⚠️ |
| **Total** | **~175,229** | **100%** | |

**Productive work: ~49% (~85,000 tokens / ~$0.96)**
**Wasted on rework: ~5% (~8,000 tokens / ~$0.09)**
**Overhead (necessary but non-productive): ~47% (~82,229 tokens / ~$0.91)**

### Effort-to-value ratio

| Deliverable | Complexity | Tokens spent | Efficiency |
|---|---|---|---|
| GitHub issue #99 created | Low | ~5,000 | Good — proportionate |
| Root cause identified (Tailwind v4 @source gap) | Medium | ~75,000 | Fair — node_modules exploration was wide; targeted Grep would have reduced this by ~40% |
| globals.css @source directive added | Low | ~23,000 | Fair — 3× reads of a single file inflated cost for a one-line change |

### Key insight

The debug investigation phase consumed ~42% of total tokens (~75,000), yet produced a single-line fix to `globals.css`. The disproportionate cost traces directly to the node_modules exploration strategy: 15 Bash `find`/`ls` calls were used to navigate `@base-ui/react`'s directory tree. Each call generates significant output that flows through context. A single `Grep -rn "background" node_modules/@base-ui/react/select/popup/` would have surfaced the relevant CSS classes in one pass. This is a recurring pattern in debug sessions targeting third-party libraries — the debug-worker prompt should explicitly prefer Grep over directory listing when investigating node_modules.
