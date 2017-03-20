import
  ../../../src/frag,
  ../../../src/frag/config,
  ../../../src/frag/graphics/window,
  ../../../src/frag/logger,
  ../../../src/frag/modules/graphics

type
  App = ref object

proc initializeApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  logDebug "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  logDebug "App shut down."

startFrag[App](Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: DebugMode.Text
))

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