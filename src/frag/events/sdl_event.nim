import events

import 
  sdl2 as sdl except Event

import
  event,
  ../modules/module

type
  SDLEventType* {.pure.} = enum
    AppDidEnterForeground
    KeyDown
    KeyUp
    MouseButtonDown
    MouseButtonUp
    MouseMotion
    WindowResize = "WindowEvent_Resized"

  SDLEvent* = object of Event
    sdlEventData*: sdl.Event
    gui*: GUI
    userData*: pointer
    case sdlEventType*: SDLEventType
    of SDLEventType.KeyDown, SDLEventType.KeyUp, 
      SDLEventType.MouseButtonDown, SDLEventType.MouseButtonUp,
      SDLEventType.MouseMotion:
      input*: Input
    of SDLEventType.WindowResize, SDLEventType.AppDidEnterForeground:
      graphics*: Graphics
    else:
      discard

  SDLEventMessage* = object of EventArgs
    event*: SDLEvent
