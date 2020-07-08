weapons = {}
weapons.removeGroups = {}
weapons.resources = {}

weapons.removeGroups.protoBuster = {"megaBuster", "protoChargedBuster"}

weapons.resources.protoBuster = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/misc/weapons/protoBuster.png", "protoBuster")
    megautils.loadResource("assets/sfx/buster.ogg", "buster")
    megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge")
    megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged")
    megautils.loadResource("assets/sfx/reflect.ogg", "dink")
    megautils.loadResource("protoBusterGrid", 29, 10, 68, 10, 10, 0)
  end

weapons.resources.rollBuster = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/misc/weapons/rollBuster.png", "rollBuster")
    megautils.loadResource("assets/sfx/buster.ogg", "buster")
    megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge")
    megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged")
    megautils.loadResource("assets/sfx/reflect.ogg", "dink")
    megautils.loadResource("protoBusterGrid", 29, 10, 68, 10, 10, 0)
  end

protoSemiBuster = basicEntity:extend()

function protoSemiBuster:new(x, y, dir, wpn, skin, grav)
  protoSemiBuster.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(10, 10)
  self.tex = megautils.getResource(skin)
  self.quad = love.graphics.newQuad(0, 0, 10, 10, 68, 10)
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self.grav = grav
  megautils.playSound("semiCharged")
end

function protoSemiBuster:added()
  self:addToGroup("megaBuster")
  self:addToGroup("megaBuster" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("weapon")
end

function protoSemiBuster:dink(e)
  self.velocity.vely = -4 * self.grav
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function protoSemiBuster:update(dt)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -1, 2)
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function protoSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y)-3)
end

protoChargedBuster = basicEntity:extend()

function protoChargedBuster:new(x, y, dir, wpn, skin, grav)
  protoChargedBuster.super.new(self)
  self.tex = megautils.getResource(skin)
  self.anim = anim8.newAnimation(megautils.getResource("protoBusterGrid")("1-2", 1), 1/20)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(29, 8)
  self.velocity = velocity()
  self.spd = 4
  self.velocity.velx = dir * 6
  self.side = dir
  self.wpn = wpn
  self.grav = grav
  self:face(-self.side)
  megautils.playSound("protoCharged")
end

function protoChargedBuster:added()
  self:addToGroup("protoChargedBuster")
  self:addToGroup("protoChargedBuster" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function protoChargedBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function protoChargedBuster:dink(e)
  self.velocity.vely = -4*self.grav
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function protoChargedBuster:update(dt)
  self.anim:update(defaultFramerate)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -2, 2)
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function protoChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y-1))
end

bassBuster = entity:extend()

weapons.removeGroups.bassBuster = {"bassBuster"}

weapons.resources.bassBuster = function()
    megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster")
    megautils.loadResource("assets/sfx/buster.ogg", "buster")
    megautils.loadResource("assets/sfx/reflect.ogg", "dink")
  end

function bassBuster:new(x, y, dir, wpn, t, grav)
  bassBuster.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(6, 6)
  self.tex = megautils.getResource("bassBuster")
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(dir) * 5
  self.velocity.vely = megautils.calcY(dir) * 5
  self.side = self.velocity.velx < 0 and -1 or 1
  self.wpn = wpn
  self.treble = t
  self:setGravityMultiplier("global", grav)
end

function bassBuster:recycle(x, y, dir, wpn, t, grav)
  self.wpn = wpn
  self.velocity.velx = megautils.calcX(dir) * 5
  self.velocity.vely = megautils.calcY(dir) * 5
  self.side = self.velocity.velx < 0 and -1 or 1
  self.dinked = nil
  self.transform.x = x
  self.transform.y = y
  self.treble = t
  self:setGravityMultiplier("global", grav)
end

function bassBuster:added()
  self:addToGroup("bassBuster")
  self:addToGroup("bassBuster" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("weapon")
  if not self.treble then
    megautils.playSound("buster")
  end
end

function bassBuster:dink(e)
  self.velocity.vely = -4 * (self.gravity >= 0 and 1 or -1)
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function bassBuster:update(dt)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), self.treble and -1 or -0.5, 2)
  end
  local col = collision.checkSolid(self, self.velocity.velx, self.velocity.vely)
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or (not self.treble and not self.dinked and col) then
    megautils.removeq(self)
  end
