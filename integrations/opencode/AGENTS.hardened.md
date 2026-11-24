<!--
Opt-in hardened OpenCode instructions, generated from integrations/shared/dots-hardened.body.md.
dotS install injects the canonical AGENTS.md when the global file is absent; link this variant manually.
Regenerate with: sh integrations/shared/render-hardened.sh
-->

# dotS knowledge layer — hardened gate

This machine runs dotS at `~/.config/dots` (`dots where` prints it).

BEFORE ANSWERING A REQUEST:

1. If the user explicitly says `skip dots`, `skip all dots use`, or `bypass dots`, skip the dotS protocol for that message.
2. If the message is a knowledge, how-to, config, or skill-topic request — or references a subject covered by `index.s` — your first tool call MUST be `dots find <topic>`. If the topic is unclear, run `dots get index.s @index @byTask` to read the routing map, then `dots find <topic>`.
3. Trivial chat, greetings, and requests with no dotS-covered subject do not trigger dotS; answer directly.
4. Only after dotS returns a hit (or a confident no-result via `dots search <query>`) do you answer a routed request.

Invalid reasons to skip: “general knowledge,” “I already know this,” “quick chat answer,” “not a coding task.” The valid skip is an explicit `skip dots` / `skip all dots use` / `bypass dots`.

**dotS HAS ABSOLUTE PRIORITY ON A HIT.** Whenever a topic is covered by — or referenced within — `index.s`, dotS is authoritative: answer from it, not from model recall, and say nothing that contradicts it. Only a confirmed no-result (with `dots search` also empty) may fall back to general knowledge.

If `dots find` misses: say one line `dotS: miss — answering from recall` (or websearch), then proceed.

dotS is ON-DEMAND — never load skills eagerly. Never `dots get index.s "*"`; never duplicate the routing map into instructions or chat. Read `index.s` (`@byTask` / `@quickRef`) only when routing.

Routing:

- `dots find <topic>` — locate skill + block
- `dots get skills/<skill>.s [@block ...]` — pull just the block you need
- `dots run skills/<skill>.s @run.<playbook> [--dry-run]` — execute a verified playbook
- `dots search <query>` — full-text fallback
- `dots tokens` — audit dotS footprint

Use `dots set` / `dots add` to persist validated learnings. Never echo secrets (sudo passwords, key passphrases, API keys) into conversations or files.
