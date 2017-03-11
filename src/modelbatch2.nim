import event, glm, graphics, log, lighting, math, model, skinned_model, opengl, ibo, shader, vbo, sdl2, texture

type
  ModelBatch* = object
    ibo: IBO
    shader: ShaderProgram
    cameraPos, cameraDeltaPos, cameraFront, cameraRight, cameraUp, cameraLookAt: Vec3f
    cameraYaw, cameraPitch: float
    cameraSpeed: float
    lastX, lastY: GLfloat
    fov: GLFloat
    texture: Texture
    environment: Environment


proc createDefaultShader() : ShaderProgram =
  let vertexShaderSource = """
    #version 330 core

    layout (location = 0) in vec3 Position;
    layout (location = 1) in vec2 TexCoord;

    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 projection;

    out vec2 TexCoord0;

    void main()
    {
        gl_Position = projection * view * model * vec4(Position, 1.0);
        TexCoord0 = TexCoord;
    }
  """
  let fragmentShaderSource = """
    #version 330

    in vec2 TexCoord0;

    out vec4 FragColor;

    uniform sampler2D gSampler;

    void main()
    {
        FragColor = texture(gSampler, TexCoord0.xy);
    }
  """
  let shaderProgram = newShaderProgram(vertexShaderSource, fragmentShaderSource)
  if not shaderProgram.isCompiled:
    logError "Error compiling shader : " & shaderProgram.log
  return shaderProgram

proc moveCameraUp*(modelBatch: var ModelBatch, deltaTime: float) =
  let movementSpeed = modelBatch.cameraSpeed * (deltaTime * 0.001)
  modelBatch.cameraDeltaPos += modelBatch.cameraUp * movementSpeed

proc moveCameraDown*(modelBatch: var ModelBatch, deltaTime: float) =
  let movementSpeed = modelBatch.cameraSpeed * (deltaTime * 0.001)
  modelBatch.cameraDeltaPos -= modelBatch.cameraUp * movementSpeed

proc moveCameraForward*(modelBatch: var ModelBatch, deltaTime: float) =
  let movementSpeed = modelBatch.cameraSpeed * (deltaTime * 0.001)
  modelBatch.cameraDeltaPos += modelBatch.cameraFront * movementSpeed

proc moveCameraBackward*(modelBatch: var ModelBatch, deltaTime: float) =
  let movementSpeed = modelBatch.cameraSpeed * (deltaTime * 0.001)
  modelBatch.cameraDeltaPos -= modelBatch.cameraFront * movementSpeed

proc moveCameraLeft*(modelBatch: var ModelBatch, deltaTime: float) =
  let movementSpeed = modelBatch.cameraSpeed * (deltaTime * 0.001)
  modelBatch.cameraDeltaPos -= modelBatch.cameraRight * movementSpeed

proc moveCameraRight*(modelBatch: var ModelBatch, deltaTime: float) =
  let movementSpeed = modelBatch.cameraSpeed * (deltaTime * 0.001)
  modelBatch.cameraDeltaPos += modelBatch.cameraRight * movementSpeed

proc adjustCameraYawAndPitch*(modelBatch: var ModelBatch, yaw, pitch: float) =
  modelBatch.cameraYaw += yaw
  modelBatch.cameraPitch += pitch

  let front = vec3f(
      cos(radians(modelBatch.cameraYaw)) * cos(radians(modelBatch.cameraPitch))
      , sin(radians(modelBatch.cameraPitch))
      , sin(radians(modelBatch.cameraYaw)) * cos(radians(modelBatch.cameraPitch))
  )
  modelBatch.cameraFront = normalize(front)

