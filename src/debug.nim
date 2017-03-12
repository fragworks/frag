import
  event_bus,
  events/event

type
  DebugMode* = enum
    TEXT

  Debug* = ref object

proc init*(debug: Debug, events: EventBus) =
  events.dispatch(
    DEngineEvent(
      eventType: LOAD_ASSET,
      filename: "Testing Event Emission..."
    )
  )