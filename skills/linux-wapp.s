# wapp - Isolated Browser Apps on Linux

@meta |topic:linux wapp browser isolation|lastUpdated:2026-08-26|confidence:high|

@core |
  purpose:CLI tool for creating isolated browser apps with separate profiles/cookies/sessions
  location:~/user_scripts/wapp/
  install:ln -sf ~/user_scripts/wapp/wapp ~/.local/bin/wapp
  requires:gum curl
  browsers:firefox brave-origin-nightly chromium google-chrome
|

@commands |
  create:wapp create <name> <url> [browser]
  createInteractive:wapp create
  open:wapp open <name>
  list:wapp list
  remove:wapp remove <name>
  removeKeepData:wapp remove <name> --keep-data
  recreate:wapp recreate <name> <url> [browser] [--keep-data]
  help:wapp help
|

@isolation |
  chromium:--user-data-dir=~/.local/share/wapp/<name> --app=<url>
  firefox:-P "wapp-<name>" -no-remote <url>
  firefoxProfile:~/.mozilla/firefox/wapp-<name>/
  chromeHide:chrome/userChrome.css hides #TabsToolbar #nav-bar #PersonalToolbar
|

@fileLayout |
  profile:~/.local/share/wapp/<name>/
  launcher:~/.local/bin/wapp-<name>
  desktop:~/.local/share/applications/wapp-<name>.desktop
  icon:~/.local/share/applications/icons/wapp-<name>.png
|

@multiAccount |
  pattern:wapp create <service>-<label> <url> <browser>
  example:wapp create gmail-personal https://mail.google.com brave
  example2:wapp create gmail-work https://mail.google.com brave
  note:each instance gets fully isolated cookies/sessions
|

@gotchas |
  firefoxNoRemote:-no-remote prevents connecting to existing Firefox instance
  symlinkRequired:wapp binary must be in PATH via symlink to ~/.local/bin/
  gumRequired:interactive mode fails without gum installed
  braveUseNightly:brave-origin-nightly required, not plain brave
|

@index |
  commands:@commands
  isolation:@isolation
  fileLayout:@fileLayout
  multiAccount:@multiAccount
  gotchas:@gotchas
|
