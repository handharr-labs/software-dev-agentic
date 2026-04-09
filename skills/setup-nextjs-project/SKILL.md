# /setup-nextjs-project

Wire a freshly cloned Next.js project to consume the `reference` starter kit as a git submodule, then guide the user through filling in project-specific details.

---

## When to use

Invoke this skill when the user says:
- "Set up this project with the starter kit"
- "Wire the reference submodule"
- "Initialize `.claude/` for this project"
- `/setup-nextjs-project`

---

## Steps

### 1 — Confirm the repo URL

Ask the user (or use the default):
> "Which web-agentic repo should I use? Default: `https://github.com/handharr-labs/web-agentic`"

If the user says "default" or provides no URL, use `https://github.com/handharr-labs/web-agentic`.

### 2 — Add submodule

```bash
git submodule add <STARTER_KIT_URL> .claude/web-agentic
```

### 3 — Create symlinks

```bash
cd .claude
ln -s web-agentic/agents     agents
ln -s web-agentic/docs       docs
ln -s web-agentic/hooks      hooks
ln -s web-agentic/reference reference
ln -s web-agentic/skills     skills
cd ..
```

### 4 — Make hooks executable

```bash
chmod +x .claude/web-agentic/hooks/*.sh
```

### 5 — Copy and prompt for CLAUDE.md

```bash
cp .claude/web-agentic/CLAUDE-template.md CLAUDE.md
```

Tell the user:
> "I've created `CLAUDE.md` from the template. Please fill in the placeholders:
> - `[AppName]` — your project name
> - `[One-line description...]` — what the app does
> - `[Database]`, `[ORM]`, `[Auth]`, `[UI library]`, `[Test framework]` — your chosen stack
> - `src/features/{auth,[feature-a],...}` — your actual feature names"

### 6 — Create project-specific agent overrides stub

Create `.claude/agents.local/arch-reviewer.local.md`:

```markdown
# arch-reviewer — project-specific rules

> Additive rules for this project. The baseline is in `.claude/web-agentic/agents/arch-reviewer.md`.

<!-- Add project-specific audit rules below -->
```

Also add to `CLAUDE.md` (before the closing line):

```markdown
## Project-specific agent rules
`.claude/agents.local/` — additive rules on top of the shared web-agentic agents.
```

### 7 — Stage and summarize

```bash
git add .gitmodules .claude/ CLAUDE.md
```

Tell the user what was done:
- `.claude/web-agentic/` — submodule pointing to the starter kit repo
- `.claude/{agents,docs,hooks,reference,skills}` — symlinks into the submodule
- `CLAUDE.md` — copied from template (needs placeholder fill-in)
- `.claude/agents.local/arch-reviewer.local.md` — stub for project-specific arch rules

---

## Updating the starter kit later

```bash
cd .claude/web-agentic && git pull && cd ../..
git add .claude/web-agentic
git commit -m "chore: bump reference starter kit"
```
