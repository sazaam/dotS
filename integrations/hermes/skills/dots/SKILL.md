---
name: dots
description: >-
  Use the dotS knowledge layer before web search or speculation on infrastructure,
  system configuration, and supported stacks (SSH, Docker, Podman, Nginx, Linux,
  Dusky/Hyprland, Blender, Three.js, GLSL, Rust). Loads dense .s blocks on demand.
---

# dotS Knowledge Layer

Store: `~/.config/dots`. CLI: `dots` (fallback: `~/.config/dots/dots`).

## When to Use

- Before web research or speculative answers on topics covered by dotS skills.
- To run verified `@run` playbooks.
- To persist validated, reusable operational learnings.

## Core Commands

- `dots find <topic>` — route a topic to relevant blocks; start here
- `dots get skills/<skill>.s [@block ...] [key]` — load a whole skill, one or more blocks, or one key
- `dots search "<term>"` — full-text fallback when `find` misses
- `dots list <skill>.s` — list blocks in a skill
- `dots run skills/<skill>.s @run.<playbook> [--dry-run]` — run a verified playbook
- `dots set <file.s> <block.key> <value>` — set a value
- `dots add <file.s> @block <item> [key:value ...]` — append to a block
- `dots validate [file.s]` — check store integrity, or structurally check one draft
- `dots where` — show install location

## Rules

- On-demand only: run `find` first; never dump `index.s` or all skills into context.
- Do not duplicate the routing map into instructions or chat.
- Before authoring `.s` files, load the spec: `dots get skills/writing-skill.s @format @blocks @proofGate @gotchas @index`.
- Never present a `.s` draft before `dots validate <draft>` passes and `dots optimize --dry-run <draft>` shows zero actions.
- Domain skills must not copy guide blocks (`@versioning`, `@locking`, `@debugging`, bare `@run`); use named playbooks only.

See `references/hermes-enablement.md` for verification, dry-run authoring and PATH notes.
