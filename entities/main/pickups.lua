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

pickup.autoClean = false

pickup.banIDs = {}

function pickup.isBanned(i, id, path)
  return pickup.banIDs[i] and table.icontains(pickup.banIDs[i], (path or "") .. "|" .. id)
end

function pickup:new(despawn, gd, fwp, id, path)
  pickup.super.new(self)
  self:setRectangleCollision(16, 16)
  self.timer = 0
  self.blockCollision.global = true
  self.fwp = fwp == nil or fwp
  self.gravDir = gd or 1
  self.mapID = id
  if self.mapID == -1 then
    self.mapID = nil
  end
  self.despawn = despawn == nil and self.mapID == nil or despawn
  self.path = path or ""
  self.removeWhenOutside = self.despawn
  self.autoCollision = {global = true}
  self.autoGravity = {global = true}
  self.noSlope = false
  self.maxFallingSpeed = 7
  if gd or self.fwp then
    self:setGravityMultiplier("flipWithPlayer",  megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  if not pickup.banIDs[self.__index] then
    pickup.banIDs[self.__index] = {}
  end
end

function pickup:added()
  self:addToGroup("removeOnTransition")
  if self.despawn then
    self:addToGroup("handledBySections")
  end
end

function pickup:grav()
  self.velY = math.clamp(self.velY + self.gravity, -self.maxFallingSpeed, self.maxFallingSpeed)
end

function pickup:taken(p) end

function pickup:afterUpdate()
  if self.fwp then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  if checkFalse(self.autoGravity) then
    collision.doGrav(self, self.noSlope)
  end
  if checkFalse(self.autoCollision) then
    collision.doCollision(self, self.noSlope)
  end
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      self:taken(p)
      if not self.despawn and self.mapID and
        not pickup.isBanned(self.__index, tostring(self.mapID), self.path) then
        pickup.banIDs[self.__index][#pickup.banIDs[self.__index]+1] = self.path .. "|" .. tostring(self.mapID)
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

smallHealth.autoClean = false

mapEntity.register("smallHealth", function(v, map)
  megautils.add(spawner, v.x+4, v.y, 8, 6, function()
      return not pickup.isBanned(smallHealth, v.id, map.path)
    end, smallHealth, v.x+4, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function smallHealth:new(x, y, despawn, gd, fwp, id, path)
  smallHealth.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(8, 6)
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.anim = animation("smallHealthGrid", {"1-2", 1}, 1/8)
end

function smallHealth:taken(p)
  self:interact(p, 2, true)
end

function smallHealth:update()
  smallHealth.super.update(self)
  self.anim:update(1/60)
end

function smallHealth:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  self.t:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.tOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.tOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  end
end

health = pickup:extend()

health.autoClean = false

mapEntity.register("health", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 14, function()
      return not pickup.isBanned(health, v.id, map.path)
    end, health, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function health:new(x, y, despawn, gd, fwp, id, path)
  health.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 14)
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.anim = animation("healthGrid", {"1-2", 1}, 1/8)
end

function health:taken(p)
  self:interact(p, 10, true)
end

function health:update()
  health.super.update(self)
  self.anim:update(1/60)
end

function health:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  self.t:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.tOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.tOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  end
end

smallEnergy = pickup:extend()

smallEnergy.autoClean = false

mapEntity.register("smallEnergy", function(v, map)
  megautils.add(spawner, v.x+4, v.y, 8, 6, function()
      return not pickup.isBanned(smallEnergy, v.id, map.path)
    end, smallEnergy, v.x+4, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function smallEnergy:new(x, y, despawn, gd, fwp, id, path)
  smallEnergy.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(8, 6)
  self.anim = animation("smallEnergyGrid", {"1-2", 1}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function smallEnergy:taken(p)
  megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 2)
end

function smallEnergy:update()
  smallEnergy.super.update(self)
  self.anim:update(1/60)
end

function smallEnergy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  end
end

energy = pickup:extend()

energy.autoClean = false

mapEntity.register("energy", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 10, function()
      return not pickup.isBanned(energy, v.id, map.path)
    end, energy, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function energy:new(x, y, despawn, gd, fwp, id, path)
  energy.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 10)
  self.anim = animation("energyGrid", {"1-2", 1}, 1/8)
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
end

function energy:taken(p)
  megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 10)
end

function energy:update()
  energy.super.update(self)
  self.anim:update(1/60)
end

function energy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  end
end

life = pickup:extend()

life.autoClean = false

mapEntity.register("life", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickup.isBanned(life, v.id, map.path)
    end, life, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function life:new(x, y, despawn, gd, fwp, id, path)
  life.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
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
  local ox, oy = math.floor(self.collisionShape.w/2), self.collisionShape.h
  
  if megaMan.mainPlayer then
    local skin = megaMan.getSkin(megaMan.mainPlayer.player)
    
    local fy = self.gravity < 0
    
    love.graphics.setColor(1, 1, 1, 1)
    skin.texture:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    skin.outline:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    skin.one:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    skin.two:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
  else
    local skin = megaMan.getSkin(1)
    
    local fy = self.gravity < 0
    
    love.graphics.setColor(1, 1, 1, 1)
    skin.texture:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(0, 0, 0, 1)
    skin.outline:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    skin.one:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(0, 232/255, 216/255, 1)
    skin.two:draw(self.quad, math.floor(self.x)+ox, math.floor(self.y)+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
  end
end

eTank = pickup:extend()

eTank.autoClean = false

mapEntity.register("eTank", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickup.isBanned(eTank, v.id, map.path)
    end, eTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

eTank.banIds = {}

function eTank:new(x, y, despawn, gd, fwp, id, path)
  eTank.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 15)
  self.anim = animation("tankGrid", {1, 1, 2, 2}, 1/8)
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
  self.anim:update(1/60)
end

function eTank:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -1
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  end
end

wTank = pickup:extend()

wTank.autoClean = false

mapEntity.register("wTank", function(v, map)
  megautils.add(spawner, v.x, v.y, 16, 15, function()
      return not pickup.isBanned(wTank, v.id, map.path)
    end, wTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function wTank:new(x, y, despawn, gd, fwp, id, path)
  wTank.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 15)
  self.anim = animation("tankGrid", {2, 2, 2, 1}, 1/8)
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
  self.anim:update(1/60)
end

function wTank:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -1
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, math.floor(self.x), math.floor(self.y)+offy)
  end
end

megautils.resetGameObjectsFuncs.pickups = {func=function()
    pickup.banIDs = {}
  end, autoClean=false}