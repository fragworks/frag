import glm, opengl, tables

const POSITION_ATTRIBUTE* = "d_position"
const COLOR_ATTRIBUTE* = "d_color"
const TEXCOORD_ATTRIBUTE* = "d_texCoord"

type
  Shader = object
    handle: GLuint
    source: string
  
  VertexShader = Shader
  FragmentShader = Shader

  ShaderProgram* = ref object of RootObj
    handle*: GLuint
    vertexShader: VertexShader
    fragmentShader: FragmentShader
    log*: string
    isCompiled*: bool
    attributes: Table[string, int]
    attributeNames: seq[string]
    attributeSizes: seq[GLint]
    attributeTypes: seq[GLenum]

proc createShader(shaderProgram: var ShaderProgram, `type`: GLenum, source: string) : bool =
  let shader = glCreateShader(`type`)
  if shader == 0:
    return false
  
  let shaderSrc = allocCStringArray([source])

  var compileStatus : GLint

  glShaderSource(shader, 1, shaderSrc, nil)
  glCompileShader(shader)

  deAllocCStringArray(shaderSrc)

  glGetShaderiv(shader, GL_COMPILE_STATUS, addr compileStatus)

  if compileStatus == 0:
    var infoLogLength: GLint = 0
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr infoLogLength)
    var infoLog = ""
    glGetShaderInfoLog(shader, infoLogLength, nil, infoLog)
    shaderProgram.log.add(infoLog)
    echo infolog
    return false

  if `type` == GL_VERTEX_SHADER:
    shaderProgram.vertexShader.handle = shader
  else:
    shaderProgram.fragmentShader.handle = shader
  
  return true

proc linkProgram(shaderProgram: var ShaderProgram) : bool =
  glAttachShader(shaderProgram.handle, shaderProgram.vertexShader.handle)
  glAttachShader(shaderProgram.handle, shaderProgram.fragmentShader.handle)
  glLinkProgram(shaderProgram.handle)

  var linkStatus : GLint

  glGetProgramiv(shaderProgram.handle, GL_LINK_STATUS, addr linkStatus)
  if linkStatus == 0:
    var infoLogLength: GLint = 0
    glGetProgramiv(shaderProgram.handle, GL_INFO_LOG_LENGTH, addr infoLogLength)
    var infoLog = ""
    glGetProgramInfoLog(shaderProgram.handle, infoLogLength, nil, infoLog)
    shaderProgram.log.add(infoLog)
    return false
  
  return true

proc compileShaders(shaderProgram: var ShaderProgram) =
  let vertexShaderCreated = createShader(shaderProgram, GL_VERTEX_SHADER, shaderProgram.vertexShader.source)
  let fragmentShaderCreated = createShader(shaderProgram, GL_FRAGMENT_SHADER, shaderProgram.fragmentShader.source)

  if not vertexShaderCreated or not fragmentShaderCreated:
    shaderProgram.isCompiled = false
    return

  shaderProgram.handle = glCreateProgram()

  if shaderProgram.handle == 0:
    shaderProgram.isCompiled = false
    return

  if not linkProgram(shaderProgram):
    shaderProgram.isCompiled = false
    return

  shaderProgram.isCompiled = true

proc extractAttr(shaderProgram: ShaderProgram, i: int): (string,int, GLint, GLenum) =
  var name = newStringOfCap(1024)
  var retLength: GLsizei
  var retSizeOfAttr: GLint
  var retTypeOfAttr: GLenum
  glGetActiveAttrib(shaderProgram.handle, i.GLuint, 1024.GLsizei, retLength.addr, retSizeOfAttr.addr, retTypeOfAttr.addr, name)
  name.setlen(retLength)
  let location = glGetAttribLocation(shaderProgram.handle, name)
  (name, location.int, retSizeOfAttr, retTypeOfAttr)

proc fetchAttributes(shaderProgram: var ShaderProgram) =
  var numAttributes : GLint
  glGetProgramiv(shaderProgram.handle, GL_ACTIVE_ATTRIBUTES, addr numAttributes)
  shaderProgram.attributes = initTable[string, int]()
  shaderProgram.attributeNames = @[]
  shaderProgram.attributeTypes = @[]
  shaderProgram.attributeSizes = @[]

  for i in 0..<numAttributes:
    let (name, location, size, `type`) = extractAttr(shaderProgram, i)
    add(shaderProgram.attributes, name, location)
    shaderProgram.attributeTypes.add(`type`)
    shaderProgram.attributeSizes.add(size)
    shaderProgram.attributeNames.add(name)

proc newShader(source: string) : Shader =
  result = Shader()
  result.source = source

proc newShaderProgram*(vertexShaderSource: string, fragmentShaderSource: string) : ShaderProgram =
  result = ShaderProgram()
  result.vertexShader = newShader(vertexShaderSource)
  result.fragmentShader = newShader(fragmentShaderSource)
  result.log = ""

  compileShaders(result)

  if result.isCompiled:
    fetchAttributes(result)

proc getAttributeLocation*(shaderProgram: ShaderProgram, name: string) : int =
  if shaderProgram.attributes.contains(name):
    return shaderProgram.attributes[name]
  else:
    return -1

proc disableVertexAttribute*(shaderProgram: ShaderProgram, location: int) =
  glDisableVertexAttribArray(GLuint location)

proc enableVertexAttribute*(shaderProgram: ShaderProgram, location: int) =
  glEnableVertexAttribArray(GLuint location)

proc setVertexAttribute*(shaderProgram: ShaderProgram, location: int, size: int, `type`: GLenum, normalize: bool, stride: int, offset: var int) =
  glVertexAttribPointer(GLuint location, GLint size, `type`, normalize, GLsizei stride, addr offset)

proc begin*(shaderProgram: ShaderProgram) =
  glUseProgram(shaderProgram.handle)

proc `end`*(shaderProgram: ShaderProgram) =
  glUseProgram(0)

proc setUniformMatrix*(shaderProgram: ShaderProgram, name: string, matrix: var Mat4x4[GLfloat], transpose: bool) =
  glUniformMatrix4fv(GLint(glGetUniformLocation(shaderProgram.handle, name)), 1, transpose, matrix.caddr)

proc setUniformMatrix*(shaderProgram: ShaderProgram, name: string, matrix: var Mat4x4[GLfloat]) =
  glUniformMatrix4fv(GLint(glGetUniformLocation(shaderProgram.handle, name)), 1, false, matrix.caddr)

proc setUniform3f*(shaderProgram: ShaderProgram, name: string, value: Vec3f) =
  glUniform3f(GLint(glGetUniformLocation(shaderProgram.handle, name)),value.x, value.y, value.z)

proc setUniform1f*(shaderProgram: ShaderProgram, name: string, value: float) =
  glUniform1f(GLint(glGetUniformLocation(shaderProgram.handle, name)),value)

proc setUniformi*(shaderProgram: ShaderProgram, name: string, value: int) =
  glUniform1i(GLint(glGetUniformLocation(shaderProgram.handle, name)), GLint value)