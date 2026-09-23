---
description: Extract session learnings into the dotS .s knowledge base (.s only, no .md)
---

# dotS Learn

Analyze the current session for $ARGUMENTS, extract learnings, and store them in the
dotS knowledge base as `.s` files. This is the dotS-native twin of `/learn`.

## Hard Boundary (never violated)

- NEVER read, create, or modify any `.md` file — including `AGENTS.md`, `INSTRUCTIONS.md`,
  `.opencode/skills/*`, `.opencode/commands/*`, and `SKILL.md`.
- Operate exclusively through the `dots` CLI on `.s` files inside the dotS store
  (`$(dots where)`).
- If the user explicitly requests file-based output, stop and confirm — do not switch formats.

## Task

1. Run `dots find $1` to check existing entries and their `@meta` confidence.
2. Run `dots compact` to fold session learnings into `.s` files, then review what it produced.
3. Extract learnings in these areas (mirroring `/learn`):
   - **Code Patterns**: reusable solutions discovered
   - **Mistakes**: errors made and how they were resolved
   - **Preferences**: user style/coding conventions observed
   - **Tool Usage**: effective command/library combinations
   - **Architecture**: structural decisions and rationale
4. Store each surgically in the dotS store (`$(dots where)`):
   - Skills/topics → `dots set skills/<name>.s <block.key> <value>` or `dots add skills/<name>.s <block> "<text>"`
   - New skill file? → register it: `dots add index.s @index skills/<name>.s` and add a `@byTask` trigger entry
5. Update freshness metadata: `dots set <file> @meta lastUpdated <YYYY-MM-DD>` and bump `confidence` as appropriate.
6. Log the change: `dots add changelog.s @h "#<n>: learned <topic> when:<date>"`
7. Verify: `dots validate`

## Output Format

```
## dotS Learnings: [Topic]
### Stored In
- <file> @<block> (updated/created)
### Extracted
- Patterns: ...
- Mistakes: ...
- Preferences: ...
- Tool Usage: ...
- Architecture: ...
### Confidence & Freshness
- confidence: high/medium/low · lastUpdated: <date>
### Files Touched
- <list of .s files only — must contain no .md>
```