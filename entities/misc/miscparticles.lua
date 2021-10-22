megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource("assets/misc/slideParticle.anim", "slideParticleAnim", true)
megautils.loadResource("assets/misc/deathExplodeParticle.anim", "deathExplodeParticleAnim", true)
megautils.loadResource("assets/misc/damageSteam.anim", "damageSteamAnim", true)

particle = entity:extend()

particle.autoClean = false
particle.invisibleToHash = true

function particle:new(user)
  particle.super.new(self)
  
  self.user = user
  self._didCol = false
  
  if not self.recycling then
    self:setRectangleCollision(8, 8)
    self.autoGravity.global = false
    self.blockCollision.global = false
    self.removeWhenOutside = true
    self.doAutoCollisionBeforeUpdate = true
    self.flipWithUser = true
    self.noSlope = false
    self.maxFallingSpeed = 7
  end
end

function particle:added()
  self:addToGroup("removeOnTransition")
end

function particle:grav()
  self.velY = math.clamp(self.velY + self.gravity, -self.maxFallingSpeed, self.maxFallingSpeed)
end

function particle:_beforeUpdate(dt)
  for i = 1, #self.gfx do
    self.gfx[i]:_update(dt)
  end
  
  if self.flipWithUser and self.user and self.user.gravityMultipliers then
    self:setGravityMultiplier("flipWithUser", self.user.gravityMultipliers.gravityFlip or 1)
  end
end

function particle:_afterUpdate(dt)
  if self.removeWhenOutside and megautils.outside(self) then
    megautils.remove(self)
  end
  
  self:afterUpdate(dt)
end

slideParticle = particle:extend()

slideParticle.autoClean = false

function slideParticle:new(x, y, p, side)
  slideParticle.super.new(self, p)
  
  self.x = x or 0
  self.y = y or 0
  self.side = side or 1
  
  if self.recycling then
    self:getGFXByName("anim"):gotoFrame(1)
  else
    self:setRectangleCollision(8, 8)
    self:addGFX("anim", animation("slideParticleAnim"):flip(self.side == 1, self.gravity < 0))
    self.autoCollision.global = false
    self.recycle = true
  end
end

function slideParticle:update()
  self:getGFXByName("anim"):flip(self.side == 1, self.gravity < 0)
  if self:getGFXByName("anim"):looped() then
    megautils.remove(self)
  end
end

damageSteam = particle:extend()

damageSteam.autoClean = false

function damageSteam:new(x, y, p)
  damageSteam.super.new(self, p)
  
  self.x = x or 0
  self.y = y or 0
  
  if self.recycling then
    self:getGFXByName("anim"):gotoFrame(1)
  else
    self:setRectangleCollision(5, 8)
    self:addGFX("anim", animation("damageSteamAnim"):flip(false, self.gravity < 0))
    self.autoCollision.global = false
    self.recycle = true
  end
end

function damageSteam:update()
  self:getGFXByName("anim"):flip(false, self.gravity < 0)
  if self:getGFXByName("anim"):looped() then
    megautils.remove(self)
  end
end

airBubble = particle:extend()

airBubble.autoClean = false

function airBubble:new(x, y, p)
  airBubble.super.new(self, p)
  
  if not self.recycling then
    self:setRectangleCollision(2, 8)
    self:addGFX("tex", image("particles", quad(104, 28, 4, 4)))
    self.recycle = true
  end
  
  self.x = x or 0
  self.y = y or 0
  
  self.off = 0
  self.timer = 0
  self.velY = -1
end

function airBubble:check()
  return collision.checkSolid(self) or
    self:collisionNumber(megautils.groups().water, 0, -4) == 0
end

function airBubble:update(dt)
  self.timer = math.min(self.timer+1, 8)
  if self.timer == 8 then
    self.timer = 0
    self.off = math.wrap(self.off+1, 0, 2)
  end
  if self:check() then
    megautils.remove(self)
  end
  self:getGFXByName("tex"):off(-self.off, 0)
end

harm = particle:extend()

harm.autoClean = false

function harm:new(p, time)
  harm.super.new(self, p)
  
  if self.user then
    local cx, cy = megautils.center(self.user)
    self.x = cx-12
    self.y = cy-12
  end
  
  self:setRectangleCollision(24, 24)
  self:addGFX("tex", image("particles", quad(0, 22, 24, 24)))
  self.timer = 0
  self.maxTime = time or 32
  self.autoCollision.global = false
end

function harm:update()
  if not self.user or self.user.isRemoved or self.timer == self.maxTime then
    megautils.remove(self)
  else
    self.x = self.user.x+(self.user.collisionShape.w/2)-12
    self.y = self.user.y+(self.user.collisionShape.h/2)-12
    self.timer = math.min(self.timer+1, self.maxTime)
    self.canDraw.global = not self.user.canDraw.flash
  end
end

deathExplodeParticle = particle:extend()

deathExplodeParticle.autoClean = false

