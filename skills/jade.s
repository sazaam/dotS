# Jade/Pug Template Language Knowledge Base

@meta |topic:jade pug template|versions:Jade 1.x-Pug 2.x|lastUpdated:2026-08-18|confidence:high|

@syntax |
  tag:div or just name (div is default)
  id:#myId
  class:.myClass or .class1.class2
  attributes:div(attr="value", attr2="value2")
  text:p Hello World
  multiline:p.
    Line 1
    Line 2
  comments:// comment (not rendered)
 块注释://- comment (not rendered to HTML)
  HTML comment:/** comment **/ (rendered to HTML)
  doctype:doctype html
  escape:\#{expr} or !{expr} for unescaped
  interpolation:#{variable} or #{object.property}
  literal:#{"string + expression"}
|

@attributes |
  boolean:input(type="checkbox", checked)
  dynamic:div(data-id=#{id})
  style:div(style="color: red")
  classArray:div(class=["a", "b", "c"])
  classObject:div(class={active: true, hidden: false})
  idAndClass:div#myId.class1.class2
  shorthand:div#id.class1.class2
  attrs:div(data-name="value", tabindex="1")
  multiLine: |
    div(
      attr1="value1"
      attr2="value2"
    )
|

@control |
  if:if condition
  unless:unless condition (inverse of if)
  else:else
  elseIf:else if condition
  case:case variable
  when:when value
  default:default
  each:each item in array
  eachKeyValue:each value, key in object
  while:while condition
|

@mixin |
  define:mixin mixinName(args)
  call:+mixinName(args)
  block:mixin mixinName(args)\n  block content
  callBlock:+mixinName()\n  block content
  attrs:mixin mixinName(args)\n  block content
  callAttrs:+mixinName({attr: "value"})
  dynamicCall:+#{mixinName}(args)
  restArgs:mixin mixinName(...args)
  variableArgs:+mixinName(arg1, arg2, rest...)
|

@includes |
  include:include partial.jade
  includeFiltered:include:css style.css
  includeMarkdown:include:markdown content.md
  extends:extends layout.jade
  block:block content\n  p default content
  prepend:block content\n  prepend p prepended
  append:block content\n  append p appended
  yield:yield (in parent template)
|

@filters |
  css:include:css file.css
  javascript:include:js script.js
  markdown:include:markdown file.md
  cdata:include:cdata file.cdata
  custom:register with jade.filters.name = fn
|

@builtins |
  escape:jade.escape(str)
  attrs:jade.attrs(obj, terse)
  cls:jade.cls(arr, escaped)
  merge:jade.merge(a, b)
  style:jade.style(obj)
  joinClasses:jade.joinClasses(arr)
  runtime:jade.runtime
|

@browserLib |
  file:jade_async.js (browser bundle)
  global:jade (exposed on window)
  preload:jade.preload(url, cb) (pre-fetch template + deps)
  render:jade.render(str, options, cb)
  renderFile:jade.renderFile(url, options, cb)
  compile:jade.compile(str, options) (returns function)
  compileFile:jade.compileFile(url, options, cb)
  compileClient:jade.compileClient(str, options) (returns JS string)
  compileFileClient:jade.compileFileClient(url, options, cb)
  cache:enable with { cache: true } + { filename: 'file.jade' }
  debug:enable with { compileDebug: true }
  self:enable with { self: true } (no with statement)
  client:deprecated, use compileClient instead
|

@browserAPI |
  preload:"jade.preload(url, cb) - pre-fetch template and all includes/extends"
  render:"jade.render(str, {filename: url}, cb) - render template string"
  renderFile:"jade.renderFile(url, {}, cb) - render template file"
  compile:"jade.compile(str, {filename: url}) - compile to function"
  compileFile:"jade.compileFile(url, {}, cb) - compile file to function"
  compileClient:"jade.compileClient(str, opts) - compile to client JS"
  compileFileClient:"jade.compileFileClient(url, opts, cb) - compile file to client JS"
  preloadDeps:"automatically fetches include/extends dependencies"
  asyncXhr:"uses async XHR for fetching (no fetch API)"
  es5Compat:"works in ES5 browsers (IE9+)"
|

@browserUsage |
  basic:"jade.preload('template.jade', function(err) {\n  jade.renderFile('template.jade', {data: value}, function(err, html) {\n    document.getElementById('target').innerHTML = html;\n  });\n});"
  compile:"jade.preload('template.jade', function(err) {\n  var fn = jade.compileFile('template.jade', {filename: 'template.jade'});\n  var html = fn({data: value});\n  document.getElementById('target').innerHTML = html;\n});"
  client:"var js = jade.compileClient('p Hello', {filename: 'hello.jade'});\n// js is a function string that can be eval'd or saved"
  async:"jade.preload('layout.jade', function(err) {\n  if (err) throw err;\n  jade.renderFile('layout.jade', locals, function(err, html) {\n    if (err) throw err;\n    document.body.innerHTML = html;\n  });\n});"
|

@vsPug |
  name:"Jade = original name, Pug = renamed in 2016"
  syntax:"mostly identical syntax in Jade 1.x and Pug 2.x"
  differences:"Pug 2.x adds: each...in, while loops, case/when improvements"
  deprecations:"Jade deprecated !!! doctype, use doctype html"
  deprecations:"Jade deprecated doctype 5, use doctype html"
  deprecations:"Jade deprecated client option, use compileClient"
  fileExt:".jade = Jade, .pug = Pug (both work in Pug 2.x)"
  runtime:"Jade uses jade.runtime, Pug uses pug.runtime"
  package:"npm install jade (old) vs npm install pug (new)"
  async:"Jade async lib uses XHR, modern Pug uses fetch or fs"
  compatibility:"Jade templates work in Pug (mostly backward compatible)"
  naming:"I prefer .jade extension (user preference)"
|

@jadeVsPugGotchas |
  doctype:"Jade: !!! or doctype 5 (deprecated). Pug: doctype html"
  each:"Jade: each item in arr. Pug: each...in (same syntax)"
  unless:"Jade: unless. Pug: unless (still works)"
  interpolation:"Jade: #{expr}. Pug: #{expr} (same)"
  unescaped:"Jade: !{expr}. Pug: !{expr} (same)"
  attrs:"Jade: (attr=val). Pug: (attr=val) (same)"
  multilineText:"Jade: use | prefix. Pug: use | prefix (same)"
  include:"Jade: include file.jade. Pug: include file.pug"
  extends:"Jade: extends layout.jade. Pug: extends layout.pug"
  block:"Jade: block name. Pug: block name (same)"
  mixin:"Jade: mixin name(args). Pug: mixin name(args) (same)"
  runtime:"Jade: jade.escape(). Pug: pug.escape()"
  asyncLib:"Jade async lib hardcoded .jade extension"
|

@asyncLibDetails |
  file:jade_async.js
  fs:custom fs module (in-memory cache, XHR fetch)
  normalize:fs._normalize() - collapse path segments
  resolve:fs._resolve() - resolve relative paths
  scanDeps:fs._scanDeps() - find include/extends in source
  preload:fs.preload(url, cb) - recursive dependency fetch
  cache:fs._cache - in-memory template cache
  error:"was not pre-loaded. Call jade.preload(url, cb) before rendering"
  xhr:uses XMLHttpRequest (async GET, not fetch)
  http:accepts HTTP 200 or 304
  es5:ES5 compatible (var, function, for loops)
  browserify:bundled with Browserify
|

@gotchas |
  indentation:"use spaces or tabs, not both"
  indentationCount:"2 spaces standard (configurable)"
  selfClosing:"br, hr, img, input, link, meta, area, base, col, command, embed, keygen, param, source, track, wbr"
  avoidInline:"avoid inline styles, use classes"
  avoidID:"prefer classes over IDs for reuse"
  attributeOrder:"class before id (div.class#id)"
  interpolation:"#{expr} escapes HTML, !{expr} does not"
  escape:"jade.escape() for XSS protection"
  asyncPreload:"must preload before render in browser"
  cache:"enable cache only with filename option"
  deprecations:"!!! → doctype, doctype 5 → doctype html"
  filename:"required for caching and error messages"
  clientOption:"deprecated, use compileClient method"
  pipeText:"use | for multiline text blocks"
  dotText:"use . for block text without pipes"
  caseWhen:"when must have block or break"
  eachObject:"each val, key in object (order matters)"
|

@patterns |
  layout:"extends layout.jade + block content"
  partial:"include partial.jade"
  mixin:"mixin button(label)\n  button.btn= label\n+button('Click')"
  conditional:"if user\n  p Welcome\nelse\n  p Login"
  loop:"each item in items\n  li= item"
  case:"case status\n  when 'active'\n    p Active\n  default\n    p Unknown"
  mixinAttrs:"mixin card(opts)\n  .card(class=opts.class)\n    block\n+card({class: 'wide'})\n  p Content"
|

@verification |
  1.cmd:jade --version
  1.note:"check installed jade/pug version"
  2.note:"use jade --pretty for formatted output"
  3.note:"use jade --client for client-side JS"
  4.note:"use jade --watch for file watching"
|
