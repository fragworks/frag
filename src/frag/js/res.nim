import
  jsconsole,
  jsffi

type
  Loader* {.importc.} = ref object of RootObj
    progress*: int
    loading*: bool
    #resources*: Resources

  
  Resource* {.importc.} = ref object of RootObj
    name*, url*, extension*: cstring
    data*: JsObject


proc newLoader*(): Loader {.importcpp: "new Loader()".}
proc add*(loader: Loader, name: cstring, url: cstring): Loader {.importcpp: "#.add(@)".}
proc load*(loader: Loader) {.importcpp: "#.load(@)".}
proc resources*(loader: Loader): JsObject {.importcpp: "#.resources".}
