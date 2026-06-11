"""
KMS MCP server — exposes kms_list, kms_fetch, kms_query, kms_upsert.

Run:
  KMS_DB_PATH=/path/to/chroma python -m kms.application.mcp_server

Logging (opt-in):
  CP8_ENABLE_LOGGING=true   enable usage log
  KMS_LOG_PATH=<path>       log file path (default: <db_parent>/logs/kms-usage.log)
  CP8_LOG_MAX_MB=<n>        rotate when log exceeds this size in MB (default: 10)
"""
from __future__ import annotations
import os
import sys
import time
from datetime import datetime, timezone
from typing import Optional

from mcp.server.fastmcp import FastMCP

# Allow running from the kms/ package root.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from kms.data.chroma_repository import ChromaKnowledgeRepository
from kms.domain.use_cases.fetch_knowledge import FetchKnowledge
from kms.domain.use_cases.list_knowledge import ListKnowledge
from kms.domain.use_cases.query_knowledge import QueryKnowledge
from kms.domain.use_cases.upsert_knowledge import UpsertKnowledge
from kms.domain.entities import KnowledgeNode

_db_path = os.environ.get("KMS_DB_PATH", os.path.join(os.path.dirname(__file__), "..", "db"))
_db_path_abs = os.path.abspath(_db_path)
_repo = ChromaKnowledgeRepository(db_path=_db_path_abs)

# --- Usage logger ---
_enable_logging = os.environ.get("CP8_ENABLE_LOGGING", "false").lower() == "true"
_log_max_bytes = float(os.environ.get("CP8_LOG_MAX_MB", "10")) * 1024 * 1024
_log_path = os.path.abspath(
    os.environ.get(
        "KMS_LOG_PATH",
        os.path.join(os.path.dirname(_db_path_abs), "logs", "kms-usage.log"),
    )
)


def _summarize_result(tool: str, result) -> str:
    if tool == "kms_list":
        if not result:
            return "count=0"
        ids = [r.get("id", "") for r in result[:5]]
        return f"count={len(result)}  top_ids=[{', '.join(ids)}]"
    if tool == "kms_fetch":
        if not result:
            return "found=false"
        content_chars = len(result.get("content") or "")
        return f"id={result.get('id')}  content_chars={content_chars}"
    if tool == "kms_query":
        if not result:
            return "count=0"
        ids = [r.get("id", "") for r in result[:5]]
        return f"count={len(result)}  hits=[{', '.join(ids)}]"
    return ""


def _log(tool: str, inputs: dict, result_count: int, latency_ms: float, result=None) -> None:
    if not _enable_logging:
        return
    try:
        os.makedirs(os.path.dirname(_log_path), exist_ok=True)
        if os.path.isfile(_log_path) and os.path.getsize(_log_path) > _log_max_bytes:
            os.replace(_log_path, _log_path + ".old")
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        inputs_str = "  ".join(f"{k}={v}" for k, v in inputs.items() if v is not None)
        result_str = _summarize_result(tool, result)
        lines = [
            f"{'─' * 60}",
            f"{ts}  {tool}  {round(latency_ms, 1)}ms",
            f"inputs:  {inputs_str or '-'}",
        ]
        if result_str:
            lines.append(f"result:  {result_str}")
        lines.append("")
        with open(_log_path, "a") as f:
            f.write("\n".join(lines) + "\n")
    except Exception:
        pass

_list_uc = ListKnowledge(_repo)
_fetch_uc = FetchKnowledge(_repo)
_query_uc = QueryKnowledge(_repo)
_upsert_uc = UpsertKnowledge(_repo)

_knowledge_dir = os.environ.get("KMS_KNOWLEDGE_DIR", os.path.join(os.path.dirname(__file__), "..", "..", "knowledge"))
_knowledge_dir_abs = os.path.abspath(_knowledge_dir)

mcp = FastMCP("cp8")


@mcp.tool()
def kms_info() -> dict:
    """
    Return diagnostic info about this KMS server instance.
    Call this from kms-status to verify the plugin shipped correctly:
    - db_path: ChromaDB directory the server is reading from
    - db_exists: whether the chroma directory is present
    - total_nodes: total node count in the DB
    - knowledge_dir: fallback markdown directory shipped with the plugin
    - knowledge_exists: whether the knowledge directory is present
    - knowledge_files: count of pattern .md files (excludes index.md)
    """
    import glob as _glob
    db_exists = os.path.isdir(_db_path_abs)
    knowledge_exists = os.path.isdir(_knowledge_dir_abs)
    knowledge_files = len([
        f for f in _glob.glob(os.path.join(_knowledge_dir_abs, "**", "*.md"), recursive=True)
        if os.path.basename(f) != "index.md"
    ]) if knowledge_exists else 0
    try:
        total_nodes = _repo._col.count()
    except Exception:
        total_nodes = -1
    return {
        "db_path":         _db_path_abs,
        "db_exists":       db_exists,
        "total_nodes":     total_nodes,
        "knowledge_dir":   _knowledge_dir_abs,
        "knowledge_exists": knowledge_exists,
        "knowledge_files": knowledge_files,
    }


