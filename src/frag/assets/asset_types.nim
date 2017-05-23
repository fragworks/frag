#   FRAG - Framework for Rather Awesome Games
#   (c) Copyright 2017 Fragworks
#
#   See the file "LICENSE", included in this
#   distribution, for details about the copyright.

## ===============
## Module frag.assets.asset_types
## ===============
##
## Contains enumeration ``AssetType`` which acts as a discriminator
## for the variant type ``Asset`` in the ``frag.assets.asset`` module.

type
  AssetType* {.pure.} = enum
    ## Asset types supported by FRAG
    Sound
    Texture
    TextureRegion 
    TextureAtlas
    TiledMap