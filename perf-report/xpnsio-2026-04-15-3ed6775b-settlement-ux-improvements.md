# Agentic Performance Report — Issue #81

> Date: 2026-04-15
> Session: 3ed6775b-0c72-4106-bd5d-3db13318843d
> Branch: fix/issue-081-settlement-ux-improvements
> Duration: ~548 min (2026-04-15T07:13:20.924Z → 2026-04-15T16:21:35.968Z)

## Summary Scores

| Dimension | Score | Rating | Key Signal |
|---|---|---|---|
| D1 · Orchestration Quality | 8/10 | Good | feature-orchestrator correctly spawned; no evidence of orchestrator doing direct file reads |
| D2 · Worker Invocation | 3/10 | Poor | feature-orchestrator spawned no layer workers; data + UI files written inline |
| D3 · Skill Execution | 2/10 | Critical | Zero skill calls despite writing data-layer and presentation-layer artifacts |
| D4 · Token Efficiency | 6/10 | Fair | Excellent cache ratio (97.6%) but 4 duplicate-read paths including TripPublicView.tsx read 8x |
| D5 · Routing Accuracy | 7/10 | Good | Branch prefix fix/ matches bug-fix task; issue-worker spawned first; brief work on main before branching |
| D6 · Workflow Compliance | 7/10 | Good | issue-worker called early, specific git-add used, no --no-verify; no visible gh pr create |
| D7 · One-Shot Rate | 5/10 | Fair | 0 rejections but TripPublicView.tsx read 8 times signals heavy iteration; user:assistant ratio 0.65 |
| **Overall** | **5.4/10** | **Fair** | |

## Token Breakdown

| Metric | Value |
|---|---|
| Input tokens | 408 |
| Cache creation | 262,194 |
| Cache reads | 10,762,073 |
| Output tokens | 87,657 |
| **Billed approx** | **350,259** |
| Cache hit ratio | 97.6% |
| Avg billed / turn | ~2,136 |

## Tool Usage

| Tool | Calls |
|---|---|
| Read | 25 |
| Bash | 20 |
| Edit | 16 |
| Grep | 14 |
| Glob | 9 |
| Agent | 2 |

Read:Grep ratio: 1.8 (target < 3 — high ratio signals full-file reads over targeted search)

## Agent & Skill Invocations

| Component | Args / Description | Outcome |
|---|---|---|
| Agent: issue-worker | Create GitHub issue and branch for Trip/Split Bill UX improvements | ✓ Issue #81 created, branch fix/issue-081-settlement-ux-improvements |
| Agent: feature-orchestrator | Implement settlement UX improvements for issue #81 | ✓ Delivered — but spawned no layer-specific workers |

No skill calls were recorded for this session.

## Findings

### What went well
- Cache hit ratio of 97.6% is excellent — the session benefited heavily from prompt caching, keeping costs low despite 9+ hours of work.
- Read:Grep ratio of 1.8 is well within the Good band — targeted search was used appropriately over full file reads.
- issue-worker was spawned first before any feature work, following the correct workflow start sequence.
- git add used specific file paths (not `-A` or `.`), compliant with workflow rules.
- Zero rejected tool calls — no tool usage errors during the session.
- Branch prefix fix/ correctly matches the UX bug-fix nature of the task.

### Issues found
- **[D2]** feature-orchestrator did not spawn any layer-specific workers (domain-worker, data-worker, presentation-worker, ui-worker). Write paths include `TripDbDataSourceImpl.ts` (data layer) and three presentation/UI view files. All layer work was done inline by the orchestrator itself, violating the orchestrator-as-coordinator pattern.
- **[D3]** Zero skill calls despite modifying a data-layer datasource file and three presentation-layer view files. At minimum `data-update-datasource` and a presentation-layer update skill should have been invoked. Direct writes bypassing skills are a documented anti-pattern.
- **[D4]** `TripPublicView.tsx` was read 8 times across the session — far above any reasonable re-read threshold. This, along with 3 other duplicate-read paths (`TripDbDataSourceImpl.ts`, `TripDetailView.tsx`, `SplitBillManageView.tsx`), signals repeated context loss or iterative trial-and-error editing without retaining state.
- **[D6]** No `gh pr create` command is visible in `bash_commands`. A `git push` to the feature branch was issued but no pull request was created, leaving the branch unreviewed and unmerged via the standard PR workflow.
- **[D5]** The session appears to have begun work on the `main` branch (git_branch recorded as `main` at session start) before the feature branch was created. Feature branches should be created before any file edits are made.

