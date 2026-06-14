"""
KMS Dashboard HTTP server — local web UI mirroring kms_list / kms_fetch / kms_query MCP tools.

Run via: bash scripts/kms-dashboard.sh [port]
Or directly: KMS_DB_PATH=... python -m kms.dashboard.server [port]
"""
from __future__ import annotations
import json
import os
import sys
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from kms.data.chroma_repository import ChromaKnowledgeRepository
from kms.domain.entities import KnowledgeNode
from kms.domain.use_cases.fetch_knowledge import FetchKnowledge
from kms.domain.use_cases.list_knowledge import ListKnowledge
from kms.domain.use_cases.query_knowledge import QueryKnowledge
from kms.domain.use_cases.upsert_knowledge import UpsertKnowledge

_REPO_ROOT = os.environ.get(
    "KMS_REPO_ROOT",
    os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")),
)
_DB_PATH = os.environ.get(
    "KMS_DB_PATH",
    os.path.join(_REPO_ROOT, "dist", ".kms_seeds", ".shared", "chroma"),
)
_STATIC = os.path.join(os.path.dirname(__file__), "index.html")

_repo = ChromaKnowledgeRepository(db_path=os.path.abspath(_DB_PATH))
_list_uc = ListKnowledge(_repo)
_fetch_uc = FetchKnowledge(_repo)
_query_uc = QueryKnowledge(_repo)
_upsert_uc = UpsertKnowledge(_repo)


def _fetch_by_id(node_id: str):
    """
    Direct ID lookup — fallback for old-schema nodes where area/artifact/subtopic are absent
    and fetch_exact's where-clause returns empty.

    Old stored format (5 parts): platform:project:discipline:topic:pattern
    New computed format (8 parts): platform:project:discipline:area:artifact:topic:subtopic:pattern
    """
    from kms.data.chroma_repository import _from_meta

    def _try(id_: str):
        r = _repo._col.get(ids=[id_], include=["metadatas", "documents"])
        metas = r.get("metadatas") or []
        docs  = r.get("documents") or []
        return _from_meta(metas[0], content=docs[0] if docs else None) if metas else None

    node = _try(node_id)
    if node is not None:
        return node

    # Reconstruct old 5-part ID from new 8-part: keep parts [0,1,2,5,7] (plt:prj:dis:topic:pattern)
    parts = node_id.split(":")
    if len(parts) == 8:
        old_id = ":".join([parts[0], parts[1], parts[2], parts[5], parts[7]])
        return _try(old_id)

    return None


