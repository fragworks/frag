import events

import 
  sdl2 as sdl except Event

import
  event,
  ../modules/module

type
  SDLEventType* {.pure.} = enum
    KeyDown
    KeyUp
    MouseButtonDown
    MouseButtonUp
    MouseMotion
    WindowResize = "WindowEvent_Resized"

  SDLEvent* = object of Event
    sdlEventData*: sdl.Event
    case sdlEventType*: SDLEventType
    of SDLEventType.KeyDown, SDLEventType.KeyUp, 
      SDLEventType.MouseButtonDown, SDLEventType.MouseButtonUp,
      SDLEventType.MouseMotion:
      input*: Input
      gui*: GUI
    of SDLEventType.WindowResize:
      graphics*: Graphics
      userData*: pointer
    else:
      discard

  SDLEventMessage* = object of EventArgs
    event*: SDLEvent
