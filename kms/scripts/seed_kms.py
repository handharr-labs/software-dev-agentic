"""
Bootstrap ChromaDB from lib/core/knowledge/ pattern files.

Usage:
  python -m kms.scripts.seed_kms \\
    --knowledge-dir /path/to/lib/core/knowledge \\
    --db-path       /path/to/chroma

Each .md file must have YAML frontmatter with: platform, project (optional),
discipline, topic, pattern. Summary is extracted from the first sentence of
the ## Theory section.
"""
from __future__ import annotations
import argparse
import os
import re
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

import yaml

from kms.data.chroma_repository import ChromaKnowledgeRepository
from kms.domain.entities import KnowledgeNode
from kms.domain.use_cases.upsert_knowledge import UpsertKnowledge


_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_THEORY_SECTION_RE = re.compile(r"##\s+Theory\s*\n+(.*?)(?=\n##|\Z)", re.DOTALL)


def _parse_file(path: Path) -> KnowledgeNode | None:
    raw = path.read_text(encoding="utf-8")

    fm_match = _FRONTMATTER_RE.match(raw)
    if not fm_match:
        print(f"  skip (no frontmatter): {path}")
        return None

    try:
        meta = yaml.safe_load(fm_match.group(1))
    except yaml.YAMLError as e:
        print(f"  skip (YAML error): {path} — {e}")
        return None

    required = ("discipline", "topic", "pattern")
    if not all(meta.get(k) for k in required):
        print(f"  skip (missing fields): {path}")
        return None

    content = raw[fm_match.end():]
    summary = _extract_summary(content)

    return KnowledgeNode(
        platform=meta.get("platform") or None,
        project=meta.get("project") or None,
        discipline=meta["discipline"],
        topic=meta["topic"],
        pattern=meta["pattern"],
        summary=summary,
        tags=meta.get("tags") or [],
        source_file=str(path),
        updated_at=date.today().isoformat(),
        content=content.strip(),
    )


def _extract_summary(content: str) -> str:
    m = _THEORY_SECTION_RE.search(content)
    if not m:
        return ""
    first_sentence = re.split(r"(?<=[.!?])\s", m.group(1).strip(), maxsplit=1)[0]
    return first_sentence.strip()


def seed(knowledge_dir: str, db_path: str) -> None:
    repo = ChromaKnowledgeRepository(db_path=os.path.abspath(db_path))
    upsert = UpsertKnowledge(repo)

    root = Path(knowledge_dir)
    if not root.exists():
        print(f"ERROR: knowledge dir not found: {root}")
        sys.exit(1)

    md_files = list(root.rglob("*.md"))
    print(f"Found {len(md_files)} .md files in {root}")

    ok = skipped = 0
    for path in sorted(md_files):
        if path.name == "index.md":
            continue
        node = _parse_file(path)
        if node is None:
            skipped += 1
            continue
        upsert.execute(node)
        print(f"  upserted: {node.id}")
        ok += 1

    print(f"\nDone — {ok} upserted, {skipped} skipped.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--knowledge-dir", required=True)
    parser.add_argument("--db-path", required=True)
    args = parser.parse_args()
    seed(args.knowledge_dir, args.db_path)
