megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource("assets/misc/particlesOutline.png", "particlesOutline", true)
megautils.loadResource("assets/misc/particlesOne.png", "particlesOne", true)
megautils.loadResource("assets/misc/particlesTwo.png", "particlesTwo", true)
megautils.loadResource(24, 0, 8, 8, "smallHealthGrid", true)
megautils.loadResource(40, 0, 16, 16, "healthGrid", true)
megautils.loadResource(72, 0, 8, 8, "smallEnergyGrid", true)
megautils.loadResource(88, 0, 16, 12, "energyGrid", true)
megautils.loadResource(72, 12, 16, 16, "tankGrid", true)

pickup = entity:extend()

pickup.banIDs = {}

function pickup.isBanned(i, id)
  return pickup.banIDs[i] and table.contains(pickup.banIDs[i], id)
end

function pickup:new(despawn, gd, fwp, id)
  pickup.super.new(self)
  self:setRectangleCollision(16, 16)
  self.despawn = despawn == nil and self.id == nil or despawn
  self.timer = 0
  self.blockCollision = true
  self.fwp = fwp
  self.gravDir = gd or 1
  self.id = id
  if self.id == -1 then
    self.id = nil
  end
  self.removeWhenOutside = self.despawn
  if gd or self.fwp then
    self:setGravityMultiplier("flipWithPlayer",  megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  if not pickup.banIDs[self.__index] then
    pickup.banIDs[self.__index] = {}
  end
end

function pickup:grav()
  if self.ground then return end
  self.velocity:clampY(7)
  self.velocity.vely = self.velocity.vely + self.gravity
end

function pickup:taken(p) end

function pickup:update(dt)
  self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      self:taken(p)
      if not self.despawn and self.id and not table.contains(pickup.banIDs[self.__index], self.id) then
        pickup.banIDs[self.__index][#pickup.banIDs[self.__index]+1] = self.id
      end
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 or (self.removeWhenOutside and megautils.outside(self)) then
      megautils.removeq(self)
    end
  end
end

smallHealth = pickup:extend()

addObjects.register("smallHealth", function(v)
  megautils.add(spawner, v.x, v.y, 8, 6, function()
      return not pickup.isBanned(smallHealth, v.id)
    end, smallHealth, v.x+10, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

function smallHealth:new(x, y, despawn, gd, fwp, id)
  smallHealth.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.anim = megautils.newAnimation("smallHealthGrid", {"1-2", 1}, 1/8)
end

function smallHealth:taken(p)
  p:addHealth(2)
end

function smallHealth:update()
  smallHealth.super.update(self)
  self.anim:update(defaultFramerate)
end

function smallHealth:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y)+offy)
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
  end
end

health = pickup:extend()

addObjects.register("health", function(v)
  megautils.add(spawner, v.x, v.y, 16, 14, function()
      return not pickup.isBanned(health, v.id)
    end, health, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

function health:new(x, y, despawn, gd, fwp, id)
  health.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 14)
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.anim = megautils.newAnimation("healthGrid", {"1-2", 1}, 1/8)
end

function health:taken(p)
  p:addHealth(10)
end

function health:update()
  health.super.update(self)
  self.anim:update(defaultFramerate)
end

function health:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y)+offy)
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
  end
end

smallEnergy = pickup:extend()

addObjects.register("smallEnergy", function(v)
  megautils.add(spawner, v.x, v.y, 8, 6, function()
      return not pickup.isBanned(smallEnergy, v.id)
    end, smallEnergy, v.x, v.y+10, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

function smallEnergy:new(x, y, despawn, gd, fwp, id)
  smallEnergy.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = megautils.newAnimation("smallEnergyGrid", {"1-2", 1}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function smallEnergy:taken(p)
  megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 2)
end

function smallEnergy:update()
  smallEnergy.super.update(self)
  self.anim:update(defaultFramerate)
end

function smallEnergy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  end
end

energy = pickup:extend()

addObjects.register("energy", function(v)
  megautils.add(spawner, v.x, v.y, 16, 10, function()
      return not pickup.isBanned(energy, v.id)
    end, energy, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

function energy:new(x, y, despawn, gd, fwp, id)
  energy.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.anim = megautils.newAnimation("energyGrid", {"1-2", 1}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function energy:taken(p)
  megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 10)
end

function energy:update()
  energy.super.update(self)
  self.anim:update(defaultFramerate)
end

function energy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  end
end

life = pickup:extend()

addObjects.register("life", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickup.isBanned(life, v.id)
    end, life, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

function life:new(x, y, despawn, gd, fwp, id)
  life.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.tex = megautils.getResource("particles")
  self.texTwo = megautils.getResource("particlesTwo")
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.quad = {}
  self.quad.mega = quad(104, 12, 16, 16, 128, 98)
  self.quad.proto = quad(56, 31, 16, 15, 128, 98)
  self.quad.bass = quad(54, 16, 18, 15, 128, 98)
  self.quad.roll = quad(38, 16, 16, 16, 128, 98)
end

function life:taken(p)
  if megautils.hasInfiniteLives() then
    p:addHealth(9999)
  else
    globals.lives = math.min(globals.lives+1, maxLives)
    megautils.playSoundFromFile("assets/sfx/life.ogg")
  end
end

function life:draw()
  local ox, oy = 0, 0
  if self.gravity < 0 then
    oy = -1
  end
  if megaMan.mainPlayer then
    if megaMan.mainPlayer.playerName == "proto" then
      --oy = 1
      if self.gravity < 0 then
        oy = -2
      end
    elseif megaMan.mainPlayer.playerName == "bass" then
      ox = -1
      if self.gravity < 0 then
        oy = -2
      end
    end
    self.quad[megaMan.mainPlayer.playerName].flipY = self.gravity < 0
    love.graphics.setColor(1, 1, 1, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.tex,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.texTwo,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.texOutline,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.texOne,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
  else
    if megautils.getPlayer(1) == "proto" then
      --oy = 1
      if self.gravity < 0 then
        oy = -2
      end
    elseif megautils.getPlayer(1) == "bass" then
      ox = -1
      --oy = 1
      if self.gravity < 0 then
        oy = -2
      end
    end
    local p1 = megautils.getPlayer(1)
    self.quad[p1].flipY = self.gravity < 0
    love.graphics.setColor(1, 1, 1, 1)
    self.quad[p1]:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)+oy)
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.quad[p1]:draw(self.texTwo, math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
    love.graphics.setColor(0, 0, 0, 1)
    self.quad[p1]:draw(self.texOutline, math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.quad[p1]:draw(self.texOne, math.round(self.transform.x+ox), math.round(self.transform.y)+oy)
  end
end

eTank = pickup:extend()

addObjects.register("eTank", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickup.isBanned(eTank, v.id)
    end, eTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

eTank.banIds = {}

function eTank:new(x, y, despawn, gd, fwp, id)
  eTank.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = megautils.newAnimation("tankGrid", {1, 1, 2, 2}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function eTank:taken(p)
  globals.eTanks = math.min(globals.eTanks+1, maxETanks)
  megautils.playSoundFromFile("assets/sfx/life.ogg")
end

function eTank:update()
  eTank.super.update(self)
  self.anim:update(defaultFramerate)
end

function eTank:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -1
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  end
end

wTank = pickup:extend()

addObjects.register("wTank", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickup.isBanned(wTank, v.id)
    end, wTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id)
end, 0, true)

function wTank:new(x, y, despawn, gd, fwp, id)
  wTank.super.new(self, despawn, gd, fwp, id)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = megautils.newAnimation("tankGrid", {2, 2, 2, 1}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function wTank:taken(p)
  globals.wTanks = math.min(globals.wTanks+1, maxWTanks)
  megautils.playSoundFromFile("assets/sfx/life.ogg")
end

function wTank:update(dt)
  wTank.super.update(self)
  self.anim:update(defaultFramerate)
end

function wTank:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -1
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy)
  end
end

megautils.resetGameObjectsFuncs.pickups = function()
  pickup.banIDs = {}
end