proc newModelBatch*(defaultShader: ShaderProgram) : ModelBatch =
  result = ModelBatch()
  #result.ibo = newIBO(false)

  #var vertices : seq[GLfloat] = @[
  #  GLfloat(-1.0), GLfloat(-1.0), GLfloat 0.5773, GLfloat 0.0, GLfloat 0.0,
  #  GLfloat 0.0, GLfloat(-1.0), GLfloat(-1.15475), GLfloat 0.5, GLfloat 0.0,
  #  GLfloat 1.0, GLfloat(-1.0), GLfloat 0.5773, GLfloat 1.0, GLfloat 0.0,
  #  GLfloat 0.0, GLfloat 1.0, GLfloat 0.0, GLfloat 0.5, GLfloat 1.0
  #]

  #glGenBuffers(1, addr result.vbo)
  #glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  #glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(vertices.len * sizeof(GLfloat)), vertices[0].addr, GL_STATIC_DRAW)

  #var indices : seq[GLushort] = @[
  #  GLushort 0, GLushort 3, GLushort 1,
  #  GLushort 1, GLushort 3, GLushort 2,
  #  GLushort 2, GLushort 3, GLushort 0,
  #  GLushort 0, GLushort 1, GLushort 2
  #]

  #result.ibo.setIndices(indices)
  #result.ibo.`bind`()

  result.cameraPos = vec3f(0,10,20.0)
  result.cameraFront = vec3f(0, 0.0, -1.0)
  result.cameraUp = vec3f(0.0, 1.0, 0.0)
  result.cameraLookAt = vec3f(0.0, 0.0, 0.0)
  result.cameraPitch = 0.0
  result.cameraYaw = -90.0
  result.cameraSpeed = 10.0
  result.lastX = getWidth() / 2
  result.lastY = getHeight() / 2
  result.fov = 45.0
  

  #glBindVertexArray(0)

  if defaultShader.isNil:
    result.shader = createDefaultShader()
  else:
    result.shader = defaultShader

proc newModelBatch*(environment: Environment) : ModelBatch =
  result = newModelBatch(environment.shader)
  result.environment = environment

proc begin*(modelBatch: ModelBatch) =
  modelBatch.shader.begin()

