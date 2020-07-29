megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource(8, 8, "slideParticleGrid", true)
megautils.loadResource(0, 46, 24, 24, "explodeParticleGrid", true)
megautils.loadResource(108, 28, 5, 8, "damageSteamGrid", true)

particle = entity:extend()

function particle:new(user)
  particle.super.new(self)
  
  if not self.recycling then
    self:setRectangleCollision(8, 8)
    self.autoCollision = true
    self.autoGravity = false
    self.removeWhenOutside = true
    self.doAutoCollisionBeforeUpdate = true
    self.flipWithUser = true
  end
  
  self.user = user
  self._didCol = false
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

function slideParticle:new(x, y, p, side, g)
  slideParticle.super.new(self, p)
  
  if self.recycling then
    self.anim:gotoFrame(1)
  else
    self:setRectangleCollision(8, 8)
    self.tex = megautils.getResource("particles")
    self.anim = megautils.newAnimation("slideParticleGrid", {"1-3", 1}, 1/10)
    self.autoCollision = false
    self.recycle = true
  end
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.side = side or 1
  self.anim.flipX = self.side == 1
  self.anim.flipY = (g or 1) < 0
end

function slideParticle:update()
  self.anim:update(defaultFramerate)
  if self.anim:looped() then
    megautils.removeq(self)
  end
end

function slideParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

damageSteam = particle:extend()

function damageSteam:new(x, y, p, g)
  damageSteam.super.new(self, p)
  
  if self.recycling then
    self.anim:gotoFrame(1)
  else
    self:setRectangleCollision(5, 8)
    self.tex = megautils.getResource("particles")
    self.anim = megautils.newAnimation("damageSteamGrid", {"1-3", 1}, 1/8)
    self.autoCollision = false
    self.recycle = true
  end
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.anim.flipY = (g or 1) < 0
end

function damageSteam:update()
  self.anim:update(defaultFramerate)
  if self.anim:looped() then
    megautils.removeq(self)
  end
end

function damageSteam:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

airBubble = entity:extend()

function airBubble:new(x, y, p)
  airBubble.super.new(self, p)
  
  if not self.recycling then
    self:setRectangleCollision(2, 8)
    self.tex = megautils.getResource("particles")
    self.quad = quad(104, 28, 4, 4)
    self.velocity.velx = -1
    self.recycle = true
  end
  
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.off = 0
  self.timer = 0
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
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x)-self.off, math.round(self.transform.y))
end

harm = particle:extend()

function harm:new(p, time)
  harm.super.new(self, p)
  self.transform.x = (self.follow.transform.x+self.follow.collisionShape.w/2)-24/2
  self.transform.y = (self.follow.transform.y+self.follow.collisionShape.h/2)-24/2
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.quad = quad(0, 22, 24, 24)
  self.timer = 0
  self.maxTime = time or 32
  self.autoCollision = false
end

function harm:afterUpdate()
  if not self.user or self.user.isRemoved or self.timer == self.maxTime then
    megautils.removeq(self)
  else
    self.transform.x = math.round(self.user.transform.x)+math.round(self.user.collisionShape.w/2)-12
    self.transform.y = math.round(self.user.transform.y)+math.round(self.user.collisionShape.h/2)-12
    self.timer = math.min(self.timer+1, self.maxTime)
    self.canDraw.global = not self.follow.canDraw.flash
  end
  
  harm.super.afterUpdate(self)
end

function harm:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

explodeParticle = entity:extend()

function explodeParticle:new(x, y, angle, spd)
  explodeParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("explodeParticleGrid", {"1-5", 1}, 1/10)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle)*spd
  self.velocity.vely = megautils.calcY(angle)*spd
end

function explodeParticle:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function explodeParticle:update(dt)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) then
    megautils.removeq(self)
  end
  self.anim:update(defaultFramerate)
end

function explodeParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

function explodeParticle.createExplosion(x, y)
  for j=1, 2 do
    for i=1, 8 do
      megautils.add(explodeParticle, x, y, i*45, j*1.8)
    end
  end
end

absorbParticle = entity:extend()

function absorbParticle:new(x, y, towards, spd)
  absorbParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("explodeParticleGrid", {"1-5", 1}, 1/10)
  self.towards = towards
  self.startX = x
  self.startY = y
  self.pos = 0
  self.spd = spd
end

function absorbParticle:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function absorbParticle:update(dt)
  if self.towards and not self.towards.isRemoved then
    self.transform.x = math.lerp(self.startX, self.towards.transform.x+(self.towards.collisionShape.w/2), self.pos)
    self.transform.y = math.lerp(self.startY, self.towards.transform.y+(self.towards.collisionShape.h/2), self.pos)
    self.pos = math.min(self.pos + self.spd, 1)
  end
  if not self.towards or self.pos == 1 or self.towards.isRemoved then
    megautils.removeq(self)
  end
  self.anim:update(defaultFramerate)
end

function absorbParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y), 0, 1, 1, 12, 12)
end

function absorbParticle.createAbsorbtion(towards, spd)
  for i=1, 8 do
    megautils.add(absorbParticle, (view.x+view.w/2)+megautils.calcX(i*45)*view.w,
        (view.y+view.h/2)+megautils.calcY(i*45)*view.w, towards, (spd or 0.02))
    megautils.add(absorbParticle, (view.x+view.w/2)+megautils.calcX(i*45)*view.w,
        (view.y+view.h/2)+megautils.calcY(i*45)*view.w, towards, ((spd or 0.02)*1.5))
  end
end

absorb = entity:extend()

function absorb:new(towards, times, spd)
  absorb.super.new(self)
  self.timer = 60
  self.times = 0
  self.maxTimes = times or 3
  self.spd = spd
  self.towards = towards
end

function absorb:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function absorb:update(dt)
  self.timer = math.min(self.timer+1, 60)
  if self.timer == 60 then
    self.timer = 0
    self.times = self.times + 1
    megautils.playSoundFromFile("assets/sfx/absorb.ogg")
    absorbParticle.createAbsorbtion(self.towards, self.spd)
    if self.times == self.maxTimes then
      megautils.removeq(self)
    end
  end
end

smallBlast = entity:extend()

function smallBlast:new(x, y, spd)
  smallBlast.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.spd = spd or 0.065
  self.anim = megautils.newAnimation("explodeParticleGrid", {"1-5", 1}, self.spd)
end

function smallBlast:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function smallBlast:update(dt)
  self.anim:update(defaultFramerate)
  if megautils.outside(self) or self.anim.looped then
    megautils.removeq(self)
  end
end

function smallBlast:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

blast = entity:extend()

function blast:new(x, y, times)
  blast.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self.deg = 0
  self.timer = 0
  self.times = 0
  self.max = times == nil and 4 or times
end

function blast:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  megautils.add(smallBlast, self.transform.x, self.transform.y)
end

function blast:update(dt)
  self.timer = math.min(self.timer+1, 5)
  if self.timer == 5 then
    self.timer = 0
    megautils.add(smallBlast, megautils.circlePathX(self.transform.x, self.deg, 20), 
        megautils.circlePathY(self.transform.y, self.deg, 20))
    megautils.add(smallBlast, megautils.circlePathX(self.transform.x, self.deg-180, 20), 
        megautils.circlePathY(self.transform.y, self.deg-180, 20))
    self.deg = math.wrap(self.deg+360/6, 0, 360)
    self.times = self.times + 1
  end
  if self.times == self.max then
    megautils.removeq(self)
  end
end
