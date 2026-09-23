# dotS Knowledge Base Index
@meta |type:index|lastUpdated:2026-09-23|totalFiles:36|
@constraints |
  pipe:"|" has three roles: block delimiter, metadata separator, value content
  pipeRule:block ends only when a line is JUST "|" — pipes inside key:value are safe
  pipeAvoid:never put "|" alone on a line inside a block — it will close the block
  shellPipes:cmd:cat file | grep pattern is fine — the pipe is part of the value
|
@index |
  nginx.s:blocks:21|topic:nginx web server|keyBlocks:@ssl @security @reverseProxy @gotchas @run
  git.s:blocks:23|topic:git version control|keyBlocks:@branching @committing @merging @undoing @run
  node.s:blocks:21|topic:node.js runtime|keyBlocks:@debugging @performance @errors @gotchas @run
  ssh.s:blocks:17|topic:ssh connections|keyBlocks:@config @keygen @tunneling @security @run
  linux.s:blocks:21|topic:linux admin|keyBlocks:@processes @networking @systemd @gotchas @run
  docker.s:blocks:18|topic:docker containers|keyBlocks:@containers @compose @multiStage @gotchas @run
  javascript.s:blocks:20|topic:vanilla JS ES5-ES6+|keyBlocks:@es6Features @arrays @async @gotchas
  python.s:blocks:24|topic:python 3.12+|keyBlocks:@types @functions @classes @gotchas
  rust.s:blocks:25|topic:rust ownership-safe systems|keyBlocks:@ownership @borrowing @errorHandling @gotchas
  sh.s:blocks:20|topic:shell scripting|keyBlocks:@conditionals @functions @pipesRedirection @gotchas
  type.s:blocks:7|topic:Type.js OOP class system|keyBlocks:@core @packages @slots @lookup @utils @usage
  strawexpress.s:blocks:18|topic:strawexpress SPA router|keyBlocks:@architecture @step @express @response @formulate
  strawnode.s:blocks:13|topic:strawnode boot framework|keyBlocks:@boot @modules @sectionSystem @jadeTemplates
  betweenjs.s:blocks:14|topic:BetweenJS animation engine|keyBlocks:@tweenHierarchy @easing @publicAPI @color @modernEnhancements
  blender-python.s:blocks:33|topic:blender python API bpy 5.2+|keyBlocks:@core @modules @operators @bmesh @gpu @vse @gotchas
  blender-addon.s:blocks:16|topic:blender addon authoring extensions keymaps overlay drawing|keyBlocks:@manifest @keymaps @overlayDraw @layouts @versionGotchas @run
  ffmpeg.s:blocks:13|topic:ffmpeg audio video processing|keyBlocks:@trimSilence @pitchFormant @loudness @concat @gotchas @run
  audio-drama-pipeline.s:blocks:9|topic:per-line theatrical audio drama recording pipeline|keyBlocks:@flow @trim @pacing @loudness @gotchas @futureProject
  writing-skill.s:blocks:20|topic:meta - how to write .s skills|keyBlocks:@format @blocks @tokens @patterns @optimize @gotchas @dependencies @mega @mutations @pollination
  comfy-t2v-ltx-2.3.s:blocks:9|topic:comfyui ltx-2.3 22b t2v on 16GB gpu|keyBlocks:@models @launch @workflow @vramMap @gotchas
  mml.s:blocks:20|topic:mml music macro language chiptune|keyBlocks:@basics @notes @lengths @loops @macros @dialects @gotchas
  server-setup.s:blocks:12|topic:vps server hardening fail2ban firewall deploy keys|keyBlocks:@sshHarden @firewall @fail2ban @gitKeys @verify @run
  terminal-tui.s:blocks:8|topic:terminal tui workflow herdr sessions|keyBlocks:@herdr @sessions @workflow @gotchas
  comfy-minimax-music3.s:blocks:9|topic:comfy-minimax-music3|keyBlocks:@core @models @workflow @launch @runCmd @gotchas @fix @index
  css.s:blocks:15|topic:css|keyBlocks:@selectors @boxModel @flexbox @grid @position @units @media @specificity @gotchas @modern @run
  glsl.s:blocks:21|topic:glsl shader shaderwebgl shader toy|keyBlocks:@types @swizzle @mathBuiltins @texture @flow @qualifiers @vertexShader @fragmentShader @noise @sdf @raymarching @shadertoylite @stlUniforms @stlAPI @stlPasses @stlConfig @stlGotchas @glslGotchas @commonPatterns @verification
  html.s:blocks:20|topic:html|keyBlocks:@structure @semantic @forms @accessibility @media @tables @scripting @gotchas @metadata @html5Features @seo @structuredData @openGraph @performance @seoGotchas @run
  index.s:blocks:6|topic:nginx web server|keyBlocks:@index @byTask @quickRef @runQuickRef
  jade.s:blocks:20|topic:jade pug template|keyBlocks:@syntax @attributes @control @mixin @strawLibrary @compose @strawWorkflow @includes @filters @builtins @browserLib @browserAPI @browserUsage @vsPug @jadeVsPugGotchas @asyncLibDetails @gotchas @patterns @verification
  linux-wapp.s:blocks:8|topic:linux wapp browser isolation|keyBlocks:@core @commands @isolation @fileLayout @multiAccount @gotchas @index
  md.s:blocks:15|topic:markdown obsidian md|keyBlocks:@basic @obsidianCallouts @obsidianDataview @obsidianProperties @gfm @obsidianFormatting @obsidianFrontmatter @obsidianPlugins @obsidianThemes @obsidianBestPractices @obsidianMOC @markdownGotchas @obsidianGotchas
  mise.s:blocks:14|topic:mise|keyBlocks:@core @install @activate @tools @config @python @node @env @tasks @backends @gotchas @index @run
  ponytail.s:blocks:7|topic:ponytail yagni minimal-code|keyBlocks:@info @rules @commands @pluginUsage @run
  strawnode-docs.s:blocks:8|topic:strawnode-docs|keyBlocks:@boot @modules @sectionSystem @serverSide @dependencyGraph @keyPatterns @quirks
  strawnode-prototype.s:blocks:17|topic:strawnode-prototype|keyBlocks:@dependencies @core @session @philosophy @layout @playbook @sectionFactory @graphics @readability @jadeJson @i18n @addressing @behaviorLinking @verification @gotchas @index
  threejs.s:blocks:22|topic:threejs 3d webgl|keyBlocks:@core @scene @renderer @geometry @material @physical @texture @light @mesh @group @animation @controls @loader @raycasting @postprocessing @InstancedMesh @performance @webgpu @gotchas @math @examples
