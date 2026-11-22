@meta |
  topic:dusky arch linux hyprland orchestrator matugen btrfs
  versions:1.0
  confidence:high
  lastUpdated:2026-11-22
  source:profiles/README.md and installed dusky_config.toml
|
@dependencies |
  requires:index.s
  related:skills/linux.s skills/sh.s skills/ssh.s
|
@core |
  purpose:offline-capable Arch-like desktop layer on Hyprland with matugen theming and Btrfs snapshots
  usage:load for Dusky install, orchestrator profiles, theming, drives, services, keybinds or updates
  cli:dots get skills/dusky.s @core
  loadAll:dots get skills/dusky.s
  scope:~/user_scripts ~/.config/dusky ~/.config/hypr ~/.config/systemd/user
|
@layout |
  scripts:~/user_scripts
  orchestrator:~/user_scripts/arch_setup_scripts/orchestrator.sh
  profiles:~/user_scripts/arch_setup_scripts/profiles (01_main, 02_iso, 03_dusk_personal)
  profileDocs:~/user_scripts/arch_setup_scripts/profiles/README.md
  taskScripts:~/user_scripts/arch_setup_scripts/scripts
  settings:~/.config/dusky (dusky_config.toml, settings/)
  theme:~/.config/matugen/templates
  bareRepo:~/dusky (bare git, origin github.com/dusklinux/dusky, work-tree ~)
  state:~/Documents/state (per-profile .db + once.db)
  logs:~/Documents/logs
  backups:~/Documents/dusky_backups
  cache:~/.cache/dusky
  lock:/run/user/<UID>/dusky/orchestrator.lock
|
@orchestrator |
  entry:orchestrator.sh launches TUI profile selector
  pick:--profile 01_main or "Main Setup" or 3
  inspect:--list --list-scripts --explain --dry-run --doctor
  doctor:read-only check of versions, paths and deps - run before profile edits
  offline:--offline skips wrapper net checks, downloads and git pulls; task scripts still use network
  reset:--reset wipes profile state DB; --reset-and-run also runs immediately
  once:--list-once / --forget-once <script> manage persistent markers
  git:--no-git-update / --git-update-only; [git] enabled pulls before each run
  failure:default asks on failure; --stop-on-fail aborts immediately
  env:DUSKY_FORCE DUSKY_INTERACTIVE DUSKY_PROFILE_NAME DUSKY_TASK_PATH DUSKY_RUN_ID
  interpreter:ELF direct, shebang, .py/.sh/.fish extension, bash fallback
|
@profiles |
  spec:profiles/README.md is authoritative for TOML fields
  tables:[profile] [policy] [git] [search_dirs] [conflict_resolutions] [sequence]
  sequence:scripts compact strings + tasks TOML tables; scripts load first
  entry:MODE | flags | command - bare command defaults to U mode
  modes:U user / S sudo; sudo timestamp refreshed after auth
  flags:ignore always force interactive no-interactive timeout retry retry_delay on_failure
  conditions:if:btrfs if:battery if:gpu:nvidia if:vm if:wayland if:command:X if:package:X if:not:X
  deferred:false condition defers task, rechecks after other tasks, re-evaluated next run
  conflicts:duplicate names across search_dirs raise [CONFLICT]; pin in [conflict_resolutions]
  overrides:profiles/settings/orchestrator.toml controls paths, ui, logging, conditions, sudo, git
  schema:schema_version is informational and ignored today
|
@markers |
  once:run once; re-runs if script content changes; stored in once.db
  onceForever:never re-run even when the script changes
  onceSealed:warn once on change instead of re-running
  scope:once:profile is default; once:global is machine-wide
  always:re-run every run regardless of state
  skip:intentional bypass; continue:failed but non-blocking
|
@theming |
  engine:matugen generates palettes from wallpaper into ~/.config/matugen/templates
  switch:theme_matugen/theme_ctl.sh set --mode dark or light
  center:dusky_config.toml toggle with key dusky_theme/state
  waybar:horizontal vertical circular minimal switched via rofi at setup
  compositor:single keybind toggles gaps, shadow, blur and opacity together
  liveDisk:paru required for copy-on-write verification
