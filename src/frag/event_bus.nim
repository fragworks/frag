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
  eventType: enum,
  eventHandler: event.EventHandler
) =
  echo repr eventType
  events.on(eventBus.emitter, $eventType, eventHandler)

proc emit*(eventBus: EventBus, event: var Event) =
  if event of SDLEvent:
    let sdlEvent = SDLEvent(event)
    let sdlEventData = sdlEvent.sdlEventData
    case sdlEventData.kind
    of sdl.WindowEvent:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      eventBus.emitter.emit($sdlEventData.window.event, eventMessage)
    of sdl.KeyDown, sdl.KeyUp:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      eventBus.emitter.emit($sdlEventData.kind, eventMessage)
    else:
      warn "Unable to emit event with unknown type : " & $sdlEventData.kind
  else:
    case event.eventType
    of EventType.LoadAsset, EventType.UnloadAsset, EventType.GetAsset:
      event.assetManager = eventBus.assetManager
      let eventMessage = EventMessage(event: event)
      eventBus.emitter.emit($event.eventType, eventMessage)

proc init*(eventBus: EventBus) =
  eventBus.emitter = events.initEventEmitter()
