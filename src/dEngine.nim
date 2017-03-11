import
  logging

import
  config
  , globals

type
  dEngine* = ref TDEngine
  TDEngine* = object

var consoleLogger : ConsoleLogger
var fileLogger : FileLogger

proc init(ctx: dEngine, config: dEngineConfig) =
  echo "Initializing dEngine - " & globals.version & "..."

  echo "Initializing logging subsystem..."

  consoleLogger = newConsoleLogger()
  fileLogger = newFileLogger(config.logFileName)

  logging.addHandler(consoleLogger)
  logging.addHandler(fileLogger)

  info "Logging subsystem initialized."

proc startdEngine*[App](config: dEngineConfig) =
  var ctx = dEngine()

  ctx.init(config)
  
  var app = App()

  app.initialize(ctx)