## Recommendations

1. **Highest impact fix — enforce layer-worker delegation inside feature-orchestrator.** The orchestrator must decompose work by layer and spawn the appropriate worker (data-worker for `TripDbDataSourceImpl.ts`, presentation-worker or ui-worker for view files) rather than implementing changes inline. This is the root cause of both D2 and D3 failures.
2. **Invoke skills for every artifact modification.** Even for updates to existing files, the matching update skill (e.g. `data-update-datasource`, `pres-update-stateholder`) must be called. Skills encode architectural constraints that inline edits bypass.
3. **Create the feature branch before touching any files.** The issue-worker should create and checkout the branch as its final step, so all subsequent edits land on the feature branch from the start.
4. **Always complete the workflow with `gh pr create`.** Pushing a branch without opening a PR leaves work in an unreviewed state. The feature-orchestrator should issue `gh pr create --title ... --body "Closes #81"` as its final step.
5. **Reduce repeated reads of large view files.** TripPublicView.tsx being read 8 times indicates the agent was losing context between edit attempts. Workers should read the file once, form a complete edit plan, and apply all changes in a single Edit pass.

---

## Effort vs Billing

### Token cost breakdown

| Token type | Count | Unit price | Cost (USD) |
|---|---|---|---|
| Input | 408 | $3.00 / MTok | $0.001 |
| Cache creation | 262,194 | $3.75 / MTok | $0.98 |
| Cache reads | 10,762,073 | $0.30 / MTok | $3.23 |
| Output | 87,657 | $15.00 / MTok | $1.31 |
| **Total** | **350,259 billed-equiv** | | **~$5.52** |

Cache hit ratio of **97.6%** was the primary cost saver — without caching, the same 11 million tokens processed as input reads would have cost approximately **$34.38** at full input rates, meaning caching saved roughly **$28.86** (84% cost reduction).

### Where the tokens went

| Task | Estimated tokens | % of total | Productive? |
|---|---|---|---|
| Issue creation and branch setup (issue-worker) | ~15,000 | 4% | ✅ |
| Context loading and exploration (Glob/Grep/Read passes) | ~60,000 | 17% | ⚠️ |
| TripPublicView.tsx iterative edits (8 reads + multiple Edits) | ~90,000 | 26% | ❌ Rework — repeated reads signal failed edit attempts |
| TripDetailView.tsx + SplitBillManageView.tsx edits | ~50,000 | 14% | ✅ |
| TripDbDataSourceImpl.ts data-layer changes | ~35,000 | 10% | ✅ |
| TypeScript validation and debugging (tsc runs) | ~30,000 | 9% | ⚠️ |
| Git operations and push | ~10,000 | 3% | ⚠️ |
| Remaining assistant reasoning / output | ~60,259 | 17% | ⚠️ |
| **Total** | **~350,259** | **100%** | |

**Productive work: ~38% (~133,000 tokens / ~$2.10)**
**Wasted on rework: ~26% (~90,000 tokens / ~$1.44)**

### Effort-to-value ratio

| Deliverable | Complexity | Tokens spent | Efficiency |
|---|---|---|---|
| Issue #81 created, branch setup | Low | ~15,000 | Good — proportionate to a simple issue-worker task |
| TripDbDataSourceImpl.ts — settlement data changes | Medium | ~35,000 | Fair — some overhead from duplicate reads |
| TripDetailView.tsx — settlement UX updates | Medium | ~50,000 | Fair — involved some re-reads but broadly proportionate |
| TripPublicView.tsx — settlement UX updates | Medium | ~90,000 | Poor — 8 reads of the same file consumed 26% of total tokens for a single medium-complexity view |
| SplitBillManageView.tsx — UX changes | Medium | ~50,000 | Fair — two reads, reasonable for scope |

### Key insight
`TripPublicView.tsx` consumed an estimated 90,000 tokens — 26% of the entire session budget — for a single medium-complexity view update. The file was read 8 separate times, indicating repeated context reloads between edit attempts rather than a single coherent read-plan-write pass. This pattern typically arises when a worker lacks a persistent edit plan: it reads the file, makes a partial edit, loses the full file state, re-reads, edits again, and cycles. The fix is straightforward: workers should read the target file once, produce a complete diff-level edit plan covering all required changes, and apply it in a single `Edit` call. Eliminating this one inefficiency would reduce session token spend by roughly a quarter.
