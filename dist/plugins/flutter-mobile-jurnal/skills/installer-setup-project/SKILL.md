---
name: installer-setup-project
description: Set up the software-dev-agentic submodule and wire flutter-mobile-jurnal platform symlinks into the downstream repo.
user-invocable: false
---

Wire the agentic toolkit into mobile-jurnal.

## Steps

1. **Verify** submodule is present at the expected path in mobile-jurnal
2. **Run** the setup script for this platform:

```bash
software-dev-agentic/scripts/setup-symlinks.sh --platform=flutter-mobile-jurnal
```

3. **Confirm** the following symlinks are created in mobile-jurnal:
   - `.claude/agents/` → `software-dev-agentic/lib/core/agents/`
   - `.claude/skills/` → `software-dev-agentic/lib/core/skills/`
   - `.claude/reference/` → `software-dev-agentic/lib/platforms/flutter-mobile-jurnal/reference/`
   - `.claude/skills/contract/` → `software-dev-agentic/lib/platforms/flutter-mobile-jurnal/skills/contract/`

4. **Verify** `.claude/reference/code-architecture/domain-impl.md` resolves correctly from mobile-jurnal root

## Troubleshooting

- If symlinks already exist, re-run with `--force` flag (if supported by setup script)
- If platform name mismatch: confirm `--platform=flutter-mobile-jurnal` matches the directory under `lib/platforms/`

## Output

Confirm all symlinks created and list their resolved targets.
