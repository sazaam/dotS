# Three.js Knowledge Base
@meta |topic:threejs 3d webgl|versions:r150-r170+|lastUpdated:2026-08-18|confidence:high|
@core |
  scene:new THREE.Scene()
  camera:PerspectiveCamera(fov, aspect, near, far)
  orthoCamera:OrthographicCamera(left, right, top, bottom, near, far)
  renderer:new THREE.WebGLRenderer({ antialias: true })
  canvas:renderer.domElement
  clock:new THREE.Clock()
  vector3:new THREE.Vector3(x, y, z)
  vector2:new THREE.Vector2(x, y)
  color:new THREE.Color(hex | r,g,b)
  raycaster:new THREE.Raycaster()
  clockGetDelta:clock.getDelta() (time since last call)
  clockGetElapsedTime:clock.getElapsedTime() (total time)
|
@scene |
  add:scene.add(mesh)
  remove:scene.remove(mesh)
  background:scene.background = new THREE.Color(0x000000)
  fog:scene.fog = new THREE.Fog(color, near, far)
  fogExp2:scene.fog = new THREE.FogExp2(color, density)
  traverse:scene.traverse(child => { })
  children:scene.children (array)
|
@renderer |
  .setSize:renderer.setSize(w, h)
  setPixelRatio:renderer.setPixelRatio(Math.min(devicePixelRatio, 2))
  render:renderer.render(scene, camera)
  shadows:renderer.shadowMap.enabled = true
  shadowType:renderer.shadowMap.type = THREE.PCFSoftShadowMap
  toneMapping:renderer.toneMapping = THREE.ACESFilmicToneMapping
  toneExposure:renderer.toneMappingExposure = 1.0
  outputColorSpace:renderer.outputColorSpace = THREE.SRGBColorSpace
  dispose:renderer.dispose()
  resize:onResize: renderer.setSize(w, h); camera.aspect = w/h; camera.updateProjectionMatrix()
|
@geometry |
  box:BoxGeometry(w, h, d, wSeg, hSeg, dSeg)
  sphere:SphereGeometry(radius, wSeg, hSeg, phiStart, phiLen, thetaStart, thetaLen)
  plane:PlaneGeometry(w, h, wSeg, hSeg)
  cylinder:CylinderGeometry(rTop, rBot, h, rSeg, hSeg)
  cone:ConeGeometry(radius, height, rSeg)
  torus:TorusGeometry(radius, tube, rSeg, tSeg)
  torusKnot:TorusKnotGeometry(radius, tube, tSeg, p, q)
  icosahedron:IcosahedronGeometry(radius, detail)
  octahedron:OctahedronGeometry(radius, detail)
  dodecahedron:DodecahedronGeometry(radius, detail)
  ring:RingGeometry(innerR, outerR, thetaSeg)
  circle:CircleGeometry(radius, thetaSeg)
  extrude:ExtrudeGeometry(shape, { depth, bevelEnabled })
  lathe:LatheGeometry(points, segments)
  parametric:ParametricGeometry(func, uSeg, vSeg)
  buffer:BufferGeometry() (custom)
  setAttribute:geo.setAttribute('position', new THREE.BufferAttribute(array, 3))
  setIndex:geo.setIndex(array)
  computeVertexNormals:geo.computeVertexNormals()
  dispose:geo.dispose()
|
@material |
  basic:MeshBasicMaterial({ color, map, wireframe })
  lambert:MeshLambertMaterial({ color, map })
  phong:MeshPhongMaterial({ color, map, shininess })
  standard:MeshStandardMaterial({ color, map, roughness, metalness })
  physical:MeshPhysicalMaterial({ clearcoat, transmission, ior })
  toon:MeshToonMaterial({ color, map })
  depth:MeshDepthMaterial()
  normal:MeshNormalMaterial()
  wireframe:MeshBasicMaterial({ wireframe: true })
  shader:ShaderMaterial({ uniforms, vertexShader, fragmentShader })
  points:PointsMaterial({ color, size, map })
  line:LineBasicMaterial({ color })
  dashed:LineDashedMaterial({ color, dashSize, gapSize })
  clone:material.clone()
  dispose:material.dispose()
  needsUpdate:material.needsUpdate = true
