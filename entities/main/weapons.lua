megaBuster = entity:extend()

function megaBuster:new(x, y, dir, wpn)
  megaBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaBuster")
    self:addToGroup("megaBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
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
  mmSfx.play("buster")
end

function megaBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) or (self.wpn.currentSlot ~= 0 and self.wpn.currentSlot ~= 9
    and self.wpn.currentSlot ~= 10) then
    megautils.remove(self, true)
  end
end

function megaBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megaSemiBuster = entity:extend()

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
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) or self.wpn.currentSlot ~= 0 then
    megautils.remove(self, true)
  end
end

function megaSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-3)
end

megaChargedBuster = entity:extend()

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
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) or self.wpn.currentSlot ~= 0 then
    megautils.remove(self, true)
  end
end

function megaChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-8, math.round(self.transform.y)-3)
end

rushJet = entity:extend()

function rushJet:new(x, y, side, w)
  rushJet.super.new(self)
  self.added = function(self)
    self:addToGroup("rush")
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(27, 8)
  self.tex = loader.get("rush")
  self.c = "spawn"
  self.anims = {}
  self.anims["spawn"] = anim8.newAnimation(loader.get("rush_grid")(1, 1), 1)
  self.anims["spawn_land"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 1, 2, 1), 1/20)
  self.anims["jet"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 2), 1/8)
  self.side = side
  self.s = 0
  self.velocity = velocity()
  self.wpn = w
  self.timer = 0
  self:setLayer(2)
  self:setUpdateLayer(-1)
end

function rushJet:solid(x, y, d)
  return #self:collisionTable(megautils.groups()["solid"], x, y) ~= 0 or
    ((d==nil and true or d) and #self:collisionTable(megautils.groups()["death"], x, y)) ~= 0 or
    #oneway.collisionTable(self, megautils.groups()["oneway"], x, y) ~= 0 or
    #self:collisionTable(megautils.groups()["movingSolid"], x, y) ~= 0
end

function rushJet:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushJet:phys()
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
end

function rushJet:checkGround()
  local tmp = table.merge({self:collisionTable(megautils.groups()["solid"], 0, 1),
    self:collisionTable(megautils.groups()["death"], 0, 1),
    oneway.collisionTable(self, megautils.groups()["oneway"], 0, 1),
    self:collisionTable(megautils.groups()["movingSolid"], 0, 1)})
  local result = false
  for k, v in ipairs(tmp) do
    if self.transform.y == v.transform.y - self.collisionShape.h then
      result = true
      break
    end
  end
  return result
end

function rushJet:update(dt)
  self.anims[self.c]:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not (self:solid(0, 0) or #self:collisionTable(megautils.groups()["slope"]) ~= 0) then
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
    end
  elseif self.s == 2 then
    for i=1, playerCount do
      local player = globals.allPlayers[i]
      if oneway.collision(player, self, player.velocity.velx, player.velocity.vely+1) then
        self.s = 3
        self.velocity.velx = self.side
        self.user = player
        self.user.canWalk = false
        break
      end
    end
    self:moveBy(self.velocity.velx, self.velocity.vely)
    movingOneway.shift(self, megautils.groups()["carry"])
  elseif self.s == 3 then
    if self.user then
      if control.upDown[self.user.player] then
        self.velocity.vely = -1
      elseif control.downDown[self.user.player] and not (self:checkGround() or self.onSlope) then
        self.velocity.vely = 1
      else
        self.velocity.vely = 0
      end
    else
      self.velocity.vely = 0
      for i=1, playerCount do
        local player = globals.allPlayers[i]
        if oneway.collision(player, self, player.velocity.velx, player.velocity.vely+1) then
          self.velocity.velx = self.side
          self.user = player
          self.user.canWalk = false
          break
        end
      end
    end
    local dx, dy = self.transform.x, self.transform.y
    self:phys()
    local lvx, lvy = self.velocity.velx, self.velocity.vely
    self.velocity.velx = self.transform.x - dx
    self.velocity.vely = self.transform.y - dy
    movingOneway.shift(self, megautils.groups()["carry"])
    self.velocity.velx = lvx
    self.velocity.vely = lvy
    if self.user and not self.user:collision(self, 0, 1) then
      self.user.canWalk = true
      self.user = nil
    end
    if self.collisionChecks.leftWall or self.collisionChecks.rightWall or
      (self.user and self:solid(0, -self.user.collisionShape.h-4)) then
      if self.user then self.user.canWalk = true self.user.onMovingFloor = false end
      self.c = "spawn_land"
      self.anims["spawn_land"]:gotoFrame(1)
      self.s = 4
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
  if megautils.outside(self) or self.wpn.currentSlot ~= 10 then
    megautils.remove(self, true)
  end
end

function rushJet:removed()
  if self.user then
    self.user.canWalk = true
  end
  movingOneway.clean(self)
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

function rushCoil:new(x, y, side, w)
  rushCoil.super.new(self)
  self.added = function(self)
    self:addToGroup("rush")
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-16
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = loader.get("rush")
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
  self:setLayer(2)
end

function rushCoil:solid(x, y, d)
  return #self:collisionTable(megautils.groups()["solid"], x, y) ~= 0 or
    ((d==nil and true or d) and #self:collisionTable(megautils.groups()["death"], x, y)) ~= 0 or
    #oneway.collisionTable(self, megautils.groups()["oneway"], x, y) ~= 0 or
    #self:collisionTable(megautils.groups()["movingSolid"], x, y) ~= 0
end

function rushCoil:phys()
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
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
      if not (self:solid(0, 0) or #self:collisionTable(megautils.groups()["slope"]) ~= 0) then
        self.s = 1
        self.velocity.vely = 8
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    self:phys()
    if self.collisionChecks.ground then
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
    for i=1, playerCount do
      local player = globals.allPlayers[i]
      if not player.climb and player.velocity.vely > 0 and
        math.between(player.transform.x+player.collisionShape.w/2, self.transform.x, self.transform.x+self.collisionShape.w) and
        player:collision(self) then
        player.canStopJump = false
        player.velocity.vely = -10.5
        player.step = false
        player.stepTime = 0
        player.ground = false
        player.currentLadder = nil
        player.wallJumping = false
        player.dashJump = false
        if player.slide then
          local lh = self.collisionShape.h
          player:regBox()
          player.transform.y = player.transform.y - (player.collisionShape.h - lh)
          player.slide = false
        end
        self.s = 4
        self.c = "coil"
        self.wpn.energy[self.wpn.currentSlot] = self.wpn.energy[self.wpn.currentSlot] - 7
        break
      end
    end
  elseif self.s == 4 then
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
  if megautils.outside(self) or self.wpn.currentSlot ~= 9 then
    megautils.remove(self, true)
  end
end

function rushCoil:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims[self.c]:draw(self.tex, math.round(self.transform.x-8), math.round(self.transform.y-12))
end

stickWeapon = entity:extend()

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
  if megautils.outside(self) or self.wpn.currentSlot ~= 1 then
    megautils.remove(self, true)
  end
end

function stickWeapon:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end