when defined(js):
  import
    config,
    ../../platforms/html5/src/frag/modules/js_graphics as graphics
    
  type
    Frag* = ref object
      graphics*: Graphics

else:
  import
    config,
    framerate/framerate,
    globals,
    logger,
    modules/assets,
    modules/event_bus as events,
    modules/graphics,
    modules/gui,
    modules/input,
    modules/module

  type
    Frag* = ref object
      assets*: AssetManager
      events*: EventBus
      graphics*: Graphics
      gui*: GUI
      input*: Input