function deathExplodeParticle:new(x, y, p, angle, spd)
  deathExplodeParticle.super.new(self, p)
  
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(24, 24)
  self:addGFX("anim", animation("deathExplodeParticleAnim"))
  self.velX = megautils.calcX(angle or 0)*(spd or 1)
  self.velY = megautils.calcY(angle or 0)*(spd or 1)
end

function deathExplodeParticle.createExplosion(x, y, p)
  for j=1, 2 do
    for i=1, 8 do
      megautils.add(deathExplodeParticle, x, y, p, i*45, j*1.8)
    end
  end
end

absorbParticle = particle:extend()

absorbParticle.autoClean = false

function absorbParticle:new(x, y, p, spd)
  absorbParticle.super.new(self, p)
  
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(24, 24)
  self:addGFX("anim", animation("deathExplodeParticleAnim"):origin(12, 12))
  self.startX = x
  self.startY = y
  self.pos = 0
  self.spd = spd or 0.02
  self.autoCollision.global = false
  self.removeWhenOutside = false
end

function absorbParticle:update()
  if self.user and not self.user.isRemoved then
    local cx, cy = megautils.center(self.user)
    self.x = math.lerp(self.startX, cx, self.pos)
    self.y = math.lerp(self.startY, cy, self.pos)
    self.pos = math.min(self.pos + self.spd, 1)
  end
  if not self.user or self.pos == 1 or self.user.isRemoved then
    megautils.remove(self)
  end
end

function absorbParticle.createAbsorbtion(towards, spd)
  for i=1, 8 do
    megautils.add(absorbParticle, (view.x+view.w/2)+megautils.calcX(i*45)*view.w,
        (view.y+view.h/2)+megautils.calcY(i*45)*view.w, towards, (spd or 0.02))
    megautils.add(absorbParticle, (view.x+view.w/2)+megautils.calcX(i*45)*view.w,
        (view.y+view.h/2)+megautils.calcY(i*45)*view.w, towards, ((spd or 0.02)*1.5))
  end
end

absorb = particle:extend()

absorb.autoClean = false

function absorb:new(p, times, spd)
  absorb.super.new(self, p)
  
  self.timer = 60
  self.times = 0
  self.maxTimes = times or 3
  self.spd = spd or 0.02
  self.autoCollision.global = false
  self.removeWhenOutside = false
end

function absorb:update()
  self.timer = math.min(self.timer+1, 60)
  if self.timer == 60 then
    self.timer = 0
    self.times = self.times + 1
    megautils.playSoundFromFile("assets/sfx/absorb.ogg")
    absorbParticle.createAbsorbtion(self.user, self.spd)
  end
  if self.times == self.maxTimes or not self.user or self.user.isRemoved then
    megautils.remove(self)
  end
end

smallBlast = particle:extend()

smallBlast.autoClean = false

function smallBlast:new(x, y, p)
  smallBlast.super.new(self, p)
  
  self.x = x or 0
  self.y = y or 0
  
  if self.recycling then
    self:getGFXByName("anim"):gotoFrame(1)
  else
    self:setRectangleCollision(24, 24)
    self.tex = megautils.getResource("particles")
    self:addGFX("anim", animation("deathExplodeParticleAnim"))
    self.autoCollision.global = false
    self.recycle = true
  end
end

function smallBlast:update()
  if self:getGFXByName("anim"):looped() then
    megautils.remove(self)
  end
end

blast = particle:extend()

blast.autoClean = false

function blast:new(x, y, p, hurt, damage, times)
  blast.super.new(self, p)
  
  self.x = x or 0
  self.y = y or 0
  self.deg = 0
  self.timer = 0
  self.times = 0
  self.max = times or 4
  self.autoCollision.global = false
  self.hurt = not not hurt
  self.damage = damage or -2
end

function blast:added()
  blast.super.added(self)
  
  megautils.add(smallBlast, self.x, self.y, self.user)
end

function blast:check()
  if megaMan.allPlayers then
    local ox, oy = self.x, self.y
    self.x = self.x + 12 - 24
    self.y = self.y + 12 - 24
    self:setRectangleCollision(48, 48)
    self:interact(self:collisionTable(megaMan.allPlayers), self.damage)
    self.collisionShape = nil
    self.x, self.y = ox, oy
  end
end

function blast:update()
  self.timer = math.min(self.timer+1, 5)
  if self.timer == 5 then
    self.timer = 0
    megautils.add(smallBlast, megautils.circlePathX(self.x, self.deg, 20), 
      megautils.circlePathY(self.y, self.deg, 20), self.user)
    megautils.add(smallBlast, megautils.circlePathX(self.x, self.deg-180, 20), 
      megautils.circlePathY(self.y, self.deg-180, 20), self.user)
    self.deg = math.wrap(self.deg+360/6, 0, 360)
    self.times = self.times + 1
  end
  if self.hurt then
    self:check()
  end
  if self.times == self.max then
    megautils.remove(self)
  end
end