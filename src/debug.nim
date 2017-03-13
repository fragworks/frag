import
  hashes

import
  assets/asset,
  event_bus,
  events/event

type
  DebugMode* = enum
    TEXT

  Debug* = ref object

proc init*(debug: Debug, events: EventBus) =
  var loadDebugFontEvent = FragEvent(
      eventType: LOAD_ASSET,
      filename: "fonts/FiraCode/distr/ttf/FiraCode-Regular.ttf",
      assetType: TTF
    )
  events.dispatch(
    loadDebugFontEvent
  )

proc shutdown*(debug: Debug, events: EventBus) =
  var unloadDebugFontEvent = FragEvent(
    eventType: UNLOAD_ASSET,
    filename: "fonts/FiraCode/distr/ttf/FiraCode-Regular.ttf"
  )