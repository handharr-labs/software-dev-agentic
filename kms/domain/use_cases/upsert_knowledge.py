from __future__ import annotations
import dataclasses
from typing import Optional

from ..entities import KnowledgeNode
from ..repository import KnowledgeRepository


def _section_heading_level(content: str) -> int:
    """Detect the heading depth used for top-level sections in this content (## or ###).

    A node's content may be rooted at ## (no ### children) or ### (promoted pattern
    node, subtopic = enclosing ## slug). Defaults to 2 if no heading is found.
    """
    for line in content.split("\n"):
        stripped = line.lstrip()
        if stripped.startswith("#"):
            return len(stripped) - len(stripped.lstrip("#"))
    return 2


def _parse_sections(content: str) -> dict[str, str]:
    """Split markdown content into {section_key: section_body} by its top-level headings (## or ###)."""
    prefix = "#" * _section_heading_level(content) + " "
    sections: dict[str, str] = {}
    current_key: Optional[str] = None
    current_lines: list[str] = []

    for line in content.split("\n"):
        if line.startswith(prefix):
            if current_key is not None:
                sections[current_key] = "\n".join(current_lines).strip()
            current_key = line[len(prefix):].strip().lower().replace(" ", "_")
            current_lines = []
        else:
            current_lines.append(line)

    if current_key is not None:
        sections[current_key] = "\n".join(current_lines).strip()

    return sections


def _assemble_sections(sections: dict[str, str], level: int = 2) -> str:
    """Reassemble {section_key: body} back into markdown at the given heading level."""
    prefix = "#" * level
    parts = []
    for key, body in sections.items():
        header = key.replace("_", " ").title()
        parts.append(f"{prefix} {header}\n{body}")
    return "\n\n".join(parts)


class UpsertKnowledge:

    def __init__(self, repo: KnowledgeRepository) -> None:
        self._repo = repo

    def execute(self, node: KnowledgeNode, owns: Optional[list[str]] = None) -> None:
        if not node.content:
            raise ValueError(f"node.content is required for upsert: {node.id}")

        existing = self._repo.fetch_exact(
            node.platform, node.project, node.discipline, node.artifact, node.topic, node.subtopic, node.pattern
        )

        if node.content_type == "stub" and existing is not None and existing.content_type == "real":
            return  # stubs never overwrite real content

        if owns is None:
            self._repo.upsert(node)
            return

        level = _section_heading_level(node.content)

        if existing is None or not existing.content:
            owned = {k: v for k, v in _parse_sections(node.content).items() if k in owns}
            assembled = _assemble_sections(owned, level)
            # Fall back to full content when no owned sections match (e.g. project docs
            # with domain-specific headings like ## Features that aren't in the owns list).
            node = dataclasses.replace(node, content=assembled if assembled else node.content)
        else:
            merged = _parse_sections(existing.content)
            new_sections = _parse_sections(node.content)
            for section in owns:
                if section in new_sections:
                    merged[section] = new_sections[section]
            node = dataclasses.replace(node, content=_assemble_sections(merged, level))

        self._repo.upsert(node)
