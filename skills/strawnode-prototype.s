# StrawNode SPA Prototyping - Reliable Recipe for Standing Up a New Webapp

@meta |
  topic:strawnode-prototype
  versions:1.1.1
  confidence:high
  lastUpdated:2026-09-09
  lineage:distilled from live StrawNode builds (nested sections, deep children)
  scope:|
  playbook:how to scaffold + boot + render a new StrawNode SPA with jade + json + BetweenJS
  focus:the reliable critical details that actually make it render (nested-section invariant, self-contained toggle, JSON loading, absolute paths)
  NOT:framework internals (that is strawexpress.s / strawnode.s)
|

@dependencies |
  requires:index.s strawexpress.s strawnode.s betweenjs.s jade.s
|

@core |
  purpose:One skill to stand up a working StrawNode SPA from scratch (server + boot + sections + jade + json + transitions + verification)
  usage:load when asked to BUILD a new Strawnode/StrawNode webapp, SPA, or multi-page hash site
  seed:copy ONLY the framework seed (strawnode.js + its bundled module dir) from the current working StrawNode stack in play - the project layers (server/boot/routes/graphics/templates/models/css) are authored fresh, never lifted
  cli:dots get strawnode-prototype.s @playbook
|

@session |
  when:STARTING any StrawNode prototyping session - read FIRST, before writing code |
  order:|
  1.:load the map - dots find / read index.s to see what skills exist and what each covers
  2.:load the toolset - dots get strawnode-prototype.s plus its dependencies (strawexpress strawnode betweenjs jade)
  3.:restate the prompt in the project's own words - purpose, structure kinds (Landing-vs-Host thinking), and the behavior that must exist
  4.:improvise once the restatement is clear - seed only the framework, author everything else fresh, name as it reads most clearly
  principle:understand the tools fully BEFORE choosing which is needed and best for the task - the load, the restate, then the creation
  cli:dots get strawnode-prototype.s @session
|

@philosophy |
  when:any existing project (e.g. strawAI) is given as INSPIRATION - not as a template to copy |
  value:the source project is a set of learned PATTERNS and their real mechanisms - what to understand fully, not what to reproduce
  ownership:namings, structure splits, pattern choices and behavioral decisions are the author's own - keep what reads intuitively correct, freely improve what can be better, for the purpose of this project's prompts
  standard:judge every echo against two tests - does it serve THIS prompt best, and does it follow best practice (reuse with flexibility, no redundancy, no forced vocabulary)?
  spirit:"I offered the tools, now let us improvise and create with them - with a right understanding of the tools, and of which is needed and best for which task"
|

