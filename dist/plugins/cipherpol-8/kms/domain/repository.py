from __future__ import annotations
from abc import ABC, abstractmethod
from typing import Optional
from .entities import KnowledgeNode

# Callers that need an explicit "stored as null" filter pass this sentinel
# instead of Python None (which means "no filter on this field").
NULL_SENTINEL = "__null__"


class KnowledgeRepository(ABC):

    @abstractmethod
    def list(
        self,
        platform: Optional[str] = None,
        project: Optional[str] = None,
        discipline: Optional[str] = None,
        artifact: Optional[str] = None,
        topic: Optional[str] = None,
    ) -> list[KnowledgeNode]:
        """Return metadata-only nodes matching all supplied filters (no content)."""

    @abstractmethod
    def fetch_exact(
        self,
        platform: Optional[str],
        project: Optional[str],
        discipline: str,
        artifact: Optional[str],
        topic: str,
        pattern: str,
    ) -> Optional[KnowledgeNode]:
        """Fetch one node with full content. No cascade — exact match only."""

    @abstractmethod
    def query(
        self,
        text: str,
        where: Optional[dict] = None,
        n_results: int = 5,
    ) -> list[KnowledgeNode]:
        """Semantic search. Returns nodes with content, ranked by similarity."""

    @abstractmethod
    def upsert(self, node: KnowledgeNode) -> None:
        """Write or overwrite a node. node.content must be set."""
