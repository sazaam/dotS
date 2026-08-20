# Blender Python API (bpy) Knowledge Base
@meta |
  topic:blender-python
  versions:5.2+
  confidence:high
  lastUpdated:2026-08-21
  python:3.13
|
@core |
  module:bpy
  purpose:Python access to Blender's internal data via RNA system
  source:projects.blender.org/blender/blender.git
  docs:docs.blender.org/api/current/
  pypi:pip install bpy
|
@modules |
  bpy.data:all blend-file data (ID data blocks)
  bpy.context:current state (active object, mode, selection)
  bpy.ops:operators with undo support
  bpy.types:type definitions for all Blender structs
  bpy.props:property definitions for custom data
  bpy.utils:utility functions (registration, paths)
  bpy.app:application info (version, handlers)
  bpy.path:Blender-aware path utilities (bpy.path.abspath)
  bpy.msgbus:message bus for property notifications
  mathutils:Vector, Matrix, Quaternion, Euler, KDTree, BVHTree
  bmesh:internal mesh editing API
  gpu:GPU shader module (replaces bgl)
  blf:font drawing
  imbuf:image buffer operations
  aud:audio system
  idprop.types:ID property access
  os.path:use for file existence checks
  io.StringIO:capture print output from executed code
|
@dataCollections |
  objects:scene objects
  meshes:mesh data
  materials:materials
  scenes:scenes
  collections:collection hierarchy
  node_groups:node trees (geometry/shader/compositor)
  images:textures:lights:cameras:curves:armatures:worlds
  actions:texts:brushes:particles:movieclips:masks
  linestyles:caches:fonts:palettes:sounds:speakers
  pointclouds:volumes:greasepencils
|
@accessPatterns |
  byName:bpy.data.objects["Cube"]
  byIndex:bpy.data.objects[0]
  iterate:list(bpy.data.objects)
  create:bpy.data.meshes.new("MyMesh")
  remove:bpy.context.collection.objects.unlink(obj)
  link:bpy.context.collection.objects.link(obj)
|
@context |
  object:bpy.context.object (active object)
  selected:bpy.context.selected_objects
  scene:bpy.context.scene
  viewLayer:bpy.context.view_layer
  toolSettings:bpy.context.scene.tool_settings
  mode:bpy.context.mode (OBJECT, EDIT_MESH, SCULPT, etc.)
  area:region:window:screen:all read-only
  readOnly:context is read-only, use data API to modify
  tempOverride:with bpy.context.temp_override(...) for operators
|
@operators |
  invoke:calls operator, shows UI if available
  execute:calls operator directly, no UI
  poll:check if operator can run in current context
  draw:draw operator properties
  cancel:cancel running modal operator
  result:returns {'FINISHED'}, {'CANCELLED'}, {'PASS_THROUGH'}
  modal:runs repeatedly until cancelled
  example:bpy.ops.mesh.primitive_cube_add()
  contextOverride:with bpy.context.temp_override(area=area, region=region):
|
@depsgraph |
  get:bpy.context.evaluated_depsgraph_get()
  evalObject:obj.evaluated_get(depsgraph)
  evalMesh:obj_eval.to_mesh()
  useCases:modifier evaluation, physics, constraints
|
@properties |
  BoolProperty:IntProperty:FloatProperty:StringProperty:EnumProperty
  FloatVectorProperty:IntVectorProperty:PointerProperty:CollectionProperty
  define:my_prop: bpy.props.FloatProperty() in class body
  register:bpy.utils.register_class()
  custom:obj["my_prop"] = 42 (ID properties)
  wmProps:bpy.types.WindowManager.my_prop = bpy.props.XxxProperty()
  fileProp:StringProperty(subtype='FILE_PATH') - auto folder icon
  textPtr:PointerProperty(type=bpy.types.Text) - text block dropdown
  delete:del bpy.types.WindowManager.my_prop in unregister()
|
@operatorsDef |
  bl_idname:unique identifier (e.g., "object.my_op")
  bl_label:display name
  bl_description:tooltip text
  bl_options:{'REGISTER':True,'UNDO':True}
  bl_space_type:bl_region_type:bl_context:where shown
  invoke:def invoke(self, context, event): ...
  execute:def execute(self, context): ...
  poll:@classmethod def poll(cls, context): ...
