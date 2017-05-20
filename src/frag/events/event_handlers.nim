#   FRAG - Framework for Rather Awesome Games
#   (c) Copyright 2017 Fragworks
#
#   See the file "LICENSE", included in this
#   distribution, for details about the copyright.

## ===============
## Module frag.events.event_handlers
## ===============
##
## Framework level event handlers are contained within this module.
## Both framework-specific and SDL2 event handlers are found within.

import
  events

import
  ../assets/asset,
  ../assets/asset_types,
  ../modules/assets,
  ../modules/gui,
  ../modules/input,
  ../modules/graphics,
  event

when not defined(js):
  import
    sdl_event

  proc handleLoadAssetEvent*(e: EventArgs) {.procvar.} =
    let event = EventMessage(e).event
    if not event.assetManager.isNil:
      let assetId = event.assetManager.load(event.filename, event.assetType, true)
      event.loadAssetCallback(event.producer, event.eventBus, assetId)

  proc handleUnloadAssetEvent*(e: EventArgs) {.procvar.} =
    let event = EventMessage(e).event
    if not event.assetManager.isNil:
      event.assetManager.unload(event.filename, true)

  proc handleGetAssetEvent*(e: EventArgs) {.procvar.} =
    let event = EventMessage(e).event
    if not event.assetManager.isNil:
      let asset = assets.get[Texture](event.assetManager, event.assetId)
      event.getAssetCallback(event.producer, asset)

  proc handleKeyDown*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.input.isNil:
      input.onKeyDown(event.input, event.sdlEventData)
    if not event.gui.isNil:
      gui.onkeyDown(event.gui, event.sdlEventData)

  proc handleKeyUp*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.input.isNil:
      input.onKeyUp(event.input, event.sdlEventData)
    if not event.gui.isNil:
      gui.onKeyUp(event.gui, event.sdlEventData)

  proc handleMouseButtonDown*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.input.isNil:
      input.onMouseButtonDown(event.input, event.sdlEventData)
    if not event.gui.isNil:
      gui.onMouseButtonDown(event.gui, event.sdlEventData)

  proc handleMouseButtonUp*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.input.isNil:
      input.onMouseButtonUp(event.input, event.sdlEventData)
    if not event.gui.isNil:
      gui.onMouseButtonUp(event.gui, event.sdlEventData)

  proc handleMouseMotionEvent*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.input.isNil:
      input.onMouseMotion(event.input, event.sdlEventData)
    if not event.gui.isNil:
      gui.onMouseMotion(event.gui, event.sdlEventData)

  proc handleWindowResizeEvent*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.graphics.isNil:
      event.graphics.onWindowResize(event.sdlEventData)

  proc handleAppDidEnterForegroundEvent*(e: EventArgs) {.procvar.} =
    let event = SDLEventMessage(e).event
    if not event.graphics.isNil:
      event.graphics.onUnpause(event.sdlEventData)