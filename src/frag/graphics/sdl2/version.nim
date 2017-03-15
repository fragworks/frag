# Printable format: "$1.$2.$3" % [MAJOR, MINOR, PATCHLEVEL]
const
  MAJOR_VERSION* = 2
  MINOR_VERSION* = 0
  PATCHLEVEL* = 5

template version*(x: untyped) = ##  \
  ##  Template to determine SDL version program was compiled against.
  ##
  ##  This template fills in a Version object with the version of the
  ##  library you compiled against. This is determined by what header the
  ##  compiler uses. Note that if you dynamically linked the library, you might
  ##  have a slightly newer or older version at runtime. That version can be
  ##  determined with getVersion(), which, unlike version(),
  ##  is not a template.
  ##
  ##  ``x`` Version object to initialize.
  ##
  ##  See also:
  ##
  ##  ``Version``
  ##
  ##  ``getVersion``
  (x).major = MAJOR_VERSION
  (x).minor = MINOR_VERSION
  (x).patch = PATCHLEVEL