> Related: [shared-kms-retrieve skill](../../skills/procedures/shared-kms-retrieve/SKILL.md) · [kms-conventions.md](../../../../docs/principles/kms/kms-conventions.md)

Standard output format produced after every `shared-kms-retrieve` call. Agents emit this block; orchestrators and calling skills can parse it by heading.

---

## Format

~~~
## Knowledge Loaded — {discipline}/{artifact}

### Theory
{KMS content from kms_fetch / kms_query — definitions, patterns, naming conventions, dependency rules.
One entry per fetched pattern; label each with its pattern slug.}

### Code Pattern
{file: <path>}
{excerpt — constructor, class signature, or representative method body.
Enough to match naming and structural style; not the full file.}
~~~

---

## Rules

- Always emit both `### Theory` and `### Code Pattern`. If either is unavailable, state why:
  - No KMS content: `Theory: no nodes found for {discipline}/{artifact} on {platform} — check kms_list output`
  - No codebase match: `Code Pattern: no match for "{codebase_grep}" outside test paths`
- One `## Knowledge Loaded` block per `shared-kms-retrieve` call. Two calls → two blocks, each labelled with their own `{discipline}/{artifact}`.
- Do not forward raw KMS JSON. Summarise into human-readable pattern descriptions.
- Theory and Code Pattern together are the ground truth for all artifact decisions in the current session. An agent that skips either is operating on incomplete knowledge.