|
@byTask |
  webServer:nginx.s
  deployment:docker.s linux.s ssh.s
  development:node.s git.s
  frontend:javascript.s
  backend:python.s node.s
  rust:rust.s
  rustBorrowing:rust.s@borrowing rust.s@fixingErrors
  rustOwnership:rust.s@ownership rust.s@slices
  rustErrors:rust.s@errorHandling rust.s@gotchas
  scripting:sh.s
  security:nginx.s@ssl nginx.s@security ssh.s@security
  debugging:node.s@debugging linux.s@logAnalysis
  performance:node.s@performance nginx.s@cache
  automation:sh.s docker.s
  execution:git.s@run nginx.s@run docker.s@run linux.s@run ssh.s@run node.s@run
  spa:strawexpress.s strawnode.s
  animation:betweenjs.s
  oop:type.s
  templating:strawnode.s@jadeTemplates
  routing:strawexpress.s@express strawexpress.s@formulate
  domProxy:strawexpress.s@domnode
  backgroundTasks:strawexpress.s@backgroundQueue
  classSystem:type.s@core type.s@packages
  moduleSystem:strawnode.s@boot strawnode.s@modules
  tween:betweenjs.s@publicAPI betweenjs.s@tweenHierarchy
  easing:betweenjs.s@easing
  colorAnimation:betweenjs.s@color
  gestures:strawexpress.s@domnode
  i18n:strawnode.s@modules
  reactive:strawexpress.s@domnode
  blender:blender-python.s
  blenderAddon:blender-addon.s @manifest @gotchas
  addonKeymaps:blender-addon.s@keymaps
  overlayDrawing:blender-addon.s@overlayDraw blender-addon.s@modalPattern
  blenderMesh:blender-python.s@bmesh
  blenderGPU:blender-python.s@gpu
  blenderNodes:blender-python.s@geometryNodes blender-python.s@materialNodes
  blenderAnim:blender-python.s@animation
  blenderContext:blender-python.s@context blender-python.s@depsgraph
  audio:ffmpeg.s
  audioProcessing:ffmpeg.s@trimSilence ffmpeg.s@loudness
  pitchShift:ffmpeg.s@pitchFormant
  audioConcat:ffmpeg.s@concat
  dramaRecording:audio-drama-pipeline.s
  dramaTrim:audio-drama-pipeline.s@trim ffmpeg.s@trimSilence
  dramaAssembly:audio-drama-pipeline.s@flow audio-drama-pipeline.s@loudness
  blenderVSE:blender-python.s@vse
  writeSkill:writing-skill.s
  optimizeSkill:writing-skill.s@tokens writing-skill.s@optimize
  videoGenVideo:comfy-t2v-ltx-2.3.s
  ltxT2V:comfy-t2v-ltx-2.3.s@workflow
  comfyOOM:comfy-t2v-ltx-2.3.s@vramMap comfy-t2v-ltx-2.3.s@gotchas
  comfyLaunch:comfy-t2v-ltx-2.3.s@launch
  chiptune:mml.s
  mmlSequencing:mml.s@basics mml.s@notes mml.s@lengths
  mmlTiming:mml.s@loops mml.s@quantize mml.s@tempo
  mmlDrums:mml.s@macros mml.s@channels
  mmlDialectWest:mml.s@dialects mml.s@tools
  musicMacro:mml.s@macros
  serverSetup:server-setup.s
  hardening:server-setup.s@sshHarden server-setup.s@fail2ban
  terminal:terminal-tui.s
  herdr:terminal-tui.s@herdr
