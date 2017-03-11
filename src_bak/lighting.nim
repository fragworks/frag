import glm

import shader

const fs = """
  #version 330                                                                                 
  const int MAX_POINT_LIGHTS = 2;                            
  const int MAX_SPOT_LIGHTS = 2;                                                      
  in vec2 TexCoord0;                                         
  in vec3 Normal0;                                           
  in vec3 WorldPos0;                                                                  
  out vec4 FragColor;                                                                 
                                                              
  struct BaseLight                                            
  {                                                           
      vec3 Color;                                             
      float AmbientIntensity;                                 
      float DiffuseIntensity;                                 
  };                                                                                  
                                                              
  struct DirectionalLight                                     
  {                                                           
      BaseLight Base;                                         
      vec3 Direction;                                         
  };                                                                                  
                                                                                      
  struct Attenuation                                                                  
  {                                                                                   
      float Constant;                                                                 
      float Linear;                                                                   
      float Exp;                                                                      
  };                                                                                  
                                                                                      
  struct PointLight                                                                           
  {                                                                                           
      BaseLight Base;                                                                         
      vec3 Position;                                                                          
      Attenuation Atten;                                                                      
  };                                                                                          
                                                                                              
  struct SpotLight                                                                            
  {                                                                                           
      PointLight Base;                                                                        
      vec3 Direction;                                                                         
      float Cutoff;                                                                           
  };                                                                                          
                                                                                              
  uniform int gNumPointLights;                                                                
  uniform int gNumSpotLights;                                                                 
  uniform DirectionalLight gDirectionalLight;                                                 
  uniform PointLight gPointLights[MAX_POINT_LIGHTS];                                          
  uniform SpotLight gSpotLights[MAX_SPOT_LIGHTS];                                             
  uniform sampler2D gSampler;                                                                 
  uniform vec3 gEyeWorldPos;                                                                  
  uniform float gMatSpecularIntensity;                                                        
  uniform float gSpecularPower;                                                               
                                                                                              
  vec4 CalcLightInternal(BaseLight Light, vec3 LightDirection, vec3 Normal)                   
  {                                                                                           
      vec4 AmbientColor = vec4(Light.Color * Light.AmbientIntensity, 1.0f);
      float DiffuseFactor = dot(Normal, -LightDirection);                                     
                                                                                              
      vec4 DiffuseColor  = vec4(0, 0, 0, 0);                                                  
      vec4 SpecularColor = vec4(0, 0, 0, 0);                                                  
                                                                                              
      if (DiffuseFactor > 0) {                                                                
          DiffuseColor = vec4(Light.Color * Light.DiffuseIntensity * DiffuseFactor, 1.0f);
                                                                                              
          vec3 VertexToEye = normalize(gEyeWorldPos - WorldPos0);                             
          vec3 LightReflect = normalize(reflect(LightDirection, Normal));                     
          float SpecularFactor = dot(VertexToEye, LightReflect);                                      
          if (SpecularFactor > 0) {                                                           
              SpecularFactor = pow(SpecularFactor, gSpecularPower);                               
              SpecularColor = vec4(Light.Color * gMatSpecularIntensity * SpecularFactor, 1.0f);
          }                                                                                   
      }                                                                                       
                                                                                              
      return (AmbientColor + DiffuseColor + SpecularColor);                                   
  }                                                                                           
                                                                                              
  vec4 CalcDirectionalLight(vec3 Normal)                                                      
  {                                                                                           
      return CalcLightInternal(gDirectionalLight.Base, gDirectionalLight.Direction, Normal);  
  }                                                                                           
                                                                                              
  vec4 CalcPointLight(PointLight l, vec3 Normal)                                              
  {                                                                                           
      vec3 LightDirection = WorldPos0 - l.Position;                                           
      float Distance = length(LightDirection);                                                
      LightDirection = normalize(LightDirection);                                             
                                                                                              
      vec4 Color = CalcLightInternal(l.Base, LightDirection, Normal);                         
      float attenuation =  l.Atten.Constant +                                                 
                          l.Atten.Linear * Distance +                                        
                          l.Atten.Exp * Distance * Distance;                                 
                                                                                              
      return Color / attenuation;                                                             
  }                                                                                           
                                                                                              
  vec4 CalcSpotLight(SpotLight l, vec3 Normal)                                                
  {                                                                                           
      vec3 LightToPixel = normalize(WorldPos0 - l.Base.Position);                             
      float SpotFactor = dot(LightToPixel, l.Direction);                                      
                                                                                              
      if (SpotFactor > l.Cutoff) {                                                            
          vec4 Color = CalcPointLight(l.Base, Normal);                                        
          return Color * (1.0 - (1.0 - SpotFactor) * 1.0/(1.0 - l.Cutoff));                   
      }                                                                                       
      else {                                                                                  
          return vec4(0,0,0,0);                                                               
      }                                                                                       
  }                                                                                           
                                                                                              
  void main()                                                                                 
  {                                                                                           
      vec3 Normal = normalize(Normal0);                                                       
      vec4 TotalLight = CalcDirectionalLight(Normal);                                         
                                                                                              
      for (int i = 0 ; i < gNumPointLights ; i++) {                                           
          TotalLight += CalcPointLight(gPointLights[i], Normal);                              
      }                                                                                       
                                                                                              
      for (int i = 0 ; i < gNumSpotLights ; i++) {                                            
          TotalLight += CalcSpotLight(gSpotLights[i], Normal);                                
      }                                                                                       
                                                                                              
      FragColor = texture(gSampler, TexCoord0.xy) * TotalLight;                             
  }
"""

