import
  logging,
  tables

import
  freetype,
  glm,
  opengl

import
  ../../assets/asset,
  ../color,
  ../shader

type
  TTF* = ref Asset

  FontSize* = tuple[
    width, height: uint32
  ]

const defaultFontSize : FontSize = (width: 0u32, height: 12u32)

const backgroundVertexShaderSource = """
  #version 330 core
  layout (location = 0) in vec2 vertex; // <vec2 pos>

  uniform mat4 projection;

  void main()
  {
      gl_Position = projection * vec4(vertex.xy, 0.0, 1.0);
  } 
"""

const backgroundFragmentShaderSource = """
  #version 330 core
  out vec4 color;

  uniform sampler2D text;
  uniform vec4 backgroundTextColor;

  void main()
  {
      color = backgroundTextColor;
  }  
"""

const vertexShaderSource = """
  #version 330 core
  layout (location = 0) in vec4 vertex; // <vec2 pos, vec2 tex>
  out vec2 TexCoords;

  uniform mat4 projection;

  void main()
  {
      gl_Position = projection * vec4(vertex.xy, 0.0, 1.0);
      TexCoords = vertex.zw;
  } 
"""

const fragmentShaderSource = """
  #version 330 core
  in vec2 TexCoords;
  out vec4 color;

  uniform sampler2D text;
  uniform vec4 textColor;

  void main()
  {
      vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, TexCoords).r);
      color = textColor * sampled;
  }  
"""

proc setSize*(ttf: TTF, size: FontSize) =
  discard freetype.setPixelSizes(ttf.fontFace, size.width, size.height)

proc initializeFont(ttf: TTF, fontSize: FontSize) =
  ttf.setSize(fontSize)

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1)

  var c : GLubyte = 0
  while c < 128:
    if freetype.loadChar(ttf.fontFace, c, freetype.LOAD_RENDER) != 0:
      warn "Failed to load TrueType font glyph."

    var texture : GLuint
    glGenTextures(1, addr texture)
    glBindTexture(GL_TEXTURE_2D, texture)
    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_RED.ord,
        GLsizei ttf.fontFace.glyph.bitmap.width,
        GLsizei ttf.fontFace.glyph.bitmap.rows,
        0,
        GL_RED,
        GL_UNSIGNED_BYTE,
        ttf.fontFace.glyph.bitmap.buffer
    )

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    ttf.characters.add(
      GLchar c,
      Character(
        textureID: texture,
        size: vec2i(int32 ttf.fontFace.glyph.bitmap.width, int32 ttf.fontFace.glyph.bitmap.rows),
        bearing: vec2i(ttf.fontFace.glyph.bitmap_left, ttf.fontFace.glyph.bitmap_top),
        height: GLuint ttf.fontFace.glyph.bitmap.rows,
        advance: GLuint `shr`(ttf.fontFace.glyph.advance.x, 6)
      )
    )
    inc(c)

  glBindTexture(GL_TEXTURE_2D, 0)

  glGenVertexArrays(1, addr ttf.backgroundVAO)
  glGenVertexArrays(1, addr ttf.vao)
  
  glGenBuffers(1, addr ttf.vbo)
  glGenBuffers(1, addr ttf.backgroundVBO)
  
  glBindVertexArray(ttf.backgroundVAO)
  
  glBindBuffer(GL_ARRAY_BUFFER, ttf.backgroundVBO)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 6 * 2, nil, GL_STATIC_DRAW)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 2, cGL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), nil)

  glBindVertexArray(ttf.vao)
  glBindBuffer(GL_ARRAY_BUFFER, ttf.vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 6 * 4, nil, GL_DYNAMIC_DRAW)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 4, cGL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), nil)
  
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  
  glBindVertexArray(0)

  ttf.backgroundProgram = createShaderProgram(backgroundVertexShaderSource, backgroundFragmentShaderSource)
  ttf.shaderProgram = createShaderProgram(vertexShaderSource, fragmentShaderSource)

