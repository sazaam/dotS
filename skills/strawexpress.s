@meta |
  type:SPA framework core
  file:public/js/strawnode_app/strawnode_modules/strawexpress.js
  lines:4904
  deps:type.js
  author:saz aka True
  version:1.0.0
  lastUpdated:2026-09-08
  pattern:hash-based SPA router with command queue navigation
|
@architecture |
  description:hash-based SPA router modeling navigation as tree of Step nodes
  flow:|
  URL:hash change
  ->:focusIn/focusOut events fire
  keyPattern:command-queue-based navigation every nav produces Command array executed sequentially
  mirroring:Express.js server-side API (app.get, middleware, settings) in browser
|
@classes |
  Kompat:Lines 44-181
  purpose:null-safe URL/hash path manipulation
  methods:_setLevel error warn info debug
  CodeUtil:Lines 188-207
  StringUtil:Lines 211-234
  constants:SPACE SLASH HASH AROBASE DOLLAR EMPTY
  extends:Number.prototype.clamped(min max)
  NumberUtil:Lines 237-248
  ArrayUtil:Lines 252-286
  PathUtil:Lines 327-419
  Logger:Lines 293-322
  levels:error:0 warn:1 info:2 debug:3
|
@networking |
  Request:Lines 427-600
  signature:Request(url complete postData error progress)
  methods:setTimeout(ms) load(async url complete postData error keepInLocalCache forceBrowserNoCache progress) destroy
  features:sync/async caching timeout progress legacy IE ActiveX
  cache:in-memory response cache at line 525
  AjaxRequest:Lines 602-632
  extends:Request
  forces:async mode
|
@proxy |
  Proxy:Lines 645-871
  purpose:dynamic proxy/prototype system for any object or DOM element
  nativeUses:native Proxy when available fallback to static closure enumeration
  methods:getProxy(target) Class(t o)
  handler:makeNativeHandler(tar over) builds native Proxy with get/set/has traps
  populate:populateOriginal(tar over) pre-populates over.original with getter/setter closures
|
@events |
  IEvent:Lines 881-898
  signature:IEvent(type data)
  purpose:static central event relay managing listener registration proxy chains dispatch hierarchy
  DOMEventDispatcher:Lines 902-968
  methods:loop _addHandler _removeHandler _registerDispatcher _registerProxy
  EventDispatcher:Lines 974-1047
  extends:DOMEventDispatcher
  registries:_listeners _proxies _dispatchers
  Global:Lines 1053-1501
  domProxy:generateDomProxyAlongTarget(p) create EventDispatcher for DOM element
  dispatch:bind unbind willTrigger fire trigger triggerDown
|
@domnode |
  DOMNodeProxy:Lines 1503-2030
  purpose:event-driven DOM element proxy using native Proxy
  statics:find(selector) wrap(node) unwrap(p) hookup(root) tween(node prop endValue cfg receiver disp)
  globalAlias:window.prox = DOMNodeProxy
  eventMethods:on off once trigger with @-prefix support
  traversal:children parent
  content:html(v) text(v) val(v)
  classHelpers:addClass removeClass toggleClass hasClass
  domManip:append remove attr css
  animation:animate(props cfg) multi-property BetweenJS animation
  cssProps:auto-detected from document.body.style animated when config.time present
  attrs:getAttribute setAttribute fallback for unknown properties
  directives:|
  data-text:key one-way scope.key -> textContent
  data-bind:key two-way textContent + input -> scope.key
  data-click:expr evaluate JS in scope via with(p) { expr }
  data-show:key data-hide=key display toggle
  data-scope:marks root scope element
  events:|
  @focus:> focusIn + focusOut
  @open:> step_opening
  @close:> step_closing
  @toggle:> step_opening + step_closing
  @toggleIn:> step_opening
  @toggleOut:> step_closing
  mutation:MutationObserver for attribute/child/character mutations fires change event
