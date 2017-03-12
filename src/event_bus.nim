import
  events,
  logging

import 
  sdl2 as sdl

import
  assets,
  events/event

type
  EventBus* = ref object
    eventEmitter: EventEmitter
    assetManager: AssetManager

proc registerEventHandler*(
  eventBus: EventBus
  , eventHandler: event.EventHandler
  , eventType: SDLEventType
) =
  events.on(eventBus.eventEmitter, $eventType, eventHandler)

proc registerEventHandler*(
  eventBus: EventBus
  , eventHandler: event.EventHandler
  , eventType: dEngineEventType
) =
  events.on(eventBus.eventEmitter, $eventType, eventHandler)

proc dispatch*(eventBus: EventBus, e: var dEngineEvent) =  
  case e.eventType
  of LOAD_ASSET:
    e.assetManager = eventBus.assetManager
    let eventMessage = dEngineEventMessage(event: e)
    eventBus.eventEmitter.emit($e.eventType, eventMessage)

proc dispatch*(eventBus: EventBus, e: sdl.Event) =  
  case e.kind
  of sdl.WindowEvent:
    let eventMessage  = SDLEventMessage(event: e)
    eventBus.eventEmitter.emit($e.window.event, eventMessage)
  else:
    warn "Unable to dispatch event with unknown type : " & $e.kind

proc registerAssetManager*(eventBus: EventBus, assetManager: AssetManager) =
  eventBus.assetManager = assetManager

proc init*(eventBus: EventBus) =
  eventBus.eventEmitter = initEventEmitter()