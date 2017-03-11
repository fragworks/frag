{.experimental.}

import bgfx, nuklear, glfw3 as glfw, typetraits

import vs_nuklear_texture
import fs_nuklear_texture

import ../../graphics, ../../fpumath

import ../../font/robotomono_regular.nim

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
  NuklearBGFXDevice = ref TNuklearBGFXDevice
  TNuklearBGFXDevice = object
    cmds: buffer
    vsh: ShaderHandle
    fsh: ShaderHandle
    sph: ProgramHandle
    vdecl: ptr VertexDecl
    uh: UniformHandle
    cc: convert_config
    null: draw_null_texture
    fah: TextureHandle
    vb: buffer
    ib: buffer
    vertexLayout: seq[draw_vertex_layout_element]

  NuklearBGFX* = ref TNuklearBGFX
  TNuklearBGFX* = object
    ctx*: ref context
    dev*: NuklearBGFXDevice
    fa*: font_atlas
    textLen*: int
    text*: string
    scroll: float

proc get_avail_transient_buffers(vertexCount: uint32_t, vdecl: ptr VertexDecl, indexCount: uint32_t) : bool =
  if GetAvailTransientVertexBuffer(vertexCount, vdecl) >= vertexCount and GetAvailTransientIndexBuffer(indexCount) >= indexCount:
    return true
  return false

#[proc updateText(nkbgfx: var NuklearBGFX, character: var char) =
  if nkbgfx.textLen < TEXT_MAX:
    nkbgfx.text[nkbgfx.textLen] = character
    inc(nkbgfx.textLen)]#

template testKey(key: int, window: Window) : cint =
  (glfw.GetKey(window, key) == PRESS).cint

#[proc glfw_char_callback(window: Window; character: cuint) {.cdecl.} =
  setupForeignThreadGc()
  var c = char character
  updateText(c)]#

proc getContextRef*(ctx: context): ref context =
  new(result); result[] = ctx

proc init*(nkbgfx: var NuklearBGFX) =
  nkbgfx.text = newString(TEXT_MAX)
  # discard glfw.SetCharCallback(graphics.rootWindow, glfw_char_callback)
  nkbgfx.dev = new(NuklearBGFXDevice)
  init(nkbgfx.dev.cmds)
  nkbgfx.dev.vsh = CreateShader(MakeRef(addr vs_nuklear_texture.vs[0], uint32_t sizeof(vs_nuklear_texture.vs)))
  nkbgfx.dev.fsh = CreateShader(MakeRef(addr fs_nuklear_texture.fs[0], uint32_t sizeof(fs_nuklear_texture.fs)))
  nkbgfx.dev.sph = CreateProgram(nkbgfx.dev.vsh, nkbgfx.dev.fsh)
  nkbgfx.dev.vdecl = createShared(VertexDecl)
  nkbgfx.dev.vdecl.Begin()
  nkbgfx.dev.vdecl.Add(bgfx.Attrib_Position, 2, bgfx.AttribType_Float)
  nkbgfx.dev.vdecl.Add(bgfx.Attrib_TexCoord0, 2, bgfx.AttribType_Float)
  nkbgfx.dev.vdecl.Add(bgfx.Attrib_Color0, 4, bgfx.AttribType_Uint8, true, false)
  nkbgfx.dev.vdecl.End()
  nkbgfx.dev.uh = CreateUniform("s_texColor", UniformType_Int1)

  nkbgfx.dev.vertexLayout = @[
    draw_vertex_layout_element(
        attribute: VERTEX_POSITION,
        format: FORMAT_FLOAT, 
        offset: nkbgfx.dev.vdecl.offset[Attrib_Position]
      ),
      draw_vertex_layout_element(
        attribute: VERTEX_TEXCOORD,
        format: FORMAT_FLOAT, 
        offset: nkbgfx.dev.vdecl.offset[Attrib_TexCoord0]
      ),
      draw_vertex_layout_element(
        attribute: VERTEX_COLOR,
        format: FORMAT_R8G8B8A8, 
        offset: nkbgfx.dev.vdecl.offset[Attrib_Color0]
      ),
      draw_vertex_layout_element(
        attribute: VERTEX_ATTRIBUTE_COUNT,
        format: FORMAT_COUNT,
        offset: 0
      )
  ]

  nkbgfx.dev.cc.vertex_layout = addr nkbgfx.dev.vertexLayout[0]
  nkbgfx.dev.cc.vertex_size = culong sizeof(bgfx_vertex)
  nkbgfx.dev.cc.vertex_alignment = alignof(bgfx_vertex)
  nkbgfx.dev.cc.null = nkbgfx.dev.null
  nkbgfx.dev.cc.circle_segment_count = 22
  nkbgfx.dev.cc.curve_segment_count = 22
  nkbgfx.dev.cc.arc_segment_count = 22
  nkbgfx.dev.cc.global_alpha = 1.0
  nkbgfx.dev.cc.shape_AA = ANTIALIASING_ON
  nkbgfx.dev.cc.line_AA = ANTIALIASING_ON

  nkbgfx.fa.init()

  nkbgfx.fa.open()

  let roboto_ttf = addr s_robotoMonoRegularTtf

  var font = nkbgfx.fa.addFromMemory(roboto_ttf, uint sizeof(s_robotoMonoRegularTtf), 13, nil)
  # Uncomment for default font
  #var font = nk_font_atlas_add_default(addr fa, 13, nil)

  var w, h : cint
  let image = nkbgfx.fa.bake(w, h, FONT_ATLAS_RGBA32)
  let size : uint32_t = uint32_t(w * h * 4)
  
  var mem : ptr bgfx.Memory = bgfx.Alloc(size)
  copymem(mem.data, image, size)
  nkbgfx.dev.fah = CreateTexture2D(uint16_t w, uint16_t h, false, 1, TextureFormat_RGBA8, 0, mem)
  nkbgfx.fa.close(handle_id(cint nkbgfx.dev.fah.idx), nkbgfx.dev.null)

  discard nkbgfx.ctx.init(font.handle)

