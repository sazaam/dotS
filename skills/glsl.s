# GLSL + ShaderToyLite Knowledge Base

@meta |topic:glsl shader shaderwebgl shader toy|versions:GLSL ES 3.0|lastUpdated:2026-08-18|confidence:high|

@types |
  void:void
  float:float (32-bit)
  int:int
  bool:bool
  vec2:vec2(x, y)
  vec3:vec3(x, y, z) or vec3(xyz)
  vec4:vec4(x, y, z, w) or vec4(xyzw) or vec4(rgb, a)
  mat2:mat2 (2x2 matrix)
  mat3:mat3 (3x3 matrix)
  mat4:mat4 (4x4 matrix)
  sampler2D:sampler2D (2D texture)
  samplerCube:samplerCube (cubemap)
  ivec2/3/4:integer vectors
  bvec2/3/4:boolean vectors
  uvec2/3/4:unsigned int vectors
|

@swizzle |
  xyzw:position components
  rgba:color components
  stp:textcoord components
  xy:vec2(x, y)
  xyz:vec3(x, y, z)
  xyzw:vec4(x, y, z, w)
  rgb:vec3(r, g, b)
  rrg:vec4(r, r, g, b) (repeat allowed)
|

@mathBuiltins |
  sin:sin(x)
  cos:cos(x)
  tan:tan(x)
  asin:asin(x) (-π/2 to π/2)
  acos:acos(x) (0 to π)
  atan:atan(y, x) or atan(x)
  pow:pow(x, y)
  exp:exp(x)
  log:log(x)
  exp2:exp2(x) (2^x)
  log2:log2(x)
  sqrt:sqrt(x)
  inversesqrt:inversesqrt(x)
  abs:abs(x)
  sign:sign(x)
  floor:floor(x)
  ceil:ceil(x)
  fract:fract(x) (x - floor(x))
  mod:mod(x, y) (x - y * floor(x/y))
  clamp:clamp(x, min, max)
  min:min(x, y)
  max:max(x, y)
  mix:mix(x, y, a) (lerp)
  step:step(edge, x)
  smoothstep:smoothstep(edge0, edge1, x)
  length:length(x)
  distance:distance(p0, p1)
  dot:dot(x, y)
  cross:cross(x, y) (vec3 only)
  normalize:normalize(x)
  faceforward:faceforward(N, I, Nref)
  reflect:reflect(I, N)
  refract:refract(I, N, eta)
  matrixCompMult:matrixCompMult(x, y) (element-wise)
  lessThan:lessThan(x, y)
|

@texture |
  texture:texture(sampler, coord)
  textureLod:textureLod(sampler, coord, lod)
  textureProj:textureProj(sampler, coord)
  texelFetch:texelFetch(sampler, coord, lod)
  textureSize:textureSize(sampler, lod)
  textureGrad:textureGrad(sampler, coord, dPdx, dPdy)
|

@flow |
  if:if (cond) { } else { }
  for:for (init; cond; incr) { }
  while:while (cond) { }
  break:break
  continue:continue
  discard:discard (fragment shader only)
  return:return value
|

@qualifiers |
  in:in (vertex input / fragment varying)
  out:out (vertex output / fragment output)
  uniform:uniform (constant per draw call)
  varying:varying (deprecated, use in/out)
  flat:flat (no interpolation)
  smooth:smooth (default interpolation)
  const:const (compile-time constant)
  precision:precision highp float;
  invariant:invariant (output must match)
|

@vertexShader |
  input:in vec2 vertexInPosition (or vec3 aPos)
  output:out vec2 vUv (or varying)
  builtin:gl_Position = vec4(pos, 0.0, 1.0)
  builtinSize:gl_PointSize = size
  passThrough:vUv = aTexCoord (pass to fragment)
|

@fragmentShader |
  input:in vec2 vUv (from vertex)
  output:out vec4 fragColor (or gl_FragColor in ES2)
  coord:gl_FragCoord.xy (pixel position)
  builtin:gl_FragCoord (vec4, xy = pixel coords)
  depth:gl_FragDepth = value (write depth)
|

@noise |
  valueNoise:fract(sin(dot(floor(p), vec2(12.9898, 78.233))) * 43758.5453)
  perlinNoise:use gradient noise with smoothstep
  simplexNoise:use permutation polynomial
  fbm:for(int i=0; i<octaves; i++) { value += amp * noise(p); p *= 2.0; amp *= 0.5; }
  turbulence:abs(noise(p)) instead of noise(p)
  voronoi:distance to nearest point in grid
  cellular:cellular noise for organic patterns
|

@sdf |
  circle:float sdCircle(vec2 p, float r) { return length(p) - r; }
  box:float sdBox(vec2 p, vec2 b) { vec2 d = abs(p) - b; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); }
  line:float sdSegment(vec2 p, vec2 a, vec2 b) { vec2 pa = p-a, ba = b-a; return length(pa - ba*clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0)); }
  roundedBox:sdBox + radius
  union:sdf1 < sdf2 ? sdf1 : sdf2
  subtract:max(sdf1, -sdf2)
  intersection:max(sdf1, sdf2)
  smoothUnion:smoothstep(min, max, d1-d2)
  opSmoothUnion:float opSmoothUnion(float d1, float d2, float k) { float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0); return mix(d2, d1, h) - k*h*(1.0-h); }
|

@raymarching |
  setup:vec3 ro (ray origin), vec3 rd (ray direction)
  direction:rd = normalize(vec3(uv, focalLength))
  march:for(int i=0; i<MAX_STEPS; i++) { d = scene(ro + rd*t); if(d < EPSILON) break; t += d; }
  normal:vec3 n = normalize(vec3(scene(p+eps) - scene(p-eps), 2.0*eps))
  lighting:float diff = max(dot(n, lightDir), 0.0)
  ambient:color * ambientStrength
  shadows:soft shadows via marching from hit point to light
  ao:ambient occlusion by sampling along normal
  reflection:reflect(rd, n) + offset
  refraction:refract(rd, n, eta)
  distanceField:return float (signed distance)
  scene:float scene(vec3 p) { return opUnion(sdBox(p), sdSphere(p)); }