|
@panels |
  bl_label:panel title
  bl_idname:unique identifier (e.g., "VIEW3D_PT_my_panel")
  bl_space_type:bl_region_type:bl_context:bl_category:where shown
  draw:def draw(self, context): layout = self.layout
  subpanels:subclass Panel, set bl_parent_id
  box:layout.box() - grouped section
  row:layout.row(align=True) - horizontal elements
  prop:layout.prop(wm, "my_prop", text="") - property field
  operator:layout.operator("my.operator", icon='PLAY') - button
  label:layout.label(text="Text", icon='INFO') - static text
  icons:CHECKMARK:CANCEL:X:PLAY:TEXT:FILE:ERROR:INFO:FILE_FOLDER
  invalidIcons:NETWORK does not exist - will crash
|
@operatorsUI |
  layout.prop:draw property
  layout.operator:draw operator button
  layout.label:draw text label
  layout.separator:horizontal line
  layout.row:column:box:menu:popover:arrangement helpers
  layout.template_id:selector for data blocks
  layout.context_pointer:set context for next item
|
@handlers |
  before:load_pre:save_pre:frame_change_pre:render_pre:scene_update_pre
  after:load_post:save_post:frame_change_post:render_post:scene_update_post
  render:init:render_init complete:render_complete cancel:render_cancel
  persistent:decorator to keep handler across file loads
  register:bpy.app.handlers.my_handler.append(func)
  unregister:bpy.app.handlers.my_handler.remove(func)
|
@timers |
  register:bpy.app.timers.register(func, first_interval=0, persistent=True)
  unregister:isRegistered:bpy.app.timers.unregister/is_registered(func)
  return:float = call again in N seconds, None = stop
  persistent:keep timer across file loads
  threading:use Queue + timer for thread-safe bpy calls
  pattern:server puts commands in queue, timer processes in main thread
  background:timers don't work in -b mode, must run with GUI
|
@msgbus |
  subscribe:bpy.msgbus.subscribe_rna(key, owner, args, notify, options)
  publish:bpy.msgbus.publish_rna(key)
  clear:bpy.msgbus.clear_by_owner(owner)
  key:tuple of (type, property) or RNA path
  options:{'PERSISTENT'} to survive remapping
  limitations:not triggered by viewport transform or animation
|
@bmesh |
  purpose:internal mesh editing API
  create:bm = bmesh.new()
  fromMesh:bm.from_mesh(mesh)
  toMesh:bm.to_mesh(mesh)
  fromEdit:bm = bmesh.from_edit_mesh(mesh)
  toEdit:bmesh.update_edit_mesh(mesh)
  free:bm.free() (ALWAYS call this)
  elements:bm.verts, bm.edges, bm.faces
  operators:bmesh.ops.subdivide_edges(bm, edges=edges, cuts=1)
  data:verts[].co, edges[].verts, faces[].loops
|
@gpu |
  purpose:GPU drawing (replaces bgl)
  shader:gpu.shader.from_builtin('UNIFORM_COLOR')
  batch:gpu_extras.batch.batch_for_shader(shader, 'TRIS', ...)
  offscreen:gpu.types.GPUOffScreen(width, height)
  drawHandler:SpaceView3D.draw_handler_add(callback, args, 'WINDOW', 'POST_VIEW')
  state:gpu.state.blend_set('ALPHA'), depth_test_set('ENABLED')
  builtinShaders:UNIFORM_COLOR, FLAT_COLOR, SMOOTH_COLOR, IMAGE
|
@blf |
  load:blf.load(path)
  loadDefault:blf.load_default()
  position:size:color:draw:dimensions:blur:drawBuffer:all take font_id
|
@imbuf |
  load:imbuf.load(filepath)
  loadFromBuffer:imbuf.load_from_buffer(data)
  save:imbuf.save(ibuf, filepath)
  channels:ibuf.channels (3=RGB, 4=RGBA)
  pixels:ibuf.pixels (flat array)
  rect:ibuf.rect (int buffer, BGRA)
  rectFloat:ibuf.rect_float (float buffer, RGBA)
|
@idProperties |
  access:obj["my_prop"] = value
  check:get:delete:use "in", obj.get(), del obj["my_prop"]
  types:int, float, string, array, dict
  nested:obj["settings"]["sub"] = val
  limit:1024 levels nesting depth
  ui:bpy.types.ID.id_properties_ui_get()
