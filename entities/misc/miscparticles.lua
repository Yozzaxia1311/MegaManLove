megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource(8, 8, "slideParticleGrid", true)
megautils.loadResource(0, 46, 24, 24, "explodeParticleGrid", true)
megautils.loadResource(108, 28, 5, 8, "damageSteamGrid", true)

slideParticle = basicEntity:extend()

function slideParticle:new(x, y, side, g)
  slideParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 8)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("slideParticleGrid", {"1-3", 1}, 1/10)
  self.side = side
  self.anim.flippedV = g < 0
end

function slideParticle:recycle(x, y, side, g)
  self.side = side
  self.transform.y = y
  self.transform.x = x
  self.anim:gotoFrame(1)
  self.anim.flippedV = g < 0
end

function slideParticle:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function slideParticle:update(dt)
  self.anim.flipX = self.side == 1
  self.anim:update(defaultFramerate)
  if self.anim.looped then
    megautils.removeq(self)
  elseif megautils.outside(self) then
    megautils.removeq(self)
  end
end

function slideParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

damageSteam = basicEntity:extend()

function damageSteam:new(x, y, g)
  damageSteam.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(5, 8)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("damageSteamGrid", {"1-3", 1}, 1/8)
  self.anim.flippedV = g < 0
end

function damageSteam:recycle(x, y, g)
  self.transform.y = y
  self.transform.x = x
  self.anim:gotoFrame(1)
  self.anim.flippedV = g < 0
end

function damageSteam:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function damageSteam:update(dt)
  self.anim:update(defaultFramerate)
  if self.anim.looped then
    megautils.removeq(self)
  elseif megautils.outside(self) then
    megautils.removeq(self)
  end
end

function damageSteam:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

airBubble = entity:extend()

function airBubble:new(x, y)
  airBubble.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(2, 8)
  self.tex = megautils.getResource("particles")
  self.quad = quad(104, 28, 4, 4)
  self.off = 0
  self.timer = 0
end

function airBubble:recycle(x, y)
  self.transform.y = y
  self.transform.x = x
  self.timer = 0
  self.off = 0
end

function airBubble:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function airBubble:check(x, y)
  return collision.checkSolid(self) or
    self:collisionNumber(megautils.groups().water, x, y) == 0
end

function airBubble:update(dt)
  self.timer = math.min(self.timer+1, 8)
  if self.timer == 8 then
    self.timer = 0
    self.off = math.wrap(self.off+1, 0, 2)
  end
  self.transform.y = self.transform.y - 1
  if megautils.outside(self) or self:check(0, -8) then
    megautils.removeq(self)
  end
end

function airBubble:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x)-self.off, math.round(self.transform.y))
end

angleParticle = entity:extend()

function angleParticle:new(x, y, a)
  angleParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(2, 8)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("slideParticleGrid", {"1-3", 1}, 1/10)
  self.once = false
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(a)
  self.velocity.vely = megautils.calcY(a)
  self.side = self.velocity.velx>0 and -1 or 1
end

function angleParticle:recycle(x, y, a)
  self.transform.y = y
  self.transform.x = x
  self.once = false
  self.velocity.velx = megautils.calcX(a)
  self.velocity.vely = megautils.calcY(a)
  self.side = self.velocity.velx>0 and -1 or 1
  self.anim:gotoFrame(1)
end

function angleParticle:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function angleParticle:update(dt)
  self.anim.flipX = self.side == 1
  self.anim:update(defaultFramerate)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if self.anim.looped then
    megautils.removeq(self)
  elseif megautils.outside(self) then
    megautils.removeq(self)
  end
end

function angleParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

harm = entity:extend()

function harm:new(e, time)
  harm.super.new(self)
  self.follow = e
  self.transform.x = (self.follow.transform.x+self.follow.collisionShape.w/2)-24/2
  self.transform.y = (self.follow.transform.y+self.follow.collisionShape.h/2)-24/2
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("particles")
  self.quad = quad(0, 22, 24, 24)
  self.timer = 0
  self.maxTime = time or 32
end

function harm:recycle(e, time)
  self.follow = e
  self.transform.x = (self.follow.transform.x+self.follow.collisionShape.w/2)-24/2
  self.transform.y = (self.follow.transform.y+self.follow.collisionShape.h/2)-24/2
  self.timer = 0
  self.maxTime = time or 32
end

function harm:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function harm:afterUpdate(dt)
  if not self.follow or self.follow.isRemoved then
    megautils.removeq(self)
    return
  end
  self.transform.x = math.round(self.follow.transform.x)+math.round(self.follow.collisionShape.w/2)-12
  self.transform.y = math.round(self.follow.transform.y)+math.round(self.follow.collisionShape.h/2)-12
  self.timer = math.min(self.timer+1, self.maxTime)
  self.canDraw.global = not self.follow.canDraw.flash
  if self.timer == self.maxTime or self.follow.isRemoved then
    megautils.removeq(self)
  end
end

function harm:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, self.transform.x, self.transform.y)
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

function smallBlast:recycle(x, y, spd)
  self.transform.y = y
  self.transform.x = x
  if spd ~= self.spd then
    self.spd = spd or 0.065
    self.anim:setDurations(self.spd)
  end
  self.anim:gotoFrame(1)
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

function blast:recycle(x, y, times)
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