|
@commands |
  Command:Lines 2039-2081
  extends:Command
  signature:AjaxCommand(url success? postData? init? progress?)
  methods:execute returns this async cancel destroy
  async:truthy return = sync falsy = async
  CommandQueue:Lines 2087-2206
  depth:tracking via $-chain depth = this.depth + '$'
  behavior:sync commands advance immediately async await depth event
  WaitCommand:Lines 2211-2275
  AjaxCommand:Lines 2281-2342
  reloadCommand:Lines 3677-3692 close + reopen the step ONLY - ancestor chrome re-render (.navzone/.contentzone surgery + hard-coded templateB urljade) REMOVED (2026-09-08); framework must not know project chrome - the per-project two-template A/B split lives in graphics.js, templateA/B are project targeting
|
@backgroundQueue |
  BackgroundTaskQueue:Lines 4379-4587
  purpose:priority task queue that drains tasks across animation frames
  requires:BetweenJS for frame scheduling warns and falls back to setTimeout if missing
  tiers:|
  Tier:2 on-demand:does not auto-drain call flush(2) explicitly
  constructor:BackgroundTaskQueue() initializes tiers running paused currentTier taskCount _draining
  statics:|
  hasBJS():> boolean check if BetweenJS available
  getBJS():> Object|null get BJS reference (BetweenJS or BJS global)
  methods:|
  add(task:tier?) => this add task to tier (default 1)
  start():> this begin processing tier 0 sync tier 1 via rAF
  pause():> this pause tier 1 processing
  resume():> this resume tier 1 after pause
  cancel(tier?):> this clear specific tier or all if omitted
  flush(tier):> this manually drain a specific tier
  pending():> number tasks remaining across all tiers
  destroy():> release references
  events:|
  'complete':fires when all tiers are drained
  'taskComplete':fires after each task finishes
  usage:|
  var:q = new BackgroundTaskQueue();
  q.add(function():{ precompileShader(heroConfig); }, 0);
  q.add(function(done):{ loadPointCloud(done); }, 1);
  quirks:|
  tier:2 requires explicit flush(2) call
  BetweenJS:fallback uses setTimeout(fn 0) functional but not frame-aligned
  _draining:flag prevents overlapping frame scheduling
  done():is idempotent safe to call multiple times
|
@cyclic |
  Cyclic:Lines 2350-2604
  purpose:cyclic array wrapper for carousel navigation with trigonometric index mapping
  signature:Cyclic(arr?)
  methods:add remove next prev go seek size launch destroy
  unit:object with index deg rad computed from array length
  math:radians for circular index computation
|
@step |
  Step:Lines 2612-3065
  purpose:singleton root step registered under id '@'
  signature:Step(id commandOpen commandClose)
  openLifecycle:|
  1.:Guard throw if not opened/opening
  2.:Set closing = true
  3.:If isCloseable execute commandClose
  4.:Dispatch step_closing
  5.:If async bind completion then checkCloseNDispatch
  6.:opened = false closing = false dispatch step_close
  closeLifecycle:|
  treeMethods:add remove empty getChild hasChild getIndexOfChild
  navMethods:play kill next prev getNext getPrev hasNext hasPrev handleNext handlePrev handleUp handleDown
  hierarchyMethods:register unregister registerAsAncestor linkHierarchy
  events:dispatchOpening dispatchOpen dispatchClosing dispatchClose dispatchFocusIn dispatchFocusOut dispatchCleared
  state:id path depth index parentStep children alphachildren opened opening closing playhead looping isFinal way state userData loaded defaultStep ancestor
  static:Step.hierarchies{} global registry of all step paths keyed by ancestor ID
  Unique:Lines 3071-3095
  extends:Step
  methods:getInstance
  behavior:all navigation starts from this root
