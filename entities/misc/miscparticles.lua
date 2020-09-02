megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource(8, 8, "slideParticleGrid", true)
megautils.loadResource(0, 46, 24, 24, "deathExplodeParticleGrid", true)
megautils.loadResource(108, 28, 5, 8, "damageSteamGrid", true)

particle = entity:extend()

particle.autoClean = false

function particle.transfer(from, to)
  particle.super.transfer(from, to)
  
  to.user = from.user
  to._didCol = from._didCol
  to.autoCollision = from.autoCollision
  to.autoGravity = from.autoGravity
  to.removeWhenOutside = from.removeWhenOutside
  to.doAutoCollisionBeforeUpdate = from.doAutoCollisionBeforeUpdate
  to.flipWithUser = from.flipWithUser
end

function particle:new(user)
  particle.super.new(self)
  
  self.user = user
  self._didCol = false
  
  if not self.recycling then
    self:setRectangleCollision(8, 8)
    self.autoCollision = true
    self.autoGravity = false
    self.removeWhenOutside = true
    self.doAutoCollisionBeforeUpdate = true
    self.flipWithUser = true
  end
end

function particle:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("collision")
end

function particle:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(7)
end

function particle:beforeUpdate()
  if self.flipWithUser and self.user then
    self:setGravityMultiplier("flipWithUser", self.user.gravityMultipliers.gravityFlip or 1)
  end
  if self.autoGravity then
    collision.doGrav(self)
  end
  self._didCol = false
  if self.autoCollision and self.doAutoCollisionBeforeUpdate then
    collision.doCollision(self)
    self._didCol = true
  end
end

function particle:afterUpdate()
  if self.autoCollision and not self.doAutoCollisionBeforeUpdate and not self._didCol then
    collision.doCollision(self)
  end
  if self.removeWhenOutside and megautils.outside(self) then
    megautils.removeq(self)
  end
end

slideParticle = particle:extend()

slideParticle.autoClean = false

function slideParticle:new(x, y, p, side)
  slideParticle.super.new(self, p)
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.side = side or 1
  
  if self.recycling then
    self.anim:gotoFrame(1)
  else
    self:setRectangleCollision(8, 8)
    self.tex = megautils.getResource("particles")
    self.anim = megautils.newAnimation("slideParticleGrid", {"1-3", 1}, 1/10)
    self.autoCollision = false
    self.recycle = true
  end
end

function slideParticle:update()
  self.anim:update(1/60)
  if self.anim:looped() then
    megautils.removeq(self)
  end
end

function slideParticle:draw()
  self.tex:draw(self.anim, math.floor(self.transform.x), math.floor(self.transform.y),
    nil, nil, nil, nil, nil, nil, nil, self.side == 1, self.gravity < 0)
end

damageSteam = particle:extend()

damageSteam.autoClean = false

function damageSteam:new(x, y, p)
  damageSteam.super.new(self, p)
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  
  if self.recycling then
    self.anim:gotoFrame(1)
  else
    self:setRectangleCollision(5, 8)
    self.tex = megautils.getResource("particles")
    self.anim = megautils.newAnimation("damageSteamGrid", {"1-3", 1}, 1/8)
    self.autoCollision = false
    self.recycle = true
  end
end

function damageSteam:update()
  self.anim:update(1/60)
  if self.anim:looped() then
    megautils.removeq(self)
  end
end

function damageSteam:draw()
  self.tex:draw(self.anim, math.floor(self.transform.x), math.floor(self.transform.y),
    nil, nil, nil, nil, nil, nil, nil, nil, self.gravity < 0)
end

airBubble = particle:extend()

airBubble.autoClean = false

function airBubble:new(x, y, p)
  airBubble.super.new(self, p)
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.off = 0
  self.timer = 0
  
  if not self.recycling then
    self:setRectangleCollision(2, 8)
    self.tex = megautils.getResource("particles")
    self.quad = quad(104, 28, 4, 4)
    self.velocity.velx = -1
    self.recycle = true
  end
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
    megautils.removeq(self)
  end
end

function airBubble:draw()
  self.tex:draw(self.quad, math.floor(self.transform.x)-self.off, math.floor(self.transform.y))
end

harm = particle:extend()

harm.autoClean = false

function harm:new(p, time)
  harm.super.new(self, p)
  if self.user then
    local cx, cy = megautils.center(self.user)
    self.transform.x = cx-12
    self.transform.y = cy-12
  end
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.quad = quad(0, 22, 24, 24)
  self.timer = 0
  self.maxTime = time or 32
  self.autoCollision = false
end

