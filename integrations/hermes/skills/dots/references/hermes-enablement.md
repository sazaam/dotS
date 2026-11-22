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

1. Load the spec: `dots get skills/writing-skill.s @format @blocks @gotchas @index`.
2. Draft at a scratch path, e.g. `~/.hermes/cache/scratch/<name>.s`.
3. Confirm it parses: `dots get /abs/path/<name>.s @meta` — absolute paths outside the store work.
4. Preview trimming: `dots optimize --dry-run /abs/path/<name>.s` — changes nothing.
5. Only when asked: copy into `~/.config/dots/skills/<name>.s`, register it in `skills/index.s` (`@quickRef`, `@byTask`, `@index`, `@runQuickRef`), then run `dots validate` and `dots find <topic>`.
6. Every block named in the skill's `@index` must exist; rerun `dots optimize --dry-run` until it reports zero changes.

## Standing rules

- Prefer `dots find <topic>` before web search.
- On-demand: never load `index.s` wholesale.
- Persist only validated learnings with `dots set` / `dots add`.
