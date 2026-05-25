---
name: reference-sendmessage
description: SendMessage tool — resumes a paused mid-run agent; distinct from spawning a new one
metadata:
  type: reference
---

`SendMessage` sends a follow-up message to an agent that is **still running and waiting for input** (e.g., paused after an AskUserQuestion). It cannot resume a completed agent.

**How to apply:** May be useful in future skills or orchestrators that need multi-turn agent interactions — e.g., an agent that asks a clarifying question mid-run and the skill needs to reply without re-spawning. Not needed when agents always run to completion and return a Decision block.
