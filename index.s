@p |
  name:dotS
  ver:0.1.0
|

@quickRef |
  ponytail:s get skills/ponytail.s @rules
  ponytailReview:s get skills/ponytail.s @run.review
  css:s get skills/css.s
  html:s get skills/html.s
  threejs:s get skills/threejs.s
  glsl:s get skills/glsl.s
  md:s get skills/md.s
  jade:s get skills/jade.s
  obsidian:s get skills/md.s @obsidian
  shaderToy:s get skills/glsl.s @shadertoylite
  htmlValidate:s get skills/html.s @run.validate
  htmlLint:s get skills/html.s @run.lint
  a11y:s get skills/html.s @run.accessibility
  seoCheck:s get skills/html.s @run.seoCheck
  cssLint:s get skills/css.s @run.lint
  cssValidate:s get skills/css.s @run.validate
  cssSpecificity:s get skills/css.s @run.specificity
  cssAudit:s get skills/css.s @run.audit
  docker:s get skills/docker.s
  dockerCompose:s get skills/docker.s @compose
  dockerMultiStage:s get skills/docker.s @multiStage
  git:s get skills/git.s
  gitUndo:s get skills/git.s @undoing
  gitBranching:s get skills/git.s @branching
  gitCommitting:s get skills/git.s @committing
  gitMerging:s get skills/git.s @merging
  javascript:s get skills/javascript.s
  jsES6:s get skills/javascript.s @es6Features
  jsAsync:s get skills/javascript.s @async
  jsArrays:s get skills/javascript.s @arrays
  jsGotchas:s get skills/javascript.s @gotchas
  linux:s get skills/linux.s
  linuxProcess:s get skills/linux.s @processes
  linuxNetworking:s get skills/linux.s @networking
  linuxSystemd:s get skills/linux.s @systemd
  nginx:s get skills/nginx.s
  nginxSSL:s get skills/nginx.s @ssl
  nginxSecurity:s get skills/nginx.s @security
  nginxReverseProxy:s get skills/nginx.s @reverseProxy
  nginxGotchas:s get skills/nginx.s @gotchas
  node:s get skills/node.s
  nodeDebug:s get skills/node.s @debugging
  nodePerformance:s get skills/node.s @performance
  nodeGotchas:s get skills/node.s @gotchas
  python:s get skills/python.s
  pythonTypes:s get skills/python.s @types
  pythonClasses:s get skills/python.s @classBasics
  pythonGotchas:s get skills/python.s @gotchas
  sh:s get skills/sh.s
  shConditionals:s get skills/sh.s @conditionals
  shPipes:s get skills/sh.s @pipesRedirection
  shGotchas:s get skills/sh.s @gotchas
  ssh:s get skills/ssh.s
  sshConfig:s get skills/ssh.s @config
  sshTunnel:s get skills/ssh.s @tunneling
  sshSecurity:s get skills/ssh.s @security
  strawexpress:s get skills/strawexpress.s
  strawexpressRoutes:s get skills/strawexpress.s @express
  strawexpressStep:s get skills/strawexpress.s @step
  strawexpressFormulate:s get skills/strawexpress.s @formulate
  strawexpressEvents:s get skills/strawexpress.s @events
  strawexpressDOM:s get skills/strawexpress.s @domnode
  strawexpressCommands:s get skills/strawexpress.s @commands
  strawexpressBackground:s get skills/strawexpress.s @backgroundQueue
  strawexpressCyclic:s get skills/strawexpress.s @cyclic
  strawexpressAddress:s get skills/strawexpress.s @address
  strawexpressMiddleware:s get skills/strawexpress.s @middleware
  strawnode:s get skills/strawnode.s
  strawnodeBoot:s get skills/strawnode.s @boot
  strawnodeModules:s get skills/strawnode.s @modules
  strawnodeSections:s get skills/strawnode.s @sectionSystem
  strawnodeJade:s get skills/strawnode.s @jadeTemplates
  betweenjs:s get skills/betweenjs.s
  betweenjsCreate:s get skills/betweenjs.s @publicAPI
  betweenjsEasing:s get skills/betweenjs.s @easing
  betweenjsTween:s get skills/betweenjs.s @tweenHierarchy
  betweenjsColor:s get skills/betweenjs.s @color
  betweenjsModern:s get skills/betweenjs.s @modernEnhancements
  betweenjsQuirks:s get skills/betweenjs.s @quirks
  type:s get skills/type.s
  typeDefine:s get skills/type.s @core
  typePackages:s get skills/type.s @packages
  typeSlots:s get skills/type.s @slots
  typeUsage:s get skills/type.s @usage
  typeQuirks:s get skills/type.s @quirks
