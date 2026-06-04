# knowledge-sources

Raw knowledge documents — the source material that gets seeded into ChromaDB.

Files here can be any format: `.md`, `.pdf`, `.txt`. Origin can be anything: exported from Confluence, downloaded from the web, written locally.

## Structure

Organized by discipline, matching `schema.DISCIPLINE_VALUES`:

```
knowledge-sources/
  architecture/    # ADRs, system design docs, Clean Architecture references
  engineering/     # Implementation guides, best practices
  agile/           # Ceremony guides, retrospective templates, sprint rituals
  product/         # PRD templates, decision frameworks
  qa/              # Test strategy docs, quality checklists
  devops/          # CI/CD guides, runbooks, infra references
  security/        # Threat model references, compliance docs
```

## How to register a source

After adding a file here, register it in `kms/sources.yaml` or run:

```bash
python -m kms.scripts.seed_kms --db-path /path/to/chroma --add kms/knowledge-sources/architecture/clean-arch.md
```

The seed runner auto-detects the type and prompts for confirmation before registering.

## Notes

- Files here are the bootstrap source — after seeding, ChromaDB is authoritative
- Unstructured files (PDF, TXT) require a parser adapter before they can be seeded — see `kms/domain/sources/`
- Markdown files with valid frontmatter (`discipline`, `topic`, `pattern`) are picked up by `MarkdownSource` directly