|

@shadertoylite |
  header:"ShaderToy-compatible uniforms provided by ShaderToyLite"
  version:"GLSL ES 3.0 (#version 300 es)"
  precision:"precision highp float; precision highp int;"
  textureCompat:"#define texture2D texture"
  output:"out vec4 frag_out_color"
  entryPoint:"void mainImage(out vec4 c, in vec2 f)"
  mainWrapper:"main() calls mainImage()"
|

@stlUniforms |
  iResolution:vec3 (viewport width, height, 1.0)
  iTime:float (elapsed time in seconds)
  iTimeDelta:float (frame delta in seconds)
  iFrameRate:float (assumed 60)
  iFrame:int (frame counter)
  iChannelTime:float[4] (per-channel time)
  iChannelResolution:vec3[4] (per-channel resolution)
  iMouse:vec4 (xy = current pos if down, zw = click pos)
  iChannel0:sampler2D (input channel 0)
  iChannel1:sampler2D (input channel 1)
  iChannel2:sampler2D (input channel 2)
  iChannel3:sampler2D (input channel 3)
  iDate:vec4 (year, month, day, unixtime)
  iSampleRate:float (44100)
|

@stlAPI |
  constructor:new ShaderToyLite(canvasId, forceIndependent)
  setCommon:setCommon(source) (shared GLSL code)
  setBufferA:setBufferA({ source, iChannel0-3 })
  setBufferB:setBufferB({ source, iChannel0-3 })
  setBufferC:setBufferC({ source, iChannel0-3 })
  setBufferD:setBufferD({ source, iChannel0-3 })
  setImage:setImage({ source, iChannel0-3 })
  setOnDraw:setOnDraw(callback) (pre-draw hook)
  play:play() (start animation)
  pause:pause() / stop() (pause animation)
  resume:resume() (resume if paused)
  reset:reset() (reset time + frame)
  time:time() (total elapsed seconds)
  isPlaying:isPlaying() (boolean)
  redraw:redraw() (single frame)
  addTexture:addTexture(texture, key) (external texture)
|

@stlPasses |
  passes:A, B, C, D, Image
  pingPong:double-buffered for feedback (A/B textures)
  routing:setBufferA({ iChannel0: 'B' }) reads B into A
  feedback:pass output feeds into next frame input
  chain:A reads D, B reads A, Image reads B
  imagePass:Image pass renders to screen (no framebuffer)
|

@stlConfig |
  alpha:false (no alpha channel)
  depth:false (no depth buffer)
  stencil:false (no stencil buffer)
  antialias:true (MSAA)
  preserveDrawingBuffer:false (for perf)
  powerPreference:high-performance
|

@stlGotchas |
  version:must use #version 300 es
  texture2D:ShaderToy uses texture2D, GLSL300 uses texture
  mainImage:must define void mainImage(out vec4, in vec2)
  gl_FragCoord:use gl_FragCoord.xy, not fragCoord in mainImage
  precision:must declare precision
  flips:ping-pong flips each frame, watch input ordering
  iMouse:iMouse.zw = 0 when mouse up (click ended)
  common:setCommon recompiles all passes
  dispose:not implemented (manual WebGL cleanup needed)
|

@glslGotchas |
  noExplicitTypes:GLSL is strongly typed, declare everything
  noImplicitConversion:float f = 1.0; not float f = 1;
  noIntegerOps:can't mix int/float without cast
  arrayLoop:for(int i=0; i<arr.length(); i++) (no .length on arrays)
  noStrings:no string type in GLSL
  noDynamicLoops:loop count must be compile-time constant
  precision:float precision affects performance
  mediump:mediump is 16-bit, can cause artifacts
  highp:use highp for positions, coords
  texture2D:deprecated in GLSL300, use texture()
  gl_FragColor:deprecated in GLSL300, use out variable
  varying:deprecated in GLSL300, use in/out
  attribute:deprecated in GLSL300, use in
|

@commonPatterns |
  uv:vec2 uv = gl_FragCoord.xy / iResolution.xy
  centeredUV:vec2 uv = (gl_FragCoord.xy - 0.5*iResolution.xy) / iResolution.y
  aspectCorrected:vec2 uv = gl_FragCoord.xy / iResolution.xy; uv.x *= iResolution.x/iResolution.y
  timeWarp:float t = iTime * speed
  pulse:float pulse = 0.5 + 0.5*sin(iTime)
  colorPalette:vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b*cos(6.28318*(c*t+d)); }
  hash21:float hash21(vec2 p) { p = fract(p*vec2(123.34, 456.21)); p += dot(p, p+45.32); return fract(p.x*p.y); }
  noise2D:float noise(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); f = f*f*(3.0-2.0*f); return mix(mix(hash21(i), hash21(i+vec2(1,0)), f.x), mix(hash21(i+vec2(0,1)), hash21(i+vec2(1,1)), f.x), f.y); }
  fbm:float fbm(vec2 p) { float v=0.0; float a=0.5; for(int i=0; i<6; i++) { v+=a*noise(p); p*=2.0; a*=0.5; } return v; }
|

@verification |
  1.cmd:echo "check browser console for compilation errors"
  1.note:"ShaderToyLite logs shader compile errors"
  2.note:"use WebGL inspector or Spector.js for debugging"
  3.note:"check uniform locations (null = not active/uniform)"
  4.note:"verify texture bindings (TEXTURE0-3)"
|