proc bgfx_new_frame*(nkbgfx: var NuklearBGFX) =
  var x, y : float
  openInput(nkbgfx.ctx)
  for i in 0..<nkbgfx.textLen:
    inputUnicode(nkbgfx.ctx, uint32 nkbgfx.text[i])

  if bool nkbgfx.ctx.input.mouse.grab:
    glfw.SetInputMode(graphics.rootWindow, CURSOR, CURSOR_HIDDEN)
  elif bool nkbgfx.ctx.input.mouse.ungrab:
    glfw.SetInputMode(graphics.rootWindow, CURSOR, CURSOR_NORMAL)
  
  inputKey(nkbgfx.ctx, keys.KEY_DEL, testKey(glfw.KEY_DELETE, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_ENTER, testKey(glfw.KEY_ENTER, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_TAB, testKey(glfw.KEY_TAB, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_BACKSPACE, testKey(glfw.KEY_BACKSPACE, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_UP, testKey(glfw.KEY_UP, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_DOWN, testKey(glfw.KEY_DOWN, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_TEXT_START, testKey(glfw.KEY_HOME, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_TEXT_END, testKey(glfw.KEY_END, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_SCROLL_START, testKey(glfw.KEY_HOME, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_SCROLL_END, testKey(glfw.KEY_END, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_SCROLL_DOWN, testKey(glfw.KEY_PAGE_DOWN, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_SCROLL_UP, testKey(glfw.KEY_PAGE_UP, graphics.rootWindow))
  inputKey(nkbgfx.ctx, keys.KEY_SHIFT, testKey(glfw.KEY_LEFT_SHIFT, graphics.rootWindow) or testKey(KEY_RIGHT_SHIFT, graphics.rootWindow))

  if testKey(glfw.KEY_LEFT_CONTROL, graphics.rootWindow) == 1 or testKey(glfw.KEY_RIGHT_CONTROL, graphics.rootWindow) == 1:
    inputKey(nkbgfx.ctx, keys.KEY_COPY, testKey(glfw.KEY_C, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_PASTE, testKey(glfw.KEY_V, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_CUT, testKey(glfw.KEY_X, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_TEXT_UNDO, testKey(glfw.KEY_Z, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_TEXT_REDO, testKey(glfw.KEY_R, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_TEXT_WORD_LEFT, testKey(glfw.KEY_LEFT, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_TEXT_WORD_RIGHT, testKey(glfw.KEY_RIGHT, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_TEXT_LINE_START, testKey(glfw.KEY_B, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_TEXT_LINE_END, testKey(glfw.KEY_E, graphics.rootWindow))

  else:
    inputKey(nkbgfx.ctx, keys.KEY_LEFT, testKey(glfw.KEY_LEFT, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_RIGHT, testKey(glfw.KEY_RIGHT, graphics.rootWindow))
    inputKey(nkbgfx.ctx, keys.KEY_COPY, 0)
    inputKey(nkbgfx.ctx, keys.KEY_PASTE, 0)
    inputKey(nkbgfx.ctx, keys.KEY_CUT, 0)
    inputKey(nkbgfx.ctx, keys.KEY_SHIFT, 0)
  

  glfw.GetCursorPos(graphics.rootWindow, addr x, addr y);
  input_motion(nkbgfx.ctx, cint x, cint y);

  if bool nkbgfx.ctx.input.mouse.grabbed:
    glfw.SetCursorPos(graphics.rootWindow, nkbgfx.ctx.input.mouse.prev.x, nkbgfx.ctx.input.mouse.prev.y)
    nkbgfx.ctx.input.mouse.pos.x = nkbgfx.ctx.input.mouse.prev.x
    nkbgfx.ctx.input.mouse.pos.y = nkbgfx.ctx.input.mouse.prev.y

  input_button(nkbgfx.ctx, BUTTON_LEFT, cint x, cint y, (glfw.GetMouseButton(graphics.rootWindow, MOUSE_BUTTON_LEFT) == PRESS).cint)
  input_button(nkbgfx.ctx, BUTTON_MIDDLE, cint x, cint y, (glfw.GetMouseButton(graphics.rootWindow, MOUSE_BUTTON_MIDDLE) == PRESS).cint)
  input_button(nkbgfx.ctx, BUTTON_RIGHT, cint x, cint y, (glfw.GetMouseButton(graphics.rootWindow, MOUSE_BUTTON_RIGHT) == PRESS).cint)
  input_scroll(nkbgfx.ctx, nkbgfx.scroll)
  closeInput(nkbgfx.ctx)
  
  nkbgfx.textLen = 0
  nkbgfx.scroll = 0

proc render*(nkbgfx: var NuklearBGFX) =
  var width, height : cint
  var displayWidth, displayHeight : cint

  glfw.GetWindowSize(graphics.rootWindow, addr width, addr height);
  glfw.GetFramebufferSize(graphics.rootWindow, addr displayWidth, addr displayHeight)

  var ortho : Mat4
  mtxOrtho(ortho, 0.0, float displayWidth, float displayHeight, 0.0, 0.0, 1.0)

  SetViewRect(uint8_t 0, uint16_t 0, uint16_t 0, uint16_t displayWidth, uint16_t displayHeight)
  SetViewTransform(uint8_t 0, nil, addr ortho[0])

  var scale : vec2
  scale.x = float(displayWidth) / float(width)
  scale.y = float(displayHeight) / float(height)

  init(nkbgfx.dev.vb)
  init(nkbgfx.dev.ib)
  
  convertDrawCommands(nkbgfx.ctx, nkbgfx.dev.cmds, nkbgfx.dev.vb, nkbgfx.dev.ib, nkbgfx.dev.cc)
  
  let vertexData = nkbgfx.dev.vb.memory.pointr
  let elementData = nkbgfx.dev.ib.memory.pointr
  let vertexDataSize = nkbgfx.dev.vb.allocated
  let elementDataSize = nkbgfx.dev.ib.allocated

  var offset : uint32_t = 0
  var vertexCount = uint32_t(vertexDataSize div nkbgfx.dev.vdecl.stride)

  if vertexCount > 0'u:
    var totalElemCount = uint32_t int(elementDataSize) div sizeof(uint16)
    var tvb : TransientVertexBuffer
    var tib : TransientIndexBuffer
    if get_avail_transient_buffers(vertexCount, nkbgfx.dev.vdecl, totalElemCount):
      AllocTransientVertexBuffer(addr tvb, vertexCount, nkbgfx.dev.vdecl)
      copyMem(tvb.data, vertexData, vertexDataSize)

      AllocTransientIndexBuffer(addr tib, totalElemCount)
      copyMem(tib.data, elementData, elementDataSize)

      var cmd : ptr draw_command = firstDrawCommand(nkbgfx.ctx, nkbgfx.dev.cmds)
      while not isNil(cmd):

        let scissorX : uint16_t = uint16_t max(cmd.clip_rect.x, 0.0)
        let scissorY : uint16_t = uint16_t max(cmd.clip_rect.y, 0.0)
        let scissorW : uint16_t = uint16_t min(cmd.clip_rect.w, 65535.0)
        let scissorH : uint16_t = uint16_t min(cmd.clip_rect.h, 65535.0)
        discard SetScissor(scissorX, scissorY, scissorW, scissorH)


        SetState( BGFX_STATE_RGB_WRITE or BGFX_STATE_ALPHA_WRITE or
                            BGFX_STATE_BLEND_FUNC( BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA ) )

        if not cmd.texture.isNil:
          SetTexture(0, nkbgfx.dev.uh, TextureHandle(idx: cast[uint16](cmd.texture)))
        else:
          SetTexture(0, nkbgfx.dev.uh, nkbgfx.dev.fah)

        SetVertexBuffer( addr tvb )
        SetIndexBuffer( addr tib, offset, cmd.elem_count)

        Submit(0, nkbgfx.dev.sph)

        offset += cmd.elem_count

        cmd = nextDrawCommand(cmd, nkbgfx.dev.cmds, nkbgfx.ctx[])
  nkbgfx.ctx.clear()

proc dispose*(nkbgfx: var NuklearBGFX) =
  if isValid(nkbgfx.dev.fah):
    DestroyTexture(nkbgfx.dev.fah)
  if isValid(nkbgfx.dev.uh):
    DestroyUniform(nkbgfx.dev.uh)
  if isValid(nkbgfx.dev.vsh):
    DestroyShader(nkbgfx.dev.vsh)
  if isValid(nkbgfx.dev.fsh):
    DestroyShader(nkbgfx.dev.fsh)
  if isValid(nkbgfx.dev.sph):
    DestroyProgram(nkbgfx.dev.sph)

  free(nkbgfx.dev.cmds)
  free(nkbgfx.dev.vb)
  free(nkbgfx.dev.ib)
  nkbgfx.fa.clear()
  nkbgfx.ctx.free()