end

function bassBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x-1), math.round(self.transform.y-1))
end

megaBuster = basicEntity:extend()

weapons.removeGroups.megaBuster = {"megaBuster", "megaChargedBuster"}

weapons.resources.megaBuster = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/sfx/buster.ogg", "buster")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource("assets/sfx/semi.ogg", "semiCharged")
    megautils.loadResource("assets/sfx/charged.ogg", "charged")
    megautils.loadResource("assets/sfx/reflect.ogg", "dink")
    megautils.loadResource("chargeGrid", 33, 30, 133, 47)
    megautils.loadResource("smallChargeGrid", 17, 16, 133, 47, 8, 31)
  end

function megaBuster:new(x, y, dir, wpn, grav)
  megaBuster.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = megautils.getResource("busterTex")
  self.quad = love.graphics.newQuad(0, 31, 8, 6, 133, 47)
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self.grav = grav
end

function megaBuster:recycle(x, y, dir, wpn, grav)
  self.wpn = wpn
  self.side = dir
  self.velocity.velx = dir * 5
  self.velocity.vely = 0
  self.dinked = nil
  self.transform.x = x
  self.transform.y = y
  self.grav = grav
end

function megaBuster:added()
  self:addToGroup("megaBuster")
  self:addToGroup("megaBuster" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("weapon")
  megautils.playSound("buster")
end

function megaBuster:dink(e)
  self.velocity.vely = -4*self.grav
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function megaBuster:update(dt)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -1, 2)
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function megaBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megaSemiBuster = basicEntity:extend()

function megaSemiBuster:new(x, y, dir, wpn, grav)
  megaSemiBuster.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.tex = megautils.getResource("busterTex")
  self.anim = anim8.newAnimation(megautils.getResource("smallChargeGrid")("1-2", 1), 1/12)
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self.grav = grav
  megautils.playSound("semiCharged")
  self:face(-self.side)
end

function megaSemiBuster:added()
  self:addToGroup("megaBuster")
  self:addToGroup("megaBuster" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("weapon")
end

function megaSemiBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function megaSemiBuster:dink(e)
  self.velocity.vely = -4*self.grav
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function megaSemiBuster:update(dt)
  self.anim:update(defaultFramerate)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -1, 2)
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function megaSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-3)
end

megaChargedBuster = basicEntity:extend()

function megaChargedBuster:new(x, y, dir, wpn, grav)
  megaChargedBuster.super.new(self)
  self.tex = megautils.getResource("busterTex")
  self.anim = anim8.newAnimation(megautils.getResource("chargeGrid")("1-4", 1), 1/20)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self.velocity = velocity()
  self.spd = 4
  self.velocity.velx = dir * 5.5
  self.side = dir
  self.wpn = wpn
  self.grav = grav
  megautils.playSound("charged")
  self:face(-self.side)
end

function megaChargedBuster:added()
  self:addToGroup("megaChargedBuster")
  self:addToGroup("megaChargedBuster" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("weapon")
end

function megaChargedBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function megaChargedBuster:dink(e)
  self.velocity.vely = -4*self.grav
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function megaChargedBuster:update(dt)
  self.anim:update(defaultFramerate)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -2, 2)
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function megaChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-8, math.round(self.transform.y)-3)
end

trebleBoost = entity:extend()

weapons.removeGroups.trebleBoost = {"trebleBoost", "bassBuster"}

weapons.resources.trebleBoost = function()
    megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster")
    megautils.loadResource("assets/sfx/treble.ogg", "treble")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("trebleGrid", 33, 32, 264, 32)
    
    weapons.resources.bassBuster() -- Just incase it isn't already loaded.
  end

