# dotS Knowledge Base Index
@meta |type:index|lastUpdated:2026-09-22|totalFiles:37|
@constraints |
  pipe:"|" has three roles: block delimiter, metadata separator, value content
  pipeRule:block ends only when a line is JUST "|" — pipes inside key:value are safe
  pipeAvoid:never put "|" alone on a line inside a block — it will close the block
  shellPipes:cmd:cat file | grep pattern is fine — the pipe is part of the value
|
@index |
  nginx.s:blocks:21|topic:nginx web server|keyBlocks:@ssl @security @reverseProxy @gotchas @run
  git.s:blocks:24|topic:git version control|keyBlocks:@branching @committing @merging @undoing @run
  node.s:blocks:20|topic:node.js runtime|keyBlocks:@debugging @performance @errors @gotchas @run
  ssh.s:blocks:16|topic:ssh connections|keyBlocks:@config @keygen @tunneling @security @run
  linux.s:blocks:22|topic:linux admin|keyBlocks:@processes @networking @systemd @gotchas @run
  docker.s:blocks:19|topic:docker containers|keyBlocks:@containers @compose @multiStage @gotchas @run
  javascript.s:blocks:16|topic:vanilla JS ES5-ES6+|keyBlocks:@es6Features @arrays @async @gotchas
  python.s:blocks:17|topic:python 3.12+|keyBlocks:@types @functions @classes @gotchas
  rust.s:blocks:25|topic:rust ownership-safe systems|keyBlocks:@ownership @borrowing @errorHandling @gotchas
  sh.s:blocks:14|topic:shell scripting|keyBlocks:@conditionals @functions @pipesRedirection @gotchas
  type.s:blocks:8|topic:Type.js OOP class system|keyBlocks:@core @packages @slots @usage @quirks
  strawexpress.s:blocks:12|topic:strawexpress SPA router|keyBlocks:@architecture @step @express @response @formulate
  strawnode.s:blocks:7|topic:strawnode boot framework|keyBlocks:@boot @modules @sectionSystem @jadeTemplates
  betweenjs.s:blocks:11|topic:BetweenJS animation engine|keyBlocks:@tweenHierarchy @easing @publicAPI @color @modernEnhancements
  blender-python.s:blocks:19|topic:blender python API bpy 5.2+|keyBlocks:@core @modules @operators @bmesh @gpu @vse @gotchas
  blender-addon.s:blocks:16|topic:blender addon authoring extensions keymaps overlay drawing|keyBlocks:@manifest @keymaps @overlayDraw @layouts @versionGotchas @run
  ffmpeg.s:blocks:13|topic:ffmpeg audio video processing|keyBlocks:@trimSilence @pitchFormant @loudness @concat @gotchas @run
  audio-drama-pipeline.s:blocks:9|topic:per-line theatrical audio drama recording pipeline|keyBlocks:@flow @trim @pacing @loudness @gotchas @futureProject
  writing-skill.s:blocks:17|topic:meta - how to write .s skills|keyBlocks:@format @blocks @tokens @patterns @optimize @gotchas @dependencies @mega @mutations @pollination
  comfy-t2v-ltx-2.3.s:blocks:8|topic:comfyui ltx-2.3 22b t2v on 16GB gpu|keyBlocks:@models @launch @workflow @vramMap @gotchas
  mml.s:blocks:20|topic:mml music macro language chiptune|keyBlocks:@basics @notes @lengths @loops @macros @dialects @gotchas
  server-setup.s:blocks:10|topic:vps server hardening fail2ban firewall deploy keys|keyBlocks:@sshHarden @firewall @fail2ban @gitKeys @verify @run
  terminal-tui.s:blocks:6|topic:terminal tui workflow herdr sessions|keyBlocks:@herdr @sessions @workflow @gotchas
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
  nginxSSL:s get nginx.s @ssl
  nginxSecurity:s get nginx.s @security
  gitUndo:s get git.s @undoing
  gitBranching:s get git.s @branching
  nodeDebug:s get node.s @debugging
  sshTunnel:s get ssh.s @tunneling
  dockerCompose:s get docker.s @compose
  linuxProcess:s get linux.s @processes
  jsES6:s get javascript.s @es6Features
  blenderAPI:s get blender-python.s @modules
  blenderBMesh:s get blender-python.s @bmesh
  blenderGPU:s get blender-python.s @gpu
  blenderAddon:s get blender-addon.s
  blenderAddonKeymaps:s get blender-addon.s @keymaps
  blenderOverlay:s get blender-addon.s @overlayDraw
  blenderAddonScaffold:s get blender-addon.s @run
  blenderVSE:s get blender-python.s @vse
  ffmpegTrim:s get ffmpeg.s @trimSilence
  ffmpegPitch:s get ffmpeg.s @pitchFormant
  ffmpegLoudness:s get ffmpeg.s @loudness
  ffmpegConcat:s get ffmpeg.s @concat
  ffmpegGotchas:s get ffmpeg.s @gotchas
  formant:s get ffmpeg.s @pitchFormant
  loudness:s get ffmpeg.s @loudness
  trimSilence:s get ffmpeg.s @trimSilence
  vse:s get blender-python.s @vse
  jsAsync:s get javascript.s @async
  jsArrays:s get javascript.s @arrays
  pythonTypes:s get python.s @types
  pythonClasses:s get python.s @classBasics
  pythonGotchas:s get python.s @gotchas
  rustBasics:s get rust.s @basics
  rustOwnership:s get rust.s @ownership
  rustBorrowing:s get rust.s @borrowing
  rustFixingErrors:s get rust.s @fixingErrors
  rustErrors:s get rust.s @errorHandling
  rustCollections:s get rust.s @collections
  rustConcurrency:s get rust.s @concurrency
  rustGotchas:s get rust.s @gotchas
  shConditionals:s get sh.s @conditionals
  shPipes:s get sh.s @pipesRedirection
  shGotchas:s get sh.s @gotchas
  typeDefine:s get type.s @core
  typePackages:s get type.s @packages
  typeSlots:s get type.s @slots
  typeUsage:s get type.s @usage
  typeQuirks:s get type.s @quirks
  strawexpressRoutes:s get strawexpress.s @express
  strawexpressStep:s get strawexpress.s @step
  strawexpressFormulate:s get strawexpress.s @formulate
  strawexpressEvents:s get strawexpress.s @events
  strawexpressDOM:s get strawexpress.s @domnode
  strawexpressCommands:s get strawexpress.s @commands
  strawexpressBackground:s get strawexpress.s @backgroundQueue
  backgroundQueue:s get strawexpress.s @backgroundQueue
  strawexpressCyclic:s get strawexpress.s @cyclic
  strawexpressAddress:s get strawexpress.s @address
  strawexpressMiddleware:s get strawexpress.s @middleware
  strawnodeBoot:s get strawnode.s @boot
  strawnodeModules:s get strawnode.s @modules
  strawnodeSections:s get strawnode.s @sectionSystem
  strawnodeJade:s get strawnode.s @jadeTemplates
  betweenjsCreate:s get betweenjs.s @publicAPI
  betweenjsEasing:s get betweenjs.s @easing
  betweenjsTween:s get betweenjs.s @tweenHierarchy
  betweenjsColor:s get betweenjs.s @color
  betweenjsModern:s get betweenjs.s @modernEnhancements
  betweenjsQuirks:s get betweenjs.s @quirks
  writeSkillFormat:s get writing-skill.s @format
  writeSkillTokens:s get writing-skill.s @tokens
  writeSkillPatterns:s get writing-skill.s @patterns
  writeSkillOptimize:s get writing-skill.s @optimize
  comfyT2V:s get comfy-t2v-ltx-2.3.s @workflow
  comfyT2VLaunch:s get comfy-t2v-ltx-2.3.s @launch
  comfyT2VModels:s get comfy-t2v-ltx-2.3.s @models
  comfyT2VVram:s get comfy-t2v-ltx-2.3.s @vramMap
  comfyT2VGotchas:s get comfy-t2v-ltx-2.3.s @gotchas
  mmlBasics:s get mml.s @basics
  mmlNotes:s get mml.s @notes
  mmlLengths:s get mml.s @lengths
  mmlLoops:s get mml.s @loops
  mmlMacros:s get mml.s @macros
  mmlChannels:s get mml.s @channels
  mmlDialects:s get mml.s @dialects
  mmlTools:s get mml.s @tools
  mmlExamples:s get mml.s @examples
  mmlGotchas:s get mml.s @gotchas
  blenderDeps:s deps blender-python
  blenderLoad:s load blender-python
  graphShow:s graph
  graphDeps:s graph --deps
  megaList:s mega list
  megaCreate:s mega create web-stack node.s docker.s nginx.s
  megaLoad:s mega load web-stack
  mutateList:s mutate list
  mutateCreate:s mutate create blender-python "game development"
  pollinateList:s pollinate list
  pollinateAll:s pollinate --all
