import sdl2

import log

type
  EventListener = object
    receiveEvent: ReceieveEventFunc
    subscriptions: seq[EventType]

  ReceieveEventFunc = proc(event: Event) : bool

var eventListeners {.global.} : seq[EventListener]

proc dispatchEvent(event: Event) =
  for listener in eventListeners:
    if contains(listener.subscriptions, event.kind):
      if not listener.receiveEvent(event):
        discard

proc handleEvent*(event: Event) =
  dispatchEvent(event)

proc registerEventListener*(receiveEvent: ReceieveEventFunc, subscriptions: seq[EventType]) =
  var eventListener = EventListener()
  eventListener.receiveEvent = receiveEvent
  eventListener.subscriptions = subscriptions
  add(eventListeners, eventListener)

proc eventInit*() : bool =
  eventListeners = @[]
  return true