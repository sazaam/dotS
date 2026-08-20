@meta |
  type:animation tweening engine
  file:public/js/strawnode_app/strawnode_modules/betweenjs.js
  lines:6945
  deps:type.js
  author:saz aka True
  version:0.9.8
  globalAliases:BJS BTW BetweenJS
  pattern:zero-dependency creativity-oriented tweening engine with package tree via Pkg.write
|
@architecture |
  namespace:org.libspark.betweenjs
  packages:|
  loops/:AnimationTicker Animation
  tickers/:TickerListener EnterFrameTicker
  tweens/:AbstractTween Tween actions/ decorators/ groups/
  updaters/:Updater UpdaterProxy BulkUpdater UpdaterFactory
  mapping/:PropertyMapper CustomMapper
  css/:Color ColorMode RGB HSV HSL
  ease/:Linear Quad Cubic Quart Quint Sine Expo Circ Back Bounce Elastic Custom Physical
  ticker:|
  AnimationTicker:singleton manages rAF loop sub-loops panic handling frame timing
  EnterFrameTicker:linked-list ticker drives all registered tweens processes listeners in groups of 8
  starts:automatically on first tween play auto-stops when no listeners remain
  panic:if >240 update steps accumulate per frame system breaks the loop
  polyOptimization:first 4 elements stored as named properties a b c d to avoid array overhead
|
@tweenHierarchy |
  AbstractTween:Lines 1101-1654
  inherits:GroupTween
  purpose:plays child tweens sequentially
  playback:play stop start restart toggle rewind seek gotoAndPlay gotoAndStop
  lifecycle:setup teardown register unregister
  events:bind unbind fire setHandlers
  internal:tick update draw internalUpdate setPositionAndFeedback
  cloning:clone copyFrom copyHandlersFrom
  Tween:Lines 1656
  DEFAULT_TIME:1e10 sentinel meaning infinite/undetermined
  SAFE_TIME:Number.EPSILON or 0.1 fallback minimum duration
  AbstractActionTween:Lines 1677
  TweenDecorator:Lines 2101
  GroupTween:Lines 2450
  ParallelTween:Lines 2571
  SerialTween:Lines 2667
  drawOrder:draws only currently active child tweens not all
|
@actions |
  FunctionAction:Lines 1724
  purpose:DOM removeChild action with rollback appendChild
  TimeoutAction:Lines 1777
  IntervalAction:Lines 1804
  LoadAction:Lines 1859
  cache:BetweenJS.filescache same URL served from cache unless forceBrowserNoCache
  AnimationFrameAction:Lines 1982
  AddChildAction:Lines 2021
  RemoveFromParentAction:Lines 2059
|
@decorators |
  SlicedTween:Lines 2161
  purpose:adds delay before and/or postDelay after base tween
  ScaledTween:Lines 2245
  ReversedTween:Lines 2305
  RepeatedTween:Lines 2342
  DelayedTween:Lines 2398
|
@updaters |
  UpdaterFactory:Lines 2828
  purpose:groups multiple updaters for single target e.g. tweening both left and opacity
  Updater:Lines 3226
  methods:update(position) draw setFactor(position) resolveValues(forReal) setSourceValue setDestinationValue addCuePoint getIn setIn
  UpdaterProxy:Lines 3621
  BulkUpdater:Lines 3730
|
@mapping |
  PropertyMapper:Lines 3926
  purpose:uses chain of CustomMapper instances to parse get set target properties
  mappers:|
  /^transform$/i:handles CSS transform full 2D/3D decompose/recompose
  /((border|background)?color|background)$/i:handles CSS colors RGBA/HSV/HSL interpolation
  /alpha|opacity/gi:handles opacity normalized 0-100 scale
  /scroll-?(left|top)?/gi:handles scroll position window document or element
  /(.*)$/:fallback handles all other numeric CSS properties with unit support
  relativeValues:$ prefix e.g. $100 means +100 from current value
  units:append ::px ::% to property name or include in value string
  camelCase:backgroundColor becomes background-color
  transform:decomposed properties translateX translateY translateZ rotate rotateX rotateY rotateZ scaleX scaleY skewX perspectiveW
|
@easing |
  signature:all easing functions (t b c d) => value where t=elapsed b=beginning c=change d=duration
  families:|
  Linear:Quad Cubic Quart Quint Sine Expo Circ Back Bounce Elastic
  each:provides easeIn easeOut easeInOut easeOutIn
  parameterized:|
  Elastic:easeInWith(a p) easeOutWith(a p) easeInOutWith(a p) easeOutInWith(a p)
  Back:default s:1.70158
  custom:Custom.func(fn) user-provided (t b c d) => value function
  physical:|
  PhysicalUniform:Physical.uniform(velocity fps) constant velocity
  PhysicalAccelerate:Physical.accelerate(accel iv fps) constant acceleration
  PhysicalExponential:Physical.exponential(factor threshold fps) exponential decay
  isPhysical:true on updater changes interpolation to ease.calculate(position start change)
  duration:computed automatically from ease.getDuration(start change)
  defaultEase:Expo.easeOut
  defaultTime:0.75 seconds BASE_TIME
|
@color |
  ColorMode:|
  RGB:r 0-255 g 0-255 b 0-255 a 0-1
  HSV:h 0-360 s 0-100 v 0-100 a 0-1
  HSL:h 0-360 s 0-100 l 0-100 a 0-1
  conversion:|
  Color.RGBtoHSV:Color.RGBtoHSL
  Color.HSVtoRGB:Color.HSVtoHSL
  Color.HSLtoRGB:Color.HSLtoHSV
  construction:|
  Color.makeRGB(r:g b a) Color.makeHSV(h s v a) Color.makeHSL(h s l a)
  output:|
  Color.toUINT(val):Color.toHEX(val) Color.toSTR(val) Color.toOBJ(val)
  Color.toColorObj(val):Color.toColorString(val) Color.safe(val mode)
  cssColors:148 named colors lookup table at Color.css
