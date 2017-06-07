import
  math

import
  bgfxdotnim as bgfx,
  sdl2 as sdl

import
  ../../assets/asset,
  ../../math/fpu_math as fpumath,
  ../camera,
  model,
  pos_color_vertex,
  ../two_d/texture,
  gl/fs_deferred_combine,
  gl/vs_deferred_combine,
  gl/fs_deferred_geometry,
  gl/vs_deferred_geometry,
  gl/fs_deferred_light,
  gl/vs_deferred_light,
  gl/fs_deferred_debug_line,
  gl/vs_deferred_debug_line,
  gl/fs_deferred_debug,
  gl/vs_deferred_debug,
  ../../util

type
  PosTexCoord0Vertex {.packed, pure.} = object
    x, y, z, u, v: float32

  #DebugVertex = object
  #  x, y, z: float32
  #  abgr: uint32

  Sphere = object
    center: Vec3
    radius: float32

  Aabb = object
    min: Vec3
    max: Vec3

  ModelBatch* = object
    vDecl, screenSpaceQuadDecl: ptr bgfx_vertex_decl_t
    vbh: bgfx_dynamic_vertex_buffer_handle_t
    ibh: bgfx_dynamic_index_buffer_handle_t
    dvbh: bgfx_vertex_buffer_handle_t
    dibh: bgfx_index_buffer_handle_t
    programHandle, combineProgramHandle, lightProgramHandle, debugLineProgramHandle, debugProgramHandle: bgfx_program_handle_t
    vertices*: seq[PosTexVertex]
    indices*: seq[uint16]
    renderables: seq[Renderable]
    texHandle: bgfx_uniform_handle_t
    normalHandle: bgfx_uniform_handle_t
    s_albedo: bgfx_uniform_handle_t
    s_normal: bgfx_uniform_handle_t
    s_depth: bgfx_uniform_handle_t
    s_light: bgfx_uniform_handle_t
    u_mtx: bgfx_uniform_handle_t
    u_lightPosRadius: bgfx_uniform_handle_t
    u_lightRgbInnerR: bgfx_uniform_handle_t
    oldWidth, oldHeight: uint16
    gBuffer, lightBuffer: bgfx_frame_buffer_handle_t
    gBufferTex: array[3, bgfx_texture_handle_t]
    caps: ptr bgfx_caps_t

  Renderable = object
    firstVertex, firstIndex: int
    vertexCount, indexCount: int
    textureHandles: seq[bgfx_texture_handle_t]

