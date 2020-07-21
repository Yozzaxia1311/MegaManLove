megautils.loadResource("assets/global/entities/met.png", "met")
megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit")
megautils.loadResource("assets/sfx/enemyExplode.ogg", "enemyExplode")
megautils.loadResource("assets/sfx/buster.ogg", "buster")
megautils.loadResource("assets/sfx/reflect.ogg", "dink")

met = enemyEntity:extend()

addObjects.register("met", function(v)
  megautils.add(spawner, v.x, v.y+2, 14, 14, nil, met, v.x, v.y+2)
end)

function met:new(x, y)
  met.super.new(self, 2)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(14, 14)
  self.t = megautils.getResource("met")
  self.c = "safe"
  self.quads = {safe=quad(0, 0, 18, 15), up=quad(18, 0, 18, 15)}
  self.side = -1
  self.s = 0
  self.canBeInvincible.global = true
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
  self.damage = megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3})
end

function met:weaponTable(o)
  if o:is(megaBuster) then
    return -1
  elseif o:is(megaSemiBuster) then
    return megautils.diffValue(-1, {easy=-2})
  elseif o:is(megaChargedBuster) then
    return megautils.diffValue(-2, {easy=-3})
  elseif o:is(protoSemiBuster) then
    return megautils.diffValue(-1, {easy=-2})
  elseif o:is(protoChargedBuster) then
    return megautils.diffValue(-2, {easy=-3})
  elseif o:is(bassBuster) then
    if o.treble then
      return megautils.diffValue(-1, {easy=-2})
    else
      return megautils.diffValue(-0.5, {easy=-1})
    end
  end
end

function met:determineDink(o)
  return checkTrue(self.canBeInvincible)
end

function met:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  local near = megautils.autoFace(self, megaMan.allPlayers)
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
  self.quads[self.c].flipX = self.side == 1
  self.quads[self.c].flipY = self.gravity < 0
  met.super.update(self)
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function met:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quads[self.c]:draw(self.t, math.round(self.transform.x), math.round(self.transform.y))
end

metBullet = basicEntity:extend()

function metBullet:new(x, y, vx, vy)
  metBullet.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(6, 6)
  self.tex = megautils.getResource("met")
  self.quad = quad(36, 0, 6, 6)
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

function metBullet:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("enemyWeapon")
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
    self:interact(self:collisionTable(megautils.groups().hurtable), -2, 2)
  else
    self:interact(self:collisionTable(megaMan.allPlayers), megautils.diffValue(-2, {easy=-1, normal=-2, hard=-3}), 80)
  end
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function metBullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

megautils.cleanFuncs.met = function()
  met = nil
  metBullet = nil
  megautils.cleanFuncs.met = nil
end