|
@publicAPI |
  tweenCreation:|
  BJS.create(options):master factory options: target to from time ease cuepoints delay repeat decorators actions groups
  BJS.tween(target:to from time ease) create from/to tween
  BJS.to(target:to time ease) animate TO values from current state
  BJS.from(target:from time ease) animate FROM values to current state
  BJS.apply(options:applyInBetweenContext) create and optionally apply at specific time
  BJS.instant(target:properties) instantly apply properties no animation fixed version at line 6861
  bezier:|
  BJS.bezier(target:to from cuepoints time ease)
  BJS.bezierTo(target:to cuepoints time ease)
  BJS.bezierFrom(target:from cuepoints time ease)
  physics:|
  BJS.physical(target:to from ease)
  BJS.physicalTo(target:to ease)
  BJS.physicalFrom(target:from ease)
  BJS.physicalApply(target:to from ease applyTime)
  composition:|
  BJS.parallel(...tweens):variadic parallel group
  BJS.parallelTweens(array):array-based parallel group
  BJS.serial(...tweens):variadic serial group
  BJS.serialTweens(array):array-based serial group
  decorators:|
  BJS.scale(tween:scale) duration multiplier
  BJS.slice(tween:begin end isPercent) extract portion
  BJS.reverse(tween):reverse direction idempotent
  BJS.repeat(tween:repeatCount) repeat N times
  BJS.delay(tween:delay postDelay) pre/post delay
  actions:|
  BJS.func(closure:params useRollback rollbackClosure rollbackParams) call a function
  BJS.timeout(duration:closure params) fire once after duration
  BJS.interval(duration:closure params) fire repeatedly
  BJS.load(url:callback params) XHR load blocks serial chain
  BJS.animationframe(closure:params) continuous rAF loop
  BJS.addChild(target:parent) DOM appendChild
  BJS.removeFromParent(target):DOM removeChild
  clearing:|
  BJS.clearTimeout(uid):BJS.clearInterval(uid)
  BJS.clearLoad(uid):BJS.cancelanimationframe(uid)
|
@modernEnhancements |
  date:May 2026 patch
  promise:tween.play() returns tween with .then()/.catch() Promise methods
  fluent:tween.reverse() slice(scale delay repeat instance methods on AbstractTween.prototype
  utility:|
  BJS.stagger(targets:to options) animate array with staggered delay
  BJS.timeline():fluent timeline builder .add(tw offset).play()
  BJS.pause():halt entire animation system
  BJS.resume():resume after pause
  BJS.isPlaying():check if system running
  BJS.clear():stop all and reset ticker
  BJS.restart(tween):stop and replay from beginning
  BJS.stopAll():stop every active tween across all listeners
  autoPause:|
  Listens:for visibilitychange and webkitvisibilitychange
  Suspends:AnimationTicker when tab hidden restores on return
  Stores:BJS.__suspended flag
|
@usagePatterns |
  create:|
  BJS.create({target:el, to:{opacity:100}, time:.25, ease:Linear.easeOut})
  serial:|
  BJS.serial(BJS.parallelTweens(tweens),:BJS.create({target:txt, to:{opacity:100}, from:{opacity:0}, time:1.25})).play()
  serialWithDecorators:|
  BJS.serial(BJS.delay(tw_back,:0, 2), BJS.delay(BJS.reverse(tw_back), 0, 2))
  parallelTweens:|
  func:|
  BJS.func(function(){:/* side effect */ })
  tweenShorthand:|
  BJS.tween(template_project,:dims.end, dims.start, .25, Quint.easeOut)
  timeout:|
  BetweenJS.timeout(.1,:function(){ /* delayed */ })
  colorAccess:|
  var:tw_in = BJS.reverse(tw_out) returns original if already reversed
  physicalEase:|
  ease:Physical.uniform(.02) constant angular velocity orbit
  reverseIdempotent:|
|
@quirks |
  defaultEase:Expo.easeOut not Linear
  defaultTime:0.75s but Tween.DEFAULT_TIME = 1e10 sentinel
  opacityScale:0-100 not 0-1 alphaGet/alphaSet handle conversion
  relativePrefix:$ not + e.g. {left: '$100'} means current + 100
  jqueryTargets:auto-detected arrays or jQuery collections trigger bulkcreate ParallelTween
  scriptFilter:script link style tags filtered from target arrays
  loadCache:BetweenJS.filescache same URL served from cache
  instantBug:original at line 6158 used tg undefined fixed at line 6861
  clearVsStopAll:clear resets ticker state destructive stopAll walks linked list calls stop orderly
  panicThreshold:240 update steps per frame triggers system break
  polyOptimization:first 4 elements stored as named properties a b c d
  serialDrawOrder:SerialTween draws only currently active child tweens not all
  reverseIdempotent:double-reverse returns inner baseTween not double-wrapped
|
@integration |
  strawexpress:DONE by DOMNodeProxy.animate and DOMNodeProxy.tween
  events:BetweenJS.$.AnimationTicker halted/restored during blur/focus shift+space
  sectionbehavior:primary consumer for shader transitions project slides scroll reveals orbital animations
  graphics:BJS.$.ColorMode.RGB HSV BJS.tween BJS.serialTweens BJS.delay for color and layout transitions
  shadertoylite:creates raw BJS.$.Animation for continuous shader rendering loops
|
