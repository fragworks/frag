import
  events,
  hashes

import
  glm

import
  ../assets,
  ../assets/asset,
  ../graphics/text/vector_font

type
  EventBus* = ref object
    eventEmitter*: EventEmitter
    assetManager*: AssetManager

  EventType* {.pure.} = enum
    LoadAsset
    UnloadAsset
    GetAsset

  EventProducerType* {.pure.} = enum
    Debug

  EventProducer* = object
    initialized*: bool
    case eventProducerType*: EventProducerType
    of EventProducerType.Debug:
      debugFontAssetId*: Hash
      debugFont*: vectorFont.VectorFont
      projection*: Mat4f
      projectionDirty*: bool

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
