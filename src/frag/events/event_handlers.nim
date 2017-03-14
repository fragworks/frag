import
  events

import
  event,
  sdl_event,
  ../assets

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
    let asset = event.assetManager.get(event.assetId)
    event.getAssetCallback(event.producer, asset)
  