def _bump_version() -> None:
    version_file = os.path.join(_REPO_ROOT, "dist", ".kms_seeds", ".version")
    os.makedirs(os.path.dirname(version_file), exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    with open(version_file, "w") as f:
        f.write(f"dashboard:{ts}")


# Exactly mirrors kms_list MCP response shape.
def _node_list_dict(n: KnowledgeNode) -> dict:
    return {
        "id":         n.id,
        "platform":   n.platform,
        "project":    n.project,
        "scope":      n.scope,
        "discipline": n.discipline,
        "area":       n.area,
        "artifact":   n.artifact,
        "topic":      n.topic,
        "subtopic":   n.subtopic,
        "pattern":    n.pattern,
        "summary":    n.summary,
        "tags":       n.tags,
    }


# Exactly mirrors kms_fetch MCP response shape.
def _node_fetch_dict(n: KnowledgeNode) -> dict:
    return {
        "id":          n.id,
        "platform":    n.platform,
        "project":     n.project,
        "scope":       n.scope,
        "discipline":  n.discipline,
        "area":        n.area,
        "artifact":    n.artifact,
        "topic":       n.topic,
        "subtopic":    n.subtopic,
        "pattern":     n.pattern,
        "summary":     n.summary,
        "tags":        n.tags,
        "source_file": n.source_file,
        "updated_at":  n.updated_at,
        "content":     n.content,
    }


# Exactly mirrors kms_query MCP response shape.
def _node_query_dict(n: KnowledgeNode) -> dict:
    return {
        "id":         n.id,
        "discipline": n.discipline,
        "area":       n.area,
        "topic":      n.topic,
        "subtopic":   n.subtopic,
        "pattern":    n.pattern,
        "summary":    n.summary,
        "content":    n.content,
    }


class _Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):  # noqa: A002
        pass

    def _send(self, status: int, body: bytes, content_type: str = "application/json") -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _json(self, data, status: int = 200) -> None:
        self._send(status, json.dumps(data).encode())

    def _read_body(self) -> dict:
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length)
        return json.loads(raw) if raw else {}

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        qs = parse_qs(parsed.query)

        def q(key):
            return qs.get(key, [None])[0]

        if parsed.path in ("/", "/index.html"):
            with open(_STATIC, "rb") as f:
                data = f.read()
            self._send(200, data, "text/html; charset=utf-8")
            return

        # Mirrors kms_list MCP tool.
        if parsed.path == "/api/list":
            nodes = _list_uc.execute(
                platform=q("platform"),
                project=q("project"),
                discipline=q("discipline"),
                area=q("area"),
                artifact=q("artifact"),
                topic=q("topic"),
                subtopic=q("subtopic"),
            )
            self._json([_node_list_dict(n) for n in nodes])
            return

        # Mirrors kms_fetch MCP tool.
        # Falls back to direct ID lookup for old-schema nodes missing area/artifact/subtopic.
        if parsed.path == "/api/fetch":
            node = _fetch_uc.execute(
                discipline=q("discipline") or "",
                area=q("area") or "",
                artifact=q("artifact"),
                topic=q("topic") or "",
                subtopic=q("subtopic") or q("pattern") or "",
                pattern=q("pattern") or "",
                platform=q("platform"),
                project=q("project"),
            )
            if node is None and q("id"):
                node = _fetch_by_id(q("id"))
            if node is None:
                self._json({"error": "not found"}, 404)
            else:
                self._json(_node_fetch_dict(node))
            return

        self._send(404, b"Not found", "text/plain")

    def do_POST(self):
        parsed = urlparse(self.path)
        body = self._read_body()

        # Mirrors kms_query MCP tool.
        if parsed.path == "/api/query":
            text = body.get("text", "")
            where: dict = {}
            if body.get("platform"):
                where["platform"] = body["platform"]
            if body.get("discipline"):
                where["discipline"] = body["discipline"]
            if body.get("area"):
                where["area"] = body["area"]
            n_results = int(body.get("n_results", 5))
            nodes = _query_uc.execute(text=text, where=where or None, n_results=n_results)
            self._json([_node_query_dict(n) for n in nodes])
            return

        # Mirrors kms_upsert MCP tool.
        if parsed.path == "/api/upsert":
            try:
                from datetime import date
                platform = body.get("platform") or None
                project  = body.get("project") or None
                scope    = "project" if project else "platform" if platform else "universal"
                pattern  = body["pattern"]
                node = KnowledgeNode(
                    scope=scope,
                    platform=platform,
                    project=project,
                    discipline=body["discipline"],
                    area=body.get("area") or "",
                    artifact=body.get("artifact") or None,
                    topic=body["topic"],
                    subtopic=body.get("subtopic") or pattern,
                    pattern=pattern,
                    content=body.get("content", ""),
                    summary=body.get("summary", ""),
                    tags=list(body.get("tags") or []),
                    source_file=body.get("source_file"),
                    updated_at=body.get("updated_at") or date.today().isoformat(),
                )
                _upsert_uc.execute(node)
                _bump_version()
                self._json({"id": node.id, "status": "ok"})
            except (KeyError, TypeError) as exc:
                self._json({"error": str(exc)}, 400)
            return

        self._send(404, b"Not found", "text/plain")


def main(port: int = 5173) -> None:
    server = HTTPServer(("127.0.0.1", port), _Handler)
    print(f"KMS Dashboard → http://localhost:{port}")
    print(f"  DB:   {_DB_PATH}")
    print(f"  Repo: {_REPO_ROOT}")
    print("  Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5173
    main(port)
