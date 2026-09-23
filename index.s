@p |
  name:dotS
  ver:0.1.0
|
@quickRef |
  ponytail:dots get skills/ponytail.s @rules
  ponytailReview:dots run skills/ponytail.s @run.review
  css:dots get skills/css.s
  html:dots get skills/html.s
  threejs:dots get skills/threejs.s
  glsl:dots get skills/glsl.s
  md:dots get skills/md.s
  jade:dots get skills/jade.s
  obsidian:dots get skills/md.s @obsidian
  shaderToy:dots get skills/glsl.s @shadertoylite
  htmlValidate:dots run skills/html.s @run.validate
  htmlLint:dots run skills/html.s @run.lint
  a11y:dots run skills/html.s @run.accessibility
  seoCheck:dots run skills/html.s @run.seoCheck
  cssLint:dots run skills/css.s @run.lint
  cssValidate:dots run skills/css.s @run.validate
  cssSpecificity:dots run skills/css.s @run.specificity
  cssAudit:dots run skills/css.s @run.audit
  docker:dots get skills/docker.s
  dockerCompose:dots get skills/docker.s @compose
  dockerMultiStage:dots get skills/docker.s @multiStage
  git:dots get skills/git.s
  gitUndo:dots get skills/git.s @undoing
  gitBranching:dots get skills/git.s @branching
  gitCommitting:dots get skills/git.s @committing
  gitMerging:dots get skills/git.s @merging
  javascript:dots get skills/javascript.s
  jsES6:dots get skills/javascript.s @es6Features
  jsAsync:dots get skills/javascript.s @async
  jsArrays:dots get skills/javascript.s @arrays
  jsGotchas:dots get skills/javascript.s @gotchas
  linux:dots get skills/linux.s
  linuxProcess:dots get skills/linux.s @processes
  linuxNetworking:dots get skills/linux.s @networking
  linuxSystemd:dots get skills/linux.s @systemd
  nginx:dots get skills/nginx.s
  nginxSSL:dots get skills/nginx.s @ssl
  nginxSecurity:dots get skills/nginx.s @security
  nginxReverseProxy:dots get skills/nginx.s @reverseProxy
  nginxGotchas:dots get skills/nginx.s @gotchas
  node:dots get skills/node.s
  nodeDebug:dots get skills/node.s @debugging
  nodePerformance:dots get skills/node.s @performance
  nodeGotchas:dots get skills/node.s @gotchas
  python:dots get skills/python.s
  pythonTypes:dots get skills/python.s @types
  pythonClasses:dots get skills/python.s @classBasics
  pythonGotchas:dots get skills/python.s @gotchas
  sh:dots get skills/sh.s
  shConditionals:dots get skills/sh.s @conditionals
  shPipes:dots get skills/sh.s @pipesRedirection
  shGotchas:dots get skills/sh.s @gotchas
  ssh:dots get skills/ssh.s
  sshConfig:dots get skills/ssh.s @config
  sshTunnel:dots get skills/ssh.s @tunneling
  sshSecurity:dots get skills/ssh.s @security
  serverSetup:dots get skills/server-setup.s
  serverHarden:dots get skills/server-setup.s @sshHarden @fail2ban
  fail2ban:dots get skills/server-setup.s @fail2ban
  gitDeployKey:dots get skills/server-setup.s @gitKeys
  terminalTui:dots get skills/terminal-tui.s
  herdr:dots get skills/terminal-tui.s @herdr
  strawexpress:dots get skills/strawexpress.s
  strawexpressRoutes:dots get skills/strawexpress.s @express
  strawexpressStep:dots get skills/strawexpress.s @step
  strawexpressFormulate:dots get skills/strawexpress.s @formulate
  strawexpressEvents:dots get skills/strawexpress.s @events
  strawexpressDOM:dots get skills/strawexpress.s @domnode
  strawexpressCommands:dots get skills/strawexpress.s @commands
  strawexpressBackground:dots get skills/strawexpress.s @backgroundQueue
  strawexpressCyclic:dots get skills/strawexpress.s @cyclic
  strawexpressAddress:dots get skills/strawexpress.s @address
  strawexpressMiddleware:dots get skills/strawexpress.s @middleware
  strawnode:dots get skills/strawnode.s
  strawnodeBoot:dots get skills/strawnode.s @boot
  strawnodeModules:dots get skills/strawnode.s @modules
  strawnodeSections:dots get skills/strawnode-prototype.s @sectionFactory
  strawnodeJade:dots get skills/strawnode.s @jadeTemplates
  strawnodePrototype:dots get skills/strawnode-prototype.s
  strawnodeSession:dots get skills/strawnode-prototype.s @session
  strawnodePhilosophy:dots get skills/strawnode-prototype.s @philosophy
  strawnodeScaffold:dots get skills/strawnode-prototype.s @playbook
  strawnodeToggle:dots get skills/strawnode-prototype.s @graphics
  strawnodeJson:dots get skills/strawnode-prototype.s @jadeJson
  strawnodeVerify:dots get skills/strawnode-prototype.s @verification
  betweenjs:dots get skills/betweenjs.s
  betweenjsCreate:dots get skills/betweenjs.s @publicAPI
  betweenjsEasing:dots get skills/betweenjs.s @easing
  betweenjsTween:dots get skills/betweenjs.s @tweenHierarchy
  betweenjsColor:dots get skills/betweenjs.s @color
  betweenjsModern:dots get skills/betweenjs.s @modernEnhancements
  betweenjsQuirks:dots get skills/betweenjs.s @quirks
  type:dots get skills/type.s
  typeDefine:dots get skills/type.s @core
  typePackages:dots get skills/type.s @packages
  typeSlots:dots get skills/type.s @slots
  typeUsage:dots get skills/type.s @usage
  typeQuirks:dots get skills/type.s @usage
  mise:dots get skills/mise.s
  miseTools:dots get skills/mise.s @tools
  misePython:dots get skills/mise.s @python
  miseTasks:dots get skills/mise.s @tasks
  blenderDeps:dots deps blender-python
  blenderLoad:dots load blender-python
  blenderAddon:dots get skills/blender-addon.s
  blenderAddonKeymaps:dots get skills/blender-addon.s @keymaps
  blenderOverlay:dots get skills/blender-addon.s @overlayDraw
  blenderAddonScaffold:dots get skills/blender-addon.s @run
  graphShow:dots graph
  graphDeps:dots graph --deps
  megaList:dots mega list
  megaCreate:dots mega create web-stack node.s docker.s nginx.s
  megaLoad:dots mega load web-stack
  mutateList:dots mutate list
  mutateCreate:dots mutate create blender-python "game development"
  pollinateList:dots pollinate list
  pollinateAll:dots pollinate --all
