import
  math

import
  model,
  modelbatch

import
  bgfxdotnim

import
  ../../math/fpu_math,
  ../../graphics/two_d/texture,
  ../../util,
  gl/fs_fxaa,
  gl/vs_fxaa,
  gl/fs_tone_mapping,
  gl/vs_tone_mapping

const halfPI = PI/2

var initialized = false
var decl: ptr bgfx_vertex_decl_t

type
  PosTexCoord0Vertex = object
    x,y,z,u,v: float

  Scene* = ref object
    root*: Node
    cameras*: seq[Camera]

  Node* = ref object
    parent: Node
    children: seq[Node]
    scene: Scene
    components: seq[Component]
    local, world: Mat4

  ComponentType {.pure.} = enum
    Camera, MeshRenderer, ScenicCamera

  Component = ref object of RootObj
    enabled: bool
    node: Node
    componentType: ComponentType

  MeshRenderer = ref object of Component
    model: Model
    modelBatch: ModelBatch
    uvScaleBuffer: array[4, float]
    uvScaleUniform: bgfx_uniform_handle_t
    invTransposedModelUniform: bgfx_uniform_handle_t
    albedoTextureUniform: bgfx_uniform_handle_t

  ViewportRect = object
    left, right, top, bottom: float

  Camera = ref object of Component
    componentRenderPasses: uint8

  RenderPass = object
    id: uint8
    active: bool
  
  ScenicCamera = ref object of Camera
    viewport: ViewportRect
    contextWidth, contextHeight: uint32
    viewportWidth, viewportHeight: uint16
    gBuffer: bgfx_frame_buffer_handle_t
    gBufferTex: array[5, bgfx_texture_handle_t]
    lightBuffer: bgfx_frame_buffer_handle_t
    backgroundBuffer: bgfx_frame_buffer_handle_t
    toneMappingBuffer: bgfx_frame_buffer_handle_t
    geometryPass, lightPass, backgroundPass, toneMappingPass, outputPass: RenderPass
    caps: ptr bgfx_caps_t
    view, projection: Mat4
    texelHalf: float
    albedoTextureUniform, backgroundTextureUniform, lightTextureUniform, toneMappingTextureUniform, resolutionUniform: bgfx_uniform_handle_t
    resolution: array[4, float]
    toneMappingProgram: bgfx_program_handle_t
    fxaaProgram: bgfx_program_handle_t

  GeometryPassRenderTarget {.pure.} = enum
    Position, Normal, Albedo, Material, Depth

