slideParticle = entity:extend()

function slideParticle:new(x, y, side)
  slideParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(2, 8)
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("slide_particle_grid")("1-3",1), 1/10)
  self:setLayer(2)
  self.side = side
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
end

function slideParticle:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function slideParticle:update(dt)
  self:face(self.side)
  self.anim:update(1/60)
  if self.anim.looped then
    megautils.remove(self, true)
  elseif megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function slideParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-6, math.round(self.transform.y))
end

damageSteam = entity:extend()

function damageSteam:new(x, y)
  damageSteam.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(5, 8)
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("damage_steam_grid")("1-3",1), 1/8)
  self:setLayer(2)
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
end

function damageSteam:update(dt)
  self.anim:update(1/60)
  if self.anim.looped then
    megautils.remove(self, true)
  elseif megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function damageSteam:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-6, math.round(self.transform.y))
end

airBubble = entity:extend()

function airBubble:new(x, y)
  airBubble.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(2, 8)
  self.tex = loader.get("particles")
  self.quad = love.graphics.newQuad(104, 28, 4, 4, 128, 98)
  self:setLayer(2)
  self.off = 0
  self.timer = 0
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.render = false
end

function airBubble:check(x, y)
  return #self:collisionTable(megautils.groups()["solid"], x, y) ~= 0 or
    #self:collisionTable(megautils.groups()["death"], x, y) ~= 0 or
    #self:collisionTable(megautils.groups()["movingSolid"], x, y) ~= 0 or
    #self:collisionTable(megautils.groups()["water"], x, y) == 0
end

function airBubble:update(dt)
  self.render = true
  self.timer = math.min(self.timer+1, 8)
  if self.timer == 8 then
    self.timer = 0
    self.off = math.wrap(self.off+1, 0, 2)
  end
  self.transform.y = self.transform.y - 1
  if megautils.outside(self) or self:check(0, -8) then
    megautils.remove(self, true)
  end
end

function airBubble:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x)-self.off, math.round(self.transform.y))
end

kickParticle = entity:extend()

function kickParticle:new(x, y, side)
  kickParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 8)
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("slide_particle_grid")("1-3",1), 1/10)
  self.layer = 2
  self.render = false
  self.side = side
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.once = false
end

function kickParticle:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function kickParticle:update(dt)
  if not self.once then
    self.once = true
    if #self:collisionTable(megautils.groups()["solid"]) == 0 then
      megautils.remove(self, true)
      return
    end
    self.render = true
  end
  self:face(self.side)
  self.anim:update(1/60)
  self.transform.x = self.transform.x + (0.1 * self.side)
  self.transform.y = self.transform.y +  0.25
  if self.anim.looped then
    megautils.remove(self, true)
  elseif megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function kickParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

angleParticle = entity:extend()

function angleParticle:new(x, y, a)
  angleParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(2, 8)
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("slide_particle_grid")("1-3",1), 1/10)
  self.layer = 2
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.once = false
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(a)
  self.velocity.vely = megautils.calcY(a)
  self.side = ternary(self.velocity.velx>0, -1, 1)
end

function angleParticle:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function angleParticle:update(dt)
  self:face(self.side)
  self.anim:update(1/60)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if self.anim.looped then
    megautils.remove(self, true)
  elseif megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function angleParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

harm = entity:extend()

function harm:new(e)
  harm.super.new(self)
  self.transform.y = ((e.transform.y+e.collisionShape.h)/2)-24/2
  self.transform.x = ((e.transform.x+e.collisionShape.w)/2)-24/2
  self:setRectangleCollision(24, 24)
  self.tex = loader.get("particles")
  self.quad = love.graphics.newQuad(0, 22, 24, 24, 128, 98)
  self.layer = 2
  self.follow = e
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.timer = 0
end

function harm:update(dt)
  if self.follow == nil or self.follow.isRemoved then
    megautils.remove(self, true)
    return
  end
  self.transform.x = (self.follow.transform.x+self.follow.collisionShape.w/2)-24/2
  self.transform.y = (self.follow.transform.y+self.follow.collisionShape.h/2)-24/2
  self.timer = math.min(self.timer+1, 32)
  self.render = math.wrap(self.timer, 0, 6) < 3
  if self.timer == 32 or self.follow.isRemoved then
    megautils.remove(self, true)
  end
