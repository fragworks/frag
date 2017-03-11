{.deadCodeElim: on.}

import glfw3 as glfw
import bgfx, bgfxplatform
import strutils

when defined(Windows):
    import glfw3native.Win32 as glfwn
elif defined(MacOSX):
    import glfw3native.Cocoa as glfwn
elif defined(Linux) or
    defined(FreeBSD) or
    defined(OpenBSD) or
    defined(NetBSD) or
    defined(Solaris) or
    defined(QNX):
    import glfw3native.X11 as glfwn

proc GLFWErrorCB(errorCode: cint; description: cstring) {.cdecl.} =
    debugEcho "[GLFW3] error: $1, $2".format(errorCode, description)

proc LinkGLFW3WithBGFX(window: Window) =
    var pd: ptr PlatformData = create(PlatformData)
    when defined(Windows):
        pd.nwh = glfwn.GetWin32Window(window)
        pd.ndt = nil
    elif defined(MacOSX):
        pd.nwh = glfwn.GetCocoaWindow(window)
        pd.ndt = nil
    elif defined(Linux) or
        defined(FreeBSD) or
        defined(OpenBSD) or
        defined(NetBSD) or
        defined(Solaris) or
        defined(QNX):
        pd.nwh = cast[pointer](glfwn.GetX11Window(window))
        pd.ndt = glfwn.GetX11Display()
    else:
        {.fatal: "Exposure of glfw3native functions is required".}
    pd.backBuffer = nil
    pd.backBufferDS = nil
    pd.context = nil
    SetPlatformData(pd)

proc StartExample*[Example]() =
    var app: Example = Example()

    # Set up
    discard glfw.SetErrorCallback(GLFWErrorCB)

    if glfw.Init() != glfw.TRUE:
        echo "[GLFW3] Failed to initialize!"
        quit(QuitFailure)

    glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
    var window: Window
    window = glfw.CreateWindow(1280, 720, "", nil, nil)
    if window == nil:
        echo "[GLFW3] Failed to create window!"
        quit(QuitFailure)
    glfw.SetWindowUserPointer(window, app.addr)

    LinkGLFW3WithBGFX(window)

    app.Init()

    while true:
        glfw.PollEvents()
        var current_width, current_height: cint
        var current_window_width, current_window_height: cint
        glfw.GetFramebufferSize(window, current_width.addr, current_height.addr)
        glfw.GetWindowSize(window, current_window_width.addr, current_window_height.addr)
        if cast[uint32](current_width) != app.m_width or cast[uint32](current_height) != app.m_height:
            echo "Window resize: ($1, $2)".format(current_width, current_height)
            app.m_width = cast[uint32](current_width)
            app.m_height = cast[uint32](current_height)
            app.m_window_width = cast[uint32](current_window_width)
            app.m_window_height = cast[uint32](current_window_height)
            bgfx.Reset(cast[uint16](app.m_window_width), cast[uint16](app.m_window_height), app.m_reset)
        if glfw.WindowShouldClose(window) != 0:
            break
        app.Update()

    app.CleanUp()

    glfw.DestroyWindow(window)
    glfw.Terminate()