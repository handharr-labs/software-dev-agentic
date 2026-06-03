from __future__ import annotations
from ..entities import KnowledgeNode
from ..repository import KnowledgeRepository


class UpsertKnowledge:

    def __init__(self, repo: KnowledgeRepository) -> None:
        self._repo = repo

    def execute(self, node: KnowledgeNode) -> None:
        if not node.content:
            raise ValueError(f"node.content is required for upsert: {node.id}")
        self._repo.upsert(node)
