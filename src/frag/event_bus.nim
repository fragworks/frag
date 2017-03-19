import
  events

import
  sdl2 as sdl except EventType, Event

import
  logger,
  events/event,
  events/event_handlers,
  events/sdl_event

export
  event,
  event_handlers,
  sdl_event

proc on*(
  this: EventBus,
  eventType: enum,
  eventHandler: event.EventHandler
) =
  echo repr eventType
  events.on(this.emitter, $eventType, eventHandler)

proc emit*(this: EventBus, event: var Event) =
  if event of SDLEvent:
    let sdlEvent = SDLEvent(event)
    let sdlEventData = sdlEvent.sdlEventData
    case sdlEventData.kind
    of sdl.WindowEvent:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      this.emitter.emit($sdlEventData.window.event, eventMessage)
    of sdl.KeyDown, sdl.KeyUp:
      let eventMessage  = SDLEventMessage(event: sdlEvent)
      this.emitter.emit($sdlEventData.kind, eventMessage)
    else:
      logWarn "Unable to emit event with unknown type : " & $sdlEventData.kind
  else:
    case event.eventType
    of EventType.LoadAsset, EventType.UnloadAsset, EventType.GetAsset:
      event.assetManager = this.assetManager
      let eventMessage = EventMessage(event: event)
      this.emitter.emit($event.eventType, eventMessage)

proc init*(this: EventBus) =
  this.emitter = events.initEventEmitter()
