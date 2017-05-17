when defined(js):
  import
    frag/core/js_gameloop
else:
  import
    frag/core/sdl_gameloop

import
  frag/config,
  frag/types


proc startFrag*[T](app: T, config: Config) =
  var ctx = Frag()

  when defined(js):
    js_gameloop.initFRAG(ctx, app, config)
    app.initApp(ctx)
    js_gameloop.start(ctx, app, config)

    app.shutdownApp(ctx)

    js_gameloop.shutdownFRAG(ctx, QUIT_SUCCESS, config.imgui)
  else:
    sdl_gameloop.initFRAG(ctx, app, config)
    app.initApp(ctx)
    sdl_gameloop.start(ctx, app, config)

    app.shutdownApp(ctx)

    sdl_gameloop.shutdownFRAG(ctx, QUIT_SUCCESS, config.imgui)