end

function harm:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x or 0), math.round(self.transform.y or 0))
end

explodeParticle = entity:extend()

function explodeParticle:new(x, y, angle, spd)
  explodeParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("explode_particle_grid")("1-5", 1), 1/10)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle)*spd
  self.velocity.vely = megautils.calcY(angle)*spd
end

function explodeParticle:update(dt)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
  self.anim:update(1/60)
end

function explodeParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

function explodeParticle.createExplosion(x, y)
  for j=1, 2 do
    for i=1, 8 do
      megautils.add(explodeParticle(x, y, i*45, j*1.8))
    end
  end
end

absorbParticle = entity:extend()

function absorbParticle:new(x, y, towards, spd)
  explodeParticle.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("explode_particle_grid")("1-5", 1), 1/10)
  self.towards = towards
  self.startX = x
  self.startY = y
  self.pos = 0
  self.spd = spd
end

function absorbParticle:update(dt)
  if self.towards ~= nil and not self.towards.isRemoved then
    self.transform.x = math.lerp(self.startX, self.towards.transform.x, self.pos)
    self.transform.y = math.lerp(self.startY, self.towards.transform.y, self.pos)
    self.pos = math.min(self.pos+(self.spd/view.w), 1)
  end
  if self:collision(self.towards) or self.towards.isRemoved then
    megautils.remove(self, true)
  end
  self.anim:update(1/60)
end

function absorbParticle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

function absorbParticle.createAbsorbtion(towards, spd)
  for i=1, 8 do
    megautils.add(absorbParticle((view.x+view.w/2)+megautils.calcX(i*45)*view.w,
        (view.y+view.h/2)+megautils.calcY(i*45)*view.w, towards, (spd or 5)))
    megautils.add(absorbParticle((view.x+view.w/2)+megautils.calcX(i*45)*view.w,
        (view.y+view.h/2)+megautils.calcY(i*45)*view.w, towards, ((spd or 5)*1.5)))
  end
end

absorb = entity:extend()

function absorb:new(towards, times, spd)
  absorb.super.new(self)
  self:addToGroup("removeOnCutscene")
  self:addToGroup("freezable")
  self.timer = 60
  self.times = 0
  self.maxTimes = times or 3
  self.spd = spd
  self.towards = towards
end

function absorb:update(dt)
  self.timer = math.min(self.timer+1, 60)
  if self.timer == 60 then
    self.timer = 0
    self.times = self.times + 1
    mmSfx.play("absorb")
    absorbParticle.createAbsorbtion(self.towards, self.spd)
    if self.times == self.maxTimes then
      megautils.remove(self, true)
    end
  end
end

smallBlast = entity:extend()

function smallBlast:new(x, y, spd)
  smallBlast.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("explode_particle_grid")("1-5", 1), spd or 0.065)
end

function smallBlast:update(dt)
  self.anim:update(1/60)
  if megautils.outside(self) or self.anim.looped then
    megautils.remove(self, true)
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
  self:addToGroup("freezable")
  self:addToGroup("removeOnCutscene")
  self.deg = 0
  megautils.add(smallBlast(x, y))
  self.timer = 0
  self.times = 0
  self.max = ternary(times == nil, 4, times)
end

function blast:update(dt)
  self.timer = math.min(self.timer+1, 5)
  if self.timer == 5 then
    self.timer = 0
    megautils.add(smallBlast(megautils.circlePathX(self.transform.x, self.deg, 20), 
        megautils.circlePathY(self.transform.y, self.deg, 20)))
    megautils.add(smallBlast(megautils.circlePathX(self.transform.x, self.deg-180, 20), 
        megautils.circlePathY(self.transform.y, self.deg-180, 20)))
    self.deg = math.wrap(self.deg+360/6, 0, 360)
    self.times = self.times + 1
  end
  if self.times == self.max then
    megautils.remove(self, true)
  end
end