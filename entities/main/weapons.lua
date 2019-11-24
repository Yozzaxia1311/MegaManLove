weaponhandler.removeGroups["protoBuster"] = {"megaBuster", "protoChargedBuster"}

protoSemiBuster = basicEntity:extend()

function protoSemiBuster:new(x, y, dir, wpn, roll)
  protoSemiBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaBuster")
    self:addToGroup("megaBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(10, 10)
  self.tex = loader.get(roll and "roll_buster" or "proto_buster")
  self.quad = love.graphics.newQuad(0, 0, 10, 10, 68, 10)
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  mmSfx.play("semi_charged")
  self:setLayer(1)
end

function protoSemiBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function protoSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y)-3)
end

protoChargedBuster = basicEntity:extend()

function protoChargedBuster:new(x, y, dir, wpn, roll)
  protoChargedBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("protoChargedBuster")
    self:addToGroup("protoChargedBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.tex = loader.get(roll and "roll_buster" or "proto_buster")
  self.anim = anim8.newAnimation(loader.get("proto_buster_grid")("1-2", 1), 1/20)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(29, 8)
  self.dink = false
  self.velocity = velocity()
  self.spd = 4
  self.velocity.velx = dir * 6
  self.side = dir
  self.wpn = wpn
  mmSfx.play("proto_charged")
  self:face(-self.side)
  self:setLayer(1)
end

function protoChargedBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function protoChargedBuster:update(dt)
  self.anim:update(1/60)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -2, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function protoChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y-1))
end

bassBuster = basicEntity:extend()

weaponhandler.removeGroups["bassBuster"] = {"bassBuster"}

function bassBuster:new(x, y, dir, wpn, t)
  bassBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("bassBuster")
    self:addToGroup("bassBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
    if not self.treble then
      mmSfx.play("buster")
    end
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(6, 6)
  self.tex = loader.get("bass_buster")
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(dir) * 5
  self.velocity.vely = megautils.calcY(dir) * 5
  self.side = self.velocity.velx < 0 and -1 or 1
  self.wpn = wpn
  self:setLayer(1)
  self.treble = t
end

function bassBuster:recycle(x, y, dir, wpn, t)
  self.wpn = wpn
  self.velocity.velx = megautils.calcX(dir) * 5
  self.velocity.vely = megautils.calcY(dir) * 5
  self.side = self.velocity.velx < 0 and -1 or 1
  self.dink = false
  self.transform.x = x
  self.transform.y = y
  self.treble = t
end

function bassBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), self.treble and -1 or -0.5, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or
    (not self.treble and (collision.checkSolid(self) or #self:collisionTable(megautils.groups()["boss_door"]) ~= 0)) then
    megautils.remove(self, true)
  end
end

function bassBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x-1), math.round(self.transform.y-1))
end

megaBuster = basicEntity:extend()

weaponhandler.removeGroups["megaBuster"] = {"megaBuster", "megaChargedBuster"}

