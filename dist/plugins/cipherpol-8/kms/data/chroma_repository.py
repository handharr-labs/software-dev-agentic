from __future__ import annotations
import json
from typing import Optional

import chromadb
from chromadb.config import Settings

from ..domain.entities import KnowledgeNode
from ..domain.repository import KnowledgeRepository, NULL_SENTINEL

_COLLECTION = "knowledge"
_NULL = "null"  # ChromaDB metadata can't store None; sentinel string used instead.


def _to_meta(node: KnowledgeNode) -> dict:
    return {
        "scope":          node.scope,
        "platform":       node.platform or _NULL,
        "project":        node.project or _NULL,
        "discipline":     node.discipline,
        "artifact":       node.artifact or _NULL,
        "topic":          node.topic,
        "pattern":        node.pattern,
        "summary":        node.summary,
        "tags":           json.dumps(node.tags),
        "source_file":    node.source_file or "",
        "updated_at":     node.updated_at or "",
        "content_hash":   node.content_hash or "",
        "content_type":   node.content_type,
        "schema_version": "1",
    }


def _build_where(filters: dict) -> Optional[dict]:
    """Wrap multiple equality filters in $and as required by ChromaDB."""
    if not filters:
        return None
    clauses = [{k: {"$eq": v}} for k, v in filters.items()]
    return clauses[0] if len(clauses) == 1 else {"$and": clauses}


def _from_meta(meta: dict, content: Optional[str] = None) -> KnowledgeNode:
    return KnowledgeNode(
        scope=meta.get("scope", "universal"),
        platform=None if meta.get("platform") == _NULL else meta.get("platform"),
        project=None if meta.get("project") == _NULL else meta.get("project"),
        discipline=meta["discipline"],
        artifact=None if meta.get("artifact") == _NULL else meta.get("artifact"),
        topic=meta["topic"],
        pattern=meta["pattern"],
        summary=meta.get("summary", ""),
        tags=json.loads(meta.get("tags", "[]")),
        source_file=meta.get("source_file") or None,
        updated_at=meta.get("updated_at") or None,
        content_hash=meta.get("content_hash") or None,
        content=content,
        content_type=meta.get("content_type", "real"),
    )


class ChromaKnowledgeRepository(KnowledgeRepository):

    def __init__(self, db_path: str) -> None:
        self._client = chromadb.PersistentClient(
            path=db_path,
            settings=Settings(anonymized_telemetry=False),
        )
        self._col = self._client.get_or_create_collection(_COLLECTION)

    # ------------------------------------------------------------------
    def list(
        self,
        platform: Optional[str] = None,
        project: Optional[str] = None,
        discipline: Optional[str] = None,
        artifact: Optional[str] = None,
        topic: Optional[str] = None,
    ) -> list[KnowledgeNode]:
        def _resolve(v: Optional[str]) -> Optional[str]:
            if v is None:
                return None           # no filter
            return _NULL if v == NULL_SENTINEL else v

        where: dict = {}
        pf = _resolve(platform)
        if pf is not None:
            where["platform"] = pf
        pj = _resolve(project)
        if pj is not None:
            where["project"] = pj
        if discipline is not None:
            where["discipline"] = discipline
        if artifact is not None:
            where["artifact"] = artifact
        if topic is not None:
            where["topic"] = topic

        result = self._col.get(
            where=_build_where(where),
            include=["metadatas"],
        )
        return [_from_meta(m) for m in (result["metadatas"] or [])]

    # ------------------------------------------------------------------
    def fetch_exact(
        self,
        platform: Optional[str],
        project: Optional[str],
        discipline: str,
        artifact: Optional[str],
        topic: str,
        pattern: str,
    ) -> Optional[KnowledgeNode]:
        where = {
            "platform":   platform or _NULL,
            "project":    project or _NULL,
            "discipline": discipline,
            "artifact":   artifact or _NULL,
            "topic":      topic,
            "pattern":    pattern,
        }
        result = self._col.get(where=_build_where(where), include=["metadatas", "documents"])
        metadatas = result.get("metadatas") or []
        documents = result.get("documents") or []
        if not metadatas:
            return None
        return _from_meta(metadatas[0], content=documents[0] if documents else None)

    # ------------------------------------------------------------------
    def query(
        self,
        text: str,
        where: Optional[dict] = None,
        n_results: int = 5,
    ) -> list[KnowledgeNode]:
        kwargs: dict = {
            "query_texts": [text],
            "n_results": min(n_results, self._col.count() or 1),
            "include": ["metadatas", "documents", "distances"],
        }
        built_where = _build_where(where) if where else None
        if built_where:
            kwargs["where"] = built_where

        result = self._col.query(**kwargs)
        nodes = []
        metadatas = (result.get("metadatas") or [[]])[0]
        documents = (result.get("documents") or [[]])[0]
        for meta, doc in zip(metadatas, documents):
            nodes.append(_from_meta(meta, content=doc))
        return nodes

    # ------------------------------------------------------------------
    def upsert(self, node: KnowledgeNode) -> None:
        self._col.upsert(
            ids=[node.id],
            documents=[node.content],
            metadatas=[_to_meta(node)],
        )
