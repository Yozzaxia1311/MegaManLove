megautils.loadResource("assets/global/entities/met.png", "met")
megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit")
megautils.loadResource("assets/sfx/enemyExplode.ogg", "enemyExplode")
megautils.loadResource("assets/sfx/buster.ogg", "buster")
megautils.loadResource("assets/sfx/reflect.ogg", "dink")

met = entity:extend()

addobjects.register("met", function(v)
  megautils.add(spawner, v.x, v.y+2, 14, 14, function(s)
      megautils.add(met, s.transform.x, s.transform.y, s)
    end)
end)

function met:new(x, y, s)
  met.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(14, 14)
  self.t = megautils.getResource("met")
  self.spawner = s
  self.c = "safe"
  self.quads = {safe=love.graphics.newQuad(0, 0, 18, 15, 42, 15), up=love.graphics.newQuad(18, 0, 18, 15, 42, 15)}
  self.side = -1
  self.s = 0
  self.health = 2
  self.canBeInvincible.global = true
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function met:added()
  self:addToGroup("hurtable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
end

function met:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(7)
end

function met:gettingHurt(o, c, i)
  if checkTrue(self.canBeInvincible) or (o.dinked and not o.reflectedBack) then
    if o.dink and not o.dinked then
      o:dink(self)
    end
    return
  end
  if c < 0 and not checkTrue(self.canBeInvincible) and not o:is(megaChargedBuster) then
    megautils.removeq(o)
  end
  if self.maxIFrame ~= self.iFrame then return end
  
  if o:is(megaBuster) then
    self.changeHealth = -1
  elseif o:is(megaSemiBuster) then
    self.changeHealth = megautils.diffValue(-1, {easy=-2})
  elseif o:is(megaChargedBuster) then
    self.changeHealth = megautils.diffValue(-2, {easy=-3})
  elseif o:is(protoSemiBuster) then
    self.changeHealth = megautils.diffValue(-1, {easy=-2})
  elseif o:is(protoChargedBuster) then
    self.changeHealth = megautils.diffValue(-2, {easy=-3})
  elseif o:is(bassBuster) then
    if o.treble then
      self.changeHealth = megautils.diffValue(-1, {easy=-2})
    else
      self.changeHealth = megautils.diffValue(-0.5, {easy=-1})
    end
  else
    self.changeHealth = c
  end
  
  self.health = self.health + self.changeHealth
  self.maxIFrame = i
  self.iFrame = 0
  if self.health <= 0 then
    megautils.add(smallBlast, self.transform.x-4, self.transform.y-4)
    megautils.dropItem(self.transform.x, self.transform.y+(self.gravity >= 0 and -4 or 4))
    megautils.removeq(self)
    megautils.playSound("enemyExplode")
  elseif self.changeHealth < 0 then
    if o:is(megaChargedBuster) then
      megautils.removeq(o)
    end
    megautils.playSound("enemyHit")
  end
end

function met:update(dt)
  if globals.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", globals.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  local near = megautils.autoFace(self, globals.allPlayers)
  if self.s == 0 then
    if near and math.between(near.transform.x, 
      self.transform.x - 120, self.transform.x + 120) then
      self.timer = math.min(self.timer+1, 80)
    else
      self.timer = 0
    end
    if self.timer == 80 then
      self.timer = 0
      self.s = 1
      self.canBeInvincible.global = false
      self.c = "up"
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.timer = 0
      self.s = 2
      megautils.add(metBullet, self.transform.x+4, self.transform.y+4, self.side*megautils.calcX(45)*2, -megautils.calcY(45)*2)
      megautils.add(metBullet, self.transform.x+4, self.transform.y+4, self.side*megautils.calcX(45)*2, megautils.calcY(45)*2)
      megautils.add(metBullet, self.transform.x+4, self.transform.y+4, self.side*2, 0)
      megautils.playSound("buster")
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.c = "safe"
      self.canBeInvincible.global = true
      self.timer = 0
      self.s = 0
    end
  end
  collision.doCollision(self)
  self:hurt(self:collisionTable(globals.allPlayers), megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3}), 80)
  self:updateIFrame()
  self:updateFlash()
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function met:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offx, offy = -2, 0
  if self.side == 1 then
    offx = 16
  end
  if self.gravity < 0 then
    offy = 15
  end
  love.graphics.draw(self.t, self.quads[self.c], self.transform.x+offx, self.transform.y+offy, 0, -self.side, math.sign(self.gravity))
end

function met:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

metBullet = basicEntity:extend()

function metBullet:new(x, y, vx, vy)
  metBullet.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
    self:addToGroup("enemyWeapon")
  end
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(6, 6)
  self.tex = megautils.getResource("met")
  self.quad = love.graphics.newQuad(36, 0, 6, 6, 42, 15)
  self.velocity = velocity()
  self.velocity.velx = vx
  self.velocity.vely = vy
end

function metBullet:recycle(x, y, vx, vy)
  self.transform.x = x
  self.transform.y = y
  self.velocity.velx = vx
  self.velocity.vely = vy
  self.dinked = nil
  self.reflectedBack = nil
end

function metBullet:dink(e)
  if e:is(megaMan) then
    self.velocity.velx = -self.velocity.velx
    self.velocity.vely = -self.velocity.vely
    self.dinked = true
    self.reflectedBack = true
    megautils.playSound("dink")
  end
end

function metBullet:update(dt)
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -2, 2)
  else
    self:hurt(self:collisionTable(globals.allPlayers), megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3}), 80)
  end
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function metBullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megautils.cleanFuncs.met = function()
  met = nil
  metBullet = nil
  addobjects.unregister("met")
  megautils.cleanFuncs.met = nil
end