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
      filename: "Testing Event Emission...",
      assetType: TTF
    )
  events.dispatch(
    loadDebugFontEvent
  )