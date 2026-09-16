# How to Work with the StrawNode Framework - Browser CommonJS Loader + Boot

@meta |
  topic:strawnode boot framework
  versions:1.0.0
  confidence:high
  lastUpdated:2026-09-08
  scope:|
  strawnode.js:browser-side CommonJS module loader (require/module/exports polyfill)
  boot:script-src starter= boot → fetch tree → sync eval → lifecycle events
  identity:NOT the docs project - this is the loader/framework itself
|

@dependencies |
  requires:index.s
  type.js:OOP base (packages domains mixins interfaces) loaded before loader
  strawexpress.s:Externals - the Express-like router the loader bundles
  relatedSkills:strawexpress.s strawnode-docs.s
|

@core |
  purpose:Reference for StrawNode loader mechanics: boot, require resolution, dependency pre-fetch, sync eval, lifecycle events
  usage:load when booting/editing strawnode.js, debugging module load errors, adding modules, understanding require caching
  source:/home/saz/Sites/github/strawnode/strawnode.js (~841 lines, V 1.0.0) - CANONICAL upstream; a working project's copy may sit ahead until its lib repos are re-pushed
  cli:dots get strawnode.s @boot @modules @eval @events
|

@boot |
  entryScript:strawnode.js reads its OWN <script src="strawnode.js?starter=./app/"> tag via startParams.starter
  sequence:|
  1.:parse starter= param from own script src
  2.:set module root (ModuleLoader.js_root)
  3.:fetchModuleTree(starter) reads starter/package.json → main → index.js
  4.:recursive regex scan of fetched source for require() calls
  5.:async XHR pre-fetch ENTIRE dependency tree into ModuleLoader.cache
  6.:only AFTER full tree cached → evaluateModule sync from cache
  7.:dispatch lifecycle CustomEvents on window
  rootResolve:dir → package.json main → index.js; bare id → ./strawnode_modules/<id>
  cacheRequired:eval assumes ModuleLoader.cache already holds every dependency (pre-fetch guarantees it)
  noBundler:no build step - runtime loader, files served as-is
  umd:UMD-style wrapper exposing require/module/exports
|

@modules |
  moduleObject:simfunc builds module with id dirname filename exports
  require:provided per-module resolves relative to module.dirname
  exports:module.exports assigned by source (sloppy-mode implicit globals allowed)
  isolation:global backup/restore in finally (no closure wrapper since PROLOGUE_LINES=0)
  identity:module identity = resolved absolute URL after concatRoot + ensureExtension
  cache:cache[id] returns exports (Module instance or plain value)
  strawnode_modules:bare require id resolves under ./strawnode_modules/ mirroring node_modules
  packageJson:dir require reads package.json for main field
  Type:provided as all modules' base class system (Type.define packages domains)
|

@eval |
  simfunc:global eval runner - (0, eval)(source) to keep V8 line numbers matching source files
  prologueLines:0 - zero wrapper offset helps DevTools error mapping
  useStrict:regex-neutralized by prepending 'void 0;' on the directive line (preserves line count)
  sourceURL://# sourceURL appended for DevTools identification
  returnForm:no return f - caller reads cache[id].exports after eval
  exportsRead:evaluateModule returns (s instanceof Module) ? s.exports : s
  fetchSource:cache-first, else sync XHR fallback for live require (not pre-fetched)
  liveRequire:dynamic require(path) inside callbacks works via fetchSource sync XHR
|

@events |
  strawnode-bootstrapped:dispatched after initial evaluation complete
  strawnode-ready:dispatched when loader finished (modules fetched + evaluated)
  strawnode-error:dispatched with {starter, error, hint} on dependency/syntax failure
  dispatch:dispatchSNEvent(name, detail) fires CustomEvent on window
  listener:window.addEventListener('strawnode-ready', fn) project-side entry gate
  lateInit:ready fires after eval; error helps identify wrong starter path / bad file type
|

@sectionSystem |
  factory:sections.js provides section() and project() factory helpers
  section:creates self-rendering viewport section (userData.urljade urljson parameters)
  project:creates deep leaf node with slide support
  tableau:section({style:'tableau'}) stamps userData.tableau for project gallery behavior
  routes:routes.js nested route objects with handler functions
  behavior:sectionbehavior.js focus/toggle verification WebP detection image preloading
  graphics:graphics.js BetweenJS animations for @focus and @toggle
  events:events.js EventEnhancer resize arrow-key nav shortcuts
|

@jadeTemplates |
  engine:strawjade.js - Jade template rendering (relies on 'use strict' neutralization)
  flow:section renders urljade template with urljson model data
  asyncJade:jade_async.js scans include/extends deps, async pre-fetch, sync render from cache (mirrors loader)
  templates:located project-side public/jade/ per section route
  render:template + json model → HTML injected into section DOM
|

@keyPatterns |
  twoPhase:async pre-fetch whole tree THEN sync eval - never interleave
  assetLoading:sections preload images and verify WebP support before reveal
  lazyInit:registerSNEvent listeners added before ready so no event missed
  debugErrors:|
  lineMapping:PROLOGUE_LINES=0 keeps V8 error line == source line (no wrapper offset)
  missingModule:use fetchSource sync fallback; if file absent throw Module not found VERBOSE hint
  syntaxError:check dep tree for wrong file type / bad syntax (error event hint)
  cacheVersion:cache keyed by resolved URL - changing file content needs cache-bust or reload
  requireChain:depStack/depEdges track parent-child for graph + circular detection
|

@quirks |
  noBundler:files served individually - browsers hit many XHRs, keep dep tree shallow
  cachePersist:ModuleLoader.cache survives - hard refresh may reuse XHR cache (use no-store in dev)
  sloppyGlobals:modules may rely on implicit window globals via global eval (no closure)
  typeDependency:Type.js must load before strawnode.js
  circular:deps evaluated defensively - partial exports may appear mid-cycle
  V1:0.0 header - behavior varies slightly from the production strawAI copy
  docsMirror:production copy at strawAI/public/js/strawnode.js (~1226 lines) is AHEAD of the github repo - the repo is CANONICAL; re-push lib repos after each session so seeds stay current
|

@gotchas |
  starterPath:wrong starter/ → strawnode-error with "verify path to starter" hint
  dynamicRequire:regex dep scan misses dynamic require(path) - pre-fetch misses it too, sync XHR compensates
  lineNumbers:any wrapper reintroduces offset - keep simfunc as direct global eval
  useStrictBan:removal is regex - directives reformatted must still neutralize or strict breaks globals
  emptyRequire:require with no args / unused capture breaks eval - return f removed, read cache[id].exports
  dirBase:relative requires resolve vs module.dirname - wrong base misroutes to strawnode_modules
|

@index |
  boot:@boot @dependencies
  modules:@modules @eval @events
  runtime:@sectionSystem @jadeTemplates @keyPatterns
  gotchas:@quirks @gotchas
  quickRef:dots get strawnode.s @boot - load boot flow
|
