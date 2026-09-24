# Blender Addon Authoring (extension era, 4.5 LTS + 5.x)
@meta |
  topic:blender-addon
  versions:4.5-lts 5.0 5.1 5.2-lts
  confidence:high
  lastUpdated:2026-09-22
  python:3.11(4.5-lts)|3.13(5.0+)
  focus:addon design, layouts, keymaps, live overlay UI
  ignore:pre-3.6 API is dead, never target it
|
@dependencies |
  requires:blender-python.s python.s
|
@core |
  purpose:author, design, install, debug Blender add-ons
  era:extensions system (4.2+) - blender_manifest.toml replaces bl_info
  legacy:4.5 still loads legacy bl_info addons (deprecated); 5.x too, but new code = extensions
  lts:4.5 LTS Jul-2025 to Jul-2027 | 5.2 LTS Jul-2026 to Jul-2028
  structure:addon_dir/blender_manifest.toml + addon_dir/__init__.py (+ submodules)
  installDir:user extensions ~/.config/blender/<ver>/extensions/user_default/
  onlineAccess:bpy.app.online_access_enabled - gate all network calls
|
@manifest |
  file:blender_manifest.toml at package root
  schema:schema_version = "1.0.0"
  id:must equal package directory name, unique per repo
  required:id, version, name, type, blender_version_min
  type:"add-on" or "theme"
  version:"1.2.0" semver string - not ints like bl_info
  min:blender_version_min = "4.5.0" (or "5.2.0" for 5.2-only)
  max:blender_version_max is EXCLUSIVE - first version NOT supported
  maxGotcha:exclusive max confuses users when a gate blocks unexpectedly
  tags:allowed list in docs (e.g. "Animation", "Import-Export")
  license:["SPDX:GPL-3.0-or-later"]
  optional:website, maintainer, tagline, description
  wheels:3rd-party deps as wheels in wheels/ dir (matching Python version)
  blInfo:remove bl_info from __init__ - manifest wins, never define both
  namespace:registered as extensions.<repo>.<id> - __package__ varies by install
  neverSetPackage:extensions must not overwrite __package__
|
@preferences |
  class:bpy.types.AddonPreferences subclass
  bl_idname:__package__ - required
  draw:def draw(self, context): standard layout as in @layouts
  access:bpy.context.preferences.addons[__package__].preferences
  oldAccess:addons["module_name"] breaks - repo namespace changed the key
  storePath:bpy.utils.extension_path_user(__package__, path="", create=True)
  subPath:extension_path_user(path="sub/dir") kept across upgrades, wiped on uninstall
  props:define bpy.props on the class body - owned by the class, no manual cleanup
|
@operatorsDesign |
  idname:bl_idname = "myaddon.do_thing" - lowercase dot-separated, unique
  label:bl_label human name | desc:bl_description tooltip
  options:bl_options = {'REGISTER', 'UNDO'} - UNDO mandatory when editing data
  invoke:def invoke(self, context, event) - mouse position, popups, modal start
  execute:def execute(self, context) - main path
  poll:@classmethod def poll(cls, context) - grey out instead of fail
  finish:{'FINISHED'} | {'CANCELLED'} | {'PASS_THROUGH'}
  propsOnOps:operator props on the class; kmi.properties.<name> pre-sets them per key
  fromUI:ops calls from handlers need context.temp_override(area=, region=)
  undo:test undo twice; never store bpy refs across undo
|
@layouts |
  panel:bpy.types.Panel subclass - bl_idname unique e.g. "VIEW3D_PT_myaddon"
  where:bl_space_type VIEW_3D | bl_region_type UI | bl_category tab name
  subpanel:subclass Panel with bl_parent_id - collapsible sections
  order:bl_order for vertical stacking | width:bl_ui_units_x on Panel
  groups:layout.box() group | row:layout.row(align=True) | grid:layout.grid_flow(columns=N)
  prop:layout.prop(data, "prop", text="") - binding the right data is everything
  op:layout.operator("myaddon.x", text="", icon='PLAY')
  menu:layout.menu("MYADDON_MT_menu") | popover:layout.popover(panel="...")
  list:template_list needs a custom list class | rows/maxrows params
  list5:template_list columns= deprecated 5.1+ - remove it, use scale_y
  density:layout.scale_y = 0.9 for tighter rows
  iconCrash:bad icon name = silent crash, panel invisible - verify icon names
  readOnly:draw() may not modify data - layout only
|
@keymaps |
  kc:wm.keyconfigs.addon - the only keyconfig add-ons may edit
  neverUser:never write wm.keyconfigs.user/default - users customize addon keymaps
  km:km = wm.keyconfigs.addon.keymaps.new(name="Object Mode", space_type="EMPTY")
  item:kmi = km.keymap_items.new("myaddon.do_thing", "T", "PRESS", ctrl=True, shift=True)
  variants:kmi.properties.amount = 5 - same op, different presets per key
  store:module-global addon_keymaps list of (km, kmi) pairs
  guard:check `if wm.keyconfigs.addon:` - background mode has no keyconfigs
  unreg:iterate list, km.keymap_items.remove(kmi), clear() - reverse order of register
  freeKeys:F5-F8 intentionally free - safest defaults
  conflict:avoid default shortcuts; check "is key free" before binding
  userEdits:users rebind/disable addon keymaps in Preferences > Keymap
  restartGotcha:user tweaks reset when addon re-registers - document this
