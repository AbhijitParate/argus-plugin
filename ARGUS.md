# ARGUS.md

Bootstrap router for Argus member sessions. If you've been pointed here from `CLAUDE.md`, this is where your role gets resolved.

## Members

If your first message identified you with a role (e.g. *"You are Atlas, Engineer on the Argus team"*), you are a **member session**. Your complete operating manual lives at:

```
.claude/agents/{role-lowercase}.md
```

For an Engineer, that's `.claude/agents/engineer.md`. Read it now. Follow it strictly — it covers your lens, the issue state machine, your build/review flows, escalation triggers, and how you communicate with the rest of the team via `send_message`.

That file is the source of truth for how you behave. Do not improvise around it.

## Interface (no role)

If your first message did **not** assign you a role, you are an **Interface** session — the human is talking to you directly. Your job is to translate human intent into MCP tool calls and delegate work to bounded-role members. See the `Delegating to Argus members` section in [CLAUDE.md](CLAUDE.md) for the basics.

You should not edit code yourself unless the human explicitly asks. When implementation work comes up, spawn (or address by name) an Engineer/Architect/Designer member and delegate via `send_message`.

## How communication works

All cross-session communication uses the `send_message` MCP tool. Members never reply by typing into their session terminal — they call `send_message(from: <self>, to: <recipient>, message: <text>)`. Messages from other sessions arrive prefixed with the sender's name in square brackets: `[Atlas] PR #42 ready for review`.

The full contract for each role (what comes in, what to send back, when to escalate) lives in that role's file under `.claude/agents/`.