|
@physical |
  clearcoat:clearcoat: 1.0 (car paint effect)
  clearcoatRoughness:clearcoatRoughness: 0.1
  transmission:transmission: 1.0 (glass effect)
  thickness:thickness: 0.5 (refraction depth)
  ior:ior: 1.5 (index of refraction)
  sheen:sheen: 1.0 (fabric effect)
  sheenRoughness:sheenRoughness: 0.5
  iridescence:iridescence: 1.0 (oil slick effect)
  anisotropy:anisotropy: 1.0 (brushed metal)
  dispersion:dispersion: 0.1 (rainbow glass)
|
@texture |
  load:textureLoader.load(url)
  rgbLoader:RGBELoader.load(url) (HDR)
  exrLoader:EXRLoader.load(url)
  repeat:texture.repeat.set(x, y)
  wrap:texture.wrapS = texture.wrapT = THREE.RepeatWrapping
  filtering:texture.minFilter = THREE.LinearMipmapLinearFilter
  magFilter:texture.magFilter = THREE.LinearFilter
  anisotropy:texture.anisotropy = renderer.capabilities.getMaxAnisotropy()
  flipY:texture.flipY = false (for some formats)
  colorSpace:texture.colorSpace = THREE.SRGBColorSpace
  dispose:texture.dispose()
|
@light |
  ambient:AmbientLight(color, intensity)
  directional:DirectionalLight(color, intensity)
  point:PointLight(color, intensity, distance, decay)
  spot:SpotLight(color, intensity, distance, angle, penumbra, decay)
  rectArea:RectAreaLight(color, intensity, w, h)
  hemisphere:HemisphereLight(skyColor, groundColor, intensity)
  castShadow:light.castShadow = true
  shadowSize:light.shadow.mapSize.set(1024, 1024)
  shadowCamera:light.shadow.camera.left/right/top/bottom
  followTarget:light.target = targetObject
|
@mesh |
  new:Mesh(geometry, material)
  position:mesh.position.set(x, y, z)
  rotation:mesh.rotation.set(x, y, z) (Euler)
  quaternion:mesh.quaternion.setFromEuler(mesh.rotation)
  scale:mesh.scale.set(x, y, z)
  lookAt:mesh.lookAt(target)
  castShadow:mesh.castShadow = true
  receiveShadow:mesh.receiveShadow = true
  visible:mesh.visible = false
  userData:mesh.userData = { custom: 'data' }
  traverse:mesh.traverse(child => { })
  dispose:mesh.geometry.dispose(); mesh.material.dispose()
|
@group |
  new:group = new THREE.Group()
  add:group.add(mesh1, mesh2)
  remove:group.remove(mesh)
  position:group.position.set(x, y, z)
  rotation:group.rotation.y += 0.01
  traverse:group.traverse(child => { })
  naming:group.name = 'myGroup'
  findByName:group.getObjectByName('name')
|
@animation |
  mixer:new THREE.AnimationMixer(model)
  clipAction:mixer.clipAction(clip)
  play:action.play()
  pause:action.stop()
  crossFade:action1.crossFadeTo(action2, duration)
  loop:action.setLoop(THREE.LoopRepeat)
  timeScale:action.timeScale = 1.0
  mixerUpdate:mixer.update(delta)
  clipFind:THREE.AnimationUtils.subclip(clip, 'name', start, end)
|
@controls |
  orbit:OrbitControls(camera, domElement)
  orbitTarget:controls.target.set(x, y, z)
  orbitDamping:controls.enableDamping = true; controls.dampingFactor = 0.05
  orbitAutoRotate:controls.autoRotate = true; controls.autoRotateSpeed = 2.0
  orbitLimits:controls.minDistance/maxDistance, controls.minPolarAngle/maxPolarAngle
  fly:FlyControls(camera, domElement)
  pointerLock:PointerLockControls(camera, domElement)
  drag:DragControls(objects, camera, domElement)
  transform:TransformControls(camera, domElement)
  dispose:controls.dispose()
|
@loader |
  gltfLoader:GLTFLoader.load(url, onLoad, onProgress, onError)
  gltfAnimations:gltf.animations (AnimationClip[])
  gltfScene:gltf.scene (Group)
  gltfMeshes:gltf.scene.children (Mesh[])
  dracoLoader:DRACOLoader (compression)
  ktx2Loader:KTX2Loader (GPU textures)
  objLoader:OBJLoader.load(url)
  fbxLoader:FBXLoader.load(url)
  colladaLoader:COLLADALoader.load(url)
  textureLoader:TextureLoader.load(url)
  audioLoader:AudioLoader.load(url)
  fileLoader:FileLoader.load(url)
  loaderSetPath:loader.setPath('/models/')