|
@overlayDraw |
  purpose:live operator custom UI drawn on the viewport - labels, guides, previews
  bgl:gone - use gpu module
  add:handle = bpy.types.SpaceView3D.draw_handler_add(cb, args, "WINDOW", "POST_PIXEL")
  regionType:WINDOW | HEADER | PREVIEW
  drawType:POST_PIXEL = 2D HUD | POST_VIEW = 3D scene guides | PRE_VIEW | BACKDROP
  shader:gpu.shader.from_builtin("UNIFORM_COLOR") - unprefixed names in 4.x/5.x
  shaders:UNIFORM_COLOR FLAT_COLOR SMOOTH_COLOR IMAGE POINT_UNIFORM_COLOR POLYLINE_UNIFORM_COLOR
  lines:POLYLINE_UNIFORM_COLOR needs viewportSize + lineWidth uniforms
  batch:from gpu_extras.batch import batch_for_shader; batch.draw(shader)
  state:gpu.state.blend_set("ALPHA") | gpu.state.point_size_set(4.5)
  text:blf for labels - takes font_id, position/size/color/draw
  redraw:for region in context.area.regions: region.tag_redraw() in modal loop
  remove:draw_handler_remove(handle, "WINDOW") in unregister AND modal cleanup
  leak:docs warn missed handlers may need restart to release - always remove
  args:args tuple captured at add time - pass all state you need
  thread:draw runs off the main thread - no bpy.ops, no data allocation, read-only data
|
@modalPattern |
  start:invoke does modal_handler_add(self) and returns {'RUNNING_MODAL'}
  main:def modal(self, context, event): match event.type/value/direction
  move:MOUSEMOVE updates stored state and tag_redraw
  confirm:LMB or ENTER -> {'FINISHED'} | cancel:ESC or RMB -> {'CANCELLED'}
  header:context.area.header_text_set(...) | cursor:context.window.cursor_modal_set(...) restore with cursor_modal_restore() - area.cursor_set REMOVED in 4.5, API lives on Window
  absorb:handle the events you own, pass others through deliberately
  liveProp:WHEELUPMOUSE / WHEELDOWNMOUSE tweak props mid-modal
  poll:modal ops still need poll() (e.g. active object)
|
@gizmos |
  purpose:interactive screen-space handles - less manual drag math
  group:bpy.types.GizmoGroup subclass - declares gizmos per space
  gizmo:bpy.types.Gizmo subclass - the handle itself + draw
  space:bl_space_type "VIEW_3D" | bl_region_type "WINDOW"
  bind:target_set_prop(...) to drive a property from dragging
  draw:def draw(self, context) - custom overlay via gpu
  keymap:setup_keymap(self) only when custom interactions required
  benefit:viewport grab/snap UX without modal event plumbing
|
@registration |
  order:register classes in definition order; unregister reversed
  factory:register_classes_factory(CLASSES) or manual loop
  cleanup:always remove draw handlers, keymap items, wm props in unregister
  doubleEnable:registering twice -> "already registered" errors - guard or reload
  reload:script reloads leave stale classes - restart is the clean test
  persistent:bpy.app.handlers need persistent=True to survive file load
  tempOverride:any bpy.ops call from panel/draw needs real context or temp_override
|
@gotchas |
  mainThread:all bpy calls main thread only - modal/draw handlers cannot call bpy.ops
  noRefs:never store bpy data refs - store names/keys and re-resolve
  undo:undo kills refs AND requires REGISTER+UNDO on mutating ops
  icon:invalid icon ruins the whole panel silently
  relImports:extensions use relative imports only - from . import utils
  prefsKey:preferences.addons[__package__], never the literal module name
  legacyBlInfo:no bl_info in an extension - manifest wins
  idMatch:id must equal folder name or enable fails
  maxGate:blender_version_max exclusive - silently trims supported versions
  online:check bpy.app.online_access_enabled before urllib/requests
  wmProps:WindowManager props must be deleted in unregister (del)
  enum:EnumProperty item tuples - annotate all 4 fields to avoid surprises
  drawNoOps:Panel.draw() and draw handlers are read-only - no bpy.ops
  thumbs:icon file naming rules - wrong name = missing icon, not an error
|
@versionGotchas |
  python:4.5 LTS = 3.11 | 5.0+ = 3.13 (VFX2026) - wheels must match bundled Python
  templateList:template_list columns= deprecated in 5.1 - drop it, use scale_y
  shader5:POLYLINE_UNIFORM_COLOR is the line shader; 2D_/3D_ prefixed names are legacy
  gnMods:GN modifier property API changed 5.1/5.2 - check release notes before scripting
  paint:5.2 removed paint.eraser_brush / eraser_brush_asset_reference
  sequences:VSE strips = scene.sequence_editor.strips (4.4+; .sequences is legacy alias)
  ctxMgr:5.2.1 fixed context-manager __exit__ without __enter__ crash - keep guards
  detect:if bpy.app.version >= (5, 1, 0): guard branches
  dual:one addon for both LTS: blender_version_min="4.5.0" + runtime guards above
|
@run |
  scaffold:addon_dir + blender_manifest.toml + __init__.py skeleton
  manifest:blender_manifest.toml - id equals folder, blender_version_min, type "add-on"
  install:Preferences > Get Extensions/repo; or "Install legacy Add-on" for legacy zips
  testHeadless:blender -b -P __init__.py -- --selftest; or -b --python-expr "import..."
  debug:run with --debug-extensions and read the System Console window
  migrate:legacy to extension: manifest + __package__ + relative imports + drop bl_info
|
@index |
  base:@core @manifest @preferences
  operators:@operatorsDesign @modalPattern @gizmos
  ui:@layouts @keymaps
  overlay:@overlayDraw
  lifecycle:@registration @gotchas @versionGotchas
  run:@run
|