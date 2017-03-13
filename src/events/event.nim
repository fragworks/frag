import
  events,
  hashes

import
  ../assets,
  ../assets/asset,
  ../graphics/text/ttf

type
  EventBus* = ref object
    eventEmitter*: EventEmitter
    assetManager*: AssetManager

  FragEventType* = enum
    LoadAsset
    UnloadAsset
    GetAsset

  EventProducerType* = enum
    Debug

  EventProducer* = object
    initialized*: bool
    case eventProducerType*: EventProducerType
    of Debug:
      debugFontAssetId*: Hash
      debugFont*: ttf.TTF

  FragEvent* = object of RootObj
    eventBus*: EventBus
    producer*: ref EventProducer
    case eventType*: FragEventType
    of LoadAsset, UnloadAsset, GetAsset:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType
      assetId*: Hash
      loadAssetCallback*: proc(producer: ref EventProducer, eventBus: EventBus, assetId: Hash)
      getAssetCallback*: proc(producer: ref EventProducer, asset: ref Asset)

  FragEventMessage* = object of EventArgs
    event*: FragEvent

  EventHandler* = proc(e: EventArgs)

proc registerAssetManager*(eventBus: EventBus, assetManager: AssetManager) =
  eventBus.assetManager = assetManager
