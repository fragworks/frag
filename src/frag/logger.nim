import
  logging,
  strutils

import
  globals

when defined(android):
  {.emit: """
    #include <android/log.h>
  """.}
  proc native_log(level: Level, a: cstring) =
      case level:
      of lvlDebug:
        {.emit: """__android_log_write(ANDROID_LOG_DEBUG, "FRAG", `a`);""".}
      of lvlInfo:
        {.emit: """__android_log_write(ANDROID_LOG_INFO, "FRAG", `a`);""".}
      of lvlWarn:
        {.emit: """__android_log_write(ANDROID_LOG_WARN, "FRAG", `a`);""".}
      of lvlError:
        {.emit: """__android_log_write(ANDROID_LOG_ERROR, "FRAG", `a`);""".}
      of lvlFatal:
        {.emit: """__android_log_write(ANDROID_LOG_FATAL, "FRAG", `a`);""".}
      else:
        discard

  proc logDebug*(a: varargs[string, `$`]) = native_log(Level.lvlDebug, a.join())
  proc logInfo*(a: varargs[string, `$`]) = native_log(Level.lvlInfo, a.join())
  proc logWarn*(a: varargs[string, `$`]) = native_log(Level.lvlWarn, a.join())
  proc logError*(a: varargs[string, `$`]) = native_log(Level.lvlError, a.join())
  proc logFatal*(a: varargs[string, `$`]) = native_log(Level.lvlFatal, a.join())
  proc log*(a: varargs[string, `$`]) = logDebug(a)

  proc init*(logFileName: string) =
    discard

else:
  var consoleLogger : ConsoleLogger
  var fileLogger : FileLogger

  proc logDebug*(args: varargs[string, `$`]) =
    logging.debug(args)

  proc logInfo*(args: varargs[string, `$`]) =
    logging.info(args)

  proc logWarn*(args: varargs[string, `$`]) =
    logging.warn(args)

  proc logError*(args: varargs[string, `$`]) =
    logging.error(args)

  proc logFatal*(args: varargs[string, `$`]) =
    logging.fatal(args)

  proc log*(args: varargs[string, `$`]) =
    logDebug(args)

  proc init*(logFileName: string) =
    consoleLogger = newConsoleLogger()
    if logFileName.isNil:
      fileLogger = newFileLogger(defaultLogFileName)
    else:  
      fileLogger = newFileLogger(logFileName)
    logging.addHandler(consoleLogger)
    logging.addHandler(fileLogger)