|
@address |
  Address:Lines 3103-3150
  fields:base protocol host hostname port path hash abshash qs loc
  locale:extracts from path or hash pattern /{2-letter-lang}/
  AddressHierarchy:Lines 3735-3813
  extends:HierarchyChanger
  purpose:hash-based URL manager
  methods:enable(loc hierarchy uniqueClass) getValue setValue setStepValue setTitle
  statics:setup(params) create(uniqueclass?) isReady
  params:home base useLocale defaultLocale
  AddressChanger:Lines 3819-3977
  enableFlow:|
  1.:Parse URL parts via _extractUrlParts
  2.:Set ancestor on hierarchy
  3.:If no hash redirect to #/{locale}/
  4.:Init locale from URL or document lang
  5.:Bind jQuery hashchange event
  6.:Open root step then trigger hashchange
  hashchange:|
  Extract:locale from hash
  Update:i18next.changeLanguage if locale changed
  Normalize:multiple separators
  Add:trailing slash if missing
  Call:hh.redistribute(hash)
|
@response |
  Response:Lines 4028-4377
  extends:Step
  purpose:a route handler wrapping Step with rendering focus and template loading
  signature:Response(id pattern? commandOpen? commandClose?)
  methods:ready focusReady fetch render packResponse send generateHash isLiveStep
  render:|
  1.:If res.userData.urljson set, res.fetch(urljson params cb) runs FIRST so merged data is present in locals
  2.:Append ?{randomHash} for cache-busting
  3.:AJAX load template URL via Request
  4.:Call packResponse to parse
  5.:Callback with jQuery-wrapped template
  fetch:real JSON loader (was a STUB - now active)|
  Auto:called by render() when res.userData.urljson is declared - routes never call it
  Merge:Object.assign(params data) top-level; t/lang/filename set by packResponse AFTER merge so API cannot clobber i18next
  dataCache:scoped per-route in res.userData |
  unset/'open':fetch once per step-open, share between both template passes, memo dropped on focusOut (delete res.userData.data)
  'session':module-level _sessionDataCache keyed by URL
  false:always refetch every render
  lang:appends ?lang=<locale> smartly only when endpoint lacks its own
  degrade:bad JSON or failed XHR logs and renders WITHOUT data (never throws)
  packResponse:|
  Set:params.filename params.lang params.t = i18next.t
  If:.jade extension use jade.render(t params callback)
  Otherwise:wrap as raw jQuery $(t)
  generateHash:Math.random.toString(36) random cache-busting hash
  namedParams:pattern like /user/:id compiled to regex with paramNames array
  liveStep:isLiveStep checks if dynamically matched route
  structuralDefaults:constructor open command re-derives under res.userData |
  autoResponse:parameters.response = (id=='') ? parentStep : res when not declared
  viewportInherit:landing (id '') with no urljade inherits its section's userData.urljade
  explicitWins:any urljade/parameters/userData set by the handler overrides the derived defaults
  routeRoles:Landing vs Host - the two ROLE classes, decided by owning an 'index' |
  classifier:section owns an 'index' (defaultStep)? no -> Host yes -> Landing
  Landing:index-present; closes before its children open; @toggle dismantles surface on departure; ready() completes close, focusReady() clears focus
  Host:index-absent self-rendering (non-child); opens once and STAYS; children open within as panes/slides; state persists across child tour
  tableauStamps:section({style:'tableau'}) stamps userData.tableau on the host; templates and sectionbehavior read it
  tableauVsPassage:kind layer - Tableau = destination section (you arrive and linger, pan across panes); Passage = transitional (default, invites a deeper path, dolly through)
  motion:pan = turn across the surface (inside a Tableau); dolly = travel into depth (through Passages)
|

@lexicon |
  role:the two canonical vocabularies - learn before naming things in this domain |
  structure:Landing / Host - does the section own an 'index'? |
  Landing:index-present; children close it first (a threshold you pass through)
  Host:index-absent self-rendering (non-child); children open within it
  kind:Tableau / Passage - destination vs threshold |
  Tableau:you arrive and linger; browse its panes; section({style:'tableau'})
  Passage:transitional by definition; it invites the next deeper path (the default - a Landing member)
  motion:pan / dolly |
  pan:turn across the surface (inside a Tableau)
  dolly:travel into depth (through Passages)
  line:you pan across a Tableau - you dolly along a Passage
  children:panes (inside a Tableau) vs pages (a Passage leads to pages)
