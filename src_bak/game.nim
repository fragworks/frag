type
  IGame* = tuple[
    init:      proc()
    , update:  proc(deltaTime: float)
    , render:  proc(deltaTime: float)
    , dispose: proc()
  ]

  AbstractGame* {.pure, inheritable.} = ref object of RootObj

proc init*(game: AbstractGame) =
  discard

proc update*(game: AbstractGame, deltaTime: float) =
  discard

proc render*(game: AbstractGame, deltaTime: float) =
  discard

proc dispose*(game: AbstractGame) =
  discard

#proc toGame*(game: AbstractGame) : IGame =
#  return (
#    init:      proc() = game.init()
#    , update:  proc(deltaTime: float) = game.update(deltaTime)
#    , render:  proc() = game.render()
#    , dispose: proc() = game.dispose()
#  )