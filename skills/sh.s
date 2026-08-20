# Shell (sh/bash/zsh) Knowledge Base
@meta |topic:shell|shells:sh,bash,zsh|lastUpdated:2026-08-17|confidence:high|
@basics |
  shebang:#!/bin/sh (POSIX) or #!/bin/bash or #!/usr/bin/env bash
  execute:chmod +x script.sh && ./script.sh
  source:source script.sh or . script.sh
  dryRun:set -x (print commands)
  strict:set -euo pipefail (bash)
  posix:#!/bin/sh (no bashisms)
|
@variables |
  assign:name="value" (no spaces around =)
  access:"$name" or ${name}
  default:${name:-"default"}
  assignDefault:${name:="default"}
  error:${name:?"error message"}
  length:${#name}
  substring:${name:0:3}
  replace:${name/old/new}
  removeShortest:${name#pattern}
  removeLongest:${name##pattern}
  removeShortestEnd:${name%pattern}
  removeLongestEnd:${name%%pattern}
  uppercase:${name^^}
  lowercase:${name,,}
  array:${arr[@]}
  arrayLength:${#arr[@]}
  export:export NAME="value"
  readonly:readonly NAME="value"
  env:ENV_VAR=value command
|
@arrays |
  create:arr=(one two three)
  access:${arr[0]}
  all:${arr[@]}
  length:${#arr[@]}
  append:arr+=(four)
  slice:${arr[@]:1:2}
  iterate:for item in "${arr[@]}"; do echo "$item"; done
  join:IFS=", "; echo "${arr[*]}"
  split:IFS="," read -ra arr <<< "$string"
|
@conditionals |
  if:if [ condition ]; then ...; fi
  ifElse:if [ cond ]; then ...; else ...; fi
  ifElif:if [ c1 ]; then ...; elif [ c2 ]; then ...; fi
  test:[ -f file ] (same as test -f file)
  stringEqual:[$a" = "$b]
  stringNotEqual:[$a" != "$b]
  stringEmpty:[-z "$a"]
  stringNotEmpty:[-n "$a"]
  numEqual:[$a" -eq "$b]
  numNotEqual:[$a" -ne "$b]
  numGreater:[$a" -gt "$b]
  numGreaterEqual:[$a" -ge "$b]
  numLess:[$a" -lt "$b]
  numLessEqual:[$a" -le "$b]
  fileExists:[-f "$file"]
  dirExists:[-d "$dir"]
  fileNotEmpty:[-s "$file"]
  fileReadable:[-r "$file"]
  fileWritable:[-w "$file"]
  fileExecutable:[-x "$file"]
  linkExists:[-L "$link"]
  stringMatch:[[ "$a" == pattern ]]
  regexMatch:[[ "$a" =~ regex ]]
  logicalAnd:[cond1 ] && [ cond2]
  logicalOr:[cond1 ] || [ cond2]
  logicalNot:[! cond]
  bashDouble:[[ -f file ]] (bash: pattern match, regex)
  case:case "$var" in pattern) ...;; esac
|
@loops |
  for:for i in 1 2 3; do echo "$i"; done
  forRange:for i in $(seq 1 10); do echo "$i"; done
  forCStyle:for ((i=0; i<10; i++)); do echo "$i"; done (bash)
  while:while [ cond ]; do ...; done
  whileRead:while IFS= read -r line; do echo "$line"; done < file
  until:until [ cond ]; do ...; done
  break:break
  continue:continue
  seq:seq 1 10, seq 1 2 10
  braceExpand:{1..10}:True,{a..z}:True,{1..10..2:True}
|
@functions |
  def:func() { echo "hello"; }
  call:func
  args:func arg1 arg2
  accessArgs:$1 $2 $3
  accessAll:$@
  accessAllQuoted:$@
  numArgs:$#
  return:return 0 (exit code)
  local:local var="value"
  export:export func() { ... }
  recursive:func() { func; }
|
@pipesRedirection |
  pipe:cmd1 | cmd2
  stdout:cmd > file (overwrite)
  stdoutAppend:cmd >> file (append)
  stderr:cmd 2> file
  stderrAppend:cmd 2>> file
  both:cmd > file 2>&1
  stdin:cmd < file
  hereDoc:cat << EOF ... EOF
  hereString:cmd <<< "string"
  tee:cmd | tee file
  teeAppend:cmd | tee -a file
  swap:cmd 3>&1 1>&2 2>&3
  null:cmd > /dev/null 2>&1
  pipeFail:set -o pipefail (bash, catches pipe errors)
|
@commandSubstitution |
  backticks:`cmd` (old, avoid)
  dollarParen:$(cmd) (preferred)
  assign:var=$(cmd)
  inline:echo "Today is $(date)"
  process:<(cmd) process substitution (bash)
  fileDescriptor:cmd <(cmd1) <(cmd2)
|
@quoting |
  double:"$var" (expands variables, preserves spaces)
  single:'$var' (literal, no expansion)
  escape:\$var (escapes single char)
  dollarSingle:$'...' (escape sequences: \n, \t, etc.)
  backslash:hello \"world\"
  whenDouble:always use "$var" for variables
  whenSingle:when you need literal string
  whenEscape:for individual special chars
|
@strings |
  length:${#string}
  substring:${string:position:length}
  replace:${string/old/new}
  replaceGlobal:${string//old/new}
  uppercase:${string^^}
  lowercase:${string,,}
  trim:echo "$string" | xargs
  trimLeft:${string##*pattern}
  trimRight:${string%%pattern*}
  contains:[[ "$string" == *substring* ]]
  startsWith:[[ "$string" == prefix* ]]
  endsWith:[[ "$string" == *suffix ]]
  indexOf:expr index "$string" "substring"
|
@numbers |
  arithmetic:$((a + b))
  multiply:$((a * b))
  modulo:$((a % b))
  power:$((a ** b))
  increment:((a++))
  decrement:((a--))
  float:echo "scale=2; $a / $b" | bc
  compare:[$a" -gt "$b]
  min:max:[ $(( a < b ? a : b )) ] / [ $(( a > b ? a : b )) ]
  random:$RANDOM
  hex:printf '%x\n' 255
  octal:printf '%o\n' 255
  binary:dc -e 2 o p
  format:printf '%05d\n' 42
|
@fileOperations |
  create:touch file
  createDir:mkdir -p dir/subdir
  remove:rm file
  removeDir:rm -rf dir
  copy:cp src dst
  copyRecursive:cp -r src dst
  move:mv src dst
  rename:mv old new
  link:ln -s target link
  find:find . -name "*.js" -type f
  findExec:find . -name "*.log" -exec rm {} \;
  findXargs:find . -name "*.log" | xargs rm
  glob:ls *.txt
  globRecursive:ls **/*.txt (zsh, bash 4+)
  read:cat file
  write:echo "text" > file
  append:echo "text" >> file
  readLine:read -r line < file
  readAll:data=$(cat file)
  wc:wc -l file
  sort:sort file
  sortUnique:sort -u file
  uniq:sort file | uniq -c
  grep:grep "pattern" file
  grepRecursive:grep -r "pattern" dir
  grepLineNum:grep -n "pattern" file
  sed:sed -i 's/old/new/g' file
  awk:awk '{print $1}' file
  cut:cut -d',' -f1 file
  tr:tr 'a-z' 'A-Z'
  head:head -n 10 file
  tail:tail -n 10 file
  tailFollow:tail -f file
  diff:diff file1 file2
  diffUnified:diff -u file1 file2
  paste:paste -d',' file1 file2
  column:column -t -s','
|
@processControl |
  background:cmd &
  backgroundPID:$!
  wait:wait $pid
  kill:kill $pid
  killSignal:kill -TERM $pid
  killForce:kill -9 $pid
  trap:trap 'cleanup' EXIT INT TERM
  exit:exit 1
  lastExit:$?
  shift:shift (removes $1)
  shiftN:shift 2
  getopts:while getopts "a:b:c" opt; do ... done
  getopt:long options parsing (GNU)
  xargs:find . -name "*.log" | xargs rm
  parallel:xargs -P 4 -I {} cmd {}
  timeout:timeout 10 cmd
  nohup:nohup cmd &
  screen:screen -S name
  tmux:tmux new -s name
|
@jobControl |
  suspend:Ctrl+Z
  resume:bg %1
  list:jobs -l
  foreground:fg %1
  disown:disown %1
  nice:nice -n 10 cmd
  renice:renice -n 10 -p PID
|
@networking |
  download:wget url
  downloadQuiet:wget -q url
  downloadOutput:wget -O file url
  curl:curl -O url
  curlHeaders:curl -I url
  curlPost:curl -X POST -d "data" url
  curlJSON:curl -H "Content-Type: application/json" -d '{"key":"val"}' url
  curlAuth:curl -u user:pass url
  curlFollow:curl -L url
  curlSilent:curl -s url
  ipAddr:ip addr show
  ports:ss -tlnp
  ping:ping -c 4 host
  dig:dig example.com
  nslookup:nslookup example.com
|
@security |
  checkRoot:if [ "$(id -u)" -ne 0 ]; then echo "Run as root"; exit 1; fi
  sanitize:input validation, quote variables
  unquoted:"$var" not $var
  tempfile:mktemp
  secureDelete:shred -vfz file
  hash:echo -n "password" | sha256sum
  randomPass:openssl rand -base64 32
  randomHex:openssl rand -hex 16
  sslCheck:echo | openssl s_client -connect host:443
|
@logging |
  info:echo "[INFO] message"
  warn:echo "[WARN] message" >&2
  error:echo "[ERROR] message" >&2
  timestamp:echo "[$(date '+%Y-%m-%d %H:%M:%S')] message"
  logFile:exec > >(tee -a logfile.log) 2>&1
  colorGreen:echo -e "\033[0;32mOK\033[0m"
  colorRed:echo -e "\033[0;31mFAIL\033[0m"
  colorYellow:echo -e "\033[0;33mWARN\033[0m"
|
@commonPatterns |
  exitOnError:set -euo pipefail
  requireCommand:command -v cmd >/dev/null 2>&1 || { echo "cmd required"; exit 1; }
  requireRoot:[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }
  confirm:read -p "Continue? [y/N] " -n 1 -r; echo; [[ $REPLY =~ ^[Yy]$ ]]
  selectMenu:select opt in "a" "b" "c"; do ... done
  prompt:read -p "Name: " name
  promptDefault:read -p "Name [default]: " name; name=${name:-default}
  silent:cmd > /dev/null 2>&1
  retry:for i in {1..3}; do cmd && break || sleep 1; done
  spinner:while kill -0 $pid 2>/dev/null; do ... done
  progressBar:printf '\r[%-50s] %d%%' $(printf '#%.0s' {1..$pct}) $pct
  confirmDestructive:read -p "Delete ALL? (type 'yes'): " confirm; [ "$confirm" = "yes" ]
|
@gotchas |
  unquotedVars:$var breaks on spaces → always "$var"
  wordSplitting:for i in $list → use "${arr[@]}"
  iFS:IFS=',' read -ra arr <<< "a,b,c"
  exitCode:$? is exit code of last command
  errexit:set -e doesn't catch all failures
  pipefail:set -o pipefail to catch pipe errors
  localScope:local is in functions only, not scripts
  subshell:$(cmd) runs in subshell, var changes lost
  heredoc:<<EOF must start at beginning of line
  crlf:Windows files have \r\n → dos2unix file
  readonly:set -o noclobber (prevents > file overwrite)
  noclobber:>| file to force overwrite with noclobber
  bashisms:$(()) [[ ]] arrays are bash-only
  shCompat:use [ ] and POSIX constructs for sh
  eval:avoid eval, it executes arbitrary code
  exec:exec replaces shell, used for PID 1
  source:"source" is bash, "." is POSIX
  set:"set -euo pipefail" is bash, not sh
|
