import glm, ode

proc physicsInit*() : bool =
  if InitODE() == 0:
    return false
  return true

proc createSpace*(space: PSpace) : PSpace =
  CreateSimpleSpace(space)

proc createWorld*() : PWorld =
  CreateWorld()

proc setWorldGravity*(world: PWorld, x,y,z: float) =
  SetGravity(world, x, y, z)

proc createBody*(world : PWorld) : PBody =
  CreateBody(world)

proc createPlane*(space: PSpace, a, b, c, d: float) : PGeom =
  CreatePlane(space, a, b, c, d)

proc createSphere*(space: PSpace, radius: float) : PGeom =
  CreateSphere(space, radius)

proc setBody*(geom: PGeom, body: PBody) =
  SetBody(geom, body)

proc stepWorld*(world: PWorld, stepSize: float) =
  Step(world, stepSize)

proc setZero*(mass: var TMass) =
  SetZero(addr mass)

proc setSphereTotal*(mass: var TMass, totalMass, radius: float) =
  SetSphereTotal(addr mass, totalMass, radius)

proc setMass*(body: PBody, mass: var TMass) =
  SetMass(body, addr mass)

proc setPosition*(body: PBody, position: Vec3f) =
  SetPosition(body, position.x, position.y, position.z)

proc getPosition*(body: PBody) : Vec3f =
  let body = GetPosition(body)
  vec3f(body[0], body[1], body[2])

proc createJointGroup*(size: int) : PJointGroup =
  CreateJointGroup(size.cint)

proc handleCollisions*(space: PSpace; data: pointer; 
                 callback: TNearCallback) =
  Collide(space, data, callback)

proc destroyWorld*(world: PWorld) =
  Destroy(world)

proc physicsShutdown*() =
  CloseODE()

proc newMass*() : TMass =
  result = TMass()