from __future__ import annotations
from typing import Optional
from ..entities import KnowledgeNode
from ..repository import KnowledgeRepository


class FetchKnowledge:
    """
    Cascade fetch: project-specific → platform-base → universal.
    Returns the first match with full content, or None if nothing exists.
    """

    def __init__(self, repo: KnowledgeRepository) -> None:
        self._repo = repo

    def execute(
        self,
        discipline: str,
        topic: str,
        pattern: str,
        platform: Optional[str] = None,
        project: Optional[str] = None,
    ) -> Optional[KnowledgeNode]:
        candidates: list[tuple[Optional[str], Optional[str]]] = []

        if platform and project:
            candidates.append((platform, project))
        if platform:
            candidates.append((platform, None))
        candidates.append((None, None))

        for plat, proj in candidates:
            node = self._repo.fetch_exact(plat, proj, discipline, topic, pattern)
            if node is not None:
                return node

        return None
