---
description: List all dotS skills and load one into context (.s only, no .md)
---

# dotS Skills

List the dotS skills available in the store and load one into context.
This is the dotS-native twin of the `/skills` skill picker.

Available dotS skills:

!`ls "$(dots where)"/skills/ | grep -v '^index\.s$'`

Recommended bundles (mega-skills):

!`dots mega list`

## Hard Boundary (never violated)

- NEVER read, create, or modify any `.md` file — including `.opencode/skills/*` and `SKILL.md`.
- Only load skills from the dotS store (`$(dots where)/skills/`) via `dots load`.
- Do NOT use OpenCode's built-in skill loader — that is the md system. dotS loading is `dots load` only.
- If the user names something that is not a dotS skill, report it as unavailable — do not fall back to `.opencode/skills`.

## Task

1. With an argument — load it:
   - `dots load $ARGUMENTS` — note that `dots load` accepts both `name` and `name.s` (e.g. `css` or `css.s`).
   - If the argument matches a mega-skill from the bundle list above, use `dots mega load <name>` to load the whole bundle.
   - Verify with `dots loaded` (skill appears) and `dots find $ARGUMENTS` (resolves).
   - Report dependencies loaded alongside, if any.
2. Without an argument — present the skill list and recommended bundles above, ask the user
   which to load (single skill or bundle), then run `dots load <name>` or `dots mega load <name>` and verify as above.
3. Show the summary of what is now loaded.

## Related skills

- To see which bundles exist: `dots mega list` (shown above) · create one: `dots mega create <name> <skill1> <skill2> ...`
- To compare or cross-pollinate related skills: `dots pollinate <skill1> <skill2>` or `dots pollinate --all`
- To inspect a skill's block structure: `dots blocks` or `dots get skills/<name>.s <block>`

## Output Format

```
## dotS Skills
### Available
- <list of skills, grouped or as-is>
### Recommended Bundles
- <mega-skills with members>
### Loaded
- <skill> (+ dependencies: ...)
### Currently Loaded
- <from `dots loaded`>
### Files Touched
- <none — loading does not modify files>
```