|
@runQuickRef |
  htmlValidate:npx htmlhint **/*.html
  htmlLint:npx stylelint **/*.css
  cssLint:npx stylelint **/*.css
  a11y:npx pa11y **/*.html
  seoCheck:dots run skills/html.s @run.seoCheck
  gitCommit:dots run skills/git.s @run.quickCommit
  gitRelease:dots run skills/git.s @run.releaseTag
  gitSquash:dots run skills/git.s @run.squashMerge
  gitUndo:dots run skills/git.s @run.undoLastCommit
  gitClean:dots run skills/git.s @run.cleanBranches
  nginxSSL:dots run skills/nginx.s @run.sslSetup
  nginxRenew:dots run skills/nginx.s @run.sslRenew
  nginxTest:dots run skills/nginx.s @run.configTest
  nginxTrouble:dots run skills/nginx.s @run.troubleshoot
  nginxCache:dots run skills/nginx.s @run.staticCacheSetup
  dockerBuild:dots run skills/docker.s @run.buildPush
  dockerUp:dots run skills/docker.s @run.composeUp
  dockerRestart:dots run skills/docker.s @run.composeRestart
  dockerClean:dots run skills/docker.s @run.cleanSlate
  dockerHealth:dots run skills/docker.s @run.healthCheck
  linuxDisk:dots run skills/linux.s @run.diskCleanup
  linuxLogs:dots run skills/linux.s @run.logRotate
  linuxProcs:dots run skills/linux.s @run.processAudit
  linuxSecurity:dots run skills/linux.s @run.securityCheck
  linuxSetup:dots run skills/linux.s @run.serverSetup
  sshKey:dots run skills/ssh.s @run.keySetup
  sshTunnel:dots run skills/ssh.s @run.tunnelLocal
  sshDeployKey:dots run skills/ssh.s @run.deployKey
  serverHarden:dots run skills/server-setup.s @run.harden
  nodeDeploy:dots run skills/node.s @run.buildDeploy
  nodeDev:dots run skills/node.s @run.devSetup
  nodeTest:dots run skills/node.s @run.testSuite
  nodeHealth:dots run skills/node.s @run.productionCheck
  miseSetup:dots run skills/mise.s @run.setup
  wappCreate:dots get skills/linux-wapp.s @commands
  wappIsolation:dots get skills/linux-wapp.s @isolation
  comfyT2V:dots get skills/comfy-t2v-ltx-2.3.s @workflow
  comfyT2VLaunch:dots get skills/comfy-t2v-ltx-2.3.s @launch
  comfyT2VModels:dots get skills/comfy-t2v-ltx-2.3.s @models
  comfyT2VVram:dots get skills/comfy-t2v-ltx-2.3.s @vramMap
  comfyT2VGotchas:dots get skills/comfy-t2v-ltx-2.3.s @gotchas
  comfyMusic:dots get skills/comfy-minimax-music3.s @workflow
  comfyMusicModels:dots get skills/comfy-minimax-music3.s @models
  comfyMusicLaunch:dots get skills/comfy-minimax-music3.s @launch
  comfyMusicRun:dots get skills/comfy-minimax-music3.s @runCmd
  comfyMusicGotchas:dots get skills/comfy-minimax-music3.s @gotchas
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
  obsidian:skills/md.s @obsidianPlugins @obsidianBestPractices
  vault:skills/md.s @obsidian
  notes:skills/md.s @obsidianDataview
  templates:skills/jade.s
  jade:skills/jade.s
  pug:skills/jade.s @vsPug
  containers:skills/docker.s
  compose:skills/docker.s @compose
  deployment:skills/docker.s skills/linux.s skills/ssh.s skills/server-setup.s
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
  mise:skills/mise.s
  versionManager:skills/mise.s
  toolVersions:skills/mise.s @tools @config
  taskRunner:skills/mise.s @tasks
  shell:skills/sh.s
  scripting:skills/sh.s
  bash:skills/sh.s
  zsh:skills/sh.s
  ssh:skills/ssh.s
  tunneling:skills/ssh.s @tunneling
  keygen:skills/ssh.s @keygen
  spa:strawexpress.s strawnode.s
  spaPrototype:skills/strawnode-prototype.s
  prototype:skills/strawnode-prototype.s
  scaffoldSpa:skills/strawnode-prototype.s skills/jade.s skills/css.s
  strawnodeApp:skills/strawnode-prototype.s
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
  webapps:skills/linux-wapp.s
  browserApps:skills/linux-wapp.s
  isolation:skills/linux-wapp.s @isolation
  videoGen:skills/comfy-t2v-ltx-2.3.s
  ltxVideo:skills/comfy-t2v-ltx-2.3.s @workflow
  comfyOOM:skills/comfy-t2v-ltx-2.3.s @vramMap skills/comfy-t2v-ltx-2.3.s @gotchas
  musicGen:skills/comfy-minimax-music3.s
  comfyMusic:skills/comfy-minimax-music3.s @workflow skills/comfy-minimax-music3.s @models
  textToMusic:skills/comfy-minimax-music3.s @workflow
  security:skills/nginx.s @ssl skills/nginx.s @security skills/ssh.s @security skills/server-setup.s @fail2ban
  serverSetup:skills/server-setup.s
  vps:skills/server-setup.s skills/ssh.s
  hardening:skills/server-setup.s @sshHarden @fail2ban @firewall
  deployKey:skills/server-setup.s @gitKeys
  terminal:skills/terminal-tui.s
  tui:skills/terminal-tui.s @herdr @sessions
  herdr:skills/terminal-tui.s @herdr
  performance:skills/node.s @performance skills/nginx.s @cache
  blenderAddon:skills/blender-addon.s @manifest @gotchas
  addonKeymaps:skills/blender-addon.s @keymaps
  overlayDrawing:skills/blender-addon.s @overlayDraw @modalPattern
  logAnalysis:skills/linux.s @logAnalysis