function harm:update()
  if not self.user or self.user.isRemoved or self.timer == self.maxTime then
    megautils.removeq(self)
  else
    self.transform.x = math.floor(self.user.transform.x)+math.floor(self.user.collisionShape.w/2)-12
    self.transform.y = math.floor(self.user.transform.y)+math.floor(self.user.collisionShape.h/2)-12
    self.timer = math.min(self.timer+1, self.maxTime)
    self.canDraw.global = not self.user.canDraw.flash
  end
end

function harm:draw()
  self.tex:draw(self.quad, math.floor(self.transform.x), math.floor(self.transform.y))
end

deathExplodeParticle = particle:extend()

deathExplodeParticle.autoClean = false

function deathExplodeParticle:new(x, y, p, angle, spd)
  deathExplodeParticle.super.new(self, p)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("deathExplodeParticleGrid", {"1-5", 1}, 1/10)
  self.velocity.velx = megautils.calcX(angle or 0)*(spd or 1)
  self.velocity.vely = megautils.calcY(angle or 0)*(spd or 1)
end

function deathExplodeParticle:update(dt)
  self.anim:update(1/60)
end

function deathExplodeParticle:draw()
  self.tex:draw(self.anim, math.floor(self.transform.x), math.floor(self.transform.y))
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
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("deathExplodeParticleGrid", {"1-5", 1}, 1/10)
  self.startX = x
  self.startY = y
  self.pos = 0
  self.spd = spd or 0.02
  self.autoCollision = false
  self.removeWhenOutside = false
end

function absorbParticle:update()
  if self.user and not self.user.isRemoved then
    local cx, cy = megautils.center(self.user)
    self.transform.x = math.lerp(self.startX, cx, self.pos)
    self.transform.y = math.lerp(self.startY, cy, self.pos)
    self.pos = math.min(self.pos + self.spd, 1)
  end
  if not self.user or self.pos == 1 or self.user.isRemoved then
    megautils.removeq(self)
  end
  self.anim:update(1/60)
end

function absorbParticle:draw()
  self.tex:draw(self.anim, math.floor(self.transform.x), math.floor(self.transform.y), 0, 1, 1, 12, 12)
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
  self.autoCollision = false
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
    megautils.removeq(self)
  end
end

smallBlast = particle:extend()

smallBlast.autoClean = false

function smallBlast:new(x, y, p, spd)
  smallBlast.super.new(self, p)
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.spd = spd or 0.065
  
  if self.recycling then
    self.anim:gotoFrame(1)
  else
    self:setRectangleCollision(24, 24)
    self.tex = megautils.getResource("particles")
    self.anim = megautils.newAnimation("deathExplodeParticleGrid", {"1-5", 1}, self.spd)
    self.autoCollision = false
    self.recycle = true
  end
end

function smallBlast:update()
  self.anim:update(1/60)
  if self.anim:looped() then
    megautils.removeq(self)
  end
end

function smallBlast:draw()
  self.tex:draw(self.anim, math.floor(self.transform.x), math.floor(self.transform.y))
end

blast = particle:extend()

blast.autoClean = false

function blast:new(x, y, p, hurt, damage, times)
  blast.super.new(self, p)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.deg = 0
  self.timer = 0
  self.times = 0
  self.max = times or 4
  self.autoCollision = false
  self.hurt = hurt == true
  self.damage = damage or -2
end

function blast:added()
  blast.super.added(self)
  megautils.add(smallBlast, self.transform.x, self.transform.y, self.user)
end

function blast:check()
  if megaMan.allPlayers then
    local ox, oy = self.transform.x, self.transform.y
    self.transform.x = self.transform.x + 12 - 24
    self.transform.y = self.transform.y + 12 - 24
    self:setRectangleCollision(48, 48)
    self:interact(self:collisionTable(megaMan.allPlayers), self.damage)
    self.collisionShape = nil
    self.transform.x, self.transform.y = ox, oy
  end
end

function blast:update(dt)
  self.timer = math.min(self.timer+1, 5)
  if self.timer == 5 then
    self.timer = 0
    megautils.add(smallBlast, megautils.circlePathX(self.transform.x, self.deg, 20), 
      megautils.circlePathY(self.transform.y, self.deg, 20), self.user)
    megautils.add(smallBlast, megautils.circlePathX(self.transform.x, self.deg-180, 20), 
      megautils.circlePathY(self.transform.y, self.deg-180, 20), self.user)
    self.deg = math.wrap(self.deg+360/6, 0, 360)
    self.times = self.times + 1
  end
  if self.hurt then
    self:check()
  end
  if self.times == self.max then
    megautils.removeq(self)
  end
end