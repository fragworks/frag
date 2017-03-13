import
  events

import
  event,
  ../assets

proc handleLoadAssetEvent*(e: EventArgs) {.procvar.} =
  let event = FragEventMessage(e).event
  if not event.assetManager.isNil:
    let assetId = event.assetManager.load(event.filename, event.assetType, true)
    event.loadAssetCallback(event.producer, assetId)

proc handleUnloadAssetEvent*(e: EventArgs) {.procvar.} =
  let event = FragEventMessage(e).event
  if not event.assetManager.isNil:
    event.assetManager.unload(event.filename, true)