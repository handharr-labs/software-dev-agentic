---
name: review-pr
description: |
  Review a PR or branch for conventions, architecture compliance, and reactive patterns.
user-invocable: false
---

Review code against all rules in `.claude/reference/review-rules.md`.

## Steps

1. **Grep** `.claude/reference/review-rules.md` for the relevant convention keyword; only **Read** the full file if a rule cannot be located
2. **Get the diff**: read changed files or use `git diff` output provided by the caller
3. **Check all 10 conventions** from the review rules
4. **Produce the review output** in the standard format

## Conventions Checklist (from review-rules.md)

1. Safe unwrapping — `.orEmpty()` / `.orZero()` / `.orFalse()`, parentheses rule
2. `[weak self]` in all closures referencing self
3. `distinctUntilChanged()` on all RxSwift bindings
4. `.disposed(by: disposeBag)` on all subscriptions
5. No new files in legacy folders (`Models/`, `Controllers/`, `ViewModels/`)
6. Leaf UIKit classes marked `final`
7. Mapper field omissions (silent defaults)
8. Magic numbers without named constants
9. No nested RxSwift subscriptions
10. `Result<Success, BaseErrorModel>` completion pattern

## Do NOT Comment On

- Legacy code not modified in this PR
- Generated files (`.generated.swift`, Needle files)
- V2 migration suggestions on existing code
- Already-fixed issues in this PR

## Output Format

Follow the review output format from `.claude/reference/review-rules.md`:

```markdown
## PR Review: {title}

### 📊 Overview
- Branch: {branch}
- Assessment: [✅ APPROVE | ⚠️ CHANGES REQUESTED]

## ✅ Positive Findings
## ⚠️ Issues Found
### N. [HIGH/MED/LOW] {Issue Title}
  File: path:line  ❌ Current / ✅ Fix

## 📋 Summary by File
## 🎯 Action Items
## 💡 Final Recommendation
```
