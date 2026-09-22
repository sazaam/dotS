---
description: Show the dotS routing map (@quickRef, @runQuickRef, @byTask, @index) at a glance (.s only, no .md)
---

# dotS Index

Show the dotS routing map — what knowledge exists and the exact commands to reach it.

## Routing Map (from index.s)

Project info:

!`dots get index.s @p`

Shortcuts (`@quickRef`):

!`dots get index.s @quickRef`

Playbooks (`@runQuickRef`):

!`dots get index.s @runQuickRef`

Task routing (`@byTask`):

!`dots get index.s @byTask`

Registered files (`@index`):

!`dots get index.s @index`

## Hard Boundary (never violated)

- NEVER read, create, or modify any `.md` file — including `.opencode/skills/*` and `SKILL.md`.
- Read-only command: it inspects `index.s` and loads nothing into context.
- Do NOT use OpenCode's built-in skill loader — dotS lookups are `dots get` / `dots run` / `dots load` only.

## Task

1. No argument — present the routing map above grouped by block, then offer next actions:
   - `dots get skills/<name>.s <block>` — load one block
   - `dots run skills/<name>.s @run.<name>` — run a playbook (from `@runQuickRef`)
   - `dots load <skill>` — load a whole skill (see also `/dots/skills`)
2. With an argument — narrow to the topic:
   - Run `dots find $ARGUMENTS` (index routing) and `dots search $ARGUMENTS` (full text).
   - Show the matching shortcuts/blocks and the exact command to reach the best match.
3. If a shortcut references a block or file that no longer exists, flag it as stale for the
   next `dots optimize` / freshness pass — do not silently edit `index.s`.

## Output Format

```
## dotS Index
### Project
- <name> v<ver>
### @quickRef (shortcuts)
- <key> → <value>  (matching ones first when a topic was given)
### @runQuickRef (playbooks)
- <key> → <value>
### @byTask (routing)
- <task> → <targets>
### @index (files)
- <file list>
### Next Actions
- suggested `dots get` / `dots run` / `dots load` commands
### Stale Entries (if any)
- <key> → missing target
### Files Touched
- <none — read-only>
```