import
  events,
  logging

import
  sdl2 as sdl except EventType, Event

import
  events/event,
  events/event_handlers,
  events/sdl_event

export
  event,
  event_handlers,
  sdl_event

proc on*(
  eventBus: EventBus,
  eventHandler: event.EventHandler,
  eventType: EventType
) =
  events.on(eventBus.eventEmitter, $eventType, eventHandler)

proc emit*(eventBus: EventBus, e: var Event) =
  if e of SDLEvent:
    var sdlEvent = SDLEvent(e).sdlEventData
    case sdlEvent.kind
    of sdl.WindowEvent:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      eventBus.eventEmitter.emit($sdlEvent.window.event, eventMessage)
    else:
      warn "Unable to emit event with unknown type : " & $sdlEvent.kind
  else:
    case e.eventType
    of EventType.LoadAsset, EventType.UnloadAsset, EventType.GetAsset:
      e.assetManager = eventBus.assetManager
      let eventMessage = EventMessage(event: e)
      eventBus.eventEmitter.emit($e.eventType, eventMessage)

proc init*(eventBus: EventBus) =
  eventBus.eventEmitter = initEventEmitter()