|
@express |
  Express:Lines 4589-4903
  purpose:main SPA singleton app
  routeRegistration:|
  get(pattern:handler parent?) register route
  get(key):settings getter 1 arg
  handler:checks res.opening to know open/close
  sets:res.userData.urljade urljson parameters on open
  configMember:non-function object route is converted by handlerFromConfig |
  detect:isConfigObject child-aware at non-'/' patterns; hasSectionMarkers STRICT at '/' keeps the routes-module from collapsing into one section
  dataProps:urljade tableau etc hoisted into res.userData
  atProps:@toggle @focus @open @close attached via attachHandler
  children:object values recurse as child routes (index -> landing step id '')
  funcs:function values remain plain child routes (section()/project() factories compose unchanged)
  synthesized:a member with NO @-renderer key -> pure container completing via res.ready(); with one -> pass-through return res
  settings:|
  env:development
  views:undefined
  liveautoremove:true auto-remove dynamic/404 steps on close
  middleware:|
  savescroll:true save/restore scroll on focus
  use(fn):global before-guard
  use('/path':fn) scoped before-guard
  use('after':fn) post-navigation hook
  returning:false cancels navigation
  events:listen trigger fire discard willTrigger willTriggerNow
  lifecycle:createClient initJSAddress address isReady
  response:enableResponse removeResponse
  attachHandler:bind/unbind lifecycle events
  handlerConvention:|
  handler['@focus']:-> focusIn + focusOut
  handler['@toggle']:-> step_opening + step_closing
  handler['@open']:/ handler['@close'] -> single event
  static:Express.app singleton Express.disp global EventDispatcher(window)
|
@middleware |
  beforeGuard:|
  app.use(fn):matches all paths
  app.use('/path':fn) matches path prefix
  returning:false cancels navigation
  runs:at Hierarchy.launchDeep before formulate
  afterHook:|
  app.use('after':fn) runs post-navigation
  fires:after CommandQueue completes
|
@formulate |
  description:core routing algorithm in Hierarchy.formulate(path) Lines 3385-3533
  steps:|
  1.:Compare temporary path against current path
  2.:If temp starts with current (descending) search children for match
  3.:Support regex children and :param named parameters
  4.:If no match create a live 404 step
  5.:If ascending close current step
  regex:content between slashes treated as intentional regex
  live404:dynamic steps that auto-remove on close when liveautoremove=true
|
@integration |
  strawnode:strawexpress is loaded by strawnode.js require system
  jade:templates use jade syntax with inheritance basesection.jade section.jade
  jadeHere:extends/include = first-class (jade_async); bases resolve at compile time and load WITHOUT the ?hash cache-buster; inherited pages must override the base's blocks
  jadeMixins:a base-top include ./mixins bundles a mixin library into every extended page (see jade.s @strawLibrary) - new shared components go in the library, never forked into a template
  betweenjs:all transitions use BetweenJS tween engine
  i18next:locale-aware routing with hash URLs and /{locale}/ prefix
  jquery:hashchange event binding for URL monitoring
  sections:|
  sections.js:provides section() and project() factory helpers
  section({style:'tableau'}) stamps userData.tableau for the project gallery (see @lexicon)
  routes.js:a single module.exports object; members are config members (Landing/Host) or function factories - both compose
  configHere:index key -> Landing section; self-rendering member w/ @toggle + no index -> Host; wheel in via routes.js dialect
  boot:|
  index.js:creates Express app registers Jade engine
  Sets:address config with en/ locale prefix
  Registers:routes from routes.js
  Calls:app.get('/', routes)
|
