import events

import 
  sdl2 as sdl except Event

import
  event,
  app_event_handler,
  ../modules/module

type
  EventAwareApp = concept a
    a.eventHandler is AppEventHandler

  SDLEventType* {.pure.} = enum
    KeyDown
    KeyUp
    WindowResize = "WindowEvent_Resized"

  SDLEvent* = object of Event
    sdlEventData*: sdl.Event
    case sdlEventType*: SDLEventType
    of SDLEventType.KeyDown, SDLEventType.KeyUp:
      input*: Input
      gui*: GUI
    of SDLEventType.WindowResize:
      graphics*: Graphics
      userData*: pointer
    else:
      discard

  SDLEventMessage* = object of EventArgs
    event*: SDLEvent