@mcp.tool()
def kms_list(
    platform: Optional[str] = None,
    project: Optional[str] = None,
    discipline: Optional[str] = None,
    artifact: Optional[str] = None,
    topic: Optional[str] = None,
) -> list[dict]:
    """
    Return a scoped table of contents — metadata only, no content.
    Merges project-specific + platform-base + universal nodes; more specific overrides less specific
    when (discipline, artifact, topic, pattern) collides.
    Use this as Step 0 before kms_fetch — reason over the TOC to decide what to fetch.
    """
    t0 = time.monotonic()
    nodes = _list_uc.execute(platform=platform, project=project, discipline=discipline, artifact=artifact, topic=topic)
    result = [
        {
            "id":         n.id,
            "platform":   n.platform,
            "project":    n.project,
            "discipline": n.discipline,
            "artifact":   n.artifact,
            "topic":      n.topic,
            "pattern":    n.pattern,
            "summary":    n.summary,
            "tags":       n.tags,
        }
        for n in nodes
    ]
    _log("kms_list", {"platform": platform, "project": project, "discipline": discipline, "artifact": artifact, "topic": topic}, len(nodes), (time.monotonic() - t0) * 1000, result)
    return result


@mcp.tool()
def kms_fetch(
    discipline: str,
    artifact: str,
    topic: str,
    pattern: str,
    platform: Optional[str] = None,
    project: Optional[str] = None,
) -> Optional[dict]:
    """
    Fetch a single knowledge node with full content.
    Applies cascade resolution: project-specific → platform-base → universal.
    Returns None if no node matches anywhere in the cascade.
    """
    t0 = time.monotonic()
    node = _fetch_uc.execute(
        discipline=discipline,
        artifact=artifact,
        topic=topic,
        pattern=pattern,
        platform=platform,
        project=project,
    )
    result = None if node is None else {
        "id":          node.id,
        "platform":    node.platform,
        "project":     node.project,
        "discipline":  node.discipline,
        "artifact":    node.artifact,
        "topic":       node.topic,
        "pattern":     node.pattern,
        "summary":     node.summary,
        "tags":        node.tags,
        "source_file": node.source_file,
        "updated_at":  node.updated_at,
        "content":     node.content,
    }
    _log("kms_fetch", {"discipline": discipline, "artifact": artifact, "topic": topic, "pattern": pattern, "platform": platform, "project": project}, 1 if node else 0, (time.monotonic() - t0) * 1000, result)
    return result


@mcp.tool()
def kms_query(
    text: str,
    platform: Optional[str] = None,
    discipline: Optional[str] = None,
    n_results: int = 5,
) -> list[dict]:
    """
    Semantic search across the knowledge store.
    Use when the agent doesn't know which topic/pattern it needs — intent-based discovery.
    Optional platform and discipline filters narrow the search scope.
    Returns top-k nodes with full content, ranked by similarity.
    """
    where: dict = {}
    if platform:
        where["platform"] = platform
    if discipline:
        where["discipline"] = discipline

    t0 = time.monotonic()
    nodes = _query_uc.execute(text=text, where=where or None, n_results=n_results)
    result = [
        {
            "id":         n.id,
            "discipline": n.discipline,
            "topic":      n.topic,
            "pattern":    n.pattern,
            "summary":    n.summary,
            "content":    n.content,
        }
        for n in nodes
    ]
    _log("kms_query", {"text": text, "platform": platform, "discipline": discipline, "n_results": n_results}, len(nodes), (time.monotonic() - t0) * 1000, result)
    return result


@mcp.tool()
def kms_upsert(
    platform: Optional[str],
    project: Optional[str],
    discipline: str,
    topic: str,
    pattern: str,
    content: str,
    summary: str = "",
    tags: list[str] = [],
    source_file: Optional[str] = None,
    updated_at: Optional[str] = None,
) -> dict:
    """
    Write or overwrite a knowledge node.
    Used by the dashboard (live edits) and the scan agent (code_pattern extraction).
    content must be the full document body (## Theory ... ## Definition ... ## Code Pattern ...).
    """
    from datetime import date
    node = KnowledgeNode(
        platform=platform,
        project=project,
        discipline=discipline,
        topic=topic,
        pattern=pattern,
        content=content,
        summary=summary,
        tags=list(tags),
        source_file=source_file,
        updated_at=updated_at or date.today().isoformat(),
    )
    t0 = time.monotonic()
    _upsert_uc.execute(node)
    _log("kms_upsert", {"platform": platform, "project": project, "discipline": discipline, "topic": topic, "pattern": pattern}, 1, (time.monotonic() - t0) * 1000)
    return {"id": node.id, "status": "ok"}


if __name__ == "__main__":
    mcp.run()
