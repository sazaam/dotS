---
description: Create a reusable dotS skill as a .s playbook, following writing-skill.s house style (.s only, no .md)
---

# dotS Skill Create

Create or update a reusable dotS skill from $ARGUMENTS patterns and store it as a `.s` file
inside the dotS store. This is the dotS-native twin of `/skill-create`.

## Hard Boundary (never violated)

- NEVER read, create, or modify any `.md` file — including `.opencode/skills/*`, `SKILL.md`,
  `AGENTS.md`, and `INSTRUCTIONS.md`.
- The product of this command is a `.s` file, loadable via `dots find` / `dots load` and
  executable via `dots run` when it contains an `@run` block.
- If the user explicitly requests a `SKILL.md`, stop and confirm — do not create `.md` files here.

## Task

1. Load the house style first:
   `dots get skills/writing-skill.s @patterns @blocks @tokens @antiPatterns`
   (its create playbook, `@run.create`, shows the canonical create → optimize → validate loop).
2. Check for an existing skill: `dots find $1` and `dots search $1`.
3. Identify the repeated pattern in $ARGUMENTS and abstract it to the general case.
4. Create `skills/<name>.s` in the dotS store — `$(dots where)` — (or update the existing file)
   following `writing-skill.s`:
   - Base structure (`@patterns.simpleSkill`): `@meta` + `@core` + `@blocks` + `@gotchas` + `@index`
   - Rich content (`@patterns.referenceSkill`): `@meta` + `@core` + multiple content blocks + `@gotchas` + `@index`
   - Executable workflow: a `@run` playbook with numbered steps (`1.cmd`, `1.expect`, `1.onFail`)
5. Register it in the index (formats per `@patterns.indexBlock` / `@quickRefBlock` / `@byTaskBlock`):
   - `dots add index.s @index skills/<name>.s`
   - `dots add index.s @byTask "<trigger>:skills/<name>.s"`
   - Optional shortcut: `dots add index.s @quickRef "<alias>:dots get skills/<name>.s <block>"`
6. Add a relationship if it connects to existing knowledge:
   `dots add relations.s "$<name> ~ $<related>"`
7. Log the change: `dots add changelog.s @h "#<n>: created/updated skill <name> when:<date>"`
8. Verify: `dots validate`, then `dots find $1` — it must resolve to the new skill.

## Quality Criteria (from writing-skill.s)

- Follow the `@patterns` structures — simpleSkill vs referenceSkill
- Respect `@tokens` rules — short keys, no redundancy, compact arrays
- Avoid `@antiPatterns` — verbose values, missing index, no `@meta`, lone pipes
- Practice `@honesty` — state ranges/limits, no overclaiming
- Small file — ~200-400 lines per dotS core rules

## Output Format

```
## dotS Skill: [name]
### Created/Updated
- skills/<name>.s (blocks: @meta @core @blocks [@run] @gotchas @index)
### Trigger Conditions
- ... (@byTask entry)
### Workflow
- ... (or @run playbook steps)
### Registered In
- index.s, relations.s, changelog.s
### Files Touched
- <list of .s files only — must contain no .md>
```