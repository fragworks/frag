import
  hashes,
  logging

import
  assets/asset,
  event_bus,
  events/event

type
  DebugMode* = enum
    TEXT

  Debug* = ref object of EventProducer
    debugFontAssetId: Hash

proc debugFontLoaded*(producer: EventProducer, debugFontAssetId: Hash) =
  let debug = cast[Debug](producer)
  debug.debugFontAssetId = debugFontAssetId


proc init*(debug: Debug, events: EventBus) =  
  var loadDebugFontEvent = FragEvent(
      producer: debug,
      eventType: LoadAsset,
      filename: "fonts/FiraCode/distr/ttf/FiraCode-Regular.ttf",
      assetType: TTF,
      loadAssetCallback: debugFontLoaded
    )

  events.dispatch(
    loadDebugFontEvent
  )

proc shutdown*(debug: Debug, events: EventBus) =
  var unloadDebugFontEvent = FragEvent(
    eventType: UNLOAD_ASSET,
    filename: "fonts/FiraCode/distr/ttf/FiraCode-Regular.ttf"
  )
  
  events.dispatch(
    unloadDebugFontEvent
  )