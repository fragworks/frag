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

  EventProducer* = ref object of RootObj

  FragEvent* = object of RootObj
    producer*: EventProducer
    case eventType*: FragEventType
    of LoadAsset, UnloadAsset, GetAsset:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType
      loadAssetCallback*: proc(producer: EventProducer, assetId: Hash)
      getAssetCallback*: proc(producer: EventProducer, asset: Asset)
      

  SDLEvent* = object of FragEvent
    sdlEventData*: sdl.Event

  FragEventMessage* = object of EventArgs
    event*: FragEvent

  SDLEventMessage* = object of EventArgs
    event*: sdl.Event

  EventHandler* = proc(e: EventArgs)