"""
Unified KMS seed runner.

Usage:
  # Seed all available sources registered in sources.yaml
  python -m kms.scripts.seed_kms --db-path /path/to/chroma

  # Seed a single registered source
  python -m kms.scripts.seed_kms --db-path /path --source flutter-base-knowledge

  # Seed all sources of a given type
  python -m kms.scripts.seed_kms --db-path /path --type markdown

  # Detect, seed, and register a new source in one step
  python -m kms.scripts.seed_kms --db-path /path --add /path/to/repo
  python -m kms.scripts.seed_kms --db-path /path --add https://confluence.example.com/pages/123
"""
from __future__ import annotations
import argparse
import os
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

import yaml

from kms.data.chroma_repository import ChromaKnowledgeRepository
from kms.domain.schema import SOURCE_TYPE_OWNS
from kms.domain.sources.base import KnowledgeSource
from kms.domain.sources.codebase import CodebaseSource
from kms.domain.sources.confluence import ConfluenceSource
from kms.domain.sources.directory import DirectorySource
from kms.domain.sources.markdown import MarkdownSource
from kms.domain.use_cases.upsert_knowledge import UpsertKnowledge

_SOURCES_YAML = Path(__file__).resolve().parent.parent / "sources.yaml"


# ---------------------------------------------------------------------------
# Source registry I/O
# ---------------------------------------------------------------------------

def _load_sources_yaml() -> list[dict]:
    if not _SOURCES_YAML.exists():
        return []
    with _SOURCES_YAML.open() as f:
        data = yaml.safe_load(f) or {}
    return data.get("sources", [])


def _save_sources_yaml(sources: list[dict]) -> None:
    with _SOURCES_YAML.open("w") as f:
        yaml.dump({"sources": sources}, f, default_flow_style=False, allow_unicode=True)


# ---------------------------------------------------------------------------
# Adapter factory
# ---------------------------------------------------------------------------

def _build_adapter(entry: dict, repo_root: Path) -> KnowledgeSource | None:
    name = entry["name"]
    src_type = entry.get("type", "markdown")
    owns = entry.get("owns") or SOURCE_TYPE_OWNS.get(src_type, [])
    raw_path = entry.get("path")
    url = entry.get("url")

    if src_type == "directory":
        path = repo_root / raw_path if raw_path and not Path(raw_path).is_absolute() else raw_path
        return DirectorySource(name=name, path=str(path), owns=owns)

    if src_type == "markdown":
        path = repo_root / raw_path if raw_path and not Path(raw_path).is_absolute() else raw_path
        return MarkdownSource(name=name, path=str(path), owns=owns)

    if src_type == "codebase":
        path = raw_path or ""
        return CodebaseSource(name=name, path=str(path), owns=owns)

    if src_type == "confluence":
        return ConfluenceSource(name=name, url=url or "", owns=owns)

    print(f"  ⚠  Unknown source type '{src_type}' for '{name}' — skipped")
    return None


# ---------------------------------------------------------------------------
# Auto-detect for --add
# ---------------------------------------------------------------------------

def _detect_type(target: str) -> tuple[str, str]:
    """Return (source_type, location_key) from a path or URL."""
    if target.startswith("http"):
        if "confluence" in target:
            return "confluence", "url"
        return "codebase", "url"

    p = Path(target)
    if (p / "pubspec.yaml").exists():
        return "codebase", "path"
    if (p / "package.json").exists():
        return "codebase", "path"
    if list(p.glob("*.xcodeproj")):
        return "codebase", "path"
    # directory of raw docs (no codebase markers) → directory source
    if p.is_dir() and not any((p / f).exists() for f in ("pubspec.yaml", "package.json")):
        return "directory", "path"
    if list(p.rglob("*.md")):
        return "markdown", "path"
    return "directory", "path"


