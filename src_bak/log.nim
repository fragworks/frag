import logging

proc logFatal*(args: varargs[string]) =
  fatal(args)

proc logError*(args: varargs[string]) =
  error(args)

proc logWarn*(args: varargs[string]) =
  warn(args)

proc logDebug*(args: varargs[string]) =
  debug(args)

proc logInfo*(args: varargs[string]) =
  info(args)

proc initLogging() = 
  addHandler(newConsoleLogger())
  logInfo("Logging subsystem initialized.")

initLogging()