|
@raycasting |
  setFromCamera:raycaster.setFromCamera(mouse, camera)
  intersectObjects:raycaster.intersectObjects(objects, recursive)
  firstHit:intersects[0]?.object
  distance:intersects[0]?.distance
  point:intersects[0]?.point (Vector3)
  face:intersects[0]?.face (Face3)
  uv:intersects[0]?.uv (Vector2)
|
@postprocessing |
  effectComposer:EffectComposer(renderer)
  renderPass:RenderPass(scene, camera)
  unrealBloom:UnrealBloomPass(resolution, strength, radius, threshold)
  filmPass:FilmPass(noiseIntensity, scanlinesIntensity, scanlinesCount)
  rgbShift:ShaderPass(RGBShiftShader)
  sao:SAOPass(scene, camera)
  ssr:SSRPass(scene, camera)
  outlinePass:OutlinePass(resolution, scene, camera)
  fxaa:ShaderPass(FXAAShader)
  addPass:composer.addPass(pass)
  render:composer.render()
  dispose:composer.dispose()
|
@InstancedMesh |
  new:InstancedMesh(geometry, material, count)
  setMatrixAt:mesh.setMatrixAt(index, matrix)
  setColorAt:mesh.setColorAt(index, color)
  count:mesh.count
  instanceMatrix:mesh.instanceMatrix (InstancedBufferAttribute)
  dispose:mesh.dispose()
|
@performance |
  frustumCulling:camera.frustumCulling = true (default)
  lod:LOD() (level of detail)
  lodAddLevel:lod.addLevel(mesh, distance)
  instancing:InstancedMesh for repeated geometry
  mergeGeometries:BufferGeometryUtils.mergeGeometries(geos)
  disposeAll:scene.traverse(obj => { obj.geometry?.dispose(); obj.material?.dispose() })
  gpuStats:renderer.info (memory, render stats)
  webglReport:renderer.capabilities (maxTextureSize, etc.)
  shadowMapSize:reduce shadow.mapSize for performance
  textureSize:use power-of-two textures (256, 512, 1024)
|
@webgpu |
  renderer:WebGPURenderer() (experimental)
  webglFallback:WebGLRenderer() (still primary)
  features:renderer.hasFeature('feature-name')
  compute:GPUComputePipeline (compute shaders)
  storageBuffer:StorageBuffer (GPU-side data)
|
@gotchas |
  dispose:always dispose geometry, material, texture
  disposeMemory:check renderer.info.memory for leaks
  animationLoop:requestAnimationFrame loop, not setInterval
  delta:use clock.getDelta() for frame-independent motion
  eulerOrder:default XYZ, watch for gimbal lock
  quaternion:use quaternions for complex rotations
  shadows:enable shadows on renderer, light, AND mesh
  pixelRatio:cap at 2, else perf hit on high-DPI
  resize:update camera.aspect AND renderer.setSize
  depthTest:depthTest: false for UI overlays
  transparent:transparent: true for alpha materials
  textureFlipY:false for KTX2/GLTF
  colorSpace:use SRGBColorSpace for textures and output
  toneMapping:use ACESFilmic for realistic look
  disposalRecursive:dispose children manually or use traverse
|
@math |
  clamp:THREE.MathUtils.clamp(value, min, max)
  lerp:THREE.MathUtils.lerp(a, b, t)
  mapLinear:THREE.MathUtils.mapLinear(v, a1, a2, b1, b2)
  degToRad:THREE.MathUtils.degToRad(degrees)
  radToDeg:THREE.MathUtils.radToDeg(radians)
  isPowerOfTwo:THREE.MathUtils.isPowerOfTwo(n)
  ceilPowerOfTwo:THREE.MathUtils.ceilPowerOfTwo(n)
  inverseLerp:THREE.MathUtils.inverseLerp(a, b, v)
  smoothstep:THREE.MathUtils.smoothstep(x, min, max)
|
@examples |
  basicSetup:renderer + scene + camera + cube + animate loop
  loadModel:GLTFLoader + draco + animation mixer
  raycastClick:raycaster + mouse position + intersectObjects
  shadows:renderer.shadowMap + directionalLight + mesh.receiveShadow
  postprocess:EffectComposer + RenderPass + UnrealBloomPass
  instancing:InstancedMesh + setMatrixAt + colorAt
  responsive:window resize listener + camera.aspect + renderer.setSize
|
