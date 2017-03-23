import
  bgfxdotnim as bgfx

import
  ../../logger,
  ../../math/fpu_math as fpumath,
  ../../modules/graphics,
  ../types,
  texture
  
when defined(windows):
  import
    dx/fs_default_dx11 as fs_default,
    dx/vs_default_dx11 as vs_default

else:
  import
    gl/fs_default,
    gl/vs_default


type
  SpriteBatch* = ref object
    vertices: seq[PosUVColorVertex]
    maxSprites: int
    lastTexture: Texture
    drawing: bool
    programHandle: bgfx_program_handle_t
    ibh: bgfx_index_buffer_handle_t
    vDecl: ptr bgfx_vertex_decl_t
    texHandle: bgfx_uniform_handle_t
    view: uint8
    blendSrcFunc*, blendDstFunc*: BlendFunc
    blendingEnabled*: bool

  PosUVColorVertex {.packed, pure.} = object
    x*, y*, z*: float32
    u*, v*: float32
    abgr*: uint32

proc flush(spriteBatch: SpriteBatch) =
  if spriteBatch.lastTexture.isNil:
    return

  discard bgfx_touch(0)

  var vb : bgfx_transient_vertex_buffer_t
  bgfx_alloc_transient_vertex_buffer(addr vb, 4, spriteBatch.vDecl);
  copyMem(vb.data, addr spriteBatch.vertices[0], sizeof(PosUVColorVertex) * spriteBatch.vertices.len)

  bgfx_set_texture(0, spriteBatch.texHandle, spriteBatch.lastTexture.handle, high(uint32))
  bgfx_set_transient_vertex_buffer(addr vb, 0u32, uint32 spriteBatch.vertices.len)
  bgfx_set_index_buffer(spriteBatch.ibh, 0, 6)

  var mtx: fpumath.Mat4
  mtxIdentity(mtx)

  discard bgfx_set_transform(addr mtx[0], 1)

  if spriteBatch.blendingEnabled:
    bgfx_set_state(0'u64 or BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE or BGFX_STATE_BLEND_FUNC(spriteBatch.blendSrcFunc
      , spriteBatch.blendDstFunc), 0);

  discard bgfx_submit(spriteBatch.view, spriteBatch.programHandle, 0, false)

  spriteBatch.vertices.setLen(0)

proc switchTexture(spriteBatch: SpriteBatch, texture: Texture) =
  flush(spriteBatch)
  spriteBatch.lastTexture = texture
#[
proc draw*(spriteBatch: SpriteBatch, textureRegion: TextureRegion, x, y: float32, color: uint32 = 0xffffffff'u32) =
  if not spriteBatch.drawing:
    logError "Spritebatch not in drawing mode. Call begin before calling draw."
    return

  let texture = textureRegion.texture

  if texture != spriteBatch.lastTexture:
    switchTexture(spriteBatch, texture)

  spriteBatch.vertices.add([
    PosUVColorVertex(x: x, y: y, u:textureRegion.u, v:textureRegion.v, z: 0.0'f32, abgr: color ),
    PosUVColorVertex(x: x + float textureRegion.regionWidth, y: y, u:textureRegion.u2, v:textureRegion.v, z: 0.0'f32, abgr: color ),
    PosUVColorVertex(x: x + float textureRegion.regionWidth, y: y + float textureRegion.regionHeight, u:textureRegion.u2, v:textureRegion.v2, z: 0.0'f32, abgr: color ),
    PosUVColorVertex(x: x, y: y + float textureRegion.regionHeight, u:textureRegion.u, v:textureRegion.v2, z: 0.0'f32, abgr: color ),
  ])
]#
proc draw*(spriteBatch: SpriteBatch, texture: Texture, x, y, width, height: float32, color: uint32 = 0xffffffff'u32, scale: Vec3 = [1.0'f32, 1.0'f32, 1.0'f32]) =
  if not spriteBatch.drawing:
    logError "Spritebatch not in drawing mode. Call begin before calling draw."
    return

  if texture != spriteBatch.lastTexture:
    switchTexture(spriteBatch, texture)

  var x1 = x
  var x2 = x + width
  var y1 = y
  var y2 = y + height

  if scale[0] != 1.0'f32 or scale[1] != 1.0'f32:
    x1 *= scale[0]
    x2 *= scale[0]
    y1 *= scale[0]
    y2 *= scale[0]


  spriteBatch.vertices.add([
    PosUVColorVertex(x: x1, y: y1, u:0.0, v:1.0, z: 0.0'f32, abgr: color ),
    PosUVColorVertex(x: x2, y: y1, u:1.0, v:1.0, z: 0.0'f32, abgr: color ),
    PosUVColorVertex(x: x2, y: y2, u:1.0, v:0.0, z: 0.0'f32, abgr: color ),
    PosUVColorVertex(x: x1, y: y2, u:0.0, v:0.0, z: 0.0'f32, abgr: color )
  ])

proc init*(spriteBatch: SpriteBatch, maxSprites: int, view: uint8) =
  spriteBatch.drawing = false
  spriteBatch.maxSprites = maxSprites
  spriteBatch.vertices = @[]
  spriteBatch.view = view

  spriteBatch.vDecl = create(bgfx_vertex_decl_t)

  var indexdata = [
    0'u16, 1'u16, 2'u16,
    3'u16, 0'u16, 2'u16
  ]

  spriteBatch.ibh = bgfx_create_index_buffer(bgfx_copy(addr indexdata[0], uint32 indexdata.len * sizeof(uint16)), BGFX_BUFFER_NONE)

  bgfx_vertex_decl_begin(spriteBatch.vDecl, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_decl_add(spriteBatch.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(spriteBatch.vDecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(spriteBatch.vDecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  bgfx_vertex_decl_end(spriteBatch.vDecl)

  spriteBatch.texHandle = bgfx_create_uniform("s_texColor", BGFX_UNIFORM_TYPE_INT1, 1)

  let vsh = bgfx_create_shader(bgfx_make_ref(addr vs_default.vs[0], uint32 sizeof(vs_default.vs)))
  let fsh = bgfx_create_shader(bgfx_make_ref(addr fs_default.fs[0], uint32 sizeof(fs_default.fs)))
  spriteBatch.programHandle = bgfx_create_program(vsh, fsh, true)

  var proj: fpumath.Mat4
  fpumath.mtxOrtho(proj, 0.0, 960.0, 0.0, 540.0, -1.0'f32, 1.0'f32)
  bgfx_set_view_transform(0, nil, unsafeAddr(proj[0]))

  bgfx_set_view_rect(0, 0, 0, cast[uint16](960), cast[uint16](540))

proc begin*(spriteBatch: SpriteBatch) =
  if spriteBatch.drawing:
    logError "Spritebatch is already in drawing mode. Call end before calling begin."
    return

  spriteBatch.drawing = true

proc `end`*(spriteBatch: SpriteBatch) =
  if not spriteBatch.drawing:
    logError "Spritebatch is not currently in drawing mode. Call begin before calling end."
    return

  if spriteBatch.vertices.len > 0:
    flush(spriteBatch)

  spriteBatch.lastTexture = nil
  spriteBatch.drawing = false

proc dispose*(spriteBatch: SpriteBatch) =
  bgfx_destroy_uniform(spriteBatch.texHandle)
  bgfx_destroy_index_buffer(spriteBatch.ibh)
  bgfx_destroy_program(spriteBatch.programHandle)
