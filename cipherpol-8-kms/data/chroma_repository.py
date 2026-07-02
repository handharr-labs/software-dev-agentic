from __future__ import annotations
import json
from typing import Optional

import chromadb
from chromadb.config import Settings

from ..domain.entities import KnowledgeNode
from ..domain.repository import KnowledgeRepository, NULL_SENTINEL
from ..domain.schema import SCHEMA_VERSION

_COLLECTION = "knowledge"
_NULL = "null"  # ChromaDB metadata can't store None; sentinel string used instead.

# Contextual retrieval: the embedded document is prefixed with a short, deterministic
# context line built from metadata (no seed-time LLM — hash-stable). The marker lets us
# strip the prefix on read so agents see clean content while the vector carries taxonomy.
_CTX_MARKER = "<!-- kms:ctx -->"


def _context_prefix(node: KnowledgeNode) -> str:
    lead = " / ".join(p for p in (node.platform, node.discipline, node.layer, node.artifact) if p)
    section = (node.subtopic or node.pattern or "").replace("_", " ")
    return f"{_CTX_MARKER} {lead} — {section}".strip()


def _embed_document(node: KnowledgeNode) -> str:
    """Document actually stored + embedded: context prefix + body."""
    return f"{_context_prefix(node)}\n\n{node.content or ''}"


def _strip_ctx(document: Optional[str]) -> Optional[str]:
    """Remove the context prefix so callers get the original body."""
    if document and document.startswith(_CTX_MARKER):
        parts = document.split("\n\n", 1)
        return parts[1] if len(parts) == 2 else ""
    return document


def _to_meta(node: KnowledgeNode) -> dict:
    return {
        "scope":          node.scope,
        "platform":       node.platform or _NULL,
        "project":        node.project or _NULL,
        "discipline":     node.discipline,
        "layer":          node.layer or _NULL,
        "owner":          node.owner,
        "artifact":       node.artifact or _NULL,
        "topic":          node.topic,
        "subtopic":       node.subtopic or node.pattern,
        "pattern":        node.pattern,
        "summary":        node.summary,
        "tags":           json.dumps(node.tags),
        "source_file":    node.source_file or "",
        "updated_at":     node.updated_at or "",
        "content_hash":   node.content_hash or "",
        "content_type":   node.content_type,
        "schema_version": SCHEMA_VERSION,
    }


def _build_where(filters: dict) -> Optional[dict]:
    """Wrap multiple filters in $and as required by ChromaDB.

    A scalar value is treated as equality; a dict value is passed through as an
    explicit operator expression (e.g. {"layer": {"$in": ["domain", "cross"]}}) so
    callers can express agent-scope filters like layer ∈ {domain, cross}.
    """
    if not filters:
        return None
    clauses = [{k: (v if isinstance(v, dict) else {"$eq": v})} for k, v in filters.items()]
    return clauses[0] if len(clauses) == 1 else {"$and": clauses}


def _from_meta(meta: dict, content: Optional[str] = None) -> KnowledgeNode:
    return KnowledgeNode(
        scope=meta.get("scope", "universal"),
        platform=None if meta.get("platform") == _NULL else meta.get("platform"),
        project=None if meta.get("project") == _NULL else meta.get("project"),
        discipline=meta["discipline"],
        layer=None if meta.get("layer") == _NULL else meta.get("layer"),
        owner=meta.get("owner", "curated"),
        artifact=None if meta.get("artifact") == _NULL else meta.get("artifact"),
        topic=meta["topic"],
        subtopic=meta.get("subtopic") or meta.get("pattern", ""),
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

    def __init__(self, db_path: str, collection: str = _COLLECTION) -> None:
        self._client = chromadb.PersistentClient(
            path=db_path,
            settings=Settings(anonymized_telemetry=False),
        )
        self._col = self._client.get_or_create_collection(collection)

    # ------------------------------------------------------------------
    def list(
        self,
        platform: Optional[str] = None,
        project: Optional[str] = None,
        discipline: Optional[str] = None,
        artifact: Optional[str] = None,
        topic: Optional[str] = None,
        subtopic: Optional[str] = None,
        layer: Optional[str] = None,
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
        if subtopic is not None:
            where["subtopic"] = subtopic
        if layer is not None:
            # scope to the requested layer OR cross-cutting knowledge
            where["layer"] = {"$in": [layer, "cross"]}

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
        subtopic: str,
        pattern: str,
    ) -> Optional[KnowledgeNode]:
        where = {
            "platform":   platform or _NULL,
            "project":    project or _NULL,
            "discipline": discipline,
            "artifact":   artifact or _NULL,
            "topic":      topic,
            "subtopic":   subtopic or pattern,
            "pattern":    pattern,
        }
        result = self._col.get(where=_build_where(where), include=["metadatas", "documents"])
        metadatas = result.get("metadatas") or []
        documents = result.get("documents") or []
        if not metadatas:
            return None
        return _from_meta(metadatas[0], content=_strip_ctx(documents[0]) if documents else None)

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
            nodes.append(_from_meta(meta, content=_strip_ctx(doc)))
        return nodes

    # ------------------------------------------------------------------
    def upsert(self, node: KnowledgeNode) -> None:
        self._col.upsert(
            ids=[node.id],
            documents=[_embed_document(node)],
            metadatas=[_to_meta(node)],
        )
