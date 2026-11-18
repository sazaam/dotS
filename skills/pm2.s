# PM2 Process Manager for Node.js
@meta |topic:pm2 node process manager cluster logs deploy|versions:6.x|confidence:high|lastUpdated:2026-11-13|
@core |
  purpose:keep Node.js apps alive, cluster them, log and deploy
  install:npm i -g pm2
  usage:start app -> pm2 save -> pm2 startup for boot persistence
  container:use pm2-runtime, never the pm2 daemon
|
@install |
  global:npm i -g pm2
  version:pm2 -v
  local:npm i pm2 --save-dev (npx pm2 ...)
  update:npm i -g pm2@latest && pm2 update
  uninstall:npm rm -g pm2 && pm2 kill
  nodeReq:node >= 16
|
@commands |
  start:pm2 start app.js
  startName:pm2 start app.js --name api
  startArgs:pm2 start app.js -- --port 3000
  startEco:pm2 start ecosystem.config.js --env production
  list:pm2 list (alias ls)
  status:pm2 status
  show:pm2 show <name|id>
  stop:pm2 stop <name|id|all>
  restart:pm2 restart <name|id|all>
  reload:pm2 reload <name> (zero-downtime, cluster only)
  delete:pm2 delete <name|id|all>
  logs:pm2 logs [name] --lines 200
  flush:pm2 flush
  save:pm2 save
  resurrect:pm2 resurrect
  startup:pm2 startup
  monit:pm2 monit
  env:pm2 env <id>
  reset:pm2 reset all (restart counters)
  kill:pm2 kill (stop daemon + all apps)
|
@ecosystem |
  generate:pm2 ecosystem
  file:ecosystem.config.js
  startFile:pm2 start ecosystem.config.js
  startEnv:pm2 start ecosystem.config.js --env production
  shape:module.exports = { apps: [{ name, script, instances, exec_mode, env, env_production }] }
  cjs:package.json "type":"module" -> use ecosystem.config.cjs
  json:ecosystem.config.json (no JS logic)
  multiApp:apps:[...] runs several processes from one file
|
@configKeys |
  name:unique app name
  script:entry file
  args:cli args string
  cwd:working directory
  instances:number or "max"
  exec_mode:fork|cluster
  watch:true only in dev
  ignore_watch:["node_modules","logs"]
  max_memory_restart:500M
  env:base vars
  env_production:overrides for --env production
  error_file:logs/err.log
  out_file:logs/out.log
  merge_logs:true
  time:true (timestamps)
  autorestart:true
  max_restarts:10
  restart_delay:4000
  kill_timeout:1600 (default ms before SIGKILL)
  listen_timeout:3000 (default ms for wait_ready)
  wait_ready:true (app must process.send('ready'))
  exp_backoff_restart_delay:100 (ms, backoff cap)
  uid:deploy (run as user)
|
@cluster |
  enable:exec_mode:"cluster" + instances:"max"
  shorthand:pm2 start app.js -i max
  reload:pm2 reload <app> replaces workers one by one
  forkReload:fork mode reload = full restart, brief downtime
  sharedState:in-memory state is per worker; use Redis/DB
  graceful:process.on('SIGINT', () => server.close(() => process.exit(0)))
  sessions:no sticky sessions by default; avoid in-memory sessions
  port:workers share the listening port via cluster module
|
@processFile |
  save:pm2 save -> ~/.pm2/dump.pm2
  resurrect:pm2 resurrect
  boot:pm2 startup (run printed sudo cmd)
  bootUser:pm2 startup systemd -u deploy --hp /home/deploy
  removeBoot:pm2 unstartup
  stale:pm2 save after every add/delete or resurrect restores old list
|
@logs |
  tail:pm2 logs
  lines:pm2 logs --lines 100
  raw:pm2 logs --raw
  json:pm2 logs --json
  split:pm2 logs --out | --err
  files:pm2 show <app> -> out/err log path
  rotate:pm2 install pm2-logrotate
  rotateSize:pm2 set pm2-logrotate:max_size 10M
  rotateRetain:pm2 set pm2-logrotate:retain 7
  rotateCompress:pm2 set pm2-logrotate:compress true
  defaultPath:~/.pm2/logs/<app>-{out,error}.log
