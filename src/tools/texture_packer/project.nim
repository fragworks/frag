import parsecfg

type
  Project* = object
    name*: string
    path*: string

proc openProject*(filename: string) : Project =
  result = Project()
  var cfg = loadConfig(filename)
  result.name = cfg.getSectionValue("project", "name")
  result.path = cfg.getSectionValue("project", "path")