proc load*(fontFace: Face, fontSize: FontSize = defaultFontSize): TTF =
  result = TTF(assetType: AssetType.TTF)
  result.fontFace = fontFace

  result.characters = initTable[GLchar, Character](128)

  initializeFont(result, fontSize)

proc measureText*(ttf: TTF, text: string): tuple[width, height: uint] =
  var w: uint
  for i in 0..<text.len:
    let c = text[i]
    w += ttf.characters[c].advance
  
  var h: uint
  for i in 0..<text.len:
    let c = text[i]
    if h < ttf.characters[c].height:
      h = ttf.characters[c].height
  
  return (w, h)

proc renderBackground*(ttf: TTF, bgColor: Color, x, y: float, size: tuple[width, height: uint], projection: var Mat4f, projectionDirty: bool = false) =
  ttf.backgroundProgram.begin()

  if projectionDirty:
    ttf.backgroundProgram.setUniformMatrix("projection", projection)

  ttf.backgroundProgram.setUniform4f("backgroundTextColor", vec4f(bgColor.r, bgColor.g, bgColor.b, bgColor.a))

  glBindVertexArray(ttf.backgroundVAO)

  let w: GLfloat = GLfloat size.width
  let h: GLfloat = GLfloat size.height

  var vertices: array[6, array[2, GLfloat]] = 
      [
        [GLfloat x, y + h],
        [GLfloat x + w, y],
        [GLfloat x, y],

        [GLfloat x, y + h],
        [GLfloat x + w, y + h],
        [GLfloat x + w, y]
      ]

  glBindBuffer(GL_ARRAY_BUFFER, ttf.backgroundVBO)
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), addr vertices[0], GL_STATIC_DRAW)
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glDrawArrays(GL_TRIANGLES, 0, 6)

  ttf.backgroundProgram.`end`()

proc render*(ttf: TTF, text: string, x, y, scale: float, fgColor, bgColor: Color, projection: var Mat4f, projectionDirty: bool = false) =
  glEnable(GL_CULL_FACE)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)


  let size = ttf.measureText(text)
  ttf.renderBackground(bgColor, x, y, size, projection, projectionDirty)
  
  var xd = x
  ttf.shaderProgram.begin()

  if projectionDirty:
    ttf.shaderProgram.setUniformMatrix("projection", projection)

  ttf.shaderProgram.setUniform4f("textColor", vec4f(fgColor.r, fgColor.g, fgColor.b, fgColor.a))
  glActiveTexture(GL_TEXTURE0)
  glBindVertexArray(ttf.vao)

  for c in text:
    let ch = ttf.characters[c]
    
    let xpos : GLfloat = xd + GLfloat(ch.bearing.x) * scale
    let ypos : GLfloat = y + GLfloat(ttf.characters['H'].bearing.y - ch.bearing.y) * scale

    let w : GLfloat = GLfloat(ch.size.x) * scale
    let h : GLfloat = GLfloat(ch.size.y) * scale

    var vertices: array[6, array[4, GLfloat]] = 
      [
        [xpos, ypos + h, 0.0, 1.0],
        [xpos + w, ypos, 1.0, 0.0],
        [xpos, ypos, 0.0, 0.0],

        [xpos, ypos + h, 0.0, 1.0],
        [xpos + w, ypos + h, 1.0, 1.0],
        [xpos + w, ypos, 1.0, 0.0]
      ]
    
    glBindTexture(GL_TEXTURE_2D, ch.textureID)
    glBindBuffer(GL_ARRAY_BUFFER, ttf.vbo)
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), addr vertices[0])
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glDrawArrays(GL_TRIANGLES, 0, 6)
    xd += GLfloat ch.advance

  glBindVertexArray(0)
  glBindTexture(GL_TEXTURE_2D, 0)
  ttf.shaderProgram.`end`()

  glDisable(GL_CULL_FACE)
  glDisable(GL_BLEND)

proc unload*(ttf: TTF) =
  for character in ttf.characters.mvalues:
    glDeleteTextures(1, addr character.textureID)

  ttf.shaderProgram.dispose()

  discard freetype.doneFace(ttf.fontFace)