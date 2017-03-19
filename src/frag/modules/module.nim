type Module* = ref object of RootObj
  name*: string

method init*(this: Module): bool {.base.} = discard
method deinit*(this: Module) {.base.} = discard
method update*(this: Module) {.base.} = discard
method render*(this: Module) {.base.} = discard
