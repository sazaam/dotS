# Blender Grease Pencil (GPv3, 4.5-lts era)
@meta |
  topic:blender-gp
  versions:4.5-lts (verified 4.5.14)
  confidence:high (introspected on 4.5.14)
  lastUpdated:2026-09-23
  python:3.11
  focus:GPv3 (GreasePencilv3) data model, stroke CRUD, brushes, placement
  ignore:legacy GPencil (GPv2) objects are different - same file, different API
|
@dependencies |
  requires:blender-python.s blender-addon.s
|
@object |
  create:only via bpy.ops.object.grease_pencil_add() - bpy.data.objects.new(name, gpd) FAILS ('ID type not valid') in 4.5
  data:bpy.data.grease_pencils.new(name) -> data object, class GreasePencilv3
  objectType:obj.type == 'GREASE_PENCIL'
  collection:OBJ created by op lands in active collection (headless: scene.collection)
|
@layers |
  new:gp.layers.new(name)
  frame:layer.frames.new(number); or layer.get_frame_at(frame)
  readOnly:layer.hide, .lock, .opacity, .blend_mode, .use_masks, .use_lights
  matrix:layer.matrix_local (world transform incl. parent stack)
  navigation:layer.current_frame
  frameHas:GreasePencilFrame attrs = drawing, frame_number, keyframe_type, select
  drawing:frame.drawing (GreasePencilDrawing) - NOT frame.strokes (GPv2 only)
|
@strokes |
  create:dr = frame.drawing; dr.add_strokes([n0, n1, ...]) - sizes per stroke, returns None
  access:dr.strokes - GreasePencilStrokeSlice, indexable & len()
  grow:dr.resize_strokes(slice_elem, new_point_count)
  remove:dr.remove_strokes(slice) / reorder_strokes / set_types - drawing-level methods
  stroke:GreasePencilStroke attrs = points, cyclic, material_index, fill_opacity, fill_color, softness, start_cap, end_cap, curve_type, time_start, aspect_ratio, select
  perAttr:stroke.points - GreasePencilStrokePointSlice; stroke.add_points / remove_points
  noBlWidth:no line_width/bl swatch in v3 - width comes from per-point radius x brush
|
@points |
  attrs:GreasePencilStrokePoint = position, radius, opacity, vertex_color, rotation, delta_time, select, handle_left, handle_right
  position:assign p.position = (x, y, z) tuple; read back list(p.position) - Vector
  radius:p.radius = meters (0.05 = ~pen nib); drives width with brush
  color:p.vertex_color = (r, g, b, a) in 0..1; p.opacity multiplies
  handles:handle_left / handle_right available for curve handles
  noCo:`.co` is GPv2 - v3 point position is `.position`
|
@placement |
  origin:tool_settings.gpencil_stroke_placement_view3d
  enum:ORIGIN | CURSOR | SURFACE | STROKE (verified 4.5)
  snap:tool_settings.gpencil_stroke_snap_mode = NONE | ENDS | FIRST
  surfaceOffset:tool_settings.gpencil_surface_offset (float, snap distance for SURFACE)
  helpers:use_gpencil_draw_onback / use_gpencil_draw_additive / use_gpencil_automerge_strokes
  targeting:SURFACE placement needs target drawn on - generated guide mesh works
|
@brushes |
  paint:tool_settings.gpencil_paint (Brush with .type), gpencil_sculpt, gpencil_vertex_paint
  brushData:bpy.data.brushes, filter b.gpencil_settings for GP brushes
  width:stroke width = radius * brush size behavior - set radius on points instead
|
@materials |
  gpmaterial:plain materials are NOT GP materials (is_grease_pencil False, grease_pencil None)
  convert:bpy.data.materials.create_gpencil_data(mat) -> material gains MaterialGPencilStyle
  style:mat.grease_pencil.color=(r,g,b,a) stroke | fill_color=(...) | show_stroke/fill
  default:grease_pencil_add ships one 'Black' GP material - reuse or create own
  surfaceMaterial:mesh guide = nodes material, BLEND blend_method; NO shadow_mode in 4.5 - use use_transparent_shadow
  solidAlpha:material.diffuse_color alpha drives Solid viewport shading transparency
|
@gotchas |
  frameStrokes:frame.strokes does NOT exist on GPv3 frames - go through frame.drawing
  addStrokesVoid:add_strokes returns None - re-read dr.strokes after
  objectNew:data.objects.new(name, gp) raises for GreasePencil - use operator or add empty then swap data may error
  typeEnum:obj.type value is 'GREASEPENCIL' (no underscore) - contrast RNA name GREASE_PENCIL
  addPollFails:object.grease_pencil_add().poll() is False in EDIT + all GP modes (paint/sculpt/weight/vertex) - guard with mode_set('OBJECT') and restore
  modeRestore:capture active object + context.mode before the dance; restore both after (active may go None if you remove it)
  headless:background mode - no GPU/draw calls; extension enabling that imports GPU shaders crashes (hardops)
  typesSplit:both GPencil* (legacy) and GreasePencilv3 classes exist in 4.5 - don't mix APIs
  numpyApi:drawing exposes add_strokes/resize_strokes/set_vertex_weights/tag_positions_changed (array-backed)
|