|

@runQuickRef |
  htmlValidate:npx htmlhint **/*.html
  htmlLint:npx stylelint **/*.css
  cssLint:npx stylelint **/*.css
  a11y:npx pa11y **/*.html
  seoCheck:s get skills/html.s @run.seoCheck
  gitCommit:s run skills/git.s @run.quickCommit
  gitRelease:s run skills/git.s @run.releaseTag
  gitSquash:s run skills/git.s @run.squashMerge
  gitUndo:s run skills/git.s @run.undoLastCommit
  gitClean:s run skills/git.s @run.cleanBranches
  nginxSSL:s run skills/nginx.s @run.sslSetup
  nginxRenew:s run skills/nginx.s @run.sslRenew
  nginxTest:s run skills/nginx.s @run.configTest
  nginxTrouble:s run skills/nginx.s @run.troubleshoot
  nginxCache:s run skills/nginx.s @run.staticCacheSetup
  dockerBuild:s run skills/docker.s @run.buildPush
  dockerUp:s run skills/docker.s @run.composeUp
  dockerRestart:s run skills/docker.s @run.composeRestart
  dockerClean:s run skills/docker.s @run.cleanSlate
  dockerHealth:s run skills/docker.s @run.healthCheck
  linuxDisk:s run skills/linux.s @run.diskCleanup
  linuxLogs:s run skills/linux.s @run.logRotate
  linuxProcs:s run skills/linux.s @run.processAudit
  linuxSecurity:s run skills/linux.s @run.securityCheck
  linuxSetup:s run skills/linux.s @run.serverSetup
  sshKey:s run skills/ssh.s @run.keySetup
  sshTunnel:s run skills/ssh.s @run.tunnelLocal
  sshDeployKey:s run skills/ssh.s @run.deployKey
  nodeDeploy:s run skills/node.s @run.buildDeploy
  nodeDev:s run skills/node.s @run.devSetup
  nodeTest:s run skills/node.s @run.testSuite
  nodeHealth:s run skills/node.s @run.productionCheck
|

@byTask |
  minimalCode:skills/ponytail.s
  codeReview:skills/ponytail.s
  styling:skills/css.s
  layout:skills/css.s
  markup:skills/html.s
  accessibility:skills/html.s
  seo:skills/html.s @seo @structuredData @openGraph
  metaTags:skills/html.s @seo @metadata
  threeD:skills/threejs.s
  webgl:skills/threejs.s
  3d:skills/threejs.s
  animation3d:skills/threejs.s @animation
  shaders:skills/glsl.s
  glsl:skills/glsl.s
  shaderToy:skills/glsl.s @shadertoylite
  raymarching:skills/glsl.s @raymarching
  sdf:skills/glsl.s @sdf
  markdown:skills/md.s
  obsidian:skills/md.s @obsidian @obsidianPlugins @obsidianBestPractices
  vault:skills/md.s @obsidian
  notes:skills/md.s @obsidian @obsidianDataview
  templates:skills/jade.s
  jade:skills/jade.s
  pug:skills/jade.s @vsPug
  containers:skills/docker.s
  compose:skills/docker.s @compose
  deployment:skills/docker.s skills/linux.s skills/ssh.s
  versionControl:skills/git.s
  branching:skills/git.s @branching
  committing:skills/git.s @committing
  merging:skills/git.s @merging
  undo:skills/git.s @undoing
  frontend:skills/javascript.s
  vanillaJS:skills/javascript.s
  es6:skills/javascript.s @es6Features
  jsAsync:skills/javascript.s @async
  linux:skills/linux.s
  server:skills/linux.s
  processes:skills/linux.s @processes
  networking:skills/linux.s @networking
  systemd:skills/linux.s @systemd
  webServer:skills/nginx.s
  nginx:skills/nginx.s
  ssl:skills/nginx.s @ssl
  reverseProxy:skills/nginx.s @reverseProxy
  backend:skills/python.s skills/node.s
  node:skills/node.s
  nodejs:skills/node.s
  debugging:skills/node.s @debugging
  python:skills/python.s
  python3:skills/python.s
  shell:skills/sh.s
  scripting:skills/sh.s
  bash:skills/sh.s
  zsh:skills/sh.s
  ssh:skills/ssh.s
  tunneling:skills/ssh.s @tunneling
  keygen:skills/ssh.s @keygen
  spa:strawexpress.s strawnode.s
  routing:strawexpress.s @express strawexpress.s @formulate
  animation:betweenjs.s
  tweening:betweenjs.s @publicAPI betweenjs.s @tweenHierarchy
  easing:betweenjs.s @easing
  colorAnimation:betweenjs.s @color
  oop:type.s
  classSystem:type.s @core type.s @packages
  domProxy:strawexpress.s @domnode
  backgroundTasks:strawexpress.s @backgroundQueue
  gestures:strawexpress.s @domnode
  i18n:strawnode.s @modules
  templating:strawnode.s @jadeTemplates
  moduleSystem:strawnode.s @boot strawnode.s @modules
  execution:skills/git.s @run skills/nginx.s @run skills/docker.s @run skills/linux.s @run skills/ssh.s @run skills/node.s @run
  automation:skills/sh.s skills/docker.s
  security:skills/nginx.s @ssl skills/nginx.s @security skills/ssh.s @security
  performance:skills/node.s @performance skills/nginx.s @cache
  logAnalysis:skills/linux.s @logAnalysis
