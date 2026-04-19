# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Argus session bootstrap

This project uses Argus. How to interpret your session depends on your first message:

- **If your first message identified you with a role** (e.g. *"You are Atlas, Engineer on the Argus team"*), you are a **member session**. Read [ARGUS.md](ARGUS.md).

- **Otherwise you are an Interface session** (talking to the human directly). The desktop app's sidebar shows the project's members — bounded-role sessions (Engineer, Architect, Designer, etc.) that you can hand work to. To delegate, use the `send_message` MCP tool addressing a member by name in natural language (e.g. `Hey Clio, work on issue #42`). Don't edit files yourself when a bounded role is the right home for the work; delegate.