const vs = """
  #version 330

  layout (location = 0) in vec3 Position;
  layout (location = 1) in vec2 TexCoord;
  layout (location = 2) in vec3 Normal;

  layout (location = 3) in ivec4 BoneIDs;
  layout (location = 4) in vec4 Weights;

  const int MAX_BONES = 100;

  uniform mat4 model;
  uniform mat4 view;
  uniform mat4 projection;
  uniform mat4 gWorld;
  uniform mat4 gBones[MAX_BONES];

  out vec2 TexCoord0;
  out vec3 Normal0;
  out vec3 WorldPos0;

  void main()
  {   
      mat4 BoneTransform = gBones[BoneIDs[0]] * Weights[0];
      BoneTransform     += gBones[BoneIDs[1]] * Weights[1];
      BoneTransform     += gBones[BoneIDs[2]] * Weights[2];
      BoneTransform     += gBones[BoneIDs[3]] * Weights[3];

      vec4 PosL    = BoneTransform * vec4(Position, 1.0);
      mat4 mvp = projection * view * model;
      gl_Position = mvp * PosL;
      TexCoord0 = TexCoord;
      vec4 NormalL = BoneTransform * vec4(Normal, 0.0);
      Normal0      = (gWorld * NormalL).xyz;
      WorldPos0    = (gWorld * PosL).xyz;  
  }
"""

type
  Environment* = ref object of RootObj
    lights*: seq[Light]
    shader*: ShaderProgram

  Light* = ref object of RootObj
    color*: Vec3f
    ambientIntensity*: float
    diffuseIntensity*: float

  
  DirectionalLight* = ref object of Light
    direction*: Vec3f

  Attenuation = tuple[
    constant, linear, exp: float
  ]

  PointLight* = ref object of Light
    position*: Vec3f
    attenuation*: Attenuation

  SpotLight* = ref object of Light
    direction*: Vec3f
    cutoff*: float

proc newEnvironment*() : Environment =
  result = Environment()
  result.lights = @[]
  result.shader = newShaderProgram(vs, fs)

proc newDirectionalLight*(direction: Vec3f, diffuseIntensity: float) : DirectionalLight =
  result = DirectionalLight()
  result.direction = direction
  result.diffuseIntensity = diffuseIntensity

proc newPointLight*(position: Vec3f, color: Vec3f, attenuation: Attenuation) : PointLight =
  result = PointLight()
  result.color = color
  result.position = position
  result.attenuation = attenuation

proc newSpotLight*(direction: Vec3f, cutoff: float) : SpotLight =
    result = SpotLight()
    result.direction = direction
    result.cutoff = cutoff

