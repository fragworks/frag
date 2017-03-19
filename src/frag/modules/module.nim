import
  ../config

type Module* = ref object of RootObj
  name*: string

method init*(this: Module, config: Config): bool {.base.} = discard
method shutdown*(this: Module) {.base.} = discard
method update*(this: Module) {.base.} = discard
method render*(this: Module) {.base.} = discard
