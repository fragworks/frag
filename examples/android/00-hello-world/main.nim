import
  ../../../src/frag/config,
  ../../../src/frag,
  ../../../src/frag,
  #../../../src/frag/graphics/color,
  ../../../src/frag/graphics/window

type
  App = ref object

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

logDroid "HERE"
#logDroid repr bgfx_init(BGFX_RENDERER_TYPE_NOOP, 0'u16, 0, nil, nil)
proc initializeApp*(app: App, ctx: Frag) =
  logDroid "Initializing app..."
  logDroid "App initialized."

proc updateApp*(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp*(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, graphics.ClearMode.Color.ord or graphics.ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

proc shutdownApp*(app: App, ctx: Frag) =
  logDroid "Shutting down app..."
  logDroid "App shut down."

startFrag[App](Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: graphics.ResetFlag.None,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: graphics.DebugMode.Text
))