---
description: Optimize one or more dotS skills for token savings with dry-run review (.s only, no .md)
---

# dotS Optimize

Optimize one or more named dotS skills for token savings. This is dotS-native hygiene
(no md-system twin) — run it after creating or editing any skill.

## Hard Boundary (never violated)

- NEVER read, create, or modify any `.md` file.
- Only affects the explicitly named `.s` skills in the dotS store — never unlisted files.
- If a named skill is locked, refuse and report — never edit around a lock.

## Task

1. Check locks first: `dots locked`.
   - If a named skill is locked → stop and report (`@locking.refuseLocked`). Unlock only with
     explicit user approval: `dots unlock <name>`.
2. Preview suggestions: `dots optimize $1 ... --dry-run`
3. Review the output (`@optimize.manualReview` — these are suggestions, not commands):
   - removed `.why` blocks that only restate the directive
   - redundancy flags (identical lines across blocks)
   - simplified verbose values
4. Apply: `dots optimize $1 ...` (accept the reviewed suggestions)
5. Verify integrity after optimization: `dots validate`, then `dots find $1` — still resolves.
6. When the skill is stable, optionally lock it: `dots lock $1`

## Rules

- Always optimize after editing a skill (`@optimize.runAfter`)
- Never hand-edit for optimization — always use `dots optimize` (`@locking.useOptimizer`)
- Never touch locked files — refuse and report (`@locking.refuseLocked`)
- Optimization is per explicit name only — `dots optimize A B` affects A and B, nothing else

## Output Format

```
## dotS Optimize: [skills]
### Dry-Run Suggestions
- removed .why: ...
- redundant: ...
- simplified: ...
### Applied
- [skills] optimized
### Verified
- dots validate: ✓/✗ · dots find resolves: ✓/✗
### Locked (if requested)
- [skills] → locked
### Files Touched
- <list of .s files only — must contain no .md>
```