|
@quickRef |
  nginxSSL:dots get skills/nginx.s @ssl
  nginxSecurity:dots get skills/nginx.s @security
  gitUndo:dots get skills/git.s @undoing
  gitBranching:dots get skills/git.s @branching
  nodeDebug:dots get skills/node.s @debugging
  sshTunnel:dots get skills/ssh.s @tunneling
  dockerCompose:dots get skills/docker.s @compose
  linuxProcess:dots get skills/linux.s @processes
  jsES6:dots get skills/javascript.s @es6Features
  blenderAPI:dots get skills/blender-python.s @modules
  blenderBMesh:dots get skills/blender-python.s @bmesh
  blenderGPU:dots get skills/blender-python.s @gpu
  blenderAddon:dots get skills/blender-addon.s
  blenderAddonKeymaps:dots get skills/blender-addon.s @keymaps
  blenderOverlay:dots get skills/blender-addon.s @overlayDraw
  blenderAddonScaffold:dots get skills/blender-addon.s @run
  blenderVSE:dots get skills/blender-python.s @vse
  ffmpegTrim:dots get skills/ffmpeg.s @trimSilence
  ffmpegPitch:dots get skills/ffmpeg.s @pitchFormant
  ffmpegLoudness:dots get skills/ffmpeg.s @loudness
  ffmpegConcat:dots get skills/ffmpeg.s @concat
  ffmpegGotchas:dots get skills/ffmpeg.s @gotchas
  formant:dots get skills/ffmpeg.s @pitchFormant
  loudness:dots get skills/ffmpeg.s @loudness
  trimSilence:dots get skills/ffmpeg.s @trimSilence
  vse:dots get skills/blender-python.s @vse
  jsAsync:dots get skills/javascript.s @async
  jsArrays:dots get skills/javascript.s @arrays
  pythonTypes:dots get skills/python.s @types
  pythonClasses:dots get skills/python.s @classBasics
  pythonGotchas:dots get skills/python.s @gotchas
  rustBasics:dots get skills/rust.s @basics
  rustOwnership:dots get skills/rust.s @ownership
  rustBorrowing:dots get skills/rust.s @borrowing
  rustFixingErrors:dots get skills/rust.s @fixingErrors
  rustErrors:dots get skills/rust.s @errorHandling
  rustCollections:dots get skills/rust.s @collections
  rustConcurrency:dots get skills/rust.s @concurrency
  rustGotchas:dots get skills/rust.s @gotchas
  shConditionals:dots get skills/sh.s @conditionals
  shPipes:dots get skills/sh.s @pipesRedirection
  shGotchas:dots get skills/sh.s @gotchas
  typeDefine:dots get skills/type.s @core
  typePackages:dots get skills/type.s @packages
  typeSlots:dots get skills/type.s @slots
  typeUsage:dots get skills/type.s @usage
  typeQuirks:dots get skills/type.s @usage
  strawexpressRoutes:dots get skills/strawexpress.s @express
  strawexpressStep:dots get skills/strawexpress.s @step
  strawexpressFormulate:dots get skills/strawexpress.s @formulate
  strawexpressEvents:dots get skills/strawexpress.s @events
  strawexpressDOM:dots get skills/strawexpress.s @domnode
  strawexpressCommands:dots get skills/strawexpress.s @commands
  strawexpressBackground:dots get skills/strawexpress.s @backgroundQueue
  backgroundQueue:dots get skills/strawexpress.s @backgroundQueue
  strawexpressCyclic:dots get skills/strawexpress.s @cyclic
  strawexpressAddress:dots get skills/strawexpress.s @address
  strawexpressMiddleware:dots get skills/strawexpress.s @middleware
  strawnodeBoot:dots get skills/strawnode.s @boot
  strawnodeModules:dots get skills/strawnode.s @modules
  strawnodeSections:dots get skills/strawnode.s @sectionSystem
  strawnodeJade:dots get skills/strawnode.s @jadeTemplates
  betweenjsCreate:dots get skills/betweenjs.s @publicAPI
  betweenjsEasing:dots get skills/betweenjs.s @easing
  betweenjsTween:dots get skills/betweenjs.s @tweenHierarchy
  betweenjsColor:dots get skills/betweenjs.s @color
  betweenjsModern:dots get skills/betweenjs.s @modernEnhancements
  betweenjsQuirks:dots get skills/betweenjs.s @quirks
  writeSkillFormat:dots get skills/writing-skill.s @format
  writeSkillTokens:dots get skills/writing-skill.s @tokens
  writeSkillPatterns:dots get skills/writing-skill.s @patterns
  writeSkillOptimize:dots get skills/writing-skill.s @optimize
  comfyT2V:dots get skills/comfy-t2v-ltx-2.3.s @workflow
  comfyT2VLaunch:dots get skills/comfy-t2v-ltx-2.3.s @launch
  comfyT2VModels:dots get skills/comfy-t2v-ltx-2.3.s @models
  comfyT2VVram:dots get skills/comfy-t2v-ltx-2.3.s @vramMap
  comfyT2VGotchas:dots get skills/comfy-t2v-ltx-2.3.s @gotchas
  mmlBasics:dots get skills/mml.s @basics
  mmlNotes:dots get skills/mml.s @notes
  mmlLengths:dots get skills/mml.s @lengths
  mmlLoops:dots get skills/mml.s @loops
  mmlMacros:dots get skills/mml.s @macros
  mmlChannels:dots get skills/mml.s @channels
  mmlDialects:dots get skills/mml.s @dialects
  mmlTools:dots get skills/mml.s @tools
  mmlExamples:dots get skills/mml.s @examples
  mmlGotchas:dots get skills/mml.s @gotchas
  blenderDeps:dots deps blender-python
  blenderLoad:dots load blender-python
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
  nodeDeploy:dots run skills/node.s @run.buildDeploy
  nodeDev:dots run skills/node.s @run.devSetup
  nodeTest:dots run skills/node.s @run.testSuite
  nodeHealth:dots run skills/node.s @run.productionCheck
  ffmpegNormalize:dots run skills/ffmpeg.s @run.normalizeDir
  ffmpegTrimDir:dots run skills/ffmpeg.s @run.trimAllWavs
|
