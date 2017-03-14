import
  logging,
  os

import
  freetype

type
  VectorFontLoader* = ref object
    initialized: bool
    ft: Library

proc init*(vectorFontLoader: VectorFontLoader) : bool =
  if vectorFontLoader.initialized:
    warn "VectorFontLoader already initialized."
    return true

  debug "Initializing TrueType font loader..."

  if not initFreeType(addr vectorFontLoader.ft) == 0:
    error "Unable to initialize FreeType."
    return false

  vectorFontLoader.initialized = true

  debug "TrueType font loader initialized."

  return true

proc loadFontFace*(vectorFontLoader: VectorFontLoader, filepath: string, ): Face =
  debug "Loading TrueType font..."
  if not(splitFile(filepath).ext == ".ttf" or splitFile(filepath).ext == ".otf"):
    warn "Only TrueType font files are supported by this loader."
    return

  var face : Face
  if not freetype.newFace(vectorFontLoader.ft, filepath, 0, addr face) == 0:
    warn "Failed loading TrueType font file at: " & filepath
    return

  debug "TrueType font succesfully loaded."

  return face

proc shutdown*(vectorFontLoader: VectorFontLoader) =
  debug "Shutting down TrueType font loader..."
  discard freeType.doneLibrary(vectorFontLoader.ft)
  debug "TrueType font loader shut down."
