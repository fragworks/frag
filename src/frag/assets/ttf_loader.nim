import
  logging
  , os

import
  freetype

type
  TTFLoader* = ref object
    initialized: bool
    ft: Library

proc init*(ttfLoader: TTFLoader) : bool =
  if ttfLoader.initialized:
    warn "TTFLoader already initialized."
    return true
  
  debug "Initializing TrueType font loader..."

  if not initFreeType(addr ttfLoader.ft) == 0:
    error "Unable to initialize FreeType."
    return false
  
  ttfLoader.initialized = true

  debug "TrueType font loader initialized."
  
  return true

proc loadFontFace*(ttfLoader: TTFLoader, filepath: string, ): Face =
  debug "Loading TrueType font..."
  if not(splitFile(filepath).ext == ".ttf"):
    warn "Only TrueType font files are supported by this loader."
    return

  var face : Face
  if not freetype.newFace(ttfLoader.ft, filepath, 0, addr face) == 0:
    warn "Failed loading TrueType font file at: " & filepath
    return
  
  debug "TrueType font succesfully loaded."

  return face

proc shutdown*(ttfLoader: TTFLoader) =
  debug "Shutting down TrueType font loader..."
  discard freeType.doneLibrary(ttfLoader.ft)
  debug "TrueType font loader shut down."