proc draw*(modelBatch: var ModelBatch, m: Model, translation: Vec3f = vec3f(0,0,0), angle: float = 0, axis: Vec3f = vec3f(1, 0, 0), scale: Vec3f = vec3f(1.0)) =

  
  #glEnable(GL_CULL_FACE)
  #glFrontFace(GL_CCW)
  #glCullFace(GL_BACK)
  #glDisable(GL_BLEND)

  #glEnable(GL_BLEND);
  #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  #glEnable(GL_DEPTH_TEST)
  #texture.`bind`()
  modelBatch.cameraRight = normalize(cross(modelBatch.cameraFront, vec3f(0, 1.0, 0)))
  modelBatch.cameraUp = normalize(cross(modelBatch.cameraRight, modelBatch.cameraFront))
  modelBatch.cameraPos += modelBatch.cameraDeltaPos
  var
    view = lookAt[GLfloat](modelBatch.cameraPos, modelBatch.cameraPos + modelBatch.cameraFront, modelBatch.cameraUp)
    model = mat4[GLfloat]()
    proj = perspective[GLfloat](45.0, getWidth() / getHeight(), 0.1, 1000.0)
    worldScale, worldRotate, worldTrans = mat4[GLfloat]()
    world = worldTrans * worldRotate * worldScale

  model = translate(model, translation)
  model = rotate(model, axis, angle)
  model = scale(model, scale)

  modelBatch.cameraDeltaPos = modelBatch.cameraDeltaPos * 0.8

  modelBatch.shader.setUniformMatrix("model", model)
  modelBatch.shader.setUniformMatrix("view", view)
  modelBatch.shader.setUniformMatrix("projection", proj)
  modelBatch.shader.setUniformMatrix("gWorld", world)
  modelBatch.shader.setUniformi("gSampler", 0)

  var numPointLights = 0
  var numSpotLights = 0
  for light in modelBatch.environment.lights:
    if light of DirectionalLight:
      modelBatch.shader.setUniform3f("gDirectionalLight.Base.Color", vec3f(1.0, 1.0, 1.0))
      modelBatch.shader.setUniform1f("gDirectionalLight.Base.AmbientIntensity", 0.1)
      var direction = DirectionalLight(light).direction
      direction = normalize(direction)
      modelBatch.shader.setUniform3f("gDirectionalLight.Direction", vec3f(direction.x, direction.y, direction.z))
      modelBatch.shader.setUniform1f("gDirectionalLight.Base.DiffuseIntensity", light.diffuseIntensity)
    elif light of PointLight:
      var pointLight = PointLight(light)
      modelBatch.shader.setUniform3f("gPointLights[" & $numPointLights & "].Base.Color", pointLight.color)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Base.AmbientIntensity", 0.0)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Base.DiffuseIntensity", 0.5)
      modelBatch.shader.setUniform3f("gPointLights[" & $numPointLights & "].Position", pointLight.position)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Atten.Constant", pointLight.attenuation.constant)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Atten.Linear", pointLight.attenuation.linear)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Atten.Exp", pointLight.attenuation.exp)
      inc(numPointLights)
    elif light of SpotLight:
      var spotLight = SpotLight(light)
      modelBatch.shader.setUniform3f("gSpotLights[" & $numSpotLights & "].Base.Base.Color", vec3f(0.0, 1.0, 0.0))
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Base.AmbientIntensity", 0.0)
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Base.DiffuseIntensity", 0.9)
      modelBatch.shader.setUniform3f("gSpotLights[" & $numSpotLights & "].Base.Position", modelBatch.cameraPos)
      var direction = spotLight.direction
      direction = normalize(direction)
      modelBatch.shader.setUniform3f("gSpotLights[" & $numSpotLights & "].Direction", vec3f(0,0,-1))
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Cutoff", cos(radians(spotLight.cutoff)))
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Atten.Constant", 0.0)
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Atten.Linear", 0.1)
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Atten.Exp", 0.0)
      inc(numSpotLights)
    
    
  modelBatch.shader.setUniformi("gNumPointLights", numPointLights)
  modelBatch.shader.setUniformi("gNumSpotLights", numSpotLights)

  
  modelBatch.shader.setUniform3f("gEyeWorldPos", modelBatch.cameraPos)
  modelBatch.shader.setUniform1f("gMatSpecularIntensity", 1.0)
  modelBatch.shader.setUniform1f("gSpecularPower", 32)
  
  m.render()
  #glBindBuffer(GL_ARRAY_BUFFER, modelBatch.vbo);
  #glEnableVertexAttribArray(0);
  #glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, nil);
  
  #glEnableVertexAttribArray(1);
  #glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, cast[pointer](sizeof(GLfloat) * 3))  

  #glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, modelBatch.ibo.handle());

  #glDrawElements(GL_TRIANGLES, GLsizei 12, GL_UNSIGNED_SHORT, nil);

  #glDisableVertexAttribArray(0);
  #glDisableVertexAttribArray(1);
  #glBindVertexArray(0)

  #glDisable(GL_CULL_FACE)

  #glDisable(GL_MULTISAMPLE)
  #glDisable(GL_DEPTH_TEST)
  #glDisable(GL_CULL_FACE)
  #glDisable(GL_BLEND)

