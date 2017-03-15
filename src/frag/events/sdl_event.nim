import events

import sdl2 as sdl except Event

import ./event

type
  SDLEventType* {.pure.} = enum
    KeyDown
    KeyUp
    WindowResize = "WindowEvent_Resized"

  SDLEvent* = object of Event
    sdlEventData*: sdl.Event

  SDLEventMessage* = object of EventArgs
    event*: sdl.Event