|
@drives |
  fs:BTRFS root required for zstd CoW and snapshots
  stats:user_scripts/drives/btrfs_zstd_compression_stats.sh
  snapshots:cc/dusky_snapshot_manager.py under btrfs_snapshots, run with sudo
  ntfs:user_scripts/drives/ntfs_fix.sh unlocks and unmounts problem drives
  swap:zram0 compressed swap, zram1 RAM disk, /swap/swapfile fallback via zram_swap_manager.py
  purge:365_cache_purge.sh clears pacman and AUR caches
|
@services |
  core:dusky.service plus clipboard, network, notif_time, polkit, quickpanal, screentime, visualizer user units
  config:~/.config/systemd/user; enabled via graphical-session.target.wants
  vnc:dusky_vnc_desktop.service TCP 5902 / dusky_vnc_display.service TCP 5901
  moonlight:dusky_moonlight_display.service port 47989
  ftp:vsftpd.service system unit; setup via 250_ftp_arch.sh
  ui:dusky_center config pages expose service cards and toggles
|
@station |
  tailscale:01_tailscale_setup.sh and uninstall_tailscale.sh
  ssh:02_openssh_setup.py plus dusky_ssh_filesystem.py for sshfs bookmarks
  waydroid:automated Android install
  voice:TTS kokoro on CPU/NVIDIA/AMD ROCm; STT parakeet
  wifi:airmon suite for wireless testing
  phone:wired iPhone VNC setup
|
@keybinds |
  conflict:CTRL+SHIFT+SPACE auto-unbinds the existing binding in hyprland.conf
  cheatsheet:dusky_keybinds_cheatsheet.desktop
  uwsm:set Intel/Nvidia/AMD variables manually in ~/.config/uwsm/env
  dual:built for both mouse GUI and terminal keyboard workflows
|
@updates |
  updater:update_dusky_supervisor.py via dusky-run kitty
  badge:settings/dusky_update_behind_commit (0 means updated)
  sync:bare repo ~/dusky with work-tree ~; backups in ~/Documents/dusky_backups
  restore:safe local edits restored after update; conflicts and untracked collisions saved to backup
  rolling:Arch rolling release - failed mid-install scripts are re-runnable
|
@gotchas |
  fs:Btrfs root required; ext4 breaks snapshot and CoW scripts
  wrongPath:orchestrator is under arch_setup_scripts/, not user_scripts/ root
  offlineScope:--offline only affects the wrapper; task scripts may still hit network
  readSpec:read profiles/README.md before editing TOML; schema_version is ignored
  autoPull:[git] enabled pulls before run; use --no-git-update for local edits
  lockFile:concurrent runs blocked by /run/user/<UID>/dusky/orchestrator.lock
  onceReset:once.db survives --reset; use --forget-once to truly re-run
  ttyGuard:if:wayland is false in tty/ssh; use --explain to see skips
  vncPorts:5902 desktop mirror, 5901 virtual display - do not swap
  wifiLegal:airmon only on access points you own
  quickShell:avoid quickshell for lightweight TUIs
  fractional:dual-framework scaling script respects fractional scaling
|
@index |
  meta:@meta @dependencies @index
  core:@core @layout
  orchestrate:@orchestrator @profiles @markers
  desktop:@theming @keybinds
  storage:@drives
  runtime:@services @station
  upkeep:@updates @gotchas @run
|
@run doctor |
  1.cmd:dots get skills/dusky.s @layout
  2.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --doctor
  3.note:read-only; safe on a live system
  done:resolved paths, versions and deps confirmed
|
@run inspect |
  1.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --profile 01_main --list-scripts
  2.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --profile 01_main --explain
  3.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --profile 01_main --dry-run
  done:sequence validated without execution or git pull
|
@run rerun |
  1.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --list-once
  2.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --forget-once <script>
  3.cmd:~/user_scripts/arch_setup_scripts/orchestrator.sh --profile 01_main --dry-run
  4.note:drop --dry-run to execute; other task state is preserved
  done:target task re-executed without wiping the profile
|
