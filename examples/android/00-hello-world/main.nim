import
  bgfxdotnim

import
  ../../../src/frag,
  ../../../src/frag/config,
  ../../../src/frag/logger,
  ../../../src/frag/graphics/types

type
  App = ref object

proc initializeApp(app: App, ctx: Frag) =
  log "Initializing app..."
  log "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

proc shutdownApp(app: App, ctx: Frag) =
  log "Shutting down app..."
  log "App shut down."


{.emit: """
#include <SDL_main.h>

extern int cmdCount;
extern char** cmdLine;
extern char** gEnv;

N_CDECL(void, NimMain)(void);

int main(int argc, char** args) {
    cmdLine = args;
    cmdCount = argc;
    gEnv = NULL;
    NimMain();
    return nim_program_result;
}

""".}

log BGFX_DEBUG_WIREFRAME or BGFX_DEBUG_TEXT

startFrag[App](Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  resetFlags: ResetFlag.None,
  debugMode: BGFX_DEBUG_WIREFRAME or BGFX_DEBUG_TEXT
))