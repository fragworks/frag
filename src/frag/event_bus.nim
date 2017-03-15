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
  eventBus: EventBus
  , eventHandler: event.EventHandler
  , eventType: enum
) =
  events.on(eventBus.eventEmitter, $eventType, eventHandler)

proc emit*(eventBus: EventBus, event: var Event) =
  if event of SDLEvent:
    var sdlEvent = SDLEvent(event).sdlEventData
    case sdlEvent.kind
    of sdl.WindowEvent:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      eventBus.eventEmitter.emit($sdlEvent.window.event, eventMessage)
    of sdl.KeyDown, sdl.KeyUp:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      eventBus.eventEmitter.emit($sdlEvent.kind, eventMessage)
    else:
      warn "Unable to emit event with unknown type : " & $sdlEvent.kind
  else:
    case event.eventType
    of EventType.LoadAsset, EventType.UnloadAsset, EventType.GetAsset:
      event.assetManager = eventBus.assetManager
      let eventMessage = EventMessage(event: event)
      eventBus.eventEmitter.emit($event.eventType, eventMessage)

proc init*(eventBus: EventBus) =
  eventBus.eventEmitter = initEventEmitter()
