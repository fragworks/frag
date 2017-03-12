import
  events

import
  event,
  ../assets

proc handleLoadAssetEvent*(e: EventArgs) {.procvar.} =
  let event = dEngineEventMessage(e).event
  if not event.assetManager.isNil:
    discard event.assetManager.load(event.filename, event.assetType)