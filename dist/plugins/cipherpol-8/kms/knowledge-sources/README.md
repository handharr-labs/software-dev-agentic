# knowledge-sources

Raw knowledge documents — the source material that gets seeded into ChromaDB.

Files here can be any format: `.md`, `.pdf`, `.txt`. Origin can be anything: exported from Confluence, downloaded from the web, written locally.

## Structure

Three top-level scopes, each following the same `{discipline}/{area}/{artifact}.md` path convention:

```
knowledge-sources/
  universal/                          # Cross-platform, cross-project knowledge
    {discipline}/{area}/{artifact}.md

  platform/                           # Platform-specific knowledge (shared across projects)
    {platform}/                       # android | flutter | ios | web
      {discipline}/{area}/{artifact}.md

  projects/                           # Project-specific knowledge (overrides platform)
    {project}/                        # e.g. talenta-ios, talenta-mobile-android
      {discipline}/{area}/{artifact}.md
```

### Discipline values

| Discipline | Contents |
|---|---|
| `architecture` | ADRs, system design, Clean Architecture references |
| `engineering` | Implementation guides, best practices, API references |
| `design` | Design system catalogs, component guidelines, tokens |
| `agile` | Ceremony guides, retrospective templates, sprint rituals |
| `product` | PRD templates, decision frameworks |
| `qa` | Test strategy docs, quality checklists |
| `devops` | CI/CD guides, runbooks, infra references |
| `security` | Threat model references, compliance docs |

### Example paths

```
platform/flutter/design/design-system/mekari-pixel.md
platform/flutter/engineering/core/standard-architecture.md
projects/talenta-ios/design/design-system/mekari-pixel.md
projects/talenta-ios/engineering/core/feature-inventory.md
projects/talenta-mobile-android/design/design-system/mekari-pixel.md
```

### Resolution cascade

When a node exists at multiple scopes, the most specific wins:
`project` → `platform` → `universal`

## How to register a source

After adding a file here, register it in `kms/sources.yaml` or run:

```bash
python -m kms.scripts.seed_kms --db-path /path/to/chroma --add kms/knowledge-sources/platform/flutter/design/design-system/mekari-pixel.md
```

The seed runner auto-detects the type and prompts for confirmation before registering.

## Notes

- Files here are the bootstrap source — after seeding, ChromaDB is authoritative
- Unstructured files (PDF, TXT) require a parser adapter before they can be seeded — see `kms/domain/sources/`
- Markdown files with valid frontmatter (`discipline`, `topic`, `pattern`) are picked up by `MarkdownSource` directly
