loader.load("assets/misc/particles.png", true)
loader.load("assets/misc/particlesOutline.png", true)
loader.load("assets/misc/particlesOne.png", true)
loader.load("assets/misc/particlesTwo.png", true)
loader.load("assets/misc/smallHealth.anim", true)
loader.load("assets/misc/health.anim", true)
loader.load("assets/misc/smallEnergy.anim", true)
loader.load("assets/misc/energy.anim", true)
loader.load("assets/misc/tanks.animset", true)

pickUp = entity:extend()

pickUp.autoClean = false

pickUp.banIDs = {}

function pickUp.isBanned(i, id, path)
  return pickUp.banIDs[i] and table.icontains(pickUp.banIDs[i], (path or "") .. "|" .. id)
end

function pickUp:new(despawn, gd, fwp, id, path)
  self.cancelInsertEntity = true
  pickUp.super.new(self)
  self:setRectangleCollision(16, 16)
  self.timer = 0
  self.blockCollision.global = true
  self.fwp = fwp == nil or fwp
  self.gravDir = gd or 1
  self.mapID = id
  self.despawn = despawn == nil and self.mapID == nil or despawn
  self.path = path or ""
  self.removeWhenOutside = self.despawn
  self.noSlope = false
  self.maxFallingSpeed = 7
  self.autoGravity.global = true
  if gd or self.fwp then
    self:setGravityMultiplier("flipWithPlayer",  megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  if not pickUp.banIDs[self.__index] then
    pickUp.banIDs[self.__index] = {}
  end

  if not self.cancelInsertPickup and #basicEntity.insertVars ~= 0 then
    for k, v in pairs(basicEntity.insertVars[#basicEntity.insertVars]) do
      self[k] = v ~= nil and v or self[k]
    end
    basicEntity.insertVars[#basicEntity.insertVars] = nil
  end
end

function pickUp:added()
  self:addToGroup("removeOnTransition")
  if self.despawn then
    self:addToGroup("handledBySections")
  end
end

function pickUp:grav()
  self.velY = math.clamp(self.velY + self.gravity, -self.maxFallingSpeed, self.maxFallingSpeed)
end

function pickUp:taken(p) end

function pickUp:_afterUpdate(dt)
  if self.fwp then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer and megaMan.mainPlayer.gravityMultipliers.gravityFlip or self.gravDir)
  end
  for i=1, megaMan.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      self:taken(p)
      if not self.despawn and self.mapID and
        not pickUp.isBanned(self.__index, tostring(self.mapID), self.path) then
        pickUp.banIDs[self.__index][#pickUp.banIDs[self.__index]+1] = self.path .. "|" .. tostring(self.mapID)
      end
      entities.remove(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 or (self.removeWhenOutside and megautils.outside(self)) then
      entities.remove(self)
    end
  end
  
  self:afterUpdate(dt)
end

smallHealth = pickUp:extend()

smallHealth.autoClean = false

mapEntity.register("smallHealth", function(v, map)
  entities.add(spawner, v.x+4, v.y+4, 8, 6, function()
      return not pickUp.isBanned(smallHealth, v.id, map.path)
    end, smallHealth, v.x+4, v.y+4, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function smallHealth:new(x, y, despawn, gd, fwp, id, path)
  smallHealth.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(8, 6)
  self.t = loader.get("assets/misc/particles.png")
  self.tOutline = loader.get("assets/misc/particlesOutline.png")
  self.anim = animation("assets/misc/smallHealth.anim")
end

function smallHealth:taken(p)
  self:interact(p, 2, true)
end

function smallHealth:update()
  self.anim:update(1/60)
end

function smallHealth:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  self.t:draw(self.anim, self.x, self.y+offy)
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.tOutline:draw(self.anim, self.x, self.y+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.tOutline:draw(self.anim, self.x, self.y+offy)
  end
end

health = pickUp:extend()

health.autoClean = false

mapEntity.register("health", function(v, map)
  entities.add(spawner, v.x, v.y, 16, 14, function()
      return not pickUp.isBanned(health, v.id, map.path)
    end, health, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function health:new(x, y, despawn, gd, fwp, id, path)
  health.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 14)
  self.t = loader.get("assets/misc/particles.png")
  self.tOutline = loader.get("assets/misc/particlesOutline.png")
  self.anim = animation("assets/misc/health.anim")
end

function health:taken(p)
  self:interact(p, 10, true)
end

function health:update()
  self.anim:update(1/60)
end

function health:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  self.t:draw(self.anim, self.x, self.y+offy)
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.tOutline:draw(self.anim, self.x, self.y+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.tOutline:draw(self.anim, self.x, self.y+offy)
  end
end

smallEnergy = pickUp:extend()

smallEnergy.autoClean = false

mapEntity.register("smallEnergy", function(v, map)
  entities.add(spawner, v.x+4, v.y+4, 8, 6, function()
      return not pickUp.isBanned(smallEnergy, v.id, map.path)
    end, smallEnergy, v.x+4, v.y+4, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function smallEnergy:new(x, y, despawn, gd, fwp, id, path)
  smallEnergy.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(8, 6)
  self.anim = animation("assets/misc/smallEnergy.anim")
  self.texOutline = loader.get("assets/misc/particlesOutline.png")
  self.texOne = loader.get("assets/misc/particlesOne.png")
  self.texTwo = loader.get("assets/misc/particlesTwo.png")
end

function smallEnergy:taken(p)
  megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 2)
end

function smallEnergy:update()
  self.anim:update(1/60)
end

function smallEnergy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  end
end

energy = pickUp:extend()

energy.autoClean = false

mapEntity.register("energy", function(v, map)
  entities.add(spawner, v.x, v.y, 16, 10, function()
      return not pickUp.isBanned(energy, v.id, map.path)
    end, energy, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function energy:new(x, y, despawn, gd, fwp, id, path)
  energy.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 10)
  self.anim = animation("assets/misc/energy.anim")
  self.texOutline = loader.get("assets/misc/particlesOutline.png")
  self.texOne = loader.get("assets/misc/particlesOne.png")
  self.texTwo = loader.get("assets/misc/particlesTwo.png")
end

function energy:taken(p)
  megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 10)
end

function energy:update()
  self.anim:update(1/60)
end

function energy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -2
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  end
end

life = pickUp:extend()

life.autoClean = false

mapEntity.register("life", function(v, map)
  entities.add(spawner, v.x, v.y, 16, 15, function()
      return not pickUp.isBanned(life, v.id, map.path)
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
    sfx.playFromFile("assets/sfx/life.ogg")
  end
end

function life:draw()
  local ox, oy = math.floor(self.collisionShape.w/2), self.collisionShape.h
  
  if megaMan.mainPlayer then
    local skin = megaMan.getSkin(megaMan.mainPlayer.player)
    
    local fy = self.gravity < 0
    
    love.graphics.setColor(1, 1, 1, 1)
    skin.texture:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    skin.outline:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    skin.one:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    skin.two:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
  else
    local skin = megaMan.getSkin(1)
    
    local fy = self.gravity < 0
    
    love.graphics.setColor(1, 1, 1, 1)
    skin.texture:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(0, 0, 0, 1)
    skin.outline:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    skin.one:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
    love.graphics.setColor(0, 232/255, 216/255, 1)
    skin.two:draw(self.quad, self.x+ox, self.y+oy, 0, 1, 1, 31, 37, nil, nil, nil, fy)
  end
end

eTank = pickUp:extend()

eTank.autoClean = false

mapEntity.register("eTank", function(v, map)
  entities.add(spawner, v.x, v.y, 16, 15, function()
      return not pickUp.isBanned(eTank, v.id, map.path)
    end, eTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

eTank.banIds = {}

function eTank:new(x, y, despawn, gd, fwp, id, path)
  eTank.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 15)
  self.anim = animationSet("assets/misc/tanks.animset")
  self.anim:set("eTank")
  self.texOutline = loader.get("assets/misc/particlesOutline.png")
  self.texOne = loader.get("assets/misc/particlesOne.png")
  self.texTwo = loader.get("assets/misc/particlesTwo.png")
end

function eTank:taken(p)
  megautils.setETanks(math.min(megautils.getETanks()+1, maxETanks))
  sfx.playFromFile("assets/sfx/life.ogg")
end

function eTank:update()
  self.anim:update(1/60)
end

function eTank:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -1
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  end
end

wTank = pickUp:extend()

wTank.autoClean = false

mapEntity.register("wTank", function(v, map)
  entities.add(spawner, v.x, v.y, 16, 15, function()
      return not pickUp.isBanned(wTank, v.id, map.path)
    end, wTank, v.x, v.y, false, v.properties.gravDir, v.properties.flipWithPlayer, v.id, map.path)
end, 0, true)

function wTank:new(x, y, despawn, gd, fwp, id, path)
  wTank.super.new(self, despawn, gd, fwp, id, path)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(16, 15)
  self.anim = animationSet("assets/misc/tanks.animset")
  self.anim:set("wTank")
  self.texOutline = loader.get("assets/misc/particlesOutline.png")
  self.texOne = loader.get("assets/misc/particlesOne.png")
  self.texTwo = loader.get("assets/misc/particlesTwo.png")
end

function wTank:taken(p)
  megautils.setWTanks(math.min(megautils.getWTanks()+1, maxWTanks))
  sfx.playFromFile("assets/sfx/life.ogg")
end

function wTank:update()
  self.anim:update(1/60)
end

function wTank:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = -1
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.texTwo:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 0, 0, 1)
    self.texOutline:draw(self.anim, self.x, self.y+offy)
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.texOne:draw(self.anim, self.x, self.y+offy)
  end
end

megautils.resetGameObjectsFuncs.pickups = {func=function()
    pickUp.banIDs = {}
  end, autoClean=false}
