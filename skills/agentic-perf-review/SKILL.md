---
name: agentic-perf-review
description: Analyze the agentic performance of a Claude session — scores orchestration, worker/skill routing, token efficiency, workflow compliance, and one-shot rate. Writes a numeric-scored report to journey/ and commits it.
user-invocable: true
allowed-tools: Bash, Agent
---

You are running a post-session agentic performance review.

## Arguments

Parse the user's invocation:

```
/agentic-perf-review <issue_number> [session_id]
```

- `issue_number` — required. The GitHub issue number this session addressed (e.g. `55`).
- `session_id` — optional. The Claude session UUID to analyze. If omitted, use the current (most recently active) session for this project.

## Step 1 — Validate inputs

If `issue_number` is missing, stop and ask: `Usage: /agentic-perf-review <issue_number> [session_id]`

Capture:
- `PROJECT_PATH` = current working directory (run `pwd` if needed)
- `ISSUE_NUMBER` = the issue number provided
- `SESSION_ID` = provided value, or empty string if not provided

## Step 2 — Extract session data

Run the extraction script:

```bash
# With explicit session ID:
.claude/web-agentic/scripts/extract-session.sh "$PROJECT_PATH" "$SESSION_ID"

# Without session ID (auto = current session):
.claude/web-agentic/scripts/extract-session.sh "$PROJECT_PATH"
```

The script prints the path to the extracted JSON file (e.g. `/tmp/perf-<session_id>.json`).

If the script fails, show the error and stop.

## Step 3 — Spawn perf-worker

Spawn the `perf-worker` agent with this exact prompt (fill in the values):

```
Analyze agentic performance for issue #<ISSUE_NUMBER>.

EXTRACTED_JSON: <path from step 2>
ISSUE_NUMBER: <ISSUE_NUMBER>
PROJECT_PATH: <PROJECT_PATH>

Follow the full perf-worker instructions to score all dimensions, write the report to journey/, and commit it.
```

## Step 4 — Report back

When perf-worker completes, tell the user:
- The report file path
- The overall score
- The top 1–2 recommendations
