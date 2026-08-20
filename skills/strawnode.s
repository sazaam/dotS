@ jadeTemplates |
  location:public/jade/artists/
  base:basesection.jade 5 lines base nav zone template
  content:basecontent.jade 7 lines base content zone template
  section:section.jade 10 lines main section extending basesection
  nav:nav.jade 28 lines breadcrumb navigation
  navsection:navsection.jade 17 lines section list navigation
  indicator:indicator.jade 37 lines section header with prev/next arrows
  mixins:mixins.jade shared jade mixins includes shaders.jade and svgs.jade
  index:index.jade landing page with WebGL shaders
  layout:layout.jade parent template just block content in body
  shaders:shaders.jade 5339 lines global shader vars NOT rendered in index.jade HTML only in AJAX sections
  contentProject:content_project.jade project content with slides
  projectTemplates:section_desc.jade section_choose_item.jade section_item_detail.jade section_item_numeric.jade section_project.jade contact.jade randomizer.jade navsection_project.jade
|
@meta |
  type:SPA framework core boot and module system
  pattern:custom CommonJS browser loader with async pre-fetch and synchronous eval
|
@boot |
  entry:public/js/strawnode_app/index.js 47 lines
  sequence:|
  1.:Create Express app
  2.:Register Jade engine
  3.:Set address config with en/ locale prefix
  4.:Register JSAddress listener
  5.:Register routes from routes.js
  6.:app.get('/', routes)
  htmlShell:public/jade/default.jade loads strawnode.js with starter=./strawnode_app/
  strawnodeInit:strawnode.js reads own script src extracts starter= param
  requireScan:recursively scans for require() calls via regex
  preFetch:async XHR pre-fetches entire dependency tree
  evalSync:evaluates modules synchronously from cache
  umd:wrapper exposing require module exports
|
@modules |
  core:|
  type.js:OOP class system with packages domains mixins interfaces
  strawexpress.js:SPA router 4525 lines hash-based with command queue
  betweenjs.js:animation engine 6945 lines tweens easing color
  reactive.js:186 lines dependency-tracked computed/watch/effect uses Watcher with deps Set track batch WeakMap
  reactive-i18n.js:132 lines live reactive i18n bindContainer scans [i18n] elements creates effects tracking scope.lang()
  input:|
  gesture.js:476 lines touch gesture manager hooks Express.app.attachHandler for swipe drag pinch rotate tap multi-pointer tracking velocity/distance thresholds
  keyboard.js:132 lines keyboard event manager same attachHandler interception for @keydown types supports scoped selectors
  ui:|
  modgraph.js:196 lines visual SVG dependency graph reads require.getGraph() edges renders interactive SVG
  unit.js:605 lines lightweight test framework sync/async tests done-callback thenable nested suites setup/teardown 5s timeout
  vendor:|
  jade_async.js:4241 lines modified Jade compiler with async XHR preloading fs._cache fs.preload dependency scanning for include/extends
  jade.js:Jade runtime
  jquery-1.8.1.min.js:jQuery
  jquery.ba-hashchange.min.js:jQuery hashchange plugin
  i18next.js:i18next internationalization
  marked.js:Markdown parser
  lenis.js:lenis smooth scroll
  lazyload.js:lazy loading
  lite-yt-embed.js:YouTube embed
  gsap.min.js:GSAP animation
  scrolltrigger.min.js:GSAP ScrollTrigger
  shadertoylite.js:ShaderToy WebGL shader player
  tilt-utils.js:55 lines preloadImages lerp getCursorPos map calcWinsize
  interactive-tilt.js:interactive tilt effect
|
@sectionSystem |
  factory:sections.js provides section() and project() factory helpers
  section:creates self-rendering viewport section with userData.urljade urljson parameters
  project:creates deep leaf node with slide support
  deck:section({deck:true}) stamps userData.deck for project gallery behavior
  routes:routes.js defines nested route objects with handler functions
  behavior:sectionbehavior.js handles focus/toggle verification WebP detection image preloading
  graphics:graphics.js handles animations using BetweenJS for @focus and @toggle events
  events:events.js EventEnhancer for resize arrow key navigation keyboard shortcuts
|
@serverSide |
  app:app.js Express app setup jade view engine static middleware route mounting
  routes:routes/index.js server-side hierarchy mirror
  exports:ssection() factory find(path) resolve translate() register routes Unique Hierarchy HierarchyChanger Step routes routesjson
  nodestep:routes/nodestep.js 655 lines server-side Step/Hierarchy/E classes
  classes:CodeUtil StringUtil ArrayUtil PathUtil Step Unique HierarchyChanger Hierarchy Response E
  type:routes/type.js 281 lines server-side Type system CommonJS version
  contact:routes/contact.js 102 lines POST handler nodemailer rate limiting email validation HTML escaping
  user:routes/user.js 8 lines stub user route
|
@dependencyGraph |
  strawnode.js:requires type.js and all strawnode_modules/*
  package.json:maps aliases type Express Jade BetweenJS jquery hashchange i18next shadertoylite lazyload
  modgraph:visualizes require.getGraph() edges as interactive SVG tree
|
@keyPatterns |
  twoTierHierarchy:server-side routes/nodestep.js mirrors client-side strawexpress.js
  sectionLifecycle:|
  registration:Express.get() creates Response attaches to step hierarchy
  navigation:hashchange -> Hierarchy.redistribute -> formulate -> CommandQueue
  open:commandOpen -> step_opening -> render jade template -> step_open
  focus:focusIn fires after all descendants opened
  close:commandClose -> step_closing -> fadeOut template -> remove -> step_close
  destroy:Step.destroy removes from parent empties children unregisters ancestor
  attachHandler:GestureManager and KeyboardManager intercept Express.app.attachHandler to register handlers alongside framework events
  jadePreload:jade_async.js scans include/extends dependencies fetches async then synchronous rendering from cache same pattern as strawnode.js
|
@quirks |
  devMachine:/home/saz/Sites/github/strawAI is NOT a git repo
  prodDeploy:/var/www/metavagrant.com is git repo git rev-parse works
  shaderGlobals:not in rendered HTML come from AJAX-loaded section scripts via basesection.jade include ./mixins
  betweenjsDefaultEase:Expo.easeOut not Linear
  opacityScale:BetweenJS uses 0-100 not 0-1
  relativePrefix:$ not + for relative values
  panicThreshold:240 update steps per frame triggers system break in AnimationTicker
  live404:unmatched routes create temporary steps that auto-remove on close
|
