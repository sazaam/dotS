@meta
name: gpu-draw
tags: [blender, gpu, draw, overlay, preview]
ver: 4.5.14

@facts
SpaceView3D.draw_handler_add(callback, (), "WINDOW", "POST_PIXEL") -> handle. Callback receives no args when args=().
SpaceView3D.draw_handler_remove(handle, "WINDOW"). Must be idempotent: track globally, guard double registers.
gpu.shader.from_builtin("UNIFORM_COLOR") available; bind + uniform_float("color", (r,g,b,a)).
batch_for_shader(shader, "POINTS", {"pos": coords}). gpu_extras.batch.
gpu.state.point_size_set(float) + gpu.state.blend_set("ALPHA") needed for dots; restore to 1.0 / "NONE" after draw.
POST_PIXEL vectors use the SAME logical-pixel units as region.width/height and event.mouse_region_x/y - DO NOT multiply by ui_scale/dpi or the overlay shifts and stretches on HiDPI (canonical modal template uses raw mouse_region coords).
HiDPI: preferences.system.ui_scale & preferences.view.ui_scale exist (default 1.0; NO system.dpi_factor) but are NOT needed for POST_PIXEL alignment.
Background/-b mode: registering the draw handler is safe, but from_builtin inside the callback only runs in a real GL context. NEVER call gpu.shader at import time in background (hardops python-module crash pattern).
Dotted preview: resample segment (a,b) at fixed px spacing into points; apply ui-scale to coords; tag redraws via region.tag_redraw().
Cursor: context.area.header_text_set(str|None). CURSOR IS ON Window in 4.5: context.window.cursor_modal_set("CROSSHAIR") for modal ops + context.window.cursor_modal_restore() in teardown. context.area.cursor_set does NOT exist in 4.5 (removed).

@gotchas
- draw callback args tuple must match callback arity (use () and a zero-arg callback).
- Keep draw handlers module-global; unregister on addon unregister to avoid stale handlers after extension reload.
- Preview state (points/color) shared module-level dict; never hold scene refs across redraws.
- POINTS batch with single shader is cheap; rebuild batch each draw, or cache by pan? Rebuild — simpler.

@verification
Headless selftest: assert register()/unregister() idempotent, _DRAW_HANDLE set/None, set_preview/clear_preview state. Interactive: run SKETCH_OT_DrawGuide, verify dotted line follows cursor in a 3D viewport.