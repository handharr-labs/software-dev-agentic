#!/usr/bin/env bash
# extract-session.sh — Parse a Claude Code session JSONL into structured JSON
#
# Usage:
#   extract-session.sh <project_path> [session_id]
#
# Output:
#   Writes JSON to /tmp/perf-<session_id>.json and prints the path to stdout.
#
# Examples:
#   extract-session.sh /Users/me/Workspace/wehire
#   extract-session.sh /Users/me/Workspace/wehire fc2d5f57-7b50-4133-b529-825070d52d1c

set -euo pipefail

PROJECT_PATH="${1:-$(pwd)}"
SESSION_ID="${2:-}"

# Derive the Claude project hash from the absolute path
PROJECT_HASH=$(echo "$PROJECT_PATH" | sed 's|/|-|g')
SESSIONS_DIR="$HOME/.claude/projects/${PROJECT_HASH}"

if [ ! -d "$SESSIONS_DIR" ]; then
  echo "ERROR: No Claude sessions directory found for: $PROJECT_PATH" >&2
  echo "  Expected: $SESSIONS_DIR" >&2
  exit 1
fi

if [ -n "$SESSION_ID" ]; then
  JSONL_FILE="$SESSIONS_DIR/${SESSION_ID}.jsonl"
  if [ ! -f "$JSONL_FILE" ]; then
    echo "ERROR: Session not found: $JSONL_FILE" >&2
    exit 1
  fi
else
  # Auto: pick the most recently modified session file
  JSONL_FILE=$(ls -t "$SESSIONS_DIR"/*.jsonl 2>/dev/null | head -1)
  if [ -z "$JSONL_FILE" ]; then
    echo "ERROR: No session files found in $SESSIONS_DIR" >&2
    exit 1
  fi
fi

DETECTED_SESSION_ID=$(basename "$JSONL_FILE" .jsonl)
OUTPUT_FILE="/tmp/perf-${DETECTED_SESSION_ID}.json"

python3 - "$JSONL_FILE" "$OUTPUT_FILE" << 'PYEOF'
import sys, json
from collections import defaultdict

jsonl_file = sys.argv[1]
output_file = sys.argv[2]

data = {
    "session_id": None,
    "project_path": None,
    "git_branch": None,
    "started_at": None,
    "ended_at": None,
    "tokens": {
        "input": 0,
        "cache_creation": 0,
        "cache_read": 0,
        "output": 0,
    },
    "assistant_turns": 0,
    "user_turn_count": 0,
    "rejected_tool_count": 0,
    "tool_calls": {},
    "agent_spawns": [],
    "skill_calls": [],
    "read_paths": [],
    "duplicate_reads": [],
    "write_paths": [],
    "bash_commands": [],
}

tool_counts = defaultdict(int)
read_path_counts = defaultdict(int)
write_path_set = []

with open(jsonl_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue

        # Capture session metadata from first populated entry
        if not data["session_id"] and obj.get("sessionId"):
            data["session_id"] = obj["sessionId"]
        if not data["project_path"] and obj.get("cwd"):
            data["project_path"] = obj["cwd"]
        if not data["git_branch"] and obj.get("gitBranch"):
            data["git_branch"] = obj["gitBranch"]
        if obj.get("timestamp"):
            if not data["started_at"]:
                data["started_at"] = obj["timestamp"]
            data["ended_at"] = obj["timestamp"]

        obj_type = obj.get("type")

        if obj_type == "user":
            data["user_turn_count"] += 1
            content = obj.get("message", {}).get("content", [])
            if isinstance(content, list):
                for block in content:
                    if not isinstance(block, dict):
                        continue
                    if block.get("type") == "tool_result" and block.get("is_error"):
                        text = str(block.get("content", ""))
                        if "rejected" in text.lower() or "doesn't want to proceed" in text.lower():
                            data["rejected_tool_count"] += 1

        elif obj_type == "assistant":
            data["assistant_turns"] += 1
            usage = obj.get("message", {}).get("usage", {})
            data["tokens"]["input"] += usage.get("input_tokens", 0)
            data["tokens"]["cache_creation"] += usage.get("cache_creation_input_tokens", 0)
            data["tokens"]["cache_read"] += usage.get("cache_read_input_tokens", 0)
            data["tokens"]["output"] += usage.get("output_tokens", 0)

            content = obj.get("message", {}).get("content", [])
            if not isinstance(content, list):
                continue

            for block in content:
                if not isinstance(block, dict) or block.get("type") != "tool_use":
                    continue
                name = block.get("name", "")
                inp = block.get("input", {})
                tool_counts[name] += 1

                if name == "Agent":
                    data["agent_spawns"].append({
                        "description": (inp.get("description") or "")[:80],
                        "subagent_type": inp.get("subagent_type") or "general-purpose",
                        "isolation": inp.get("isolation") or "",
                        "run_in_background": inp.get("run_in_background") or False,
                    })
                elif name == "Skill":
                    data["skill_calls"].append({
                        "skill": inp.get("skill") or "",
                        "args": (inp.get("args") or "")[:60],
                    })
                elif name == "Read":
                    path = inp.get("file_path") or ""
                    if path:
                        read_path_counts[path] += 1
                elif name in ("Write", "Edit"):
                    path = inp.get("file_path") or ""
                    if path and path not in write_path_set:
                        write_path_set.append(path)
                elif name == "Bash":
                    cmd = (inp.get("command") or "")[:100]
                    if cmd:
                        data["bash_commands"].append(cmd)

# Post-process tokens
t = data["tokens"]
total_volume = t["input"] + t["cache_creation"] + t["cache_read"]
t["total_billed_approx"] = t["input"] + t["cache_creation"] + t["output"]
t["cache_hit_ratio"] = round(t["cache_read"] / total_volume, 3) if total_volume > 0 else 0.0

# Post-process tools
data["tool_calls"] = dict(sorted(tool_counts.items(), key=lambda x: -x[1]))

# Read paths + duplicates
data["read_paths"] = [
    {"path": p, "count": c}
    for p, c in sorted(read_path_counts.items(), key=lambda x: -x[1])
]
data["duplicate_reads"] = [p for p, c in read_path_counts.items() if c > 1]
data["write_paths"] = write_path_set

# Read:Grep ratio (P7 signal)
reads = tool_counts.get("Read", 0)
greps = tool_counts.get("Grep", 0)
data["read_grep_ratio"] = round(reads / greps, 1) if greps > 0 else reads

with open(output_file, "w") as out:
    json.dump(data, out, indent=2)

print(output_file)
PYEOF
