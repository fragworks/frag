import
  hashes,
  logging

import
  glm,
  opengl

import
  ../assets/asset,
  ../event_bus,
  ../events/event,
  color,
  text/vector_font

const fontPath = "fonts/FiraCode/distr/otf/FiraCode-Regular.otf"

type
  DebugMode* {.pure.} = enum
    Text

  Debug* = ref EventProducer

proc debugFontRetrieved*(producer: ref EventProducer, debugFont: ref Asset) =
  let debug = cast[Debug](producer)
  debug.debugFont = debugFont

  debug.debugFont.setSize((width: 0u32, height: 12u32))

  debug.initialized = true

proc debugFontLoaded*(producer: ref EventProducer, events: EventBus, debugFontAssetId: Hash) =
  let debug = cast[Debug](producer)
  debug.debugFontAssetId = debugFontAssetId

  var getDebugFontEvent = Event(
    producer: debug,
    eventType: EventType.GetAsset,
    assetId: debug.debugFontAssetId,
    getAssetCallback: debugFontRetrieved
  )

  events.emit(getDebugFontEvent)

proc drawText*(debug: Debug, text: string, x, y, scale: float = 1.0, color: Color) =
  if debug.projectionDirty:
    debug.debugFont.render(text, x, y, scale, color, debug.projection)
    debug.projectionDirty = false
  else:
    debug.debugFont.render(text, x, y, scale, color)


proc setProjection*(debug: Debug, projection: Mat4f) =
  debug.projection = projection
  debug.projectionDirty = true

proc init*(debug: Debug, events: EventBus, width, height: int) =
  if debug.initialized:
    warn "Debug subsystem already initialized."
    return

  debug.projection = glm.ortho[GLfloat](0.0, GLfloat width, GLfloat height, 0.0, -1.0, 1.0)
  debug.projectionDirty = true

  var loadDebugFontEvent = Event(
      eventBus: events,
      producer: debug,
      eventType: EventType.LoadAsset,
      filename: fontPath,
      assetType: AssetType.VectorFont,
      loadAssetCallback: debugFontLoaded
    )

  events.emit(loadDebugFontEvent)

proc shutdown*(debug: Debug, events: EventBus) =
  var unloadDebugFontEvent = Event(
    eventType: EventType.UnloadAsset,
    filename: fontPath
  )

  events.emit(unloadDebugFontEvent)