function trebleBoost:new(x, y, side, player, wpn)
  trebleBoost.super.new(self)
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.skin = "assets/misc/weapons/treble.png"
  self.tex = megautils.getResource(self.skin) or megautils.loadResource(self.skin, self.skin)
  self.c = "spawn"
  self.anims = {}
  self.anims.spawn = anim8.newAnimation(megautils.getResource("trebleGrid")(1, 1), 1)
  self.anims.spawnLand = anim8.newAnimation(megautils.getResource("trebleGrid")("2-3", 1, 2, 1), 1/20)
  self.anims.idle = anim8.newAnimation(megautils.getResource("trebleGrid")(4, 1), 1)
  self.anims.start = anim8.newAnimation(megautils.getResource("trebleGrid")("5-6", 1, "5-6", 1, "5-6", 1, "5-6", 1, "7-8", 1),
    1/16, "pauseAtEnd")
  self.side = side
  self.s = 0
  self.wpn = wpn
  self.player = player
  self.blockCollision = true
  self.timer = 0
  self:setGravityMultiplier("global", self.player.gravity >= 0 and 1 or -1)
end

function trebleBoost:added()
  self:addToGroup("trebleBoost")
  self:addToGroup("trebleBoost" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("submergable")
end

function trebleBoost:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(7)
end

function trebleBoost:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function trebleBoost:update(dt)
  self.anims[self.c]:update(defaultFramerate)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velocity.vely = 8
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    collision.doGrav(self)
    collision.doCollision(self)
    if self.ground then
      self.c = "spawnLand"
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims.spawnLand.looped then
      self.c = "idle"
      self.s = 3
      megautils.playSound("start")
    end
  elseif self.s == 3 then
    megautils.autoFace(self, self.player, true)
    self.side = -self.side
    if not self.player.climb and self.player.ground and self.player:collision(self) then
      self.player:resetStates()
      self.player.canBeInvincible.treble = true
      self.player.treble = 1
      self.player.animations.trebleStart:gotoFrame(1)
      self.player.animations.trebleStart:resume()
      self.player.curAnim = "idle"
      self.player.velocity.velx = 0
      self.s = 4
      self.c = "start"
    end
  elseif self.s == 4 then
    if self.anims.start.looped then
      self.s = 5
      self.player.curAnim = "trebleStart"
      self.player:face(self.player.side)
    end
  elseif self.s == 5 then
    self.timer = self.timer + 1
    if self.timer == 20 then
      megautils.removeq(self)
    end
  end
  self:face(self.side)
  self:setGravityMultiplier("global", self.player.gravity >= 0 and 1 or -1)
  self.anims[self.c].flippedV = self.gravity < 0
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function trebleBoost:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims[self.c]:draw(self.tex, math.round(self.transform.x-6), math.round(self.transform.y-12+(self.gravity >= 0 and 0 or 11)))
end

rushJet = entity:extend()

weapons.removeGroups.rushJet = {"rushJet", "megaBuster", "bassBuster"}

weapons.resources.rushJet = function()
    megautils.loadResource("assets/misc/weapons/rush.png", "rush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("rushGrid", 32, 32, 128, 64)
    
    weapons.resources.megaBuster() -- So it's possible to use the Mega Buster shots even if the weapon wasn't already loaded in for some reason...
  end

weapons.resources.protoRushJet = function()
    megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("rushGrid", 32, 32, 128, 64)
    
    weapons.resources.megaBuster()
  end

weapons.resources.tangoJet = function()
    megautils.loadResource("assets/misc/weapons/tango.png", "tango")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("rushGrid", 32, 32, 128, 64)
    
    weapons.resources.megaBuster()
  end

function rushJet:new(x, y, side, player, wpn, skin)
  rushJet.super.new(self)
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(27, 8)
  self.tex = megautils.getResource(skin) or megautils.loadResource(skin, skin)
  self.skin = skin
  self.c = "spawn"
  self.anims = {}
  self.anims.spawn = anim8.newAnimation(megautils.getResource("rushGrid")(1, 1), 1)
  self.anims.spawnLand = anim8.newAnimation(megautils.getResource("rushGrid")("2-3", 1, 2, 1), 1/20)
  self.anims.jet = anim8.newAnimation(megautils.getResource("rushGrid")("2-3", 2), 1/8)
  self.side = side
  self.s = 0
  self.velocity = velocity()
  self.wpn = wpn
  self.timer = 0
  self.blockCollision = true
  self.player = player
  self.playerOn = false
  self.exclusivelySolidFor = {self.player}
end

function rushJet:added()
  self:addToGroup("rushJet")
  self:addToGroup("rushJet" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("submergable")
  self:addToGroup("solid")
end

function rushJet:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushJet:update(dt)
  self.anims[self.c]:update(defaultFramerate)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.c = "spawnLand"
        self.s = 1
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.anims.spawnLand.looped then
      self.c = "jet"
      self.s = 2
      self.solidType = collision.ONEWAY
      megautils.playSound("start")
    end
  elseif self.s == 2 then
    if self.player.ground and self.player:collision(self, 0, self.player.gravity >= 0 and 1 or -1) and
      not self.player:collision(self) then
      self.s = 3
      self.velocity.velx = self.side
      self.player.canWalk.rj = false
      self.playerOn = true
    end
    collision.doCollision(self)
  elseif self.s == 3 then
    if self.playerOn then
      if control.upDown[self.player.player] then
        self.velocity.vely = -1
      elseif control.downDown[self.player.player] then
        self.velocity.vely = 1
      else
        self.velocity.vely = 0
      end
    else
      self.velocity.vely = 0
      if self.player.ground and self.player:collision(self, 0, self.player.gravity >= 0 and 1 or -1) and
      not self.player:collision(self) then
        self.s = 3
        self.velocity.velx = self.side
        self.player.canWalk.rj = false
        self.playerOn = true
      end
    end
    collision.doCollision(self)
    if self.playerOn and (not self.player.ground or
      not (self.player:collision(self, 0, self.player.gravity >= 0 and 1 or -1) and
      not self.player:collision(self))) then
      self.player.canWalk.rj = true
      self.playerOn = false
    end
    if self.xColl ~= 0 or
      (self.playerOn and collision.checkSolid(self.player, 0, self.player.gravity >= 0 and -4 or 4)) then
      if self.playerOn then self.player.canWalk.rj = true end
      self.c = "spawnLand"
      self.anims.spawnLand:gotoFrame(1)
      self.s = 4
      self.solidType = collision.NONE
      megautils.playSound("ascend")
    end
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      self.wpn:updateCurrent(self.wpn:currentWE() - 1)
    end
  elseif self.s == 4 then
    if self.anims.spawnLand.looped then
      self.s = 5
      self.c = "spawn"
    end
  elseif self.s == 5 then
    self:moveBy(0, -8)
  end
  self:face(self.side)
  self.anims[self.c].flippedV = self.player.gravity < 0
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function rushJet:removed()
  self.player.canWalk.rj = true
end

function rushJet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.c == "spawn" or self.c == "spawnLand" then
    self.anims[self.c]:draw(self.tex, math.round(self.transform.x-4), math.round(self.transform.y+(self.player.gravity >= 0 and -16 or -6)))
  else
    self.anims[self.c]:draw(self.tex, math.round(self.transform.x-4), math.round(self.transform.y-12))
  end
end

rushCoil = entity:extend()

weapons.removeGroups.rushCoil = {"rushCoil", "megaBuster", "bassBuster", "rollBuster"}

weapons.resources.rushCoil = function()
    megautils.loadResource("assets/misc/weapons/rush.png", "rush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("rushGrid", 32, 32, 128, 64)
    
    weapons.resources.megaBuster() -- So it's possible to use the Mega Buster shots even if the weapon wasn't already loaded in for some reason...
  end

weapons.resources.protoRushCoil = function()
    megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("rushGrid", 32, 32, 128, 64)
    
    weapons.resources.megaBuster()
  end

weapons.resources.tangoCoil = function()
    megautils.loadResource("assets/misc/weapons/tango.png", "tango")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("rushGrid", 32, 32, 128, 64)
    
    weapons.resources.megaBuster()
  end

function rushCoil:new(x, y, side, player, w, skin)
  rushCoil.super.new(self)
  self.proto = proto
  self.transform.x = x
  self.transform.y = view.y-16
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = megautils.getResource(skin)
  self.skin = skin
  self.c = "spawn"
  self.anims = {}
  self.anims.spawn = anim8.newAnimation(megautils.getResource("rushGrid")(1, 1), 1)
  self.anims.spawnLand = anim8.newAnimation(megautils.getResource("rushGrid")("2-3", 1, 2, 1), 1/20)
  self.anims.idle = anim8.newAnimation(megautils.getResource("rushGrid")(4, 1, 1, 2), 1/8)
  self.anims.coil = anim8.newAnimation(megautils.getResource("rushGrid")(4, 2), 1)
  self.side = side
  self.s = 0
  self.timer = 0
  self.velocity = velocity()
  self.wpn = w
  self.blockCollision = true
  self.player = player
  self:setGravityMultiplier("global", self.player.gravity >= 0 and 1 or -1)
end

function rushCoil:added()
  self:addToGroup("rushCoil")
  self:addToGroup("rushCoil" .. self.wpn.id)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("submergable")
end

function rushCoil:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(7)
end

function rushCoil:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushCoil:update(dt)
  self.anims[self.c]:update(defaultFramerate)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velocity.vely = 8
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    collision.doGrav(self)
    collision.doCollision(self)
    if self.ground then
      self.c = "spawnLand"
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims.spawnLand.looped then
      self.c = "idle"
      self.s = 3
      megautils.playSound("start")
    end
  elseif self.s == 3 then
    collision.doGrav(self)
    collision.doCollision(self)
    if not self.player.climb and (self.player.gravity >= 0 and (self.player.velocity.vely > 0) or (self.player.velocity.vely < 0)) and
      math.between(self.player.transform.x+self.player.collisionShape.w/2,
      self.transform.x, self.transform.x+self.collisionShape.w) and
      self.player:collision(self) then
      self.player.canStopJump.global = false
      self.player.velocity.vely = -7.5 * (self.player.gravity >= 0 and 1 or -1)
      self.player.step = false
      self.player.stepTime = 0
      self.player.ground = false
      self.player.currentLadder = nil
      self.player.wallJumping = false
      self.player.dashJump = false
      if self.player.slide then
        self.player:slideToReg()
        self.player.slide = false
      end
      self.s = 4
      self.c = "coil"
      self.wpn:updateCurrent(self.wpn:currentWE() - 7)
    end
  elseif self.s == 4 then
    collision.doGrav(self)
    collision.doCollision(self)
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.s = 5
      self.c = "spawnLand"
      self.anims.spawnLand:gotoFrame(1)
      megautils.playSound("ascend")
    end
  elseif self.s == 5 then
    if self.anims.spawnLand.looped then
      self.s = 6
      self.c = "spawn"
    end
  elseif self.s == 6 then
    self:moveBy(0, -8)
  end
  self:face(self.side)
  self:setGravityMultiplier("global", self.player.gravity >= 0 and 1 or -1)
  self.anims[self.c].flippedV = self.gravity < 0
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function rushCoil:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims[self.c]:draw(self.tex, math.round(self.transform.x-8), math.round(self.transform.y-12+(self.gravity >= 0 and 0 or 11)))
end

stickWeapon = entity:extend()

weapons.removeGroups.stickWeapon = {"stickWeapon"}

weapons.resources.stickWeapon = function()
    megautils.loadResource("assets/misc/weapons/stickWeapon.png", "stickWeapon")
    megautils.loadResource("assets/sfx/buster.ogg", "buster")
    megautils.loadResource("assets/sfx/reflect.ogg", "dink")
  end

function stickWeapon:new(x, y, dir, wpn, grav)
  stickWeapon.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = megautils.getResource("stickWeapon")
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self.grav = grav
  megautils.playSound("buster")
end

function stickWeapon:added()
  self:addToGroup("stickWeapon")
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
end

function stickWeapon:dink(e)
  self.velocity.vely = -4*self.grav
  self.velocity.velx = 4*-self.side
  self.dinked = 1
  megautils.playSound("dink")
end

function stickWeapon:update(dt)
  if not self.dinked then
    self:hurt(self:collisionTable(megautils.groups().hurtable), -8, 1)
  end
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) then
    megautils.removeq(self)
  end
end

function stickWeapon:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end