|
@index |
  ponytail.s:blocks:7|topic:yagni minimal code|keyBlocks:@rules @commands
  css.s:blocks:15|topic:css styling layout verification|keyBlocks:@flexbox @grid @gotchas @modern @run
  html.s:blocks:20|topic:html markup accessibility seo verification|keyBlocks:@semantic @forms @accessibility @seo @structuredData @run
  threejs.s:blocks:22|topic:threejs 3d webgl rendering|keyBlocks:@core @geometry @material @mesh @animation @controls @loader @postprocessing @gotchas
  glsl.s:blocks:21|topic:glsl shader shadertoylite|keyBlocks:@shadertoylite @stlAPI @stlUniforms @sdf @raymarching @noise
  md.s:blocks:15|topic:markdown obsidian|keyBlocks:@obsidianCallouts @obsidianDataview @obsidianPlugins @obsidianBestPractices
  jade.s:blocks:20|topic:jade pug template|keyBlocks:@syntax @browserLib @browserAPI @vsPug @asyncLibDetails
  docker.s:blocks:18|topic:docker containers compose|keyBlocks:@containers @compose @multiStage @gotchas @run
  git.s:blocks:23|topic:git version control|keyBlocks:@branching @committing @merging @undoing @run
  javascript.s:blocks:20|topic:vanilla JS ES5-ES6+|keyBlocks:@es6Features @arrays @async @gotchas
  linux.s:blocks:21|topic:linux admin|keyBlocks:@processes @networking @systemd @gotchas @run
  nginx.s:blocks:21|topic:nginx web server|keyBlocks:@ssl @security @reverseProxy @gotchas @run
  node.s:blocks:21|topic:node.js runtime|keyBlocks:@debugging @performance @errors @gotchas @run
  python.s:blocks:24|topic:python 3.12+|keyBlocks:@types @functions @classBasics @gotchas
  sh.s:blocks:20|topic:shell scripting|keyBlocks:@conditionals @functions @pipesRedirection @gotchas
  ssh.s:blocks:17|topic:ssh connections|keyBlocks:@config @keygen @tunneling @security @run
  strawexpress.s:blocks:18|topic:strawexpress SPA router|keyBlocks:@architecture @step @express @response @formulate
  strawnode.s:blocks:13|topic:strawnode boot framework|keyBlocks:@boot @modules @sectionSystem @jadeTemplates
  betweenjs.s:blocks:14|topic:BetweenJS animation engine|keyBlocks:@tweenHierarchy @easing @publicAPI @color @modernEnhancements
  type.s:blocks:7|topic:Type.js OOP class system|keyBlocks:@core @packages @slots @lookup @utils @usage
  blender-python.s:blocks:33|topic:blender python API bpy 5.2+|keyBlocks:@core @modules @operators @bmesh @gpu @gotchas
  blender-addon.s:blocks:16|topic:blender addon authoring extensions keymaps overlay drawing|keyBlocks:@manifest @keymaps @overlayDraw @layouts @versionGotchas @run
  writing-skill.s:blocks:20|topic:meta - how to write .s skills|keyBlocks:@format @blocks @tokens @honesty @patterns @optimize @gotchas @dependencies @mega @mutations @pollination
  mise.s:blocks:14|topic:mise tool version manager env tasks|keyBlocks:@tools @config @python @node @env @tasks @gotchas @run
  linux-wapp.s:blocks:8|topic:wapp isolated browser apps|keyBlocks:@commands @isolation @fileLayout @multiAccount @gotchas
  comfy-t2v-ltx-2.3.s:blocks:9|topic:comfyui ltx-2.3 22b t2v on 16GB gpu|keyBlocks:@models @launch @workflow @vramMap @gotchas
  comfy-minimax-music3.s:blocks:9|topic:comfyui minimax music 3 t2m on 16GB gpu|keyBlocks:@models @workflow @launch @runCmd @gotchas
  server-setup.s:blocks:12|topic:vps server hardening fail2ban firewall deploy keys|keyBlocks:@sshHarden @firewall @fail2ban @gitKeys @verify @run
  terminal-tui.s:blocks:8|topic:terminal tui workflow herdr sessions|keyBlocks:@herdr @sessions @workflow @gotchas
  index.s:blocks:6|topic:dotS knowledge base index|keyBlocks:@index @byTask @quickRef @runQuickRef
  audio-drama-pipeline.s:blocks:9|topic:per-line theatrical audio drama recording pipeline|keyBlocks:@concept @flow @trim @pacing @loudness @dsp @gotchas @futureProject
  ffmpeg.s:blocks:13|topic:ffmpeg audio video processing|keyBlocks:@basics @probe @normalize @trimSilence @silenceDetect @pitchFormant @loudness @concat @sources @gotchas @run
  mml.s:blocks:20|topic:mml music macro language chiptune|keyBlocks:@dependencies @core @basics @notes @lengths @tempo @volume @transpose @detune @quantize @loops @macros @structure @channels @dialects @tools @examples @gotchas @index
  rust.s:blocks:25|topic:rust ownership-safe systems|keyBlocks:@basics @types @strings @ownership @borrowing @fixingErrors @slices @structs @enums @match @collections @errorHandling @generics @traits @lifetimes @closures @iterators @concurrency @moduleSystem @tooling @testing @gotchas @index @dependencies
  strawnode-docs.s:blocks:8|topic:strawnode-docs|keyBlocks:@boot @modules @sectionSystem @serverSide @dependencyGraph @keyPatterns @quirks
  strawnode-prototype.s:blocks:17|topic:strawnode-prototype|keyBlocks:@dependencies @core @session @philosophy @layout @playbook @sectionFactory @graphics @readability @jadeJson @i18n @addressing @behaviorLinking @verification @gotchas @index
|
