---
name: setup-worker
description: Set up or reconfigure a downstream project to use the software-dev-agentic toolkit.
allowed-tools: AskUserQuestion, Agent
---

## Arguments

`$ARGUMENTS` — optional platform (`web`, `ios`, `flutter`).

## Steps

1. If `$ARGUMENTS` does not specify a platform, use `AskUserQuestion`:
   - `web` — Next.js project
   - `ios` — Swift/UIKit project
   - `flutter` — Dart/BLoC project

2. Spawn `setup-worker` using the Agent tool with:

   > Platform: <platform>
