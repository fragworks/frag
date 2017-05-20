import
  dom
  
proc `title=`*(n: Node; x: cstring) {.importcpp: "#.title = #", nodecl.}
