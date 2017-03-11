import
  ../../src/config
  , ../../src/dEngine

type
  App = ref object

proc initialize*(app: App, ctx: dEngine) =
  echo "Initializing app."

startdEngine[App]((
  rootWindowTitle: "dEngine Example 00-HelloWorld"
  , logFileName: "example-00.log"
))