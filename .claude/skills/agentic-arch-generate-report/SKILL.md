---
name: agentic-arch-generate-report
description: Format raw arch-check-conventions findings into a structured review report. Called after all workers complete.
user-invocable: false
tools: Read
---

Format the raw findings passed by the caller into a structured report.

## Report Format

```markdown
## Architecture Convention Review — <scope>

> Reviewed: <date> · Scope: <what was reviewed>

### Summary
<N> critical · <M> warnings · <K> info · <P> files clean

---

### 🔴 Critical
**[<path>]** — <rule name>
> <specific violation>
Fix: <concrete action>

---

### 🟡 Warnings
**[<path>]** — <rule name>
> <specific violation>
Fix: <concrete action>

---

### 🟢 Info
**[<path>]** — <note>

---

### ✅ Clean Files
<list of files with no findings>
```

## Rules

- Group findings by severity, then by file within each group
- Every Critical and Warning must include a concrete `Fix:` line
- If zero findings: emit `✅ All files comply with conventions.` only
- Do not include the raw findings format in output — only the formatted report
