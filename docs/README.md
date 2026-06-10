# docs/

Internal design docs for the CipherPol repo. Not shipped to downstream projects.

| File | Description | Confluence |
|---|---|---|
| `principles/core-design-principles.md` | 15 core principles — agent/skill design, token efficiency, conventions | [Link](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51126370416) |
| `principles/submodule-repo-structure.md` | Cross-platform submodule architecture — decisions, setup, what goes where | [Link](https://jurnal.atlassian.net/wiki/spaces/~611df3da650a26006e44928d/pages/51129909710) |
| `deck/stakeholder-brief.md` | Non-technical stakeholder brief |  |
| `initiatives/contract-schema-improvement-backlog.md` | Contract schema gap backlog |  |

## Workflow

`docs/` is the source of truth. Confluence is the published view.

1. Edit the local `.md` file
2. When ready to publish: push to Confluence via `mmpa_save_confluence_page`

Do not edit Confluence directly — changes will be overwritten on next push.
