#   FRAG - Framework for Rather Awesome Games
#   (c) Copyright 2017 Fragworks
#
#   See the file "LICENSE", included in this
#   distribution, for details about the copyright.

## ===============
## Module frag.events.event
## ===============
##
## The variant type ``Event`` and its discriminator ``EventType`` define
## all of the framework-specific (non-SDL2) events raised by FRAG.

import
  events,
  hashes

import
  sdl2 as sdl

import
  ../assets/asset,
  ../assets/asset_types,
  ../modules/assets,
  ../modules/module

type
  EventType* {.pure.} = enum
    ## Types of the various framework-specific events raised by FRAG
    LoadAsset
    UnloadAsset
    GetAsset

  EventProducer* = object

  Event* = object of RootObj
    ## Variant type defining all framework-specific events
    eventBus*: EventBus ## ``EventBus`` the event is emitted through
    producer*: ref EventProducer ## Producer of the event
    case eventType*: EventType ## Type of event
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
