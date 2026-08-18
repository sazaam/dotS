# Git Knowledge Base

@meta |topic:git|lastUpdated:2026-08-17|confidence:high|

@basics |
  version:2.x
  configFile:~/.gitconfig
  ignoreFile:.gitignore
  hookDir:.git/hooks
  configGlobal:--global
  configLocal:local (default)
|

@branching |
  create:git checkout -b feature/name
  createFrom:git checkout -b feature/name origin/main
  deleteLocal:git branch -d feature/name
  deleteForce:git branch -D feature/name
  deleteRemote:git push origin --delete feature/name
  list:git branch -a
  current:git branch --show-current
  rename:git branch -m old-name new-name
  pattern:feature/*, bugfix/*, hotfix/*, release/*
|

@committing |
  stage:git add <file>
  stageAll:git add .
  stagePatch:git add -p
  commit:git commit -m "type(scope): description"
  amend:git commit --amend
  amendMessage:git commit --amend -m "new message"
  empty:git commit --allow-empty -m "trigger CI"
  type:feat, fix, docs, style, refactor, test, chore
  scope:optional (module, component, file)
  body:git commit -m "title" -m "body"
|

@merging |
  merge:git merge feature/name
  noFF:git merge --no-ff feature/name
  abort:git merge --abort
  tool:git mergetool
  squash:git merge --squash feature/name && git commit
  rebase:git rebase main
  rebaseAbort:git rebase --abort
  rebaseContinue:git rebase --continue
  interactive:git rebase -i HEAD~5
|

@undoing |
  lastCommit:git reset --soft HEAD~1
  keepChanges:git reset --soft HEAD~1
  discardChanges:git reset --hard HEAD~1
  unstage:git restore --staged <file>
  discardFile:git restore <file>
  stash:git stash push -m "description"
  stashPop:git stash pop
  stashList:git stash list
  stashApply:git stash apply
  fullReset:git reset --hard origin/main
  reflog:git reflog
  recover:git checkout <sha>
|

@log |
  oneline:git log --oneline -10
  graph:git log --oneline --graph --all
  author:git log --author="name"
  file:git log -- path/to/file
  since:git log --since="2 weeks ago"
  diff:git log -p
  stats:git log --stat
  pretty:git log --pretty=format:"%h %s" -10
|

@diffing |
  unstaged:git diff
  staged:git diff --staged
  file:git diff path/to/file
  main:git diff main..feature/name
  stats:git diff --stat
  word:git diff --word-diff
  commit:git diff <sha1>..<sha2>
|

@remote |
  add:git remote add origin <url>
  remove:git remote remove origin
  list:git remote -v
  fetch:git fetch origin
  prune:git fetch --prune
  setURL:git remote set-url origin <url>
  ssh:git@github.com:user/repo.git
  https:https://github.com/user/repo.git
|

@stash |
  push:git stash push -m "wip"
  pop:git stash pop
  apply:git stash apply stash@{0}
  drop:git stash drop stash@{0}
  clear:git stash clear
  list:git stash list
  branch:git stash branch new-branch
  show:git stash show -p
|

@tags |
  create:git tag v1.0.0
  annotate:git tag -a v1.0.0 -m "release"
  push:git push origin v1.0.0
  pushAll:git push origin --tags
  list:git tag -l
  delete:git tag -d v1.0.0
  deleteRemote:git push origin --delete v1.0.0
|

@worktree |
  add:git worktree add ../feature-branch feature/name
  list:git worktree list
  remove:git worktree remove ../feature-branch
  prune:git worktree prune
|

@bisect |
  start:git bisect start
  good:git bisect good <sha>
  bad:git bisect bad <sha>
  reset:git bisect reset
|

@gotchas |
  detachedHEAD:git checkout <sha> → detached HEAD
  detachedHEADFix:git checkout -b temp-branch
  forcePush:NEVER git push --force on shared branches
  forcePushSafe:git push --force-with-lease
  largeFiles:use git-lfs for binaries > 50MB
  lineEndings:git config core.autocrlf input (linux/mac)
  caseSensitivity:git config core.ignorecase false
  submoduleInit:git submodule update --init --recursive
  shallowClone:git clone --depth 1 <url>
  partialClone:git clone --filter=blob:none <url>
|

@config |
  user.name:git config --global user.name "Name"
  user.email:git config --global user.email "email"
  editor:git config --global core.editor "code --wait"
  alias:git config --global alias.st status
  pullRebase:git config --global pull.rebase true
  pushDefault:git config --global push.default current
  autocrlf:git config --global core.autocrlf input
|

@hooks |
  preCommit:runs before commit (linting, formatting)
  commitMsg:validates commit message format
  prePush:runs before push (tests)
  postMerge:runs after merge (install deps)
  hookDir:.git/hooks/
  framework:husky, lefthook
  setup:husky install && husky add .husky/pre-commit "npm run lint"
|

@submodules |
  add:git submodule add <url> path/to/dir
  init:git submodule init
  update:git submodule update --recursive
  status:git submodule status
  foreach:git submodule foreach 'git pull origin main'
|

@advanced |
  cherryPick:git cherry-pick <sha>
  cherryPickAbort:git cherry-pick --abort
  rebaseInteractive:git rebase -i HEAD~N
  fixup:git commit --fixup=<sha> && git rebase -i --autosquash
  blame:git blame path/to/file
  clean:git clean -fd (remove untracked files)
  cleanDry:git clean -fdn (preview)
  archive:git archive HEAD -o archive.zip
  shortlog:git shortlog -sn (contributor stats)
|

@run quickCommit |
  1.cmd:git status --porcelain
  1.expect:
  1.onFail:nothing to commit — working tree clean
  2.cmd:git add .
  3.cmd:git commit -m "$MSG"
  3.onFail:commit failed — check message or conflicts
  4.cmd:git push origin $(git branch --show-current)
  4.onFail:push failed — check remote or permissions
|

@run releaseTag |
  1.cmd:git status --porcelain
  1.expect:
  1.onFail:abort — uncommitted changes
  2.cmd:git tag -a $TAG -m "$MSG"
  3.cmd:git push origin $TAG
  3.onFail:push failed — tag may already exist on remote
|

@run squashMerge |
  1.cmd:git checkout main
  2.cmd:git merge --squash $BRANCH
  2.onFail:merge conflict — resolve before committing
  3.cmd:git commit -m "$MSG"
  4.cmd:git push origin main
  5.cmd:git branch -d $BRANCH
|

@run undoLastCommit |
  1.cmd:git log --oneline -1
  1.expect:
  1.onFail:no commits to undo
  2.cmd:git reset --soft HEAD~1
  2.note:changes kept in staging area
|

@run cleanBranches |
  1.cmd:git branch --merged main
  1.note:list branches that are safe to delete
  2.cmd:git branch -d $(git branch --merged main | grep -v 'main\|master')
  2.onFail:some branches not fully merged — use -D to force
  3.cmd:git fetch --prune
|
