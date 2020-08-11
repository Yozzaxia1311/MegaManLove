megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource("assets/misc/particlesOutline.png", "particlesOutline", true)
megautils.loadResource("assets/misc/particlesOne.png", "particlesOne", true)
megautils.loadResource("assets/misc/particlesTwo.png", "particlesTwo", true)
megautils.loadResource(24, 0, 8, 8, "smallHealthGrid", true)
megautils.loadResource(40, 0, 16, 16, "healthGrid", true)
megautils.loadResource(72, 0, 8, 8, "smallEnergyGrid", true)
megautils.loadResource(88, 0, 16, 12, "energyGrid", true)
megautils.loadResource(72, 12, 16, 16, "tankGrid", true)

pickupEntity = entity:extend()

pickupEntity.autoClean = false

pickupEntity.banIDs = {}

function pickupEntity.isBanned(i, id, path)
  return pickupEntity.banIDs[i] and table.contains(pickupEntity.banIDs[i], (path or "") .. "|" .. id)
end

function pickupEntity:new(despawn, gd, fwp, id, path)
  pickupEntity.super.new(self)
  self:setRectangleCollision(16, 16)
  self.despawn = despawn == nil and self.id == nil or despawn
  self.timer = 0
  self.blockCollision.global = true
  self.fwp = fwp
  self.gravDir = gd or 1
  self.id = id
  if self.id == -1 then
    self.id = nil
  end
  self.path = path or ""
  self.removeWhenOutside = self.despawn
  self.autoCollision = true
  self.autoGravity = true
  if gd or self.fwp then
    self:setGravityMultiplier("flipWithPlayer",  megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  if not pickupEntity.banIDs[self.__index] then
    pickupEntity.banIDs[self.__index] = {}
  end
end

function pickupEntity:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("collision")
  if self.despawn then
    self:addToGroup("handledBySections")
  end
end

function pickupEntity:grav()
  if self.ground then return end
  self.velocity:clampY(7)
  self.velocity.vely = self.velocity.vely + self.gravity
end

function pickupEntity:taken(p) end

function pickupEntity:afterUpdate()
  if self.fwp then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  if self.autoGravity then
    collision.doGrav(self)
  end
  if self.autoCollision then
    collision.doCollision(self)
  end
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      self:taken(p)
      if not self.despawn and self.id and
        not table.contains(pickupEntity.banIDs[self.__index], self.path .. "|" .. self.id) then
        pickupEntity.banIDs[self.__index][#pickupEntity.banIDs[self.__index]+1] = self.path .. "|" .. self.id
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

smallHealth = pickupEntity:extend()

smallHealth.autoClean = false

mapEntity.register("smallHealth", function(v, map)
  megautils.add(spawner, v.x, v.y, 8, 6, function()
      return not pickupEntity.isBanned(smallHealth, v.id, map.path)
    end, smallHealth, v.x+10, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function smallHealth:new(x, y, despawn, gd, fwp, id, path)
  smallHealth.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(8, 6)
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.anim = megautils.newAnimation("smallHealthGrid", {"1-2", 1}, 1/8)
end

function smallHealth:taken(p)
  self:interact(p, 2, true)
end

function smallHealth:update()
  smallHealth.super.update(self)
  self.anim:update(defaultFramerate)
end

function smallHealth:draw()
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

health = pickupEntity:extend()

health.autoClean = false

mapEntity.register("health", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 14, function()
      return not pickupEntity.isBanned(health, v.id, map.path)
    end, health, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function health:new(x, y, despawn, gd, fwp, id, path)
  health.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(16, 14)
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.anim = megautils.newAnimation("healthGrid", {"1-2", 1}, 1/8)
end

function health:taken(p)
  self:interact(p, 10, true)
end

function health:update()
  health.super.update(self)
  self.anim:update(defaultFramerate)
end

function health:draw()
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

smallEnergy = pickupEntity:extend()

smallEnergy.autoClean = false

mapEntity.register("smallEnergy", function(v, map)
  megautils.add(spawner, v.x, v.y, 8, 6, function()
      return not pickupEntity.isBanned(smallEnergy, v.id, map.path)
    end, smallEnergy, v.x, v.y+10, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function smallEnergy:new(x, y, despawn, gd, fwp, id, path)
  smallEnergy.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
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

energy = pickupEntity:extend()

energy.autoClean = false

mapEntity.register("energy", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 10, function()
      return not pickupEntity.isBanned(energy, v.id, map.path)
    end, energy, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function energy:new(x, y, despawn, gd, fwp, id, path)
  energy.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
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

life = pickupEntity:extend()

life.autoClean = false

mapEntity.register("life", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickupEntity.isBanned(life, v.id, map.path)
    end, life, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function life:new(x, y, despawn, gd, fwp, id, path)
  life.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(16, 15)
  self.quad = quad(203, 398, 63, 62)
end

function life:taken(p)
  if megautils.hasInfiniteLives() then
    self:interact(p, 9999, true)
  else
    megautils.setLives(math.min(megautils.getLives()+1, maxLives))
    megautils.playSoundFromFile("assets/sfx/life.ogg")
  end
end

function life:draw()
  local ox, oy = 0, 0
  
  if megaMan.mainPlayer then
    local skin = megaMan.getSkin(megaMan.mainPlayer.player)
    
    self.quad.flipY = self.gravity < 0
    
    love.graphics.setColor(1, 1, 1, 1)
    self.quad:draw(skin.texture, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.quad:draw(skin.outline, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.quad:draw(skin.one, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.quad:draw(skin.two, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
  else
    local skin = megaMan.getSkin(1)
    
    self.quad.flipY = self.gravity < 0
    
    love.graphics.setColor(1, 1, 1, 1)
    self.quad:draw(skin.texture, math.round(self.transform.x), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
    love.graphics.setColor(0, 0, 0, 1)
    self.quad:draw(skin.outline, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.quad:draw(skin.one, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.quad:draw(skin.two, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, 1, 33, 39)
  end
end

eTank = pickupEntity:extend()

eTank.autoClean = false

mapEntity.register("eTank", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickupEntity.isBanned(eTank, v.id, map.path)
    end, eTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

eTank.banIds = {}

function eTank:new(x, y, despawn, gd, fwp, id, path)
  eTank.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(16, 15)
  self.anim = megautils.newAnimation("tankGrid", {1, 1, 2, 2}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function eTank:taken(p)
  megautils.setETanks(math.min(megautils.getETanks()+1, maxETanks))
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

wTank = pickupEntity:extend()

wTank.autoClean = false

mapEntity.register("wTank", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickupEntity.isBanned(wTank, v.id, map.path)
    end, wTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function wTank:new(x, y, despawn, gd, fwp, id, path)
  wTank.super.new(self, despawn, gd, fwp, id, path)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(16, 15)
  self.anim = megautils.newAnimation("tankGrid", {2, 2, 2, 1}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function wTank:taken(p)
  megautils.setWTanks(math.min(megautils.getWTanks()+1, maxWTanks))
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
  pickupEntity.banIDs = {}
end