|

@index |
  ponytail.s:blocks:8|topic:yagni minimal code|keyBlocks:@rules @commands
  css.s:blocks:13|topic:css styling layout verification|keyBlocks:@flexbox @grid @gotchas @modern @run
  html.s:blocks:18|topic:html markup accessibility seo verification|keyBlocks:@semantic @forms @accessibility @seo @structuredData @run
  threejs.s:blocks:18|topic:threejs 3d webgl rendering|keyBlocks:@core @geometry @material @mesh @animation @controls @loader @postprocessing @gotchas
  glsl.s:blocks:16|topic:glsl shader shadertoylite|keyBlocks:@shadertoylite @stlAPI @stlUniforms @sdf @raymarching @noise
  md.s:blocks:14|topic:markdown obsidian|keyBlocks:@obsidian @obsidianCallouts @obsidianDataview @obsidianPlugins @obsidianBestPractices
  jade.s:blocks:15|topic:jade pug template|keyBlocks:@syntax @browserLib @browserAPI @vsPug @asyncLibDetails
  docker.s:blocks:19|topic:docker containers compose|keyBlocks:@containers @compose @multiStage @gotchas @run
  git.s:blocks:24|topic:git version control|keyBlocks:@branching @committing @merging @undoing @run
  javascript.s:blocks:16|topic:vanilla JS ES5-ES6+|keyBlocks:@es6Features @arrays @async @gotchas
  linux.s:blocks:22|topic:linux admin|keyBlocks:@processes @networking @systemd @gotchas @run
  nginx.s:blocks:21|topic:nginx web server|keyBlocks:@ssl @security @reverseProxy @gotchas @run
  node.s:blocks:20|topic:node.js runtime|keyBlocks:@debugging @performance @errors @gotchas @run
  python.s:blocks:17|topic:python 3.12+|keyBlocks:@types @functions @classBasics @gotchas
  sh.s:blocks:14|topic:shell scripting|keyBlocks:@conditionals @functions @pipesRedirection @gotchas
  ssh.s:blocks:16|topic:ssh connections|keyBlocks:@config @keygen @tunneling @security @run
  strawexpress.s:blocks:12|topic:strawexpress SPA router|keyBlocks:@architecture @step @express @response @formulate
  strawnode.s:blocks:7|topic:strawnode boot framework|keyBlocks:@boot @modules @sectionSystem @jadeTemplates
  betweenjs.s:blocks:11|topic:BetweenJS animation engine|keyBlocks:@tweenHierarchy @easing @publicAPI @color @modernEnhancements
  type.s:blocks:8|topic:Type.js OOP class system|keyBlocks:@core @packages @slots @usage @quirks
  index.s:blocks:4|topic:dotS knowledge base index|keyBlocks:@index @byTask @quickRef @runQuickRef
|
