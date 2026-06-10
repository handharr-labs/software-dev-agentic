"""
KMS Dashboard HTTP server — local web UI for browsing and editing knowledge nodes.

Run via: bash scripts/kms-dashboard.sh [port]
Or directly: KMS_DB_PATH=... KMS_REPO_ROOT=... python -m kms.dashboard.server [port]
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


def _bump_version() -> None:
    version_file = os.path.join(_REPO_ROOT, "dist", ".kms_seeds", ".version")
    os.makedirs(os.path.dirname(version_file), exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    with open(version_file, "w") as f:
        f.write(f"dashboard:{ts}")


class _Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):  # noqa: A002
        pass  # suppress per-request noise; errors still surfaced via sys.stderr

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

        if parsed.path == "/api/list":
            nodes = _list_uc.execute(
                platform=q("platform"), project=q("project"),
                discipline=q("discipline"), topic=q("topic"),
            )
            self._json([{
                "id": n.id, "platform": n.platform, "project": n.project,
                "discipline": n.discipline, "topic": n.topic, "pattern": n.pattern,
                "summary": n.summary, "tags": n.tags,
            } for n in nodes])
            return

        if parsed.path == "/api/fetch":
            node = _fetch_uc.execute(
                discipline=q("discipline") or "",
                topic=q("topic") or "",
                pattern=q("pattern") or "",
                platform=q("platform"),
                project=q("project"),
            )
            if node is None:
                self._json({"error": "not found"}, 404)
            else:
                self._json({
                    "id": node.id, "platform": node.platform, "project": node.project,
                    "discipline": node.discipline, "topic": node.topic, "pattern": node.pattern,
                    "summary": node.summary, "tags": node.tags,
                    "source_file": node.source_file, "updated_at": node.updated_at,
                    "content": node.content,
                })
            return

        self._send(404, b"Not found", "text/plain")

    def do_POST(self):
        parsed = urlparse(self.path)
        body = self._read_body()

        if parsed.path == "/api/query":
            text = body.get("text", "")
            where: dict = {}
            if body.get("platform"):
                where["platform"] = body["platform"]
            if body.get("discipline"):
                where["discipline"] = body["discipline"]
            n_results = int(body.get("n_results", 8))
            nodes = _query_uc.execute(text=text, where=where or None, n_results=n_results)
            self._json([{
                "id": n.id, "platform": n.platform, "project": n.project,
                "discipline": n.discipline, "topic": n.topic, "pattern": n.pattern,
                "summary": n.summary, "content": n.content,
            } for n in nodes])
            return

        if parsed.path == "/api/upsert":
            try:
                node = KnowledgeNode(
                    platform=body.get("platform") or None,
                    project=body.get("project") or None,
                    discipline=body["discipline"],
                    topic=body["topic"],
                    pattern=body["pattern"],
                    content=body.get("content", ""),
                    summary=body.get("summary", ""),
                    tags=list(body.get("tags") or []),
                    source_file=body.get("source_file"),
                    updated_at=body.get("updated_at") or datetime.now(timezone.utc).date().isoformat(),
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
