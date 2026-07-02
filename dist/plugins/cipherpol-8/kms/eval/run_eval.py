"""
KMS retrieval eval runner (migration step 1a).

Measures how well a ChromaDB collection retrieves the *expected* knowledge node
for a set of realistic agent queries. Reports recall@k and MRR — the gate the
full redesign must beat before cutover (see the redesign initiative doc).

Deliberately talks to ChromaDB directly (not the `kms` package) so it works
against any collection by name and is unaffected by the app's import layout.

Usage:
  python3 cipherpol-8-kms/eval/run_eval.py                         # current DB, collection "knowledge"
  python3 cipherpol-8-kms/eval/run_eval.py --collection knowledge_v2
  python3 cipherpol-8-kms/eval/run_eval.py -k 5 --out baseline.json

Compare two runs (baseline vs new schema):
  python3 .../run_eval.py --collection knowledge     --out baseline.json
  python3 .../run_eval.py --collection knowledge_v2  --out candidate.json
  python3 .../run_eval.py --compare baseline.json candidate.json
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import yaml

_HERE = Path(__file__).resolve().parent
_DEFAULT_DB = _HERE.parent / "db"
_DEFAULT_CASES = _HERE / "retrieval_cases.yaml"
_DEFAULT_COLLECTION = "knowledge"


# --------------------------------------------------------------------------- #
# Case loading + matching
# --------------------------------------------------------------------------- #

def _load_cases(path: Path) -> list[dict]:
    with path.open() as f:
        data = yaml.safe_load(f) or {}
    return data.get("cases", [])


def _build_where(filters: dict | None) -> dict | None:
    """Mirror ChromaKnowledgeRepository._build_where — $and-wrap multiple equalities."""
    if not filters:
        return None
    clauses = [{k: {"$eq": v}} for k, v in filters.items()]
    return clauses[0] if len(clauses) == 1 else {"$and": clauses}


def _matches(meta: dict, expectation: dict) -> bool:
    """A returned node matches when its source_file ends with `file` and its
    subtopic OR pattern equals `section`. Stable across the composite-id → uuid change."""
    src = meta.get("source_file") or ""
    if not src.endswith(expectation["file"]):
        return False
    section = expectation["section"]
    return meta.get("subtopic") == section or meta.get("pattern") == section


def _first_hit_rank(metadatas: list[dict], expect_any: list[dict]) -> int | None:
    """1-based rank of the first returned node matching any expectation, else None."""
    for rank, meta in enumerate(metadatas, start=1):
        if any(_matches(meta, e) for e in expect_any):
            return rank
    return None


# --------------------------------------------------------------------------- #
# Eval
# --------------------------------------------------------------------------- #

def run(db_path: Path, collection: str, cases_path: Path, k: int) -> dict:
    import chromadb
    from chromadb.config import Settings

    client = chromadb.PersistentClient(
        path=str(db_path), settings=Settings(anonymized_telemetry=False)
    )
    col = client.get_collection(collection)
    total = col.count()
    n_results = min(k, total) if total else k

    cases = _load_cases(cases_path)
    results = []
    for case in cases:
        res = col.query(
            query_texts=[case["query"]],
            n_results=n_results,
            where=_build_where(case.get("where")),
            include=["metadatas"],
        )
        metadatas = (res.get("metadatas") or [[]])[0]
        rank = _first_hit_rank(metadatas, case["expect_any"])
        results.append(
            {
                "id": case["id"],
                "hit": rank is not None and rank <= k,
                "rank": rank,
                "returned": len(metadatas),
            }
        )

    hits = [r for r in results if r["hit"]]
    recall_at_k = len(hits) / len(results) if results else 0.0
    mrr = sum(1.0 / r["rank"] for r in results if r["rank"]) / len(results) if results else 0.0

    return {
        "collection": collection,
        "k": k,
        "node_count": total,
        "cases": len(results),
        "recall_at_k": round(recall_at_k, 4),
        "mrr": round(mrr, 4),
        "per_case": results,
    }


# --------------------------------------------------------------------------- #
# Output
# --------------------------------------------------------------------------- #

def _print_report(summary: dict) -> None:
    print(f"\nCollection : {summary['collection']}  ({summary['node_count']} nodes)")
    print(f"Cases      : {summary['cases']}    k = {summary['k']}\n")
    print(f"  {'case':<40} {'hit':<5} {'rank':<5}")
    print(f"  {'-' * 40} {'-' * 5} {'-' * 5}")
    for r in summary["per_case"]:
        mark = "✓" if r["hit"] else "✗"
        rank = str(r["rank"]) if r["rank"] else "-"
        print(f"  {r['id']:<40} {mark:<5} {rank:<5}")
    print(f"\n  recall@{summary['k']} = {summary['recall_at_k']}    MRR = {summary['mrr']}\n")


def _compare(baseline_path: Path, candidate_path: Path) -> None:
    base = json.loads(baseline_path.read_text())
    cand = json.loads(candidate_path.read_text())
    print(f"\n{'metric':<12} {'baseline':<12} {'candidate':<12} {'Δ':<10}")
    print(f"{'-' * 12} {'-' * 12} {'-' * 12} {'-' * 10}")
    for metric in ("recall_at_k", "mrr", "node_count"):
        b, c = base.get(metric, 0), cand.get(metric, 0)
        delta = round(c - b, 4)
        arrow = "▲" if delta > 0 else ("▼" if delta < 0 else "=")
        print(f"{metric:<12} {b:<12} {c:<12} {arrow} {delta}")
    passed = cand.get("recall_at_k", 0) >= base.get("recall_at_k", 0) and cand.get("mrr", 0) >= base.get("mrr", 0)
    print(f"\nGate: candidate {'PASSES' if passed else 'FAILS'} (must be ≥ baseline on recall@k and MRR)\n")


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #

def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--db-path", type=Path, default=_DEFAULT_DB, help=f"ChromaDB path (default: {_DEFAULT_DB})")
    p.add_argument("--collection", default=_DEFAULT_COLLECTION, help=f"collection name (default: {_DEFAULT_COLLECTION})")
    p.add_argument("--cases", type=Path, default=_DEFAULT_CASES, help="eval cases YAML")
    p.add_argument("-k", type=int, default=5, help="top-k cutoff for recall (default: 5)")
    p.add_argument("--out", type=Path, help="write JSON summary to this path")
    p.add_argument("--compare", nargs=2, metavar=("BASELINE", "CANDIDATE"), type=Path,
                   help="compare two previously written JSON summaries and exit")
    args = p.parse_args()

    if args.compare:
        _compare(*args.compare)
        return

    summary = run(args.db_path, args.collection, args.cases, args.k)
    _print_report(summary)
    if args.out:
        args.out.write_text(json.dumps(summary, indent=2))
        print(f"  wrote {args.out}\n")


if __name__ == "__main__":
    main()
