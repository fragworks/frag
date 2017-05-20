import
  ../config,
  ../events/event,
  ../events/event_handlers,
  ../logger,
  module

when not defined(js):
  import
    events

  import
    sdl2 as sdl except EventType, Event

  import
    ../events/sdl_event

  export
    sdl_event

export
  event,
  event_handlers

when not defined(js):
  proc init*(self: EventBus): bool =
    self.emitter = events.initEventEmitter()
    return true

  proc on*(
    self: EventBus,
    eventType: enum,
    eventHandler: event.EventHandler
  ) =
    events.on(self.emitter, $eventType, eventHandler)

  proc emit*(self: EventBus, event: var Event) =
    if event of SDLEvent:
      let sdlEvent = SDLEvent(event)
      let sdlEventData = sdlEvent.sdlEventData
      case sdlEventData.kind
      of sdl.WindowEvent:
        let eventMessage  = SDLEventMessage(event: sdlEvent)
        self.emitter.emit($sdlEventData.window.event, eventMessage)
      of sdl.KeyDown, sdl.KeyUp, sdl.MouseButtonDown, sdl.MouseButtonUp, sdl.MouseMotion, sdl.AppDidEnterForeground:
        let eventMessage  = SDLEventMessage(event: sdlEvent)
        self.emitter.emit($sdlEventData.kind, eventMessage)
      else:
        discard
    else:
      case event.eventType
      of EventType.LoadAsset, EventType.UnloadAsset, EventType.GetAsset:
        event.assetManager = self.assetManager
        let eventMessage = EventMessage(event: event)
        self.emitter.emit($event.eventType, eventMessage)
