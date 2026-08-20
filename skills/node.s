# Node.js Knowledge Base
@meta |topic:node|lastUpdated:2026-08-17|confidence:high|
@basics |
  version:22.x LTS
  runtime:V8 engine
  moduleSystem:ESM (import/export) + CJS (require)
  packageManager:npm, pnpm, yarn
  configFile:package.json
  lockFile:package-lock.json, pnpm-lock.yaml, yarn.lock
|
@debugging |
  inspect:node --inspect server.js
  inspectBrk:node --inspect-brk server.js
  chromeDevTools:chrome://inspect
  breakpoints:debugger statement in code
  console.log:standard output
  console.table:tabular data
  console.dir:object inspection
  util.inspect:deep object logging
  --trace-warnings:show stack traces for warnings
  --throw-warnings:throw on warnings
|
@performance |
  profiling:node --prof server.js
  processV8:node --prof-process isolate-*.log
  memory:process.memoryUsage()
  heap:node --max-old-space-size=4096
  timeline:chrome devtools performance tab
  eventLoop:clinic doctor
  cpu:clinic flame
  io:clinic bubbleprof
  memory2:clinic heapprofile
|
@errors |
  uncaught:process.on('uncaughtException', handler)
  unhandled:process.on('unhandledRejection', handler)
  exit:process.exit(1)
  stack:Error.stack
  cause:new Error('msg', { cause: originalError })
  aggregate:AggregateError [errors]
  tryCatch:try { ... } catch (e) { ... }
  asyncCatch:unhandled in promises
|
@streaming |
  readable:fs.createReadStream('file.txt')
  writable:fs.createWriteStream('file.txt')
  transform:zlib.createGzip()
  pipeline:stream.pipeline(r, w, cb)
  pipe:readable.pipe(writable)
  backpressure:drain event
  highWaterMark:default 16KB
  asyncIter:for await (const chunk of stream)
|
@http |
  createServer:http.createServer(handler)
  express:const app = express()
  middleware:app.use((req, res, next) => {...})
  routes:app.get('/path', handler)
  json:express.json()
  cors:app.use(cors())
  helmet:app.use(helmet())
  rateLimit:express-rate-limit
|
@fileSystem |
  readFile:fs.readFileSync('file.txt', 'utf8')
  writeFile:fs.writeFileSync('file.txt', 'data')
  exists:fs.existsSync('path')
  mkdir:fs.mkdirSync('dir', { recursive: true })
  readdir:fs.readdirSync('dir')
  stat:fs.statSync('file')
  unlink:fs.unlinkSync('file')
  copy:fs.copyFileSync(src, dest)
  rename:fs.renameSync(old, new)
  watch:fs.watch('dir', handler)
  tempDir:fs.mkdtempSync(os.tmpdir())
|
@async |
  promise:new Promise((resolve, reject) => {...})
  async:async function name() { await ... }
  parallel:Promise.all([p1, p2, p3])
  parallelSettled:Promise.allSettled([p1, p2])
  race:Promise.race([p1, p2])
  any:Promise.any([p1, p2])
  delay:new Promise(r => setTimeout(r, ms))
  queue:p-limit for concurrency control
|
@process |
  argv:process.argv
  env:process.env
  exit:process.exit(code)
  cwd:process.cwd()
  pid:process.pid
  uptime:process.uptime()
  memory:process.memoryUsage()
  cpu:process.cpuUsage()
  nextTick:process.nextTick(cb)
  queueMicrotask:queueMicrotask(cb)
  stdout:process.stdout.write('data')
|
@childProcess |
  exec:child_process.exec(cmd, cb)
  execSync:child_process.execSync(cmd)
  spawn:child_process.spawn(cmd, args)
  spawnSync:child_process.spawnSync(cmd, args)
  fork:child_process.fork('script.js')
  execFile:child_process.execFile(file, args)
  detach:detached: true, stdio: 'ignore'
|
@modules |
  create:module.exports = {...}
  import:import pkg from 'package'
  export:export const name = value
  reExport:export { name } from './module'
  dynamic:await import('./module')
  resolve:import.meta.resolve('./module')
  dirname:import.meta.dirname
  filename:import.meta.filename
|
@networking |
  dns:dns.lookup('example.com', cb)
  dnsResolve:dns.resolve4('example.com', cb)
  tcp:new net.Socket()
  udp:dgram.createSocket('udp4')
  tls:tls.connect({ host, port })
  websocket:ws package
  fetch:globalThis.fetch(url) (built-in)
|
@security |
  crypto:crypto.createHash('sha256')
  randomBytes:crypto.randomBytes(32)
  pbkdf2:crypto.pbkdf2Sync(pass, salt, 100000, 64, 'sha512')
  timingSafe:crypto.timingSafeEqual(a, b)
  envSecrets:NEVER commit .env files
  helmet:security headers for Express
  rateLimit:prevent brute force
  sanitize:user input validation
  cors:configure allowed origins
|
@gotchas |
  eventLoop:blocking: sync operations in handler
  eventLoopFix:use async/await, worker threads
  memoryLeak:unbounded arrays/maps
  memoryLeakFix:use WeakMap, set limits
  requireCyclic:circular dependencies
  requireCyclicFix:lazy require, restructure
  unhandledPromise:missing .catch()
  encoding:always specify 'utf8' in readFile
  pathJoin:path.join() not string concat
  pathRelative:path.relative() for relative paths
|
@testing |
  jest:npm test (jest.config.js)
  vitest:npx vitest
  mocha:mocha --recursive
  cypress:npx cypress open
  playwright:npx playwright test
  supertest:HTTP assertion library
  coverage:npx jest --coverage
  watch:npx jest --watch
  snapshot:npx jest --updateSnapshot
|
@tooling |
  nodemon:nodemon server.js
  tsx:tsx watch server.ts
  esbuild:esbuild src/index.ts --bundle --outfile=dist/app.js
  swc:npx swc src -d dist
  tsc:npx tsc --noEmit
  eslint:npx eslint src/
  prettier:npx prettier --write src/
  typescript:tsc for type checking
|
@run buildDeploy |
  1.cmd:npm ci --production
  1.onFail:install failed — check package-lock.json
  2.cmd:npm run build
  2.onFail:build failed — check TypeScript errors
  3.cmd:rsync -avz --delete dist/ $USER@$HOST:$DEPLOY_PATH/
  3.onFail:upload failed — check SSH access and path
  4.cmd:ssh $USER@$HOST "systemctl restart $SERVICE"
  4.onFail:restart failed — check service logs
  5.cmd:curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN
  5.expect:200
  5.onFail:site not responding — check server logs
|
@run devSetup |
  1.cmd:npm ci
  1.onFail:install failed — delete node_modules and retry
  2.cmd:cp .env.example .env 2>/dev/null || touch .env
  2.note:create .env if missing
  3.cmd:npm run dev
  3.note:starts dev server with hot reload
|
@run testSuite |
  1.cmd:npm test
  1.onFail:tests failed — check output for details
  2.cmd:npm run lint 2>/dev/null
  2.onFail:lint errors — fix before committing
  3.cmd:npx tsc --noEmit 2>/dev/null
  3.onFail:type errors — fix before committing
|
@run productionCheck |
  1.cmd:node --max-old-space-size=4096 server.js &
  1.note:start with increased heap if needed
  2.cmd:curl -s http://localhost:$PORT/health
  2.expect:200
  2.onFail:health endpoint not responding
  3.cmd:node -e "console.log(process.memoryUsage())"
  3.note:check memory footprint
|
