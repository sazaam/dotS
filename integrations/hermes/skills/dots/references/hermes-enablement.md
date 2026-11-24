# Hermes enablement notes

## Verify

```bash
dots where
dots find writeSkill
hermes skills list
```

Expected skill row: `dots | autonomous-ai-agents | local | enabled`.

If `dots` is not on PATH, invoke `~/.config/dots/dots <cmd>`. These files are linked from the dotS repo by `install-dots.sh --hermes`; edit the repo copies, not the links.

## Authoring a .s skill (dry-run)

1. Load the spec: `dots get skills/writing-skill.s @format @blocks @proofGate @gotchas @index`.
2. Draft at a scratch path, e.g. `~/.hermes/cache/scratch/<name>.s`.
3. Structural gate: `dots validate /abs/path/<name>.s` — must print "structural checks passed" (keys, block ends, canonical `@meta`, `@index` refs, playbooks).
4. Confirm it parses: `dots get /abs/path/<name>.s @meta` — absolute paths outside the store work.
5. Preview trimming: `dots optimize --dry-run /abs/path/<name>.s` — must show zero actions.
6. When `@newSkill` triggers fire (or the user asks): copy into `~/.config/dots/skills/<name>.s`, register it in `skills/index.s` (`@quickRef`, `@byTask`, `@index`, `@runQuickRef`), then run `dots validate` and `dots find <topic>`.
7. Never deliver a draft before steps 3-5 pass; mark `@meta confidence:high` only after verification, otherwise `medium`.
8. At each gate boundary, run `dots get skills/writing-skill.s @refinement @run.promote`; promote only proven/repeated deltas and skip trivial one-offs.

## Standing rules

- Prefer `dots find <topic>` before web search.
- On-demand: never load `index.s` wholesale.
- Persist only validated learnings with `dots set` / `dots add`.
- Evolve skills at gate boundaries, not mid-task; distill, never paste raw logs or secrets.
- New skill only after `dots find`/`dots search` confirm no existing owner; otherwise extend a block or use a mutation.
- No authoring-guide residue in domain skills: use `@dependencies`, named `@run` playbooks and `@gotchas`, never copied guide blocks.