var cubeVertices = [
  PosTexVertex(x: -1.0f,  y: 1.0f,  z: 1.0f, normX: 0.0, normY: 0.0, normZ: 1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:0.0),
  PosTexVertex(x: 1.0f,  y: 1.0f,  z: 1.0f, normX: 0.0, normY: 0.0, normZ: 1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:0.0),
  PosTexVertex(x: -1.0f,  y: -1.0f,  z: 1.0f, normX: 0.0, normY: 0.0, normZ: 1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:1.0),
  PosTexVertex(x: 1.0f,  y: -1.0f,  z: 1.0f, normX: 0.0, normY: 0.0, normZ: 1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:1.0),
  PosTexVertex(x: -1.0f,  y: 1.0f,  z: -1.0f, normX: 0.0, normY: 0.0, normZ: -1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:0.0),
  PosTexVertex(x: 1.0f,  y: 1.0f,  z: -1.0f, normX: 0.0, normY: 0.0, normZ: -1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:0.0),
  PosTexVertex(x: -1.0f,  y: -1.0f,  z: -1.0f, normX: 0.0, normY: 0.0, normZ: -1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:1.0),
  PosTexVertex(x: 1.0f,  y: -1.0f,  z: -1.0f, normX: 0.0, normY: 0.0, normZ: -1.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:1.0),

  PosTexVertex(x: -1.0f,  y: 1.0f,  z: 1.0f, normX: 0.0, normY: 1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:0.0),
  PosTexVertex(x: 1.0f,  y: 1.0f,  z: 1.0f, normX: 0.0, normY: 1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:0.0),
  PosTexVertex(x: -1.0f,  y: 1.0f,  z: -1.0f, normX: 0.0, normY: 1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:1.0),
  PosTexVertex(x: 1.0f,  y: 1.0f,  z: -1.0f, normX: 0.0, normY: 1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:1.0),
  PosTexVertex(x: -1.0f,  y: -1.0f,  z: 1.0f, normX: 0.0, normY: -1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:0.0),
  PosTexVertex(x: 1.0f,  y: -1.0f,  z: 1.0f, normX: 0.0, normY: -1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:0.0),
  PosTexVertex(x: -1.0f,  y: -1.0f,  z: -1.0f, normX: 0.0, normY: -1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:1.0),
  PosTexVertex(x: 1.0f,  y: -1.0f,  z: -1.0f, normX: 0.0, normY: -1.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:1.0),

  PosTexVertex(x: 1.0f,  y: 1.0f,  z: 1.0f, normX: 1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:0.0),
  PosTexVertex(x: 1.0f,  y: -1.0f,  z: 1.0f, normX: 1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:0.0),
  PosTexVertex(x: 1.0f,  y: 1.0f,  z: -1.0f, normX: 1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:1.0),
  PosTexVertex(x: 1.0f,  y: -1.0f,  z: -1.0f, normX: 1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:1.0),
  PosTexVertex(x: -1.0f,  y: 1.0f,  z: 1.0f, normX: -1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:0.0),
  PosTexVertex(x: -1.0f,  y: -1.0f,  z: 1.0f, normX: -1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:0.0),
  PosTexVertex(x: -1.0f,  y: 1.0f,  z: -1.0f, normX: -1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 0.0, v:1.0),
  PosTexVertex(x: -1.0f,  y: -1.0f,  z: -1.0f, normX: -1.0, normY: 0.0, normZ: 0.0, tangentX: 0.0, tangentY: 0.0, tangentZ: 0.0, u: 1.0, v:1.0),
]

var cubeIndices = [
  0u16,  2,  1,
  1,  2,  3,
  4,  5,  6,
  5,  7,  6,

  8, 10,  9,
  9, 10, 11,
  12, 13, 14,
  13, 15, 14,

  16, 18, 17,
  17, 18, 19,
  20, 21, 22,
  21, 23, 22,
]

const HALF_PI = PI / 2

proc screenSpaceQuad(self: ModelBatch, width, height, texelHalf: float, originBottomLeft: bool) =
  let w, h = 1.0

  if bgfx_get_avail_transient_vertex_buffer(3, self.screenSpaceQuadDecl) == 3:
    var vb: bgfx_transient_vertex_buffer_t
    bgfx_alloc_transient_vertex_buffer(addr vb, 3, self.screenSpaceQuadDecl)
    
    let minx = -w
    let maxx = w
    let miny = 0.0
    let maxy = h * 2.0
    let texelHalfW = 0.0 / width 
    let texelHalfH = 0.0 / height
    let minu = -1.0 + texelHalfW
    let maxu = 1.0 + texelHalfH
    let zz = 0.0
    var minv = texelHalfH
    var maxv = 2.0 + texelHalfH
    if originBottomLeft:
      var temp = minv
      minv = maxv
      maxv = temp
      minv -= 1.0
      maxv -= 1.0

    var vertices = [
      PosTexCoord0Vertex(
        x: minx,
        y: miny,
        z: zz,
        u: minu,
        v: minv
      ),
      PosTexCoord0Vertex(
        x: maxx,
        y: miny,
        z: zz,
        u: maxu,
        v: minv
      ),
      PosTexCoord0Vertex(
        x: maxx,
        y: maxy,
        z: zz,
        u: maxu,
        v: maxv
      )
    ]
    
    copyMem(vb.data, addr vertices[0], sizeof(PosTexCoord0Vertex) * 3)
    bgfx_set_transient_vertex_buffer(0, addr vb, 0, 3)

