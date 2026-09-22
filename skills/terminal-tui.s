# Terminal & TUI Workflows
@meta |
  topic:terminal tui workflow herdr agent sessions
  versions:1.0
  confidence:high
  lastUpdated:2026-09-22
|
@dependencies |
  requires:index.s
  related:skills/sh.s skills/server-setup.s
|
@core |
  purpose:getting work done from terminal UIs instead of a GUI
  usage:load when driving agents/servers through a TUI or keeping long jobs alive
  cli:dots get skills/terminal-tui.s @herdr
|
@herdr |
  what:herdr = terminal workspace manager hosting AI coding agents (e.g. opencode) in embedded terminals
  workspace:one workspace per concern owns its agent session; detach to let it run, reattach to interact
  paneState:pane status = idle / working / blocked (blocked = permission or question pending)
  integration:herdr installs an opencode integration plugin (HERDR_INTEGRATION_ID=opencode-tui-v2)
  managed:integration files are generated and overwritten on herdr updates - never edit them
  customHooks:put extra hooks/plugins beside the managed files, not inside them
  wiring:~/.config/opencode/{cli.json,plugins/,tui.jsonc,herdr-*} carry the integration
|
@sessions |
  keepAlive:tmux/screen/herdr keep long jobs alive across logout
  detach:run heavy work detached; poll log, not TTY
  capture:script -qec 'cmd' log records a session - note it also echoes the typed input
  stripAnsi:sed 's/\x1b\[[0-9;]*m//g' before grepping captured output
  liveness:kill -0 <pid> or the pane/session status beats reading output size
  noColor:prefer --color=never for machine-readable logs
|
@workflow |
  freshDir:launch the agent from a clean workspace so project configs load right
  review:TUI split/attach views review agent steps while it keeps working
  longRun:start hours-long tasks detached (background) and reattach later
  parallel:separate workspaces per concern beats one monolithic session
  stop:favor sending a stop/signal over killing the terminal - killing loses session state
  capturePane:take screenshots from the pane, not through echo loops
|
@gotchas |
  inputEcho:typescript records your typed command - don't mistake it for program output
  nestedTui:TUIs inside captured terminals double-buffer; read logs for truth
  ansiGrep:raw ANSI breaks grep - strip escapes or force no-color
  paintFlood:spinners repaint constantly; filter by your own marker lines
  stateTruth:agent state (working/blocked) is the source of truth, not wall-clock time
  agentRestart:restarting the manager drops in-memory session state - persist via git/notes
|
@index |
  start:dots get skills/terminal-tui.s @core
  herdr:dots get skills/terminal-tui.s @herdr
  sessions:dots get skills/terminal-tui.s @sessions @workflow
  gotchas:dots get skills/terminal-tui.s @gotchas
|
