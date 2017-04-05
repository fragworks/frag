{.experimental.}

import 
  bgfxdotnim as bgfx, 
  nuklear,
  sdl2 as sdl

import
  font/roboto_mono_regular,
  imgui_fs,
  imgui_vs,
  ../math/fpu_math as fpumath,
  ../util

template offsetof(typ, field): untyped = (var dummy: typ; cast[uint](addr(dummy.field)) - cast[uint](addr(dummy)))

template alignof(typ) : uint =
  if sizeof(typ) > 1:
    offsetof(tuple[c: char, x: typ], x)
  else:
    1

const TEXT_MAX* = 256

type
  bgfx_vertex* = object
    position: array[2, cfloat]
    uv: array[2, cfloat]
    col: array[4, uint8]

type
  IMGUIDevice = ref object
    cmds: buffer
    vsh: bgfx_shader_handle_t
    fsh: bgfx_shader_handle_t
    sph: bgfx_program_handle_t
    vdecl: ptr bgfx_vertex_decl_t
    uh: bgfx_uniform_handle_t
    cc: convert_config
    null: draw_null_texture
    fah: bgfx_texture_handle_t
    vb: buffer
    ib: buffer
    vertexLayout: seq[draw_vertex_layout_element]

  IMGUI* = ref object
    ctx*: ref context
    dev*: IMGUIDevice
    fa*: font_atlas
    textLen*: int
    text*: string
    scroll: float
    projection: Mat4

proc get_avail_transient_buffers(vertexCount: uint32, vdecl: ptr bgfx_vertex_decl_t, indexCount: uint32) : bool =
  if bgfx_get_avail_transient_vertex_buffer(vertexCount, vdecl) >= vertexCount and bgfx_get_avail_transient_index_buffer(indexCount) >= indexCount:
    return true
  return false

proc getContextRef*(ctx: context): ref context =
  new(result); result[] = ctx

