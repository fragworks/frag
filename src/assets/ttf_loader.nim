import
  logging

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
    
  if not initFreeType(addr ttfLoader.ft) == 0:
    error "Unable to initialize FreeType."
    return false
  
  ttfLoader.initialized = true
  
  return true