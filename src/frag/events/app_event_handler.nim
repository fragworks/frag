import
  events

type
  EventHandler* = proc(e: EventArgs)

  AppEventHandler* = ref object
    handleResize*: EventHandler

proc init*(appEventHandler: AppEventHandler, handleResize: EventHandler) =
  appEventHandler.handleResize = handleResize