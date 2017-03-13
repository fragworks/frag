import events

import sdl2 as sdl

import ./event

type
  SDLEventType* {.pure.} = enum
    WindowResize = "WindowEvent_Resized"

  SDLEvent* = object of FragEvent
    sdlEventData*: sdl.Event

  SDLEventMessage* = object of EventArgs
    event*: sdl.Event