proc init() =
  if not initialized:
    initialized = true
    
    decl = workaround_createShared[bgfx_vertex_decl_t]()
    bgfx_vertex_decl_begin(decl, BGFX_RENDERER_TYPE_NOOP)
    bgfx_vertex_decl_add(decl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
    bgfx_vertex_decl_add(decl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
    bgfx_vertex_decl_end(decl)

proc screenSpaceQuad(scenicCamera: ScenicCamera, width, height: float): bool =
  let originBottomLeft = scenicCamera.caps.originBottomLeft
  let w, h = 1.0

  if bgfx_get_avail_transient_vertex_buffer(3, decl) == 3:
    var vb: bgfx_transient_vertex_buffer_t
    bgfx_alloc_transient_vertex_buffer(addr vb, 3, decl)
    var vertex = cast[array[3, PosTexCoord0Vertex]](vb.data)
    let minx = -w
    let maxx = w
    let miny = 0.0
    let maxy = h * 2.0
    let texelHalfW = scenicCamera.texelHalf / width 
    let texelHalfH = scenicCamera.texelHalf / height
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
    
    vertex[0].x = minx
    vertex[0].y = miny
    vertex[0].z = zz
    vertex[0].u = minu
    vertex[0].v = minv
    vertex[1].x = maxx
    vertex[1].y = miny
    vertex[1].z = zz
    vertex[1].u = maxu
    vertex[1].v = minv
    vertex[2].x = maxx
    vertex[2].y = maxy
    vertex[2].z = zz
    vertex[2].u = maxu
    vertex[2].v = maxv
    bgfx_set_transient_vertex_buffer(addr vb, 0, 3)
    return true

proc screenSpaceQuad(camera: ScenicCamera): bool =
  screenSpaceQuad(camera, camera.contextWidth.float * (camera.viewport.right - camera.viewport.left), camera.contextHeight.float * (camera.viewport.top - camera.viewport.bottom))

proc newNode*(): Node =
  result = Node(
    children: @[],
    components: @[]
  )

proc newScene*(): Scene =
  result = Scene(
    cameras: @[],
    root: newNode()
  )
  result.root.scene = result

proc onAttach*[T](component: T) =
  case component.componentType
  of ComponentType.Camera:
    let camera = cast[Camera](component)
    component.node.scene.cameras.add(camera)
  of ComponentType.ScenicCamera:
    let camera = cast[ScenicCamera](component)
    component.node.scene.cameras.add(camera)
  else:
    discard

proc onRender*(meshRenderer: MeshRenderer, renderPass: uint8) =
  var uvScale = [1.0, 1.0, 0.0, 0.0]
  var world: Mat4
  mtxIdentity(world)
  mtxInverse(world, world)
  mtxTranspose(world, world)
  bgfx_set_uniform(meshRenderer.uvScaleUniform, addr uvScale[0], 1)
  bgfx_set_uniform(meshRenderer.invTransposedModelUniform, addr world[0], 1)
  bgfx_set_texture(0, meshRenderer.albedoTextureUniform, texture.load("/Users/zachcarter/sandbox/frag/examples/desktop/assets/cerberus/albedo.png").handle, uint32.high)
  meshRenderer.modelBatch.begin()
  meshRenderer.modelBatch.render(meshRenderer.model)
  meshRenderer.modelBatch.`end`()

proc onRender(component: Component, renderPass: uint8, camera: Camera) =
  if component.componentType == ComponentType.Camera:
    discard
  elif component.componentType == ComponentType.MeshRenderer:
    let meshRenderer = cast[MeshRenderer](component)
    meshRenderer.onRender(renderPass)
  

proc addComponent*(node: Node, component: Component): bool =
  if component.node.isNil:
    node.components.add(component)
    component.node = node
    component.onAttach()
    return true

proc addChild*(parent: Node, child: Node): bool =
  if child.parent.isNil:
    parent.children.add(child)
    child.scene = parent.scene
    child.parent = parent
    return true

proc render(node: Node, camera: Camera, renderPass: uint8) =
  for component in node.components:
    if component.enabled:
      component.onRender(renderPass, camera)
  for child in node.children:
    child.render(camera, renderPass)

proc render(scenicCamera: ScenicCamera, width, height: uint32) =
  if scenicCamera.contextWidth != width or scenicCamera.contextHeight != height or scenicCamera.gBuffer.idx == uint16.high:
    scenicCamera.contextWidth = width
    scenicCamera.contextHeight = height
    scenicCamera.viewportWidth = (scenicCamera.contextWidth.float * (scenicCamera.viewport.right - scenicCamera.viewport.left)).uint16
    scenicCamera.viewportHeight = (scenicCamera.contextHeight.float * (scenicCamera.viewport.bottom - scenicCamera.viewport.top)).uint16

    if not scenicCamera.gBuffer.idx == uint16.high:
      bgfx_destroy_frame_buffer(scenicCamera.gBuffer)

    let samplerFlags = 0u32 or 
        BGFX_TEXTURE_RT or 
        BGFX_TEXTURE_MIN_POINT or
        BGFX_TEXTURE_MAG_POINT or
        BGFX_TEXTURE_MIP_POINT or 
        BGFX_TEXTURE_U_CLAMP or
        BGFX_TEXTURE_V_CLAMP
      
    scenicCamera.gBufferTex[GeometryPassRenderTarget.Position.ord] = bgfx_create_texture_2d(scenicCamera.viewportWidth, scenicCamera.viewportHeight, false, 1, BGFX_TEXTURE_FORMAT_RGBA32F, samplerFlags, nil)

    scenicCamera.gBufferTex[GeometryPassRenderTarget.Normal.ord] = bgfx_create_texture_2d(scenicCamera.viewportWidth, scenicCamera.viewportHeight, false, 1, BGFX_TEXTURE_FORMAT_RGBA32F, samplerFlags, nil)

    scenicCamera.gBufferTex[GeometryPassRenderTarget.Albedo.ord] = bgfx_create_texture_2d(scenicCamera.viewportWidth, scenicCamera.viewportHeight, false, 1, BGFX_TEXTURE_FORMAT_BGRA8, samplerFlags, nil)

    scenicCamera.gBufferTex[GeometryPassRenderTarget.Material.ord] = bgfx_create_texture_2d(scenicCamera.viewportWidth, scenicCamera.viewportHeight, false, 1, BGFX_TEXTURE_FORMAT_BGRA8, samplerFlags, nil)

    scenicCamera.gBufferTex[GeometryPassRenderTarget.Depth.ord] = bgfx_create_texture_2d(scenicCamera.viewportWidth, scenicCamera.viewportHeight, false, 1, BGFX_TEXTURE_FORMAT_D32F, samplerFlags, nil)

    scenicCamera.gBuffer = bgfx_create_frame_buffer_from_handles(scenicCamera.gBufferTex.len.uint8, addr scenicCamera.gBufferTex[0], true)

    if not scenicCamera.lightBuffer.idx == uint16.high:
      bgfx_destroy_frame_buffer(scenicCamera.lightBuffer)
    if not scenicCamera.backgroundBuffer.idx == uint16.high:
      bgfx_destroy_frame_buffer(scenicCamera.backgroundBuffer)
    if not scenicCamera.toneMappingBuffer.idx == uint16.high:
      bgfx_destroy_frame_buffer(scenicCamera.toneMappingBuffer)
    
    scenicCamera.lightBuffer = bgfx_create_frame_buffer(scenicCamera.viewportWidth, scenicCamera.viewportHeight, BGFX_TEXTURE_FORMAT_R11G11B10F, samplerFlags)

    scenicCamera.backgroundBuffer = bgfx_create_frame_buffer(scenicCamera.viewportWidth, scenicCamera.viewportHeight, BGFX_TEXTURE_FORMAT_RGBA32F, samplerFlags)

    scenicCamera.toneMappingBuffer = bgfx_create_frame_buffer(scenicCamera.viewportWidth, scenicCamera.viewportHeight, BGFX_TEXTURE_FORMAT_BGRA8, samplerFlags)

  bgfx_set_view_rect(scenicCamera.geometryPass.id, 0, 0, scenicCamera.viewportWidth, scenicCamera.viewportHeight)
  bgfx_set_view_frame_buffer(scenicCamera.geometryPass.id, scenicCamera.gBuffer)

  var proj: Mat4 
  mtxOrtho(proj, 0.0, 1.0, 1.0, 0.0, 0.0, 100.0)

  bgfx_set_view_rect(scenicCamera.lightPass.id, 0, 0, scenicCamera.viewportWidth, scenicCamera.viewportHeight)
  bgfx_set_view_frame_buffer(scenicCamera.lightPass.id, scenicCamera.lightBuffer)
  bgfx_set_view_transform(scenicCamera.lightPass.id, nil, addr scenicCamera.projection[0])

  bgfx_set_view_rect(scenicCamera.backgroundPass.id, 0, 0, scenicCamera.viewportWidth, scenicCamera.viewportHeight)
  bgfx_set_view_frame_buffer(scenicCamera.backgroundPass.id, scenicCamera.backgroundBuffer)
  bgfx_set_view_transform(scenicCamera.backgroundPass.id, nil, addr scenicCamera.projection[0])

  bgfx_set_view_rect(scenicCamera.toneMappingPass.id, 0, 0, scenicCamera.viewportWidth, scenicCamera.viewportHeight)
  bgfx_set_view_frame_buffer(scenicCamera.toneMappingPass.id, scenicCamera.toneMappingBuffer)
  bgfx_set_view_transform(scenicCamera.toneMappingPass.id, nil, addr scenicCamera.projection[0])

  bgfx_set_view_rect(scenicCamera.outputPass.id, 0, 0, scenicCamera.viewportWidth, scenicCamera.viewportHeight)
  bgfx_set_view_transform(scenicCamera.outputPass.id, nil, addr scenicCamera.projection[0])

  mtxInverse(scenicCamera.view, scenicCamera.node.world)

  mtxProj(scenicCamera.projection, 60.0f32, scenicCamera.viewportWidth.float32 / scenicCamera.viewportHeight.float32, 0.1f32, 100.0f32, scenicCamera.caps.homogeneousDepth)
  
  bgfx_set_view_transform(scenicCamera.geometryPass.id, addr scenicCamera.view[0], addr scenicCamera.projection[0])

proc onBeginRendering(camera: Camera, width, height: uint32) =
  case camera.componentType
  of ComponentType.ScenicCamera:
    cast[ScenicCamera](camera).render(width, height)
  else:
    discard


proc endRendering(scenicCamera: ScenicCamera) =
  if screenSpaceQuad(scenicCamera):
    bgfx_set_texture(0, scenicCamera.albedoTextureUniform, bgfx_get_texture(scenicCamera.gBuffer, GeometryPassRenderTarget.Albedo.ord), uint32.high)
    bgfx_set_texture(1, scenicCamera.lightTextureUniform, bgfx_get_texture(scenicCamera.lightBuffer, 0), uint32.high)
    bgfx_set_texture(2, scenicCamera.backgroundTextureUniform, bgfx_get_texture(scenicCamera.backgroundBuffer, 0), uint32.high)
    bgfx_set_state(0u64 or BGFX_STATE_PT_TRISTRIP or BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE, 0)
    discard bgfx_submit(scenicCamera.toneMappingPass.id, scenicCamera.toneMappingProgram, 0, false)

  if screenSpaceQuad(scenicCamera):
    var tmp: Mat4
    mtxTranslate(tmp, 0, 0, 0)
    discard bgfx_set_transform(addr tmp[0], 1)
    scenicCamera.resolution[0] = scenicCamera.viewportWidth.float
    scenicCamera.resolution[1] = scenicCamera.viewportHeight.float
    bgfx_set_uniform(scenicCamera.resolutionUniform, addr scenicCamera.resolution[0], 1)
    bgfx_set_texture(0, scenicCamera.toneMappingTextureUniform, bgfx_get_texture(scenicCamera.toneMappingBuffer, 0), uint32.high)
    bgfx_set_state(0u64 or BGFX_STATE_PT_TRISTRIP or BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE, 0)
    discard bgfx_submit(scenicCamera.outputPass.id, scenicCamera.fxaaProgram, 0, false)

proc onEndRendering(camera: Camera) =
  case camera.componentType
  of ComponentType.ScenicCamera:
    cast[ScenicCamera](camera).endRendering()
  else:
    discard


proc render*(scene: Scene, width, height: uint32) =
  if scene.cameras.len == 0:
    discard bgfx_touch(0)

  for camera in scene.cameras:
    if camera.enabled:
      camera.onBeginRendering(width, height)
      for renderPass in 0..<camera.componentRenderPasses:
        #camera.onBeginRenderPass(renderPass)
        scene.root.render(camera, renderPass)
        #camera.onEndRenderPass(renderPass)
      camera.onEndRendering()

proc newMeshRenderer*(modelBatch: ModelBatch, model: Model): MeshRenderer =
  result = MeshRenderer(
    enabled: true,
    model: model,
    modelBatch: modelBatch,
    componentType: ComponentType.MeshRenderer
  )

  result.uvScaleUniform = bgfx_create_uniform("u_uvScale", BGFX_UNIFORM_TYPE_VEC4, 1)
  result.invTransposedModelUniform = bgfx_create_uniform("u_invTransposedModel", BGFX_UNIFORM_TYPE_MAT4, 1)
  result.albedoTextureUniform = bgfx_create_uniform("s_albedo", BGFX_UNIFORM_TYPE_INT1, 1)


proc newCamera*(): Camera =
  result = Camera(
    enabled: true,
    componentType: ComponentType.Camera,
    componentRenderPasses: 1
  )

proc newScenicCamera*(): ScenicCamera = 
  result = ScenicCamera(
    enabled: true,
    componentType: ComponentType.ScenicCamera,
    componentRenderPasses: 2
  )

  bgfx_set_view_clear_mrt(result.geometryPass.id, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH or BGFX_CLEAR_STENCIL, 1.0, 0, 1, 1, 1, 1, 1, 1, 1, 1)
  bgfx_set_view_clear(result.lightPass.id, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH or BGFX_CLEAR_DISCARD_STENCIL, 0x303030ff, 1.0, 0)
  bgfx_set_view_clear(result.backgroundPass.id, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH or BGFX_CLEAR_DISCARD_STENCIL, 0x303030ff , 1.0, 0)
  bgfx_set_view_clear(result.toneMappingPass.id, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH or BGFX_CLEAR_DISCARD_STENCIL, 0x303030ff , 1.0, 0)
  bgfx_set_view_clear(result.outputPass.id, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH or BGFX_CLEAR_DISCARD_STENCIL, 0x303030ff, 1.0, 0)

  result.gBufferTex[0].idx = uint16.high
  result.gBufferTex[1].idx = uint16.high
  result.gBufferTex[2].idx = uint16.high
  result.gBufferTex[3].idx = uint16.high

  result.gBuffer.idx = uint16.high
  result.lightBuffer.idx = uint16.high
  result.backgroundBuffer.idx = uint16.high

  result.albedoTextureUniform = bgfx_create_uniform("s_albedo", BGFX_UNIFORM_TYPE_INT1, 1)
  result.backgroundTextureUniform = bgfx_create_uniform("s_background", BGFX_UNIFORM_TYPE_INT1, 1)
  result.lightTextureUniform = bgfx_create_uniform("s_light", BGFX_UNIFORM_TYPE_INT1, 1)
  result.toneMappingTextureUniform = bgfx_create_uniform("s_screen", BGFX_UNIFORM_TYPE_INT1, 1)
  result.resolutionUniform = bgfx_create_uniform("u_resolution", BGFX_UNIFORM_TYPE_VEC4, 1)

  result.geometryPass = RenderPass(
    id: 0,
    active: true
  )

  result.lightPass = RenderPass(
    id: 1,
    active: true
  )

  result.backgroundPass = RenderPass(
    id: 2,
    active: true
  )

  result.toneMappingPass = RenderPass(
    id: 3,
    active: true
  )
  
  result.outputPass = RenderPass(
    id: 4,
    active: true
  )


  result.caps = bgfx_get_caps()

  result.texelHalf = if bgfx_get_renderer_type() == BGFX_RENDERER_TYPE_DIRECT3D9:
      0.5 else: 0

  var vsh, fsh: bgfx_shader_handle_t
  vsh = bgfx_create_shader(bgfx_make_ref(addr vs_tone_mapping.vs[0], uint32 sizeof(vs_tone_mapping.vs)))
  fsh = bgfx_create_shader(bgfx_make_ref(addr fs_tone_mapping.fs[0], uint32 sizeof(fs_tone_mapping.fs)))
  result.toneMappingProgram = bgfx_create_program(vsh, fsh, true)
  

init()