import
  events

import
  event,
  sdl_event,
  ../assets,
  ../assets/asset,
  ../assets/asset_types,
  ../input

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
  
proc handleInputEvent*(e: EventArgs) {.procvar.} =
  let event = SDLEventMessage(e).event
  if not event.input.isNil:
    event.input.onKeyDown(event.sdlEventData)

  