|
@monitoring |
  monit:pm2 monit (cpu/mem live)
  status:pm2 status (restarts, uptime, mem)
  jlist:pm2 jlist (JSON, scriptable)
  pretty:pm2 prettylist
  describe:pm2 describe <app> (script, cwd, env, restarts)
  unstable:restart count climbing -> check logs and memory
  memory:max_memory_restart:"500M" as safety net
|
@deploy |
  setup:pm2 deploy ecosystem.config.js production setup
  deploy:pm2 deploy ecosystem.config.js production
  update:pm2 deploy ecosystem.config.js production update
  revert:pm2 deploy ecosystem.config.js production revert 1
  config:deploy:{user,host,ref,repo,path,pre-setup,post-setup}
  ssh:requires passwordless ssh key to host
  simple:git pull + npm ci + pm2 reload <app> is enough for one host
|
@env |
  dotenv:pm2 does NOT load .env; load it in app (dotenv/config)
  ecosystem:env / env_production in ecosystem.config.js
  apply:pm2 start ecosystem.config.js --env production
  update:pm2 restart <app> --update-env after changing shell env
  secrets:keep out of ecosystem.config.js and git
  reloadEnv:fork apps need restart, not reload, to pick env
|
@docker |
  base:FROM node:22-alpine
  install:RUN npm i -g pm2
  cmd:CMD ["pm2-runtime","ecosystem.config.js"]
  runtime:pm2-runtime stays foreground, PID 1, forwards SIGTERM
  noDaemon:pm2 start in container exits immediately
  logs:pm2-runtime writes to stdout/stderr
  instances:1 per container; scale with replicas
|
@gotchas |
  envNoDotenv:pm2 does not read .env
  envStale:env change needs --update-env restart
  esmEco:"type":"module" breaks ecosystem.config.js -> rename .cjs
  forkInstances:instances > 1 in fork mode conflicts on port
  reloadDowntime:zero-downtime reload only in cluster mode
  memoryChurn:max_memory_restart too low = restart loop
  watchProd:watch:true restarts on log writes; keep off in prod
  logGrowth:no logrotate -> disk fills
  rootPm2:root uses /root/.pm2; startup must match the run user
  nvmBoot:systemd unit pins node path; re-run startup after nvm change
  cwdWrong:wrong cwd -> MODULE_NOT_FOUND
  stopVsDelete:stop keeps app in list; delete removes it
  staleSave:forgot pm2 save -> resurrect starts old apps
  afterNodeUpgrade:npm i -g pm2@latest && pm2 update
  killTimeout:SIGKILL fires at kill_timeout + ~200ms
|
@run setup |
  1.cmd:node -v
  1.expect:v16+
  1.onFail:install or switch Node via nvm
  2.cmd:npm i -g pm2
  2.onFail:check npm prefix perms; use nvm
  3.cmd:pm2 start ecosystem.config.js --env production
  3.onFail:check cwd, script path, pm2 logs --err
  4.cmd:pm2 status
  4.expect:online
  5.cmd:pm2 save
  6.cmd:pm2 startup
  6.note:run the sudo command it prints
  7.cmd:curl -sf http://localhost:$PORT/health
  7.expect:200
|
@run zeroDowntime |
  1.cmd:pm2 reload <app>
  1.onFail:app not in cluster mode -> set exec_mode cluster
  2.cmd:pm2 status
  2.expect:online
  3.cmd:pm2 logs <app> --err --lines 50
  3.onFail:crash loop -> pm2 restart <app> and inspect env
  4.cmd:pm2 save
|
@run troubleshoot |
  1.cmd:pm2 status
  1.note:look for errored, stopped, high restart count
  2.cmd:pm2 logs <app> --err --lines 100
  3.cmd:pm2 describe <app>
  3.note:verify script, cwd, exec cwd, env, memory
  4.cmd:pm2 restart <app> --update-env
  4.onFail:pm2 delete <app> && pm2 start ecosystem.config.js --env production
  5.cmd:pm2 save
|
@index |
  basics:@install @commands @core
  config:@ecosystem @configKeys @env
  runtime:@cluster @processFile @logs @monitoring
  ops:@deploy @docker @run
  pitfalls:@gotchas
|
