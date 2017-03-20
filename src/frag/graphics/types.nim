import
  bgfxdotnim as bgfx

type
  ResetFlag* {.pure.} = enum
    None = BGFX_RESET_NONE
    Fullscreen = BGFX_RESET_FULLSCREEN
    MSAAx2 = BGFX_RESET_MSAA_X2
    MSAAx4 = BGFX_RESET_MSAA_X4
    MSAAx8 = BGFX_RESET_MSAA_X8
    MSAAx16 = BGFX_RESET_MSAA_X16
    VSync = BGFX_RESET_VSYNC
    MaxAnisotropy = BGFX_RESET_MAXANISOTROPY
    Capture = BGFX_RESET_CAPTURE
    HMD = BGFX_RESET_HMD
    DEUBG = BGFX_RESET_HMD_DEBUG
    HMDRecenter = BGFX_RESET_HMD_RECENTER
    FlushAfterRender = BGFX_RESET_FLUSH_AFTER_RENDER
    FlipAfterRender = BGFX_RESET_FLIP_AFTER_RENDER
    sRGBBackbuffer = BGFX_RESET_SRGB_BACKBUFFER

  DebugMode* {.pure.} = enum
    None = 0u32
    Wireframe = BGFX_DEBUG_WIREFRAME
    IFH = BGFX_DEBUG_IFH
    Stats = BGFX_DEBUG_STATS
    Text = BGFX_DEBUG_TEXT

  ClearMode* {.pure.} = enum
    Color = BGFX_CLEAR_COLOR
    Depth = BGFX_CLEAR_DEPTH

  BlendFunc* {.pure.} = enum
    SrcAlpha = BGFX_STATE_BLEND_SRC_ALPHA
    InvSrcAlpha = BGFX_STATE_BLEND_INV_SRC_ALPHA