function megaBuster:new(x, y, dir, wpn)
  megaBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaBuster")
    self:addToGroup("megaBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
    mmSfx.play("buster")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = loader.get("buster_tex")
  self.quad = love.graphics.newQuad(0, 31, 8, 6, 133, 47)
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self:setLayer(1)
end

function megaBuster:recycle(x, y, dir, wpn)
  self.wpn = wpn
  self.side = dir
  self.velocity.velx = dir * 5
  self.velocity.vely = 0
  self.dink = false
  self.transform.x = x
  self.transform.y = y
end

function megaBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function megaBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megaSemiBuster = basicEntity:extend()

function megaSemiBuster:new(x, y, dir, wpn)
  megaSemiBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaBuster")
    self:addToGroup("megaBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.tex = loader.get("buster_tex")
  self.anim = anim8.newAnimation(loader.get("small_charge_grid")("1-2", 1), 1/12)
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  mmSfx.play("semi_charged")
  self:face(-self.side)
  self:setLayer(1)
end

function megaSemiBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function megaSemiBuster:update(dt)
  self.anim:update(1/60)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function megaSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-3)
end

megaChargedBuster = basicEntity:extend()

function megaChargedBuster:new(x, y, dir, wpn)
  megaChargedBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaChargedBuster")
    self:addToGroup("megaChargedBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.tex = loader.get("buster_tex")
  self.anim = anim8.newAnimation(loader.get("charge_grid")("1-4", 1), 1/20)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self.dink = false
  self.velocity = velocity()
  self.spd = 4
  self.velocity.velx = dir * 5.5
  self.side = dir
  self.wpn = wpn
  mmSfx.play("charged")
  self:face(-self.side)
  self:setLayer(1)
end

function megaChargedBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function megaChargedBuster:update(dt)
  self.anim:update(1/60)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -2, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function megaChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-8, math.round(self.transform.y)-3)
end

trebleBoost = entity:extend()

weaponhandler.removeGroups["trebleBoost"] = {"trebleBoost", "bassBuster"}

function trebleBoost:new(x, y, side, player, wpn)
  trebleBoost.super.new(self)
  self.added = function(self)
    self:addToGroup("trebleBoost")
    self:addToGroup("trebleBoost" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = loader.get("treble")
  self.c = "spawn"
  self.anims = {}
  self.anims["spawn"] = anim8.newAnimation(loader.get("treble_grid")(1, 1), 1)
  self.anims["spawn_land"] = anim8.newAnimation(loader.get("treble_grid")("2-3", 1, 2, 1), 1/20)
  self.anims["idle"] = anim8.newAnimation(loader.get("treble_grid")(4, 1), 1)
  self.anims["start"] = anim8.newAnimation(loader.get("treble_grid")("5-6", 1, "5-6", 1, "5-6", 1, "5-6", 1, "7-8", 1),
    1/16, "pauseAtEnd")
  self.side = side
  self.s = 0
  self.wpn = wpn
  self:setLayer(1)
  self.player = player
  self.blockCollision = true
  self.timer = 0
end

function trebleBoost:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function trebleBoost:update(dt)
  self.anims[self.c]:update(1/60)
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
    collision.doCollision(self)
    if self.ground then
      self.c = "spawn_land"
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims["spawn_land"].looped then
      self.c = "idle"
      self.s = 3
      mmSfx.play("start")
    end
  elseif self.s == 3 then
    megautils.autoFace(self, self.player, true)
    self.side = -self.side
    if not self.player.climb and self.player.ground and self.player:collision(self) then
      self.player:resetStates()
      self.player.canBeInvincible["treble"] = true
      self.player.treble = 1
      self.player.animations["trebleStart"]:gotoFrame(1)
      self.player.animations["trebleStart"]:resume()
      self.player.curAnim = "idle"
      self.player.velocity.velx = 0
      self.s = 4
      self.c = "start"
    end
  elseif self.s == 4 then
    if self.anims["start"].looped then
      self.s = 5
      self.player.curAnim = "trebleStart"
      self.player:face(self.player.side)
    end
  elseif self.s == 5 then
    self.timer = self.timer + 1
    if self.timer == 20 then
      megautils.remove(self, true)
    end
  end
  self:face(self.side)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function trebleBoost:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims[self.c]:draw(self.tex, math.round(self.transform.x-6), math.round(self.transform.y-12))
end

rushJet = entity:extend()

weaponhandler.removeGroups["rushJet"] = {"rushJet", "megaBuster", "bassBuster"}

function rushJet:new(x, y, side, player, wpn, skin)
  rushJet.super.new(self)
  self.added = function(self)
    self:addToGroup("rushJet")
    self:addToGroup("rushJet" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(27, 8)
  self.tex = loader.get(skin or "rush")
  self.c = "spawn"
  self.anims = {}
  self.anims["spawn"] = anim8.newAnimation(loader.get("rush_grid")(1, 1), 1)
  self.anims["spawn_land"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 1, 2, 1), 1/20)
  self.anims["jet"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 2), 1/8)
  self.side = side
  self.s = 0
  self.velocity = velocity()
  self.wpn = wpn
  self.timer = 0
  self.blockCollision = true
  self:setLayer(1)
  self.player = player
  self.playerOn = false
  self.exclusivelySolidFor = {self.player}
end

function rushJet:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushJet:update(dt)
  self.anims[self.c]:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.c = "spawn_land"
        self.s = 1
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.anims["spawn_land"].looped then
      mmSfx.play("start")
      self.c = "jet"
      self.s = 2
      self.isSolid = 2
    end
  elseif self.s == 2 then
    if self.player.ground and self.player:collision(self, 0, self.player.gravity < 0 and -1 or 1) and
      not self.player:collision(self) then
      self.s = 3
      self.velocity.velx = self.side
      self.player.canWalk["rj"] = false
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
      if self.player.ground and self.player:collision(self, 0, self.player.gravity < 0 and -1 or 1) and
      not self.player:collision(self) then
        self.s = 3
        self.velocity.velx = self.side
        self.player.canWalk["rj"] = false
        self.playerOn = true
      end
    end
    collision.doCollision(self)
    if self.playerOn and (not self.player.ground or
      not (self.player:collision(self, 0, self.player.gravity < 0 and -1 or 1) and
      not self.player:collision(self))) then
      self.player.canWalk["rj"] = true
      self.playerOn = false
    end
    if self.xcoll ~= 0 or
      (self.playerOn and collision.checkSolid(self.player, 0, self.player.gravity < 0 and 4 or -4)) then
      if self.playerOn then self.player.canWalk["rj"] = true end
      self.c = "spawn_land"
      self.anims["spawn_land"]:gotoFrame(1)
      self.s = 4
      self.isSolid = 0
      mmSfx.play("ascend")
    end
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      self.wpn.energy[self.wpn.currentSlot] = self.wpn.energy[self.wpn.currentSlot] - 1
    end
  elseif self.s == 4 then
    if self.anims["spawn_land"].looped then
      self.s = 5
      self.c = "spawn"
    end
  elseif self.s == 5 then
    self:moveBy(0, -8)
  end
  self:face(self.side)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function rushJet:removed()
  self.player.canWalk["rj"] = true
end

function rushJet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.c == "spawn" or self.c == "spawn_land" then
    self.anims[self.c]:draw(self.tex, math.round(self.transform.x-4), math.round(self.transform.y-16))
  else
    self.anims[self.c]:draw(self.tex, math.round(self.transform.x-4), math.round(self.transform.y-12))
  end
end

rushCoil = entity:extend()

weaponhandler.removeGroups["rushCoil"] = {"rushCoil", "megaBuster", "bassBuster", "rollBuster"}

function rushCoil:new(x, y, side, player, w, skin)
  rushCoil.super.new(self)
  self.proto = proto
  self.added = function(self)
    self:addToGroup("rushCoil")
    self:addToGroup("rushCoil" .. w.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-16
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = loader.get(skin or "rush")
  self.c = "spawn"
  self.anims = {}
  self.anims["spawn"] = anim8.newAnimation(loader.get("rush_grid")(1, 1), 1)
  self.anims["spawn_land"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 1, 2, 1), 1/20)
  self.anims["idle"] = anim8.newAnimation(loader.get("rush_grid")(4, 1, 1, 2), 1/8)
  self.anims["coil"] = anim8.newAnimation(loader.get("rush_grid")(4, 2), 1)
  self.side = side
  self.s = 0
  self.timer = 0
  self.velocity = velocity()
  self.wpn = w
  self.blockCollision = true
  self:setLayer(1)
  self.player = player
  self.gravity = 0.25
end

function rushCoil:grav()
  self.velocity.vely = math.clamp(self.velocity.vely+self.gravity, -7, 7)
end

function rushCoil:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushCoil:update(dt)
  self.anims[self.c]:update(1/60)
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
    collision.doCollision(self)
    if self.ground then
      self.c = "spawn_land"
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims["spawn_land"].looped then
      mmSfx.play("start")
      self.c = "idle"
      self.s = 3
    end
  elseif self.s == 3 then
    collision.doCollision(self)
    if not self.player.climb and self.player.velocity.vely > 0 and
      math.between(self.player.transform.x+self.player.collisionShape.w/2,
      self.transform.x, self.transform.x+self.collisionShape.w) and
      self.player:collision(self) then
      self.player.canStopJump["global"] = false
      self.player.velocity.vely = -7.5 * (self.player.gravity < 0 and -1 or 1)
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
      self.wpn.energy[self.wpn.currentSlot] = self.wpn.energy[self.wpn.currentSlot] - 7
    end
  elseif self.s == 4 then
    collision.doCollision(self)
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.s = 5
      self.c = "spawn_land"
      self.anims["spawn_land"]:gotoFrame(1)
      mmSfx.play("ascend")
    end
  elseif self.s == 5 then
    if self.anims["spawn_land"].looped then
      self.s = 6
      self.c = "spawn"
    end
  elseif self.s == 6 then
    self:moveBy(0, -8)
  end
  self:face(self.side)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function rushCoil:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims[self.c]:draw(self.tex, math.round(self.transform.x-8), math.round(self.transform.y-12))
end

stickWeapon = entity:extend()

weaponhandler.removeGroups["stickWeapon"] = {"stickWeapon"}

function stickWeapon:new(x, y, dir, wpn)
  stickWeapon.super.new(self)
  self.added = function(self)
    self:addToGroup("stickWeapon")
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = loader.get("stick_weapon")
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self:setLayer(1)
  mmSfx.play("buster")
end

function stickWeapon:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -8, 1)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function stickWeapon:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end