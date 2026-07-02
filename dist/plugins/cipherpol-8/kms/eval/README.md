# KMS Retrieval Eval

The measurement gate for the [knowledge-management redesign](../../docs/initiatives/2026-07-03-kms-knowledge-management-redesign.md) (migration **step 1a**). The full redesign is a *bet* that retrieval improves — this proves it, rather than eyeballing.

## Files

- `retrieval_cases.yaml` — ~10 realistic `(query → expected node)` cases, each with the scope filter an agent would pass. Grounded in real content in the current DB.
- `run_eval.py` — queries a ChromaDB collection per case, reports `recall@k` + `MRR`. Talks to Chroma directly (not the `kms` package) so it runs against any collection by name.
- `baseline.json` — recorded metrics for the **current** DB. Every later migration step must beat this.

## Usage

```bash
# Baseline the current DB
python3 cipherpol-8-kms/eval/run_eval.py --out cipherpol-8-kms/eval/baseline.json

# After the reseed, score the new-schema collection
python3 cipherpol-8-kms/eval/run_eval.py --collection knowledge_v2 --out candidate.json

# Gate: candidate must be ≥ baseline on recall@k AND MRR
python3 cipherpol-8-kms/eval/run_eval.py --compare cipherpol-8-kms/eval/baseline.json candidate.json
```

## Current baseline

`recall@5 = 0.80` · `MRR = 0.645` (1331 nodes, 10 cases). Two cases miss (`dependency_rule`, `entity` rank below top-5) — the concrete quality signal the redesign should improve.

## Extending

When the `layer` facet lands (migration step 2a/5), add `layer` to the `where` of relevant cases and re-baseline against a `layer`-aware collection. Keep cases grounded in nodes that actually exist — a case pointing at a phantom node silently counts as a miss.