|
@gotchas |
  threadSafe:NO - all bpy calls must be main thread
  undoProof:NO - undo invalidates all bpy references
  contextOverride:use context.temp_override() not dict (4.0+)
  editMesh:use bmesh.from_edit_mesh() not mesh.vertices in edit mode
  dataCreate:use bpy.data.xxx.new() not xxx()
  operatorPoll:check poll() before calling operators
  drawReadOnly:Panel.draw() is read-only
  delete:bpy:NEVER store bpy references, store names instead
  timerBg:timers don't fire in background mode (-b)
  fileIcon:StringProperty(subtype='FILE_PATH') auto-adds folder icon - don't add another
  iconCrash:invalid icon name crashes silently - panel won't render
  wmPropCleanup:always del bpy.types.WindowManager.my_prop in unregister()
|
@versionGotchas |
  4_0:Principled BSDF socket renames (Subsurface→Subsurface Weight)
  5_0:shader name 3D_UNIFORM_COLOR → POLYLINE_UNIFORM_COLOR
  5_2:columns param deprecated in UILayout.template_list
  5_3:window_manager.undo_stack exposed via RNA
  detect:bpy.app.version returns (major, minor, patch)
|
@dataLifeCycle |
  create:bpy.data.meshes.new("name")
  link:bpy.context.collection.objects.link(obj)
  unlink:remove:bpy.context.collection.objects.unlink/objects.remove(obj)
  copy:mesh.copy()
  fakeUser:mesh.use_fake_user = True (prevent auto-delete)
  users:mesh.users (reference count)
  rename:obj.name = "NewName"
  update:obj.update_tag() (refresh display)
|
@animation |
  keyframeInsert:obj.keyframe_insert(data_path="location")
  keyframeDelete:obj.keyframe_delete(data_path="location")
  animData:obj.animation_data_create()
  action:fcurves:obj.animation_data.action/.fcurves
  drivers:obj.driver_add("location", 0)
  removeDriver:obj.driver_remove("location", 0)
|
@materialNodes |
  getNodeTree:bpy.data.materials["mat"].node_tree
  nodes:links:mat.node_tree.nodes/.links
  newNode:mat.node_tree.nodes.new('ShaderNodeBsdfPrincipled')
  newLink:mat.node_tree.links.new(from_socket, to_socket)
  principled:ShaderNodeBsdfPrincipled
  output:ShaderNodeOutputMaterial
|
@geometryNodes |
  access:bpy.data.node_groups["MyGN"]
  tree:nodes:inputs:outputs:tree.nodes/.interface.inputs/.outputs
  modifier:obj.modifiers["MyGN"]
  groupInput:groupOutput:bl_idname == 'NodeGroupInput'/'NodeGroupOutput'
  inputDefault:node.outputs[0].default_value
  link:tree.links.new(node1.outputs[0], node2.inputs[0])
|
@extensions |
  manifest:blender_manifest.toml (replaces bl_info)
  required:blender_version_min, name, version, tag
  optional:description, maintainer, type, license, website
  location:~/.config/blender/4.5/scripts/addons/
  install:enable:disable:bpy.ops.preferences.addon_*()
  register:unregister:def register/unregister(): ...
  onlineAccess:bpy.app.online_access (check before network)
  structure:addon_name/__init__.py + blender_manifest.toml
  blInfo:name:author:version:blender:location:description:category:doc_url:tracker_url:support
  wmProps:define in register(), delete in unregister()
  filePtr:PointerProperty(type=bpy.types.Text) creates text block dropdown
  filePath:StringProperty(subtype='FILE_PATH') adds folder icon automatically
|
@backgroundMode |
  detect:bpy.app.background
  headless:blender -b -P script.py
  render:blender -b -P render.py -- scene.blend
  limitations:no UI, limited modal operators
  output:stdout/stderr only
|
@renderEngine |
  custom:subclass bpy.types.RenderEngine
  register:render:render engine class and def render(self, scene)
  viewUpdate:viewDraw:def view_update/view_draw(self, context, depsgraph)
  availableEngines:bpy.context.preferences.addons['cycles'].preferences
|
@run |
  script:blender -b -P script.py
  background:blender -b --python script.py
  commandLine:blender --python-expr "import bpy; ..."
  addons:blender -b -P install_addon.py
  render:blender -b file.blend -o //output -f 1
  animation:blender -b file.blend -o //output -a
|
@index |
  core:@core @modules @dataCollections @accessPatterns @context
  operators:@operators @operatorsDef @operatorsUI @panels
  data:@dataLifeCycle @idProperties @animation @materialNodes @geometryNodes
  internal:@bmesh @gpu @blf @imbuf
  runtime:@handlers @timers @msgbus @depsgraph @renderEngine
  addons:@extensions @properties @gotchas @versionGotchas @backgroundMode
  execution:@run
|