proc init*(imgui: var IMGUI): bool =
  imgui.text = newString(TEXT_MAX)
  # discard glfw.SetCharCallback(graphics.rootWindow, glfw_char_callback)
  imgui.dev = IMGUIDevice()
  imgui.dev.cmds.init()
  imgui.dev.vsh = bgfx_create_shader(bgfx_make_ref(addr imgui_vs.vs[0], uint32 sizeof(imgui_vs.vs)))
  imgui.dev.fsh = bgfx_create_shader(bgfx_make_ref(addr imgui_fs.fs[0], uint32 sizeof(imgui_fs.fs)))
  imgui.dev.sph = bgfx_create_program(imgui.dev.vsh, imgui.dev.fsh, true)
  imgui.dev.vdecl = workaround_createShared[bgfx_vertex_decl_t]()
  bgfx_vertex_decl_begin(imgui.dev.vdecl, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_decl_add(imgui.dev.vdecl, BGFX_ATTRIB_POSITION, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(imgui.dev.vdecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(imgui.dev.vdecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  bgfx_vertex_decl_end(imgui.dev.vdecl)
  imgui.dev.uh = bgfx_create_uniform("s_texColor", BGFX_UNIFORM_TYPE_INT1, 1)
  

  imgui.dev.vertexLayout = @[
    draw_vertex_layout_element(
        attribute: VERTEX_POSITION,
        format: FORMAT_FLOAT, 
        offset: imgui.dev.vdecl.offset[BGFX_ATTRIB_POSITION]
      ),
      draw_vertex_layout_element(
        attribute: VERTEX_TEXCOORD,
        format: FORMAT_FLOAT, 
        offset: imgui.dev.vdecl.offset[BGFX_ATTRIB_TEXCOORD0]
      ),
      draw_vertex_layout_element(
        attribute: VERTEX_COLOR,
        format: FORMAT_R8G8B8A8, 
        offset: imgui.dev.vdecl.offset[BGFX_ATTRIB_COLOR0]
      ),
      draw_vertex_layout_element(
        attribute: VERTEX_ATTRIBUTE_COUNT,
        format: FORMAT_COUNT,
        offset: 0
      )
  ]

  imgui.dev.cc.vertex_layout = addr imgui.dev.vertexLayout[0]
  imgui.dev.cc.vertex_size = culong sizeof(bgfx_vertex)
  imgui.dev.cc.vertex_alignment = alignof(bgfx_vertex)
  imgui.dev.cc.null = imgui.dev.null
  imgui.dev.cc.circle_segment_count = 22
  imgui.dev.cc.curve_segment_count = 22
  imgui.dev.cc.arc_segment_count = 22
  imgui.dev.cc.global_alpha = 1.0
  imgui.dev.cc.shape_AA = ANTIALIASING_ON
  imgui.dev.cc.line_AA = ANTIALIASING_ON

  imgui.fa.init()

  imgui.fa.open()

  let roboto_ttf = addr s_robotoMonoRegularTtf

  var font = imgui.fa.addFromMemory(roboto_ttf, uint sizeof(s_robotoMonoRegularTtf), 13, nil)
  # Uncomment for default font
  #var font = nk_font_atlas_add_default(addr fa, 13, nil)

  var w, h : cint
  let image = imgui.fa.bake(w, h, FONT_ATLAS_RGBA32)
  let size : uint32 = uint32(w * h * 4)
  
  var mem : ptr bgfx_memory_t = bgfx_alloc(size)
  copymem(mem.data, image, size)
  imgui.dev.fah = bgfx_create_texture_2d(uint16 w, uint16 h, false, 1, BGFX_TEXTURE_FORMAT_RGBA8, 0, mem)
  imgui.fa.close(handle_id(cint imgui.dev.fah.idx), imgui.dev.null)

  mtxIdentity(imgui.projection)

  imgui.ctx = new(nuklear.context)
  return bool imgui.ctx.init(font.handle)

proc setProjectionMatrix*(imgui: IMGUI, projectionMatrix: Mat4, view: uint8) =
  imgui.projection = projectionMatrix
  bgfx_set_view_transform(view, nil, addr imgui.projection[0])

proc startUpdate*(imgui: var IMGUI) =
  openInput(imgui.ctx)

proc finishUpdate*(imgui: var IMGUI) =
  closeInput(imgui.ctx)

proc render*(imgui: var IMGUI) =
  init(imgui.dev.vb)
  init(imgui.dev.ib)
  
  convertDrawCommands(imgui.ctx, imgui.dev.cmds, imgui.dev.vb, imgui.dev.ib, imgui.dev.cc)
  
  let vertexData = imgui.dev.vb.memory.pointr
  let elementData = imgui.dev.ib.memory.pointr
  let vertexDataSize = imgui.dev.vb.allocated
  let elementDataSize = imgui.dev.ib.allocated

  var offset : uint32 = 0
  var vertexCount = uint32(vertexDataSize div imgui.dev.vdecl.stride)

  if vertexCount > 0'u:
    var totalElemCount =  uint32 int(elementDataSize) div sizeof(uint16)
    var tvb : bgfx_transient_vertex_buffer_t
    var tib : bgfx_transient_index_buffer_t
    if get_avail_transient_buffers(vertexCount, imgui.dev.vdecl, totalElemCount):
      bgfx_alloc_transient_vertex_buffer(addr tvb, vertexCount, imgui.dev.vdecl)
      copyMem(tvb.data, vertexData, vertexDataSize)

      bgfx_alloc_transient_index_buffer(addr tib, totalElemCount)
      copyMem(tib.data, elementData, elementDataSize)

      var cmd : ptr draw_command = firstDrawCommand(imgui.ctx, imgui.dev.cmds)
      while not isNil(cmd):

        let scissorX : uint16 = uint16 max(cmd.clip_rect.x, 0.0)
        let scissorY : uint16 = uint16 max(cmd.clip_rect.y, 0.0)
        let scissorW : uint16 = uint16 min(cmd.clip_rect.w, 65535.0)
        let scissorH : uint16 = uint16 min(cmd.clip_rect.h, 65535.0)
        discard bgfx_set_scissor(scissorX, scissorY, scissorW, scissorH)


        bgfx_set_state( BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE or
                            BGFX_STATE_BLEND_FUNC( BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA ), 0)

        if not cmd.texture.isNil:
          bgfx_set_texture(0, imgui.dev.uh, bgfx_texture_handle_t(idx: cast[uint16](cmd.texture)), high(uint32))
        else:
          bgfx_set_texture(0, imgui.dev.uh, imgui.dev.fah, high(uint32))

        bgfx_set_transient_vertex_buffer( addr tvb, 0, vertexCount )
        bgfx_set_transient_index_buffer( addr tib, offset, cmd.elem_count)

        discard bgfx_submit(1, imgui.dev.sph, 0, false)

        offset += cmd.elem_count

        cmd = nextDrawCommand(cmd, imgui.dev.cmds, imgui.ctx[])
  imgui.ctx.clear()

proc dispose*(imgui: var IMGUI) =
  bgfx_destroy_texture(imgui.dev.fah)
  bgfx_destroy_uniform(imgui.dev.uh)
  bgfx_destroy_program(imgui.dev.sph)

  freeShared(imgui.dev.vdecl)