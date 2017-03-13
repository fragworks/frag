import 
  events,
  hashes

import 
  sdl2 as sdl

import
  ../assets,
  ../assets/asset

type
  FragEventType* = enum
    LoadAsset
    UnloadAsset
    GetAsset    

  SDLEventType* = enum
    WindowResize = "WindowEvent_Resized"

  EventProducerType* = enum
    Debug
  
  EventProducer* = object
    case eventProducerType*: EventProducerType
    of Debug:
      debugFontAssetId*: Hash

  FragEvent* = object of RootObj
    producer*: ref EventProducer
    case eventType*: FragEventType
    of LoadAsset, UnloadAsset, GetAsset:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType
      loadAssetCallback*: proc(producer: ref EventProducer, assetId: Hash)
      getAssetCallback*: proc(producer: ref EventProducer, asset: Asset)
      

  SDLEvent* = object of FragEvent
    sdlEventData*: sdl.Event

  FragEventMessage* = object of EventArgs
    event*: FragEvent

  SDLEventMessage* = object of EventArgs
    event*: sdl.Event

  EventHandler* = proc(e: EventArgs)