def _register_source(target: str, repo_root: Path) -> dict | None:
    src_type, loc_key = _detect_type(target)
    name = Path(target).name if not target.startswith("http") else target.split("/")[-1]
    owns = SOURCE_TYPE_OWNS.get(src_type, [])

    entry = {
        "name": name,
        "type": src_type,
        loc_key: target,
        "owns": owns,
        "last_seeded": None,
    }

    print(f"\nDetected source:")
    print(f"  name : {name}")
    print(f"  type : {src_type}")
    print(f"  {loc_key:5}: {target}")
    print(f"  owns : {owns}")
    answer = input("\nRegister and seed? [y/N/rename] ").strip().lower()

    if answer == "rename":
        entry["name"] = input("Name: ").strip()
        answer = "y"

    if answer != "y":
        print("Aborted.")
        return None

    sources = _load_sources_yaml()
    existing_names = {s["name"] for s in sources}
    if entry["name"] not in existing_names:
        sources.append(entry)
        _save_sources_yaml(sources)
        print(f"  Registered '{entry['name']}' in sources.yaml")

    return entry


# ---------------------------------------------------------------------------
# Core seed logic
# ---------------------------------------------------------------------------

def _seed_source(adapter: KnowledgeSource, upsert: UpsertKnowledge, repo: ChromaKnowledgeRepository, force: bool = False) -> tuple[int, int]:
    ok = skipped = 0
    for node in adapter.read():
        existing = repo.fetch_exact(node.platform, node.project, node.discipline, node.artifact, node.topic, node.pattern)
        if not force and existing and existing.content_hash and existing.content_hash == node.content_hash and existing.content:
            skipped += 1
            continue
        upsert.execute(node, owns=adapter.owns)
        ok += 1
    return ok, skipped


def seed(
    db_path: str,
    source_filter: str | None = None,
    type_filter: str | None = None,
    add_target: str | None = None,
    repo_root: Path | None = None,
    force: bool = False,
) -> None:
    repo_root = repo_root or Path(__file__).resolve().parent.parent.parent
    repo = ChromaKnowledgeRepository(db_path=os.path.abspath(db_path))
    upsert = UpsertKnowledge(repo)

    if add_target:
        entry = _register_source(add_target, repo_root)
        if entry is None:
            return
        entries = [entry]
    else:
        entries = _load_sources_yaml()
        if source_filter:
            entries = [e for e in entries if e["name"] == source_filter]
        if type_filter:
            entries = [e for e in entries if e.get("type") == type_filter]

    if not entries:
        print("No matching sources found.")
        return

    total_ok = total_skipped = total_failed = 0

    for entry in entries:
        adapter = _build_adapter(entry, repo_root)
        if adapter is None:
            total_failed += 1
            continue

        if not adapter.is_available():
            print(f"  ⚠  '{adapter.name}' unavailable — skipped (existing nodes preserved)")
            total_failed += 1
            continue

        print(f"  Seeding '{adapter.name}' ({adapter.source_type}) …")
        ok, skipped = _seed_source(adapter, upsert, repo, force=force)
        print(f"    → {ok} upserted, {skipped} unchanged")
        total_ok += ok
        total_skipped += skipped

        _mark_seeded(entry["name"])

    print(f"\nDone — {total_ok} upserted, {total_skipped} unchanged, {total_failed} sources skipped.")


def _mark_seeded(source_name: str) -> None:
    sources = _load_sources_yaml()
    for s in sources:
        if s["name"] == source_name:
            s["last_seeded"] = date.today().isoformat()
    _save_sources_yaml(sources)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--db-path", required=True)
    parser.add_argument("--source", help="Seed one registered source by name")
    parser.add_argument("--type", dest="src_type", help="Seed all sources of this type")
    parser.add_argument("--add", dest="add_target", help="Detect, register, and seed a new source")
    parser.add_argument("--force", action="store_true", help="Re-upsert all nodes even if content_hash matches")
    args = parser.parse_args()

    seed(
        db_path=args.db_path,
        source_filter=args.source,
        type_filter=args.src_type,
        add_target=args.add_target,
        force=args.force,
    )
