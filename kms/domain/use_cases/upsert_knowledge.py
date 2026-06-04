from __future__ import annotations
import dataclasses
from typing import Optional

from ..entities import KnowledgeNode
from ..repository import KnowledgeRepository


def _parse_sections(content: str) -> dict[str, str]:
    """Split markdown content into {section_key: section_body} by ## headings."""
    sections: dict[str, str] = {}
    current_key: Optional[str] = None
    current_lines: list[str] = []

    for line in content.split("\n"):
        if line.startswith("## "):
            if current_key is not None:
                sections[current_key] = "\n".join(current_lines).strip()
            current_key = line[3:].strip().lower().replace(" ", "_")
            current_lines = []
        else:
            current_lines.append(line)

    if current_key is not None:
        sections[current_key] = "\n".join(current_lines).strip()

    return sections


def _assemble_sections(sections: dict[str, str]) -> str:
    """Reassemble {section_key: body} back into markdown."""
    parts = []
    for key, body in sections.items():
        header = key.replace("_", " ").title()
        parts.append(f"## {header}\n{body}")
    return "\n\n".join(parts)


class UpsertKnowledge:

    def __init__(self, repo: KnowledgeRepository) -> None:
        self._repo = repo

    def execute(self, node: KnowledgeNode, owns: Optional[list[str]] = None) -> None:
        if not node.content:
            raise ValueError(f"node.content is required for upsert: {node.id}")

        if owns is None:
            self._repo.upsert(node)
            return

        existing = self._repo.fetch_exact(
            node.platform, node.project, node.discipline, node.topic, node.pattern
        )

        if existing is None or not existing.content:
            owned = {k: v for k, v in _parse_sections(node.content).items() if k in owns}
            node = dataclasses.replace(node, content=_assemble_sections(owned))
        else:
            merged = _parse_sections(existing.content)
            new_sections = _parse_sections(node.content)
            for section in owns:
                if section in new_sections:
                    merged[section] = new_sections[section]
            node = dataclasses.replace(node, content=_assemble_sections(merged))

        self._repo.upsert(node)