@layout |
  server:app.js - Express 4.16 + Jade 1.11 + static public/ + no-store; port 3000
  name:each project picks ONE short app name ({myapp}) for ALL its own folders - a convention, not a mandate; the name itself is a per-project choice
  framework:strawnode.js + strawnode_modules/ are FRAMEWORK-level, never renamed or moved (they mirror node_modules) - only app-level folders take the {myapp} name
  shells:root public/jade/index.jade + layout.jade are rendered SERVER-side by express/jade views - page scaffolding only, never async-loaded by the app
  appTemplates:public/jade/{myapp}/*.jade - every async-loaded (live) template, one per section/route; the app XHRs these alongside its module dir
  jsonModels:public/js/json/{myapp}/*.json (one per section, provides jade locals)
  css:public/css/{myapp}.css (dark gridded, 1px separations)
  bootJs:public/js/{myapp}/index.js (Express app, JSAddress, address config)
  translationsJs:public/js/{myapp}/translations.js (one file - key→string per lang; the ONLY source of user-facing words)
  routesJs:public/js/{myapp}/routes.js (section()/sub() factories + route tree)
  graphicsJs:public/js/{myapp}/graphics.js (self-contained BetweenJS toggle/focus)
  packageJson:root package.json + public/js/{myapp}/package.json (main=index.js)
|

@playbook |
  scaffold:copy ONLY the framework seed (strawnode.js + whole module dir) from the working StrawNode stack in play; write every project layer (server/boot/routes/graphics/templates/models/css) fresh - never copy a prior app's layout or naming
  boot:|
  index.jade:load i18next.js THEN <script src="/js/strawnode.js?starter=./myapp/">
  on 'strawnode-ready':fire Express.app.fire('JSAddress') to route the hash
  address:app.set('address',{home:'home',base:location.protocol+'//'+location.host+location.pathname,useLocale:true,defaultLocale:document lang})
  hashes:useLocale → #/en/<section>/, deep child #/en/solution/technology/
  routes:module.exports = {home:section('home'), solution:section('solution',{technology:sub('technology')}), pricing:section('pricing'), about:section('about')}
  otherDialect:config members also valid - {about:{index:{urljade:'/jade/about.jade','@toggle':toggle}}, contact:{urljade:'/jade/contact.jade','@toggle':toggle}} (Landing vs Host)
|

@sectionFactory |
  section:factory creating a SELF-RENDERING viewport step; on opening sets urljade+urljson+parameters then renders via toggle
  sub:factory creating a named CHILD of a section (for deep sections like /solution/technology)
  invariant:parent WITH children must be a pure container, NOT self-rendering (no @toggle on itself) - the child/index renders
  namedChild:renderer used for named children (technology) → {response:res}
  indexChild:renderer for a bare child's landing → {response:res.parentStep}
  noSelfRenderChild:self-rendering sections CANNOT have index / '/' children (would double-render via defaultStep)
  toggleHook:fn['@toggle'] = graphics.toggle; fn['@focus'] = graphics.focus
  roles:Landing vs Host - the newer declarative route dialect maps the same rules |
  Landing:index-present config member (key 'index' + urljade/@toggle); auto response → res.parentStep, inherits section urljade
  Host:index-absent self-rendering member (urljade + @toggle at top of member); auto response → res
  noIndexHost:pure-container with children = Landing-style host (no urljade, no self render, index/children do the work)
  classifier:section owns an 'index'? no → Host (children open inside it) yes → Landing (children close it first)
  bothDialects:function factories (section()/sub()) and config members coexist in one routes.js module.exports; factories unchanged
|

@graphics |
  purpose:the toggle/focus closures ARE the lifecycle core - section loading→displaying, the disappearing, and the ready()/focusReady() triggers; navigation flow is traced through them
  perSection:routes.js descriptor wires ONE dedicated toggle per section type - about.team:{@toggle:graphics.team_toggle}, about.team.member:{@toggle:graphics.team_member_toggle} - the named toggle IS that section's own lifecycle
  selfContained:each dedicated toggle(e)/focus(e) derives everything from e.target - no external closure/alias param; res=e.target; urljade/res.userData.urljade; urljson/res.userData.urljson
  inOneBlock:the THREE primordial actions sit DIRECTLY inside toggle(e){ var res = e.target; if(res.opening){...}else{...} } - 1. template load 2. dedicated reveal/hide tweens 3. the crucial res.ready()/res.focusReady() - there is NO generic toggleOpen/toggleClose abstraction layer to duplicate per section
  openBranch:load JSON → merge locals → res.render(urljade, params, cb) → template in DOM → reveal tween → res.ready()
  closeBranch:hide tween → template.remove() → res.ready() (killed tweens/removed bindings are already out of here - the mirrored delegated undo did them)
  focus:focus(e) calls res.focusReady() on focusOut (clears the step); focusIn usually no-op
  readyContract:primordial - EVERY open eventually res.ready(); EVERY close res.ready(); focusOut → res.focusReady() or the step never clears; each fires EXACTLY once per branch - these are the anchors of deep-navigation tracing
  templateLoad:jade loading lives in the toggle on purpose - the reveal tween launches as soon as the loaded template is in the DOM: a cached/ready template starts fast, a slow fetch still completes the same ready() contract
  noAbstractionLayer:do NOT factor the in-one-block trio into shared toggleOpen/toggleClose helpers - each named toggle stays self-contained so team_toggle and team_member_toggle read WHOLE at a glance, no jumping between far-apart code locations
  delegated:the noisy rest (enable dropdowns/menus/counters/dots/hovers/observers - and clearing them) is transited OUT - to other blocks or another file (e.g. sectionbehavior.js) as a FLAT listing of coherently-named functions, each carrying the same if(cond){do}else{undo} mirroring
  noSideEffects:tween chains (serialTweens/delay/onComplete) never bury page logic - they only animate; behavior runs from the delegated named functions
|

@readability |
  standard:NON-NEGOTIABLE - the navigation flow (toggle/focus → ready()/focusReady()) and every delegated if(cond){do}else{undo} must read as prose at a glance
  mirrorRule:every create→destroy, bind→off/remove, tween-in→stop pair is written in the SAME edit; teardown is read off assemble() top-to-bottom
  delegate:page-behavior noise (dropdowns, counters, dots, hovers, observers) lives in name-coherent delegated functions, never inline in toggle/focus
  riceGuard:while constructing we add more functionality, detail, polish ('rice') - every added feature lands as a mirrored, delegated, named unit so clarity and a conventional ledger of additions survive each build-up
  branchBudget:~10 lines per branch, then extract - logic never buries itself in tween chains/delays/onComplete
  oneHook:cross-module signals use a documented hook defined in ONE place (e.g. graphics.onOpen/onClose) - never coined ad hoc mid-sprint
  gate:every sprint closes by reading the lifecycle as prose - if open/close or do/undo is not explainable in 30 seconds, extract before shipping
|

@jadeJson |
  renderFlow:res.userData.urljson declared → render() calls res.fetch(urljson params cb) FIRST → merges into jade locals → packResponse appends t/lang/filename AFTER
  absolutePaths:jadepath='/jade/{myapp}/' jsonpath='/js/json/{myapp}/' - ABSOLUTE, not relative ./jade/... (relative resolves vs page URL and 404s)
  fetch:strawexpress Response.fetch is now REAL (not a stub) - when res.userData.urljson is set, render() loads+merges it automatically, no manual XHR needed
  dataCache:res.userData.dataCache governs memoization - unset/'open' once per open (dropped at focusOut); 'session' module-level; false always refetch
  langParam:fetch appends ?lang=<locale> smartly (only if the endpoint lacks its own) so one API serves current locale
  degrade:API error/bad JSON → logs + renders without data (never throws, never freezes)
  loadJson:manual fallback stays $.getJSON(url).done(cb).fail(→{}) then Object.assign locals
  jadeLocals:template references top-level model keys directly (h1.hero-title= title) - they come from the merged json
  compose:extends/include IS first-class (jade_async) - bases resolve at COMPILE time and load WITHOUT the ?hash cache-buster
  patterns:|
  composeFirst:extends+blocks+includes+Mixins is the DEFAULT for every page - one-block jade only for a true single-screen scaffold, never for navs/headers/footers
  mixinRule:same markup written twice → mixin (+nav +card +cta +sectionHead +langSwitch) - mixins are the reusable, interchangeable component layer
  centralData:navs/cards/links loop over ONE sections/data array (id + t() key + path + children) - a section name lives in a single place, never scattered across jades
  inheritance:an EXISTING extends-based app must stay CONSISTENT with its own dialect - extend the right bases and override THEIR blocks; do NOT flatten it to one-block or mix dialects page-to-page
  blocks:inherited pages live on the base's block names - mismatched block names render empty/broken templates
  decide:touching existing pages → match their inheritance; greenfield pages get the compose-first default
  nameYourself:when scaffolding GREENFIELD, improvise reusable block/mixin/behavioral names as it reads most clearly - no inherited naming is mandated; the concepts are the stable part
|

@i18n |
  default:i18next + ONE translations.js is the DEFAULT word layer - never json models, never literal strings
  load:i18next.js FIRST in index.jade, THEN <script src="/js/strawnode.js?...">
  file:public/js/{myapp}/translations.js - key→string per lang; the ONLY source of user-facing words
  jades:jades call t('philosophy') through a jade-local resolver bound to the current lang
  lang:current lang comes from the address config (useLocale:true + defaultLocale = document lang) - the SAME source the hash uses
  bind:initialize i18next + resolve t() BEFORE firing JSAddress so every opened section renders translated
  noLiterals:no user-facing string ever ships in jade or js - not even placeholder/fallback text in templates
  jsonStaysForData:json models remain for DATA (counts, items, config) - words never migrate into json
|

@addressing |
  principle:internal links and the language switch ride the AddressHierarchy - never hardcoded
  links:internal hrefs = '#/' + lang + '/' + section + '/deeper/' - lang derived from the CURRENT hash/address, never a baked 'en'
  deep:child paths preserve the full route when building links (solution/technology stays deep)
  switcher:lang switch = regex on location.hash ^#/([a-z]{2})(/.*)$ → '#' + newLang + '$2', then set location.hash - the framework re-toggles the SAME route in the new locale, deep child intact
  helper:a single buildAddress/link helper produces every internal href so the shape lives once
  audit:grep hrefs for baked language segments - literals only inside the helper/translations
|

@behaviorLinking |
  core:templates hand control to JavaScript through a few stable channels - decide their spelling per project; the channels are what matter
  channels:|
  1.routeHandlers:steps declare handlers in the route config (@focus/@toggle/@open/@close); a route name like 'toggle' or 'focus' is a per-project choice, the attach mechanism is the constant
  2.elementAttrs:templates express behavior via element hooks (data-text/data-click/... and custom attrs) the browser-side proxies/behavior files read; the address is the pattern
  3.i18nKeys:words stay in translations; text/markdown come in through t() or a marked filter so a template never ships literal strings
  4.forms:forms hand off to a global entry point (e.g. AddressHierarchy/Contact) rather than inline scripts - any clear global name is fine
  reason:behavior must be reachable from anywhere a template can reference it (handlers on steps, attributes on elements, keys on translations) - never buried in template strings
|

@verification |
  playwright:headless chromium; goto /; then set location.hash for each route; assert #stage innerText non-empty + zero pageerrors
  check:for EVERY hash assert the expected heading string appears in #stage text (proves json binding, not empty template)
  deepChild:solution/technology shows BOTH parent text and child text (#stage has 2 direct children - expected, not a bug)
  serverStatic:curl each /jade/{myapp}/.../*.jade and /js/json/{myapp}/.../*.json → 200 before trusting a render
  noStore:Cache-Control: no-store in dev so edited files aren't cached by ModuleLoader XHR
  reload:no server restart needed for client JS (served fresh from disk) - just hard-refresh browser
  i18nAudit:grep jade+js for user-facing literals outside translations.js - must be empty; words only via t()
  langAudit:grep hrefs for baked language segments (/#/en/, /#/ko/) - literals must exist only inside the address helper/translations config
|

@gotchas |
  closureBug:starter helper.js toggle(e,closure) requires an external closure id that attachHandler never passes → "Cannot read properties of undefined (reading 'execute')" → just write a self-contained toggle instead
  fetchStub:OLD NOTE - fetch is no longer a stub; a missing JSON model still renders EMPTY locals silently, so set res.userData.urljson or loadJson yourself per route
  relativePaths:./jade/... vs /jade/{myapp}/... - wrong base → 404 on template XHR; use absolute
  baseCache:route template gets a fresh ?hash but inherited bases do NOT - an edited base may look stale/cached; hard-refresh in dev
  mixedDialects:one-block page next door to extends-pages = style rot; pick per-project and stick to it
  indexDouble:giving a self-rendering section an index/ child double-renders; keep containers pure (a Host section must NOT also carry an index landing)
  opacityScale:set template css opacity 0 BEFORE append; BetweenJS.to then animates to 1 - a tween cannot start from an unset value
  readyNotCalled:forgetting res.ready() on one branch → navigation wedges, subsequent hashes stuck
  noLiteralStrings:user-facing words hardcoded in jade/js instead of t() = an untranslatable site; words live only in translations.js
  bakedLang:'/#/en/...' literals in internal hrefs break every other locale - route all links through the address helper
  defaultStep:bare section (no child) still needs its own toggle to render (a Host); sub sets index renderer (that index = the Landing)
|

@index |
  session:@session
  core:@core @dependencies
  philosophy:@philosophy
  layout:@layout @playbook
  sections:@sectionFactory
  lifecycle:@graphics
  readability:@readability
  data:@jadeJson
  i18n:@i18n
  address:@addressing
  behavior:@behaviorLinking
  verify:@verification
  gotchas:@gotchas
  quickRef:dots get strawnode-prototype.s @playbook
|
