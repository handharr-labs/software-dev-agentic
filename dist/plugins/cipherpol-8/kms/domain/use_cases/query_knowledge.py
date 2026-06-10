from __future__ import annotations
from typing import Optional
from ..entities import KnowledgeNode
from ..repository import KnowledgeRepository


class QueryKnowledge:
    """
    Semantic search across the knowledge store.
    Used by feature planners for cross-discipline discovery when the exact topic is unknown.
    """

    def __init__(self, repo: KnowledgeRepository) -> None:
        self._repo = repo

    def execute(
        self,
        text: str,
        where: Optional[dict] = None,
        n_results: int = 5,
    ) -> list[KnowledgeNode]:
        return self._repo.query(text, where=where, n_results=n_results)
