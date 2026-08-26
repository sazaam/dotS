# mise Knowledge Base - polyglot tool version manager + env + tasks
@meta |topic:mise|versions:2026.x|confidence:high|lastUpdated:2026-08-24|
@core |
  purpose:manages dev tools, env vars, tasks per project via one mise.toml
  replaces:nvm pyenv rbenv sdkman tfenv direnv make
  pillars:tools env tasks
  lang:rust no-shims zero per-call overhead
  registry:1000+ tools https://mise.jdx.dev/registry.html
  config:~/.config/mise/config.toml global, mise.toml per project
  verify:mise doctor
  docs:https://mise.jdx.dev/
|
@install |
  script:curl https://mise.run | sh
  binary:~/.local/bin/mise
  archLinux:yay -S mise (or binary script)
  update:mise self-update (script installs only)
  version:mise --version
|
@activate |
  zsh:echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
  bash:eval "$(mise activate bash)"
  placement:end of rc file after all PATH edits
  whatItDoes:hooks prompt, sets PATH+env per directory on cd
  withoutActivate:prefix commands with mise x -- cmd
  shims:mise activate uses PATH not shims (asdf-style shims add ~120ms/call)
  checkHook:mise doctor shows if activation works
|
@tools |
  installPin:mise use node@20 python@3.13 (installs + writes ./mise.toml)
  global:mise use -g node@26 (writes ~/.config/mise/config.toml)
  installOnly:mise install (reads configs, installs all listed)
  oneOff:mise exec node@26 -- node -v
  listInstalled:mise ls
  listAll:mise ls-remote node
  remove:mise uninstall node@18 or rm from mise.toml then prune
  upgrade:mise upgrade node
  fuzzyVersions:node@20 matches latest 20.x everywhere
|
@config |
  hierarchy:~/.config/mise/config.toml → parent dirs mise.toml → project mise.toml
  merge:closer files override further ones per key
  legacyFiles:.nvmrc .node-version .ruby-version .tool-versions all read automatically
  precedence:mise.toml tools beat .tool-versions in same dir
  formatTOML:[tools] node = "26" python = "3.13"
  pinExact:mise use --pin writes full versions for reproducibility
|
@python |
  builds:precompiled standalone binaries, no compiling (unlike pyenv)
  venvAuto:'[env]' '_.python.venv = ".venv"' auto activates on cd
  createVenv:mise x python -- python -m venv .venv
  pipWork:normal pip/pip-tools/uv workflow inside venv
  systemPython:leave pacman/apt system python alone, mise only shadows in shell
  shebangs:#!/usr/bin/python3 still hits system python, unaffected by mise
|
@node |
  nvmrc:read automatically, no migration needed
  globalDefault:mise use -g node@26 replaces nvm alias default
  npmTools:mise use -g npm:prettier@latest installs CLIs via npm backend
  corepack:not bundled, enable via mise use -g corepack if needed
|
@env |
  literal:'[env]' KEY = "value"
  dotenvFile:'[env]' '_.file = ".env.local"'
  sourceScript:'[env]' '_.source = "./scripts/secrets.sh"'
  dirScoping:'[env]._.dev' applies only with MISE_ENV=dev
  view:mise env prints resolved exports
  direnvReplaces:this replaces direnv entirely
|
@tasks |
  defineTOML:'[tasks.test]' run = "pytest"
  run:mise run test (or mise test if unambiguous)
  fileTasks:executable scripts in mise-tasks/ dir, #MISE description="..."
  depends:depends = ["lint"] runs deps first, parallel by default
  watch:mise watch build rebuilds on file change
  caching:skips re-run when inputs unchanged
  monorepo:MISE_PROJECT_ROOT MISE_TASK_DIR env vars available in tasks
|
@backends |
  core:built-in plugins for major languages
  aqua:aqua: prefix, includes Cosign/SLSA attestation verification
  npm:npm: prefix for JS CLIs (prettier, typescript)
  cargo:cargo: prefix for rust CLIs (ripgrep, fd)
  asdf:fallback to any asdf plugin, being phased out
  github:ubi:/github: direct binary releases
|
@gotchas |
  activateMissing:no eval line in rc = no auto-switching, most common issue
  pathOrder:activate must come after other PATH mutations in rc
  twoNodeSources:pacman nodejs + mise node = shadowing confusion, pick one (mise)
  systemPythonNeverRemove:Arch pacman python required by ~50 packages
  shebangBypass:absolute shebangs skip mise PATH, by design
  cronSystemd:no shell hook there, use mise x -- cmd explicitly
  installVsUse:install downloads only, use also pins into config
  staleShell:after editing mise.toml run hash -r or new shell if weird paths
|
@index |
  basics:@core @install @activate
  setup:@config @tools
  languages:@python @node
  extras:@env @tasks @backends
  pitfalls:@gotchas
|
@run setup |
  1.cmd:curl https://mise.run | sh
  1.note:installs to ~/.local/bin/mise
  2.cmd:echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
  2.note:add at END of rc after PATH edits
  3.cmd:mise use -g node@26 python@3.13
  3.note:pin global defaults, writes ~/.config/mise/config.toml
  4.cmd:mise use -g npm:prettier@latest
  5.cmd:mise doctor
  5.note:verify hook + PATH order
  6.cmd:mise use node@20
  6.note:per project pin + commit mise.toml
|
