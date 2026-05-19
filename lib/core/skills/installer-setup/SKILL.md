---
name: installer-setup
description: Set up or reconfigure a downstream project to use the software-dev-agentic toolkit.
allowed-tools: AskUserQuestion, Bash, Agent
---

## Arguments

`$ARGUMENTS` — optional platform name (e.g. `web`, `ios-talenta`, `flutter-mobile-talenta`).

## Steps

1. If `$ARGUMENTS` does not specify a platform:

   a. Run `ls software-dev-agentic/lib/platforms/` to discover available platforms dynamically.

   b. Use `AskUserQuestion` to present the discovered platform names as options — one option per platform directory found.

2. Spawn `installer-setup-worker` using the Agent tool with:

   > Platform: <platform>
