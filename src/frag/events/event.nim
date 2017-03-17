import
  events,
  hashes

import
  sdl2 as sdl

import
  ../assets,
  ../assets/asset,
  ../assets/asset_types

type
  EventBus* = ref object
    emitter*: EventEmitter
    assetManager*: AssetManager

  EventType* {.pure.} = enum
    LoadAsset
    UnloadAsset
    GetAsset

  EventProducerType* {.pure.} = enum
    NONE

  EventProducer* = object

  Event* = object of RootObj
    eventBus*: EventBus
    producer*: ref EventProducer
    case eventType*: EventType
    of EventType.LoadAsset, EventType.UnloadAsset, EventType.GetAsset:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType
      assetId*: Hash
      loadAssetCallback*: proc(producer: ref EventProducer, eventBus: EventBus, assetId: Hash)
      getAssetCallback*: proc(producer: ref EventProducer, asset: ref Asset)

  EventMessage* = object of EventArgs
    event*: Event

  EventHandler* = proc(e: EventArgs)

proc registerAssetManager*(eventBus: EventBus, assetManager: AssetManager) =
  eventBus.assetManager = assetManager
