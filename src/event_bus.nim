import
  events,
  logging

import 
  sdl2 as sdl

import
  events/event

type
  EventBus* = ref object
    eventEmitter: EventEmitter

proc registerEventHandler*(
  eventBus: EventBus
  , eventHandler: event.EventHandler
  , eventType: SDLEventType
) =
  events.on(eventBus.eventEmitter, $eventType, eventHandler)

proc registerEventHandler*(
  eventBus: EventBus
  , eventHandler: event.EventHandler
  , eventType: DEngineEventType
) =
  events.on(eventBus.eventEmitter, $eventType, eventHandler)

proc dispatch*(eventBus: EventBus, e: DEngineEvent) =  
  let eventMessage = DEngineEventMessage(event: e)
  eventBus.eventEmitter.emit($e.eventType, eventMessage)

proc dispatch*(eventBus: EventBus, e: sdl.Event) =  
  case e.kind
  of sdl.WindowEvent:
    let eventMessage  = SDLEventMessage(event: e)
    eventBus.eventEmitter.emit($e.window.event, eventMessage)
  else:
    warn "Unable to dispatch event with unknown type : " & $e.kind

proc init*(eventBus: EventBus) =
  eventBus.eventEmitter = initEventEmitter()