|
@runQuickRef |
  gitCommit:s run git.s @run.quickCommit
  gitRelease:s run git.s @run.releaseTag
  gitSquash:s run git.s @run.squashMerge
  gitUndo:s run git.s @run.undoLastCommit
  gitClean:s run git.s @run.cleanBranches
  nginxSSL:s run nginx.s @run.sslSetup
  nginxRenew:s run nginx.s @run.sslRenew
  nginxTest:s run nginx.s @run.configTest
  nginxTrouble:s run nginx.s @run.troubleshoot
  nginxCache:s run nginx.s @run.staticCacheSetup
  dockerBuild:s run docker.s @run.buildPush
  dockerUp:s run docker.s @run.composeUp
  dockerRestart:s run docker.s @run.composeRestart
  dockerClean:s run docker.s @run.cleanSlate
  dockerHealth:s run docker.s @run.healthCheck
  linuxDisk:s run linux.s @run.diskCleanup
  linuxLogs:s run linux.s @run.logRotate
  linuxProcs:s run linux.s @run.processAudit
  linuxSecurity:s run linux.s @run.securityCheck
  linuxSetup:s run linux.s @run.serverSetup
  sshKey:s run ssh.s @run.keySetup
  sshTunnel:s run ssh.s @run.tunnelLocal
  sshDeployKey:s run ssh.s @run.deployKey
  nodeDeploy:s run node.s @run.buildDeploy
  nodeDev:s run node.s @run.devSetup
  nodeTest:s run node.s @run.testSuite
  nodeHealth:s run node.s @run.productionCheck
  ffmpegNormalize:s run ffmpeg.s @run.normalizeDir
  ffmpegTrimDir:s run ffmpeg.s @run.trimAllWavs
|
