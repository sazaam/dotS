@meta |
  topic:ponytail yagni minimal-code
  confidence:high
  lastUpdated:2026-08-18
  knownGaps:
  deprecated:false
|
@info |
  name:ponytail
  desc:lazy senior dev mode — YAGNI-first, minimal code
  usage:s get skills/ponytail.s @rules
  altUsage:plugin: @dietrichgebert/ponytail in opencode.json
  modes:lite|full|ultra|off
|
@rules |
  1:Does this need to exist? → no: skip (YAGNI)
  2:Already in codebase? → reuse, don't rewrite
  3:Stdlib does it? → use it
  4:Native platform feature? → use it
  5:Installed dependency? → use it
  6:One line? → one line
  7:Only then: minimum that works
  lazy:efficient, not careless — understand problem first
  never:input validation, error handling, security, accessibility
  check:non-trivial logic leaves ONE runnable check
  deletion:over addition. Boring over clever. Fewest files.
|
@commands |
  review:review diff for over-engineering
  audit:audit repo for over-engineering
  debt:harvest deferred ponytail: shortcuts
  gain:show impact scoreboard
|
@pluginUsage |
  install:add @dietrichgebert/ponytail to opencode.json plugins
  activate:/ponytail full or /ponytail ultra
  deactivate:/ponytail off
  review:/ponytail-review
|
@run review |
  1.cmd:git diff --cached
  1.note:check staged changes for over-engineering
  2.note:apply YAGNI ladder to each change
  3.note:flag unnecessary abstractions, deps, boilerplate
|
@run audit |
  1.cmd:find . -name "*.ts" -o -name "*.js" -o -name "*.py" | head -20
  1.note:scan codebase for over-engineering patterns
  2.note:check for unused abstractions, dead code, extra deps
|
