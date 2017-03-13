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
  VectorFont* = ref Asset

  FontSize* = tuple[
    width, height: uint32
  ]

const defaultFontSize : FontSize = (width: 0u32, height: 12u32)

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

proc setSize*(font: VectorFont, size: FontSize) =
  discard freetype.setPixelSizes(font.fontFace, size.width, size.height)

proc initializeFont(font: VectorFont, fontSize: FontSize) =
  font.setSize(fontSize)

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1)

  var c : GLubyte = 0
  while c < 128:
    if freetype.loadChar(font.fontFace, c, freetype.LOAD_RENDER) != 0:
      warn "Failed to load TrueType font glyph."

    var texture : GLuint
    glGenTextures(1, addr texture)
    glBindTexture(GL_TEXTURE_2D, texture)
    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_RED.ord,
        GLsizei font.fontFace.glyph.bitmap.width,
        GLsizei font.fontFace.glyph.bitmap.rows,
        0,
        GL_RED,
        GL_UNSIGNED_BYTE,
        font.fontFace.glyph.bitmap.buffer
    )

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    font.characters.add(
      GLchar c,
      Character(
        textureID: texture,
        size: vec2i(int32 font.fontFace.glyph.bitmap.width, int32 font.fontFace.glyph.bitmap.rows),
        bearing: vec2i(font.fontFace.glyph.bitmap_left, font.fontFace.glyph.bitmap_top),
        advance: GLuint font.fontFace.glyph.advance.x
      )
    )
    inc(c)

  glBindTexture(GL_TEXTURE_2D, 0)

  glGenVertexArrays(1, addr font.vao)
  glGenBuffers(1, addr font.vbo)
  glBindVertexArray(font.vao)
  glBindBuffer(GL_ARRAY_BUFFER, font.vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 6 * 4, nil, GL_DYNAMIC_DRAW)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 4, cGL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), nil)
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)

  font.shaderProgram = createShaderProgram(vertexShaderSource, fragmentShaderSource)

proc load*(fontFace: Face, fontSize: FontSize = defaultFontSize): VectorFont =
  result = VectorFont(assetType: AssetType.VectorFont)
  result.fontFace = fontFace

  result.characters = initTable[GLchar, Character](128)

  initializeFont(result, fontSize)

proc render*(font: VectorFont, text: string, x, y, scale: float, color: Color, shaderBegun: bool = false) =
  var xd = x

  glEnable(GL_CULL_FACE)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  if not shaderBegun:
    font.shaderProgram.begin()

  font.shaderProgram.setUniform4f("textColor", vec4f(color.r, color.g, color.b, color.a))
  glActiveTexture(GL_TEXTURE0)
  glBindVertexArray(font.vao)

  for c in text:
    let ch = font.characters[c]

    let xpos : GLfloat = xd + GLfloat(ch.bearing.x) * scale
    let ypos : GLfloat = y + GLfloat(font.characters['H'].bearing.y - ch.bearing.y) * scale

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
    glBindBuffer(GL_ARRAY_BUFFER, font.vbo)
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), addr vertices[0])
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glDrawArrays(GL_TRIANGLES, 0, 6)
    xd += GLfloat `shr`(ch.advance, 6)

  glBindVertexArray(0)
  glBindTexture(GL_TEXTURE_2D, 0)
  font.shaderProgram.`end`()

  glDisable(GL_CULL_FACE)
  glDisable(GL_BLEND)

proc render*(font: VectorFont, text: string, x, y, scale: float, color: Color, projection: var Mat4f) =
  font.shaderProgram.begin()
  font.shaderProgram.setUniformMatrix("projection", projection)
  render(font, text, x, y, scale, color, true)

proc unload*(font: VectorFont) =
  for character in font.characters.mvalues:
    glDeleteTextures(1, addr character.textureID)

  font.shaderProgram.dispose()

  discard freetype.doneFace(font.fontFace)
