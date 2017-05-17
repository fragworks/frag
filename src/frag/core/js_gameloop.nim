import
  dom,
  future

import
  pixi

import
  ../types,
  ../config,
  ../globals,
  ../logger,
  ../../../platforms/html5/src/frag/modules/js_graphics as graphics

export
  graphics

type
  GameLoop = object
    started, running: bool
    now, deltaTime, last: float
    rafHandle: int
    stats: Stats

  Stats {.importc.} = ref object of RootObj
    dom: Node

var renderer: Renderer
var stage: Container

proc getCurrentHighPTime(): float {.importcpp: "window.performance.now()".}
proc newStats(): Stats {.importcpp: "new Stats()".}
proc showPanel(stats: Stats, id: int) {.importcpp: "#.showPanel(@)".}
proc beginStats(stats: Stats) {.importcpp: "#.begin(@)".}
proc endStats(stats: Stats) {.importcpp: "#.end(@)".}

proc shutdownFRAG*(ctx: Frag, exitCode: int, shutdownIMGUI: bool) =
  discard

proc animate[T](ctx: Frag, app: T, gameLoop: var GameLoop, stats: bool, timestamp: float) =
  if stats:
    gameLoop.stats.beginStats()

  gameLoop.now = getCurrentHighPTime()
  gameLoop.deltaTime = gameLoop.deltaTime + min(1, (gameLoop.now - gameLoop.last) / 1000)
  while gameLoop.deltaTime > step:
    gameLoop.deltaTime = gameLoop.deltaTime - step
    app.updateApp(ctx, step)
  
  app.renderApp(ctx, gameLoop.deltaTime)

  #renderer.render(stage)
  graphics.render(ctx.graphics)

  gameLoop.last = gameLoop.now
  
  if stats:
    gameLoop.stats.endStats()

  gameLoop.rafHandle = window.requestAnimationFrame(
    (timestamp: float) => animate(ctx, app, gameLoop, stats, timestamp)
  )

proc start*[T](ctx: Frag, app: T, config: Config) =
  var gameLoop = GameLoop()
  if config.stats:
    gameLoop.stats = newStats()
    gameLoop.stats.showPanel(1)
    document.body.appendChild(gameLoop.stats.dom)

  gameLoop.started = true

  gameLoop.rafHandle = window.requestAnimationFrame(
    (timestamp: float) => animate(ctx, app, gameLoop, config.stats, timestamp)
  )
      
    

proc initFRAG*[App](ctx: Frag, app: App, config: Config) =
  logInfo "Initializing Frag - " & globals.version & "..."

  renderer = PIXI.autoDetectRenderer(256, 256)

  document.body.appendChild(renderer.view)

  stage = newContainer()
  
  logInfo "Frag initialized."