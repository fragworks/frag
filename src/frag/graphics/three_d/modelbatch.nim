import
  bgfxdotnim as bgfx,
  sdl2 as sdl

import
  ../../math/fpu_math as fpumath,
  model,
  pos_color_vertex,
  pos_tex_vertex,
  gl/fs_default_3d,
  gl/vs_default_3d,
  ../../util

type
  ModelBatch* = object
    vDecl: ptr bgfx_vertex_decl_t
    vbh: bgfx_dynamic_vertex_buffer_handle_t
    ibh: bgfx_dynamic_index_buffer_handle_t
    programHandle: bgfx_program_handle_t
    projectionMatrix*: fpumath.Mat4
    vertices*: seq[PosTexVertex]
    indices*: seq[uint16]
    renderables: seq[Renderable]

  Renderable = object
    firstVertex, firstIndex: int
    vertexCount, indexCount: int




proc setProjectionMatrix*(self: var ModelBatch, projectionMatrix: fpumath.Mat4) =
  discard

proc begin*(self: ModelBatch) =
  discard

proc init*(self: var ModelBatch) = 

  #mtxIdentity(self.projectionMatrix)

  self.vDecl = workaround_createShared[bgfx_vertex_decl_t]()

  bgfx_vertex_decl_begin(self.vDecl, BGFX_RENDERER_TYPE_COUNT)
  bgfx_vertex_decl_add(self.vDecl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  #bgfx_vertex_decl_add(self.vDecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  bgfx_vertex_decl_end(self.vDecl)
  
  self.vbh = bgfx_create_dynamic_vertex_buffer(1, self.vDecl, BGFX_BUFFER_ALLOW_RESIZE)
  self.ibh = bgfx_create_dynamic_index_buffer(1, BGFX_BUFFER_ALLOW_RESIZE)

  var vsh, fsh : bgfx_shader_handle_t
  when defined(windows):
    case bgfx_get_renderer_type()
    of BGFX_RENDERER_TYPE_DIRECT3D11:
      discard
    else:
      discard
  else:
    vsh = bgfx_create_shader(bgfx_make_ref(addr vs_default_3d.vs[0], uint32 sizeof(vs_default_3d.vs)))
    fsh = bgfx_create_shader(bgfx_make_ref(addr fs_default_3d.fs[0], uint32 sizeof(fs_default_3d.fs)))

  self.programHandle = bgfx_create_program(vsh, fsh, true)

  var at: Vec3 = [0.0f, 0.0f, 0.0f]
  var eye: Vec3 = [0.0f, 35.0f, -35.0f]
  var view: Mat4
  mtxLookAt(view, eye, at)


  mtxProj(self.projectionMatrix, 60.0, 960.0 / 540.0, 0.1, 100.0)
  bgfx_set_view_transform(0, addr view[0], addr self.projectionMatrix[0])

  self.vertices = @[]
  self.indices = @[]
  self.renderables = @[]

proc render*(self: var ModelBatch, model: Model) =

  discard bgfx_touch(0)

  #bgfx_update_dynamic_vertex_buffer(self.vbh, 0, bgfx_copy(addr vertexdata[0], (sizeof(PosColorVertex) * vertexdata.len).uint32))
  #bgfx_update_dynamic_index_buffer(self.ibh, 0, bgfx_copy(addr indexdata[0], (sizeof(uint16) * indexdata.len).uint32))

  for mesh in model.meshes:
    self.vertices.add(mesh.vertices)
    self.indices.add(mesh.indices)

    self.renderables.add(
      Renderable(
        firstIndex: mesh.firstIndex,
        firstVertex: mesh.firstVertex,
        indexCount: mesh.indices.len,
        vertexCount: mesh.vertices.len
      )
    )

proc flush*(self: var ModelBatch) =
  var vertices = self.vertices
  var indices = self.indices
  
  bgfx_update_dynamic_vertex_buffer(self.vbh, 0, bgfx_make_ref(addr vertices[0], (sizeof(PosTexVertex) * self.vertices.len).uint32))

  bgfx_update_dynamic_index_buffer(self.ibh, 0, bgfx_make_ref(addr indices[0], (sizeof(uint16) * self.indices.len).uint32))

  for renderable in self.renderables:

    var mtx1: fpuMath.Mat4
    mtxScale(mtx1, 1.0, 1.0, 1.0)

    let time = (sdl.getTicks()).float * 0.001

    var mtx2: fpuMath.Mat4
    mtxRotateXY(mtx2
      , 0.0f
      , time)

    var mtx3: fpuMath.Mat4
    mtxMul(mtx3, mtx1, mtx2)

    discard bgfx_set_transform(addr mtx3[0], 1)

    bgfx_set_dynamic_vertex_buffer(self.vbh, renderable.firstVertex.uint32, renderable.vertexCount.uint32)
    bgfx_set_dynamic_index_buffer(self.ibh, renderable.firstIndex.uint32, renderable.indexCount.uint32)

    bgfx_set_state(0'u64 or BGFX_STATE_DEFAULT, 0)

    discard bgfx_submit(0, self.programHandle, 0, false)
  
  self.renderables.setLen(0)
  self.vertices.setLen(0)
  self.indices.setLen(0)

proc `end`*(self: var ModelBatch) =
  if self.vertices.len > 0:
    self.flush()