proc toAabb(aabb: var Aabb, sphere: Sphere) =
  let radius = sphere.radius
  vec3Sub(aabb.min, sphere.center, radius)
  vec3Add(aabb.max, sphere.center, radius)

proc init*(self: var ModelBatch) = 

  self.vDecl = workaround_createShared[bgfx_vertex_decl_t]()

  bgfx_vertex_decl_begin(self.vDecl, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_decl_add(self.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(self.vDecl, BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT, true, false)
  bgfx_vertex_decl_add(self.vDecl, BGFX_ATTRIB_TANGENT, 3, BGFX_ATTRIB_TYPE_FLOAT, true, false)
  bgfx_vertex_decl_add(self.vDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, true, false)
  bgfx_vertex_decl_end(self.vDecl)

  self.screenSpaceQuadDecl = workaround_createShared[bgfx_vertex_decl_t]()

  bgfx_vertex_decl_begin(self.screenSpaceQuadDecl, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_decl_add(self.screenSpaceQuadDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(self.screenSpaceQuadDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_end(self.screenSpaceQuadDecl)

  #self.debugLightDecl = workaround_createShared[bgfx_vertex_decl_t]()

  #bgfx_vertex_decl_begin(self.debugLightDecl, BGFX_RENDERER_TYPE_NOOP)
  #bgfx_vertex_decl_add(self.debugLightDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  #bgfx_vertex_decl_add(self.debugLightDecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  #bgfx_vertex_decl_end(self.debugLightDecl)

  self.texHandle = bgfx_create_uniform("s_texColor", BGFX_UNIFORM_TYPE_INT1, 1)
  self.normalHandle = bgfx_create_uniform("s_texNormal", BGFX_UNIFORM_TYPE_INT1, 1)
  
  self.s_albedo = bgfx_create_uniform("s_albedo", BGFX_UNIFORM_TYPE_INT1, 1)
  self.s_normal = bgfx_create_uniform("s_normal", BGFX_UNIFORM_TYPE_INT1, 1)
  self.s_depth = bgfx_create_uniform("s_depth", BGFX_UNIFORM_TYPE_INT1, 1)
  self.s_light = bgfx_create_uniform("s_light", BGFX_UNIFORM_TYPE_INT1, 1)

  self.u_mtx = bgfx_create_uniform("u_mtx", BGFX_UNIFORM_TYPE_MAT4, 1)
  self.u_lightPosRadius = bgfx_create_uniform("u_lightPosRadius", BGFX_UNIFORM_TYPE_VEC4, 1)
  self.u_lightRgbInnerR = bgfx_create_uniform("u_lightRgbInnerR", BGFX_UNIFORM_TYPE_VEC4, 1)

  self.vbh = bgfx_create_dynamic_vertex_buffer(1, self.vDecl, BGFX_BUFFER_ALLOW_RESIZE)
  self.ibh = bgfx_create_dynamic_index_buffer(1, BGFX_BUFFER_ALLOW_RESIZE)

  self.dvbh = bgfx_create_vertex_buffer(bgfx_make_ref(addr cubeVertices[0], uint32 sizeof(PosTexVertex) * cubeVertices.len), self.vDecl, BGFX_BUFFER_NONE)
  self.dibh = bgfx_create_index_buffer(bgfx_make_ref(addr cubeIndices[0], uint32 sizeof(uint16) * cubeIndices.len), BGFX_BUFFER_NONE)

  var vsh, fsh : bgfx_shader_handle_t
  when defined(windows):
    case bgfx_get_renderer_type()
    of BGFX_RENDERER_TYPE_DIRECT3D11:
      discard
    else:
      discard
  else:
    vsh = bgfx_create_shader(bgfx_make_ref(addr vs_deferred_geometry.vs[0], uint32 sizeof(vs_deferred_geometry.vs)))
    fsh = bgfx_create_shader(bgfx_make_ref(addr fs_deferred_geometry.fs[0], uint32 sizeof(fs_deferred_geometry.fs)))
  self.programHandle = bgfx_create_program(vsh, fsh, true)

  vsh = bgfx_create_shader(bgfx_make_ref(addr vs_deferred_light.vs[0], uint32 sizeof(vs_deferred_light.vs)))
  fsh = bgfx_create_shader(bgfx_make_ref(addr fs_deferred_light.fs[0], uint32 sizeof(fs_deferred_light.fs)))
  self.lightProgramHandle = bgfx_create_program(vsh, fsh, true)

  vsh = bgfx_create_shader(bgfx_make_ref(addr vs_deferred_combine.vs[0], uint32 sizeof(vs_deferred_combine.vs)))
  fsh = bgfx_create_shader(bgfx_make_ref(addr fs_deferred_combine.fs[0], uint32 sizeof(fs_deferred_combine.fs)))
  self.combineProgramHandle = bgfx_create_program(vsh, fsh, true)

  vsh = bgfx_create_shader(bgfx_make_ref(addr vs_deferred_debug.vs[0], uint32 sizeof(vs_deferred_debug.vs)))
  fsh = bgfx_create_shader(bgfx_make_ref(addr fs_deferred_debug.fs[0], uint32 sizeof(fs_deferred_debug.fs)))
  self.debugProgramHandle = bgfx_create_program(vsh, fsh, true)

  #vsh = bgfx_create_shader(bgfx_make_ref(addr vs_deferred_debug_line.vs[0], uint32 sizeof(vs_deferred_debug_line.vs)))

  #fsh = bgfx_create_shader(bgfx_make_ref(addr fs_deferred_debug_line.fs[0], uint32 sizeof(fs_deferred_debug_line.fs)))

  #self.debugLineHandle = bgfx_create_program(vsh, fsh, true)

  #var at: Vec3 = [0.0f, 0.0f, 0.0f]
  #var eye: Vec3 = [0.0f, 0.0f, -15.0f]
  #var view: Mat4
  #mtxLookAt(view, eye, at)

  self.vertices = @[]
  self.indices = @[]
  self.renderables = @[]

  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0, 1.0, 1)
  bgfx_set_view_clear(1, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0, 1.0, 0)

  self.gBufferTex[0].idx = uint16.high
  self.gBufferTex[1].idx = uint16.high
  self.gBufferTex[2].idx = uint16.high
  self.gBuffer.idx = uint16.high
  self.lightBuffer.idx = uint16.high

  self.caps = bgfx_get_caps()

proc begin*(self: var ModelBatch, width, height: uint16, camera: Camera) =
  if self.oldWidth != width or self.oldHeight != height or self.gBuffer.idx == uint16.high:
    self.oldWidth = width
    self.oldHeight = height

    if self.gBuffer.idx != uint16.high:
      bgfx_destroy_frame_buffer(self.gBuffer)

    let samplerFlags = 0u32 or 
      BGFX_TEXTURE_RT or 
      BGFX_TEXTURE_MIN_POINT or
      BGFX_TEXTURE_MAG_POINT or
      BGFX_TEXTURE_MIP_POINT or 
      BGFX_TEXTURE_U_CLAMP or
      BGFX_TEXTURE_V_CLAMP
    
    self.gBufferTex[0] = bgfx_create_texture_2d(width, height, false, 1, BGFX_TEXTURE_FORMAT_BGRA8, samplerFlags, nil)
    self.gBufferTex[1] = bgfx_create_texture_2d(width, height, false, 1, BGFX_TEXTURE_FORMAT_BGRA8, samplerFlags, nil)
    self.gBufferTex[2] = bgfx_create_texture_2d(width, height, false, 1, BGFX_TEXTURE_FORMAT_D24, samplerFlags, nil)

    self.gBuffer = bgfx_create_frame_buffer_from_handles(3, addr self.gBufferTex[0], true)

    if self.lightBuffer.idx != uint16.high:
      bgfx_destroy_frame_buffer(self.lightBuffer)

    self.lightBuffer = bgfx_create_frame_buffer(960, 540, BGFX_TEXTURE_FORMAT_RGBA8, samplerFlags)

proc render*(self: var ModelBatch, model: Model) =

  #discard bgfx_touch(0)

  var textureHandles: seq[bgfx_texture_handle_t] = @[]

  for mesh in model.meshes:
    self.vertices.add(mesh.vertices)
    self.indices.add(mesh.indices)

    for texture in mesh.textures:
      textureHandles.add(texture.handle)

    self.renderables.add(
      Renderable(
        firstIndex: mesh.firstIndex,
        firstVertex: mesh.firstVertex,
        indexCount: mesh.indices.len,
        vertexCount: mesh.vertices.len,
        textureHandles: textureHandles
      )
    )

proc flush*(self: var ModelBatch, camera: Camera) =
  var vp, invMvp: Mat4

  bgfx_set_view_rect(0, 0, 0, 960, 540)
  bgfx_set_view_rect(1, 0, 0, 960, 540)
  bgfx_set_view_rect(2, 0, 0, 960, 540)
  bgfx_set_view_rect(3, 0, 0, 960, 540)
  bgfx_set_view_rect(4, 0, 0, 960, 540)

  bgfx_set_view_framebuffer(1, self.lightBuffer)

  bgfx_set_view_frame_buffer(0, self.gBuffer)
  bgfx_set_view_transform(0, addr camera.view[0], addr camera.projection[0])

  mtxMul(vp, camera.view, camera.projection)
  mtxInverse(invMvp, vp)

  mtxOrtho(camera.projection, 0, 1.0, 1.0, 0, 0, 100.0)
  bgfx_set_view_transform(1, nil, addr camera.projection[0])
  bgfx_set_view_transform(2, nil, addr camera.projection[0])

  let aspectRatio = 540.float / 960.float
  let size = 10.0
  mtxOrtho(camera.projection, -size, size, size*aspectRatio, -size*aspectRatio, 0.0, 1000.0)
  bgfx_set_view_transform(4, nil, addr camera.projection[0])

  mtxOrtho(camera.projection, 0, 960.0, 0.0, 540, 0, 1000.0)
  bgfx_set_view_transform(3, nil, addr camera.projection[0])

  let dim = 11
  let offset = ((dim - 1).float * 3.0) * 0.5

  var vertices = self.vertices
  var indices = self.indices

  bgfx_update_dynamic_vertex_buffer(self.vbh, 0, bgfx_make_ref(addr vertices[0], (sizeof(PosTexVertex) * self.vertices.len).uint32))

  bgfx_update_dynamic_index_buffer(self.ibh, 0, bgfx_make_ref(addr indices[0], (sizeof(uint16) * self.indices.len).uint32))
  
  for yy in 0..<dim:
    for xx in 0..<dim:
      for renderable in self.renderables:
        var mtx1: fpuMath.Mat4
        mtxScale(mtx1, 0.5, 0.5, 0.5)

        let time = ((sdl.getPerformanceCounter() * 1000) div sdl.getPerformanceFrequency()).float * 0.001

        var mtx2: fpuMath.Mat4
        mtxRotateXY(mtx2
          , 0.0f
          , time)

        var mtx3: fpuMath.Mat4
        mtxMul(mtx3, mtx1, mtx2)

        mtx3[12] = -offset + xx.float * 3.0
        mtx3[13] = -offset + yy.float * 3.0
        mtx3[14] = 0.0

        discard bgfx_set_transform(addr mtx3[0], 1)

        bgfx_set_dynamic_vertex_buffer(0, self.vbh, renderable.firstVertex.uint32, renderable.vertexCount.uint32)
        bgfx_set_dynamic_index_buffer(self.ibh, renderable.firstIndex.uint32, renderable.indexCount.uint32)

        bgfx_set_texture(0, self.texHandle, renderable.textureHandles[0], high(uint32))
        bgfx_set_texture(1, self.normalHandle, renderable.textureHandles[2], high(uint32))

        bgfx_set_state(0'u64 or BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE or BGFX_STATE_DEPTH_WRITE or BGFX_STATE_DEPTH_TEST_LESS or BGFX_STATE_MSAA, 0)

        discard bgfx_submit(0, self.programHandle, 0, false)
  
  self.renderables.setLen(0)
  
  for light in 0..<128:

    var lightPosRadius: Sphere = Sphere()

    let time = ((sdl.getPerformanceCounter() * 1000) div sdl.getPerformanceFrequency()).float * 0.001
    
    let lightTime = time * 0.1 * (fsin(light.float / 128.0) * HALF_PI) * 0.5 + 0.5
    lightPosRadius.center[0] = fsin(( (lightTime + light.float * 0.47) + HALF_PI * 1.37 ) ) * offset
    lightPosRadius.center[1] = fcos(( (lightTime + light.float * 0.69) + HALF_PI * 1.49 ) ) * offset
    lightPosRadius.center[2] = fsin(( (lightTime + light.float * 0.37) + HALF_PI * 1.57 ) ) * 2.0
    lightPosRadius.radius = 2.0

    var aabb: Aabb
    toAabb(aabb, lightPosRadius)

    let box = [
      [aabb.min[0], aabb.min[1], aabb.min[2]],
      [aabb.min[0], aabb.min[1], aabb.max[2]],
      [aabb.min[0], aabb.max[1], aabb.min[2]],
      [aabb.min[0], aabb.max[1], aabb.max[2]],
      [aabb.max[0], aabb.min[1], aabb.min[2]],
      [aabb.max[0], aabb.min[1], aabb.max[2]],
      [aabb.max[0], aabb.max[1], aabb.min[2]],
      [aabb.max[0], aabb.max[1], aabb.max[2]]
    ]

    var xyz: Vec3
    vec3MulMtxH(xyz, box[0], vp)
    var minx = xyz[0]
    var miny = xyz[1]
    var maxx = xyz[0]
    var maxy = xyz[1]
    var maxz = xyz[2]

    var ii = 1
    while ii < 8:
      vec3MulMtxH(xyz, box[ii], vp)
      minx = fmin(minx, xyz[0])
      miny = fmin(miny, xyz[1])
      maxx = fmax(maxx, xyz[0])
      maxy = fmax(maxy, xyz[1])
      maxz = fmax(maxz, xyz[2])
      inc(ii)
    
    if maxz > 0.0:
      let x0 = clamp((minx * 0.5 + 0.5) * 960, 0.0, 960)
      let y0 = clamp((miny * 0.5 + 0.5) * 540, 0.0, 540)
      let x1 = clamp((maxx * 0.5 + 0.5) * 960, 0.0, 960)
      let y1 = clamp((maxy * 0.5 + 0.5) * 540, 0.0, 540)

      #[var tvb: bgfx_transient_vertex_buffer_t
      var tib: bgfx_transient_index_buffer_t

      if bgfx_alloc_transient_buffers(addr tvb, self.debugLightDecl, 4, addr tib, 8):
        let abgr = 0x8000ff00u32

        var vertices: seq[DebugVertex] = @[
          DebugVertex(
            x: x0,
            y: y0,
            z: 0.0,
            abgr: abgr
          ),
          DebugVertex(
            x: x1,
            y: y0,
            z: 0.0,
            abgr: abgr
          ),
          DebugVertex(
            x: x1,
            y: y1,
            z: 0.0,
            abgr: abgr
          ),
          DebugVertex(
            x: x0,
            y: y1,
            z: 0.0,
            abgr: abgr
          )
        ]

        var indices = [0u16, 1, 1, 2, 2, 3, 3, 0]

        copyMem(tvb.data, addr vertices[0], sizeof(DebugVertex) * 4)
        copyMem(tib.data, addr indices[0], sizeof(uint16) * 8)

        bgfx_set_transient_vertex_buffer(addr tvb, 0, 4)
        bgfx_set_transient_index_buffer(addr tib, 0, 8)
        bgfx_set_state(0u64 or BGFX_STATE_RGB_WRITE or BGFX_STATE_PT_LINES or BGFX_STATE_BLEND_ALPHA, 0)
        discard bgfx_submit(3, self.debugLineHandle, 0, false)]#


      let val = light.uint32 and 7
      var lightRgbInnerR = [
        if(val and 0x1) > 0: 1.0.float32 else: 0.25.float32,
        if(val and 0x2) > 0: 1.0.float32 else: 0.25.float32,
        if(val and 0x4) > 0: 1.0.float32 else: 0.25.float32,
        0.8
      ]

      var test: array[4, float32] = [lightPosRadius.center[0].float32, lightPosRadius.center[1].float32, lightPosRadius.center[2].float32, lightPosRadius.radius.float32]
      bgfx_set_uniform(self.u_lightPosRadius, addr test[0], 1)
      bgfx_set_uniform(self.u_lightRgbInnerR, addr lightRgbInnerR[0], 1)
      bgfx_set_uniform(self.u_mtx, addr invMvp[0], 1)
      #let scissorHeight = (y1 - y0).uint16
      #discard bgfx_set_scissor(x0.uint16, (540u16 - scissorHeight - y0.uint16), (x1 - x0).uint16, scissorHeight)
      bgfx_set_texture(0, self.s_normal, bgfx_get_texture(self.gBuffer, 1), high(uint32))
      bgfx_set_texture(1, self.s_depth, bgfx_get_texture(self.gBuffer, 2), high(uint32))
    
      bgfx_set_state(0u64 or BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE or BGFX_STATE_BLEND_ADD, 0)
      self.screenSpaceQuad(960.float, 540.float, 0.0, self.caps.originBottomLeft)
      discard bgfx_submit(1, self.lightProgramHandle, 0, false)



proc `end`*(self: var ModelBatch, width, height: uint16, camera: Camera) =
  self.flush(camera)

  bgfx_set_texture(0, self.s_albedo, bgfx_get_texture(self.gBuffer, 0), uint32.high)
  bgfx_set_texture(1, self.s_light, bgfx_get_texture(self.lightBuffer, 0), uint32.high)
  bgfx_set_state(0'u64 or BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE, 0)

  self.screenSpaceQuad(width.float, height.float, 0.0, self.caps.originBottomLeft)
  discard bgfx_submit(2, self.combineProgramHandle, 0, false)

  let aspectRatio = 960.0 / 540.0

  for i in 0..<self.gBufferTex.len:
    var mtx: Mat4

    mtxSRT(mtx, 
      aspectRatio.float32, 1.0f32, 1.0f32, 
      0.0f32, 0.0f32, 0.0f32, 
      -7.9f32 - self.gBufferTex.len.float * 0.1 * 0.5 + i.float * 2.1 * aspectRatio, 4.0f32, 0.0f32
    )
    discard bgfx_set_transform(addr mtx[0], 1)
    
    bgfx_set_vertex_buffer(0, self.dvbh, 0, cubeVertices.len.uint32)
    bgfx_set_index_buffer(self.dibh, 0, 6)
    bgfx_set_texture(0, self.texHandle, self.gBufferTex[i], uint32.high)
    bgfx_set_state(BGFX_STATE_RGB_WRITE, 0)
    discard bgfx_submit(4, self.debugProgramHandle, 0, false)


  self.vertices.setLen(0)
  self.indices.setLen(0)