proc draw*(modelBatch: var ModelBatch, m: SkinnedModel, translation: Vec3f = vec3f(0,0,0), angle: float = 0, axis: Vec3f = vec3f(1, 0, 0), scale: Vec3f = vec3f(1.0)) =

  
  #glEnable(GL_CULL_FACE)
  #glFrontFace(GL_CCW)
  #glCullFace(GL_BACK)
  #glDisable(GL_BLEND)

  #glEnable(GL_BLEND);
  #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  #glEnable(GL_DEPTH_TEST)
  #texture.`bind`()
  modelBatch.cameraRight = normalize(cross(modelBatch.cameraFront, vec3f(0, 1.0, 0)))
  modelBatch.cameraUp = normalize(cross(modelBatch.cameraRight, modelBatch.cameraFront))
  modelBatch.cameraPos += modelBatch.cameraDeltaPos
  var
    view = lookAt[GLfloat](modelBatch.cameraPos, modelBatch.cameraPos + modelBatch.cameraFront, modelBatch.cameraUp)
    model = mat4[GLfloat]()
    proj = perspective[GLfloat](45.0, getWidth() / getHeight(), 0.1, 1000.0)
    worldScale, worldRotate, worldTrans = mat4[GLfloat]()
    world = worldTrans * worldRotate * worldScale

  model = translate(model, translation)
  model = rotate(model, axis, angle)
  model = scale(model, scale)

  modelBatch.cameraDeltaPos = modelBatch.cameraDeltaPos * 0.8

  modelBatch.shader.setUniformMatrix("model", model)
  modelBatch.shader.setUniformMatrix("view", view)
  modelBatch.shader.setUniformMatrix("projection", proj)
  modelBatch.shader.setUniformMatrix("gWorld", world)
  modelBatch.shader.setUniformi("gSampler", 0)

  var numPointLights = 0
  var numSpotLights = 0
  for light in modelBatch.environment.lights:
    if light of DirectionalLight:
      modelBatch.shader.setUniform3f("gDirectionalLight.Base.Color", vec3f(1.0, 1.0, 1.0))
      modelBatch.shader.setUniform1f("gDirectionalLight.Base.AmbientIntensity", 0.1)
      var direction = DirectionalLight(light).direction
      direction = normalize(direction)
      modelBatch.shader.setUniform3f("gDirectionalLight.Direction", vec3f(direction.x, direction.y, direction.z))
      modelBatch.shader.setUniform1f("gDirectionalLight.Base.DiffuseIntensity", light.diffuseIntensity)
    elif light of PointLight:
      var pointLight = PointLight(light)
      modelBatch.shader.setUniform3f("gPointLights[" & $numPointLights & "].Base.Color", pointLight.color)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Base.AmbientIntensity", 0.0)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Base.DiffuseIntensity", 0.5)
      modelBatch.shader.setUniform3f("gPointLights[" & $numPointLights & "].Position", pointLight.position)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Atten.Constant", pointLight.attenuation.constant)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Atten.Linear", pointLight.attenuation.linear)
      modelBatch.shader.setUniform1f("gPointLights[" & $numPointLights & "].Atten.Exp", pointLight.attenuation.exp)
      inc(numPointLights)
    elif light of SpotLight:
      var spotLight = SpotLight(light)
      modelBatch.shader.setUniform3f("gSpotLights[" & $numSpotLights & "].Base.Base.Color", vec3f(0.0, 1.0, 0.0))
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Base.AmbientIntensity", 0.0)
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Base.DiffuseIntensity", 0.9)
      modelBatch.shader.setUniform3f("gSpotLights[" & $numSpotLights & "].Base.Position", modelBatch.cameraPos)
      var direction = spotLight.direction
      direction = normalize(direction)
      modelBatch.shader.setUniform3f("gSpotLights[" & $numSpotLights & "].Direction", vec3f(0,0,-1))
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Cutoff", cos(radians(spotLight.cutoff)))
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Atten.Constant", 0.0)
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Atten.Linear", 0.1)
      modelBatch.shader.setUniform1f("gSpotLights[" & $numSpotLights & "].Base.Atten.Exp", 0.0)
      inc(numSpotLights)
    
    
  modelBatch.shader.setUniformi("gNumPointLights", numPointLights)
  modelBatch.shader.setUniformi("gNumSpotLights", numSpotLights)

  
  modelBatch.shader.setUniform3f("gEyeWorldPos", modelBatch.cameraPos)
  modelBatch.shader.setUniform1f("gMatSpecularIntensity", 1.0)
  modelBatch.shader.setUniform1f("gSpecularPower", 32)
  
  
  m.render()
  #glBindBuffer(GL_ARRAY_BUFFER, modelBatch.vbo);
  #glEnableVertexAttribArray(0);
  #glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, nil);
  
  #glEnableVertexAttribArray(1);
  #glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, cast[pointer](sizeof(GLfloat) * 3))  

  #glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, modelBatch.ibo.handle());

  #glDrawElements(GL_TRIANGLES, GLsizei 12, GL_UNSIGNED_SHORT, nil);

  #glDisableVertexAttribArray(0);
  #glDisableVertexAttribArray(1);
  #glBindVertexArray(0)

  #glDisable(GL_CULL_FACE)

  #glDisable(GL_MULTISAMPLE)
  #glDisable(GL_DEPTH_TEST)
  #glDisable(GL_CULL_FACE)
  #glDisable(GL_BLEND)

proc `end`*(modelBatch: ModelBatch) =
  modelBatch.shader.`end`()