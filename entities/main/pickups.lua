megautils.loadResource("assets/misc/particles.png", "particles", true)
megautils.loadResource("assets/misc/particlesOutline.png", "particlesOutline", true)
megautils.loadResource("assets/misc/particlesOne.png", "particlesOne", true)
megautils.loadResource("assets/misc/particlesTwo.png", "particlesTwo", true)
megautils.loadResource(24, 0, 8, 8, "smallHealthGrid", true)
megautils.loadResource(40, 0, 16, 16, "healthGrid", true)
megautils.loadResource(72, 0, 8, 8, "smallEnergyGrid", true)
megautils.loadResource(88, 0, 16, 12, "energyGrid", true)
megautils.loadResource(72, 12, 16, 16, "tankGrid", true)

smallHealth = entity:extend()

addObjects.register("smallHealth", function(v)
  megautils.add(spawner, v.x, v.y+10, 8, 6, function(s)
    megautils.add(smallHealth, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

smallHealth.banIds = {}

function smallHealth:new(x, y, despwn, id, spawner)
  smallHealth.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = megautils.newAnimation("smallHealthGrid", {"1-2", 1}, 1/8)
  self.id = id
  self.spawner = spawner
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function smallHealth:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(smallHealth.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function smallHealth:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function smallHealth:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      p:addHealth(2)
      if not self.despawn then
        smallHealth.banIds[#smallHealth.banIds+1] = self.id
      end
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
  self.anim:update(defaultFramerate)
end

function smallHealth:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function smallHealth:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offy = 0
  if self.gravity < 0 then
    offy = 8
  end
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  end
end

health = entity:extend()

addObjects.register("health", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(health, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

health.banIds = {}

function health:new(x, y, despwn, id, spawner)
  health.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 14)
  self.anim = megautils.newAnimation("healthGrid", {"1-2", 1}, 1/8)
  self.id = id
  self.spawner = spawner
  self.t = megautils.getResource("particles")
  self.tOutline = megautils.getResource("particlesOutline")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function health:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(health.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function health:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function health:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      p:addHealth(10)
      if not self.despawn then
        health.banIds[#health.banIds+1] = self.id
      end
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
  self.anim:update(defaultFramerate)
end

function health:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function health:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local offy = 0
  if self.gravity < 0 then
    offy = 14
  end
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  end
end

smallEnergy = entity:extend()

addObjects.register("smallEnergy", function(v)
  megautils.add(spawner, v.x, v.y+10, 8, 6, function(s)
    megautils.add(smallEnergy, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

smallEnergy.banIds = {}

function smallEnergy:new(x, y, despwn, id, spawner)
  smallEnergy.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = megautils.newAnimation("smallEnergyGrid", {"1-2", 1}, 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function smallEnergy:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(smallEnergy.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function smallEnergy:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function smallEnergy:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 2)
      if not self.despawn then
        smallEnergy.banIds[#smallEnergy.banIds+1] = self.id
      end
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
  self.anim:update(defaultFramerate)
end

function smallEnergy:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function smallEnergy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = 8
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  end
end

energy = entity:extend()

addObjects.register("energy", function(v)
  megautils.add(spawner, v.x, v.y, 16, 10, function(s)
    megautils.add(energy, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

energy.banIds = {}

function energy:new(x, y, despwn, id, spawner)
  energy.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.anim = anim8.newAnimation("energyGrid", {"1-2", 1}, 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function energy:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(energy.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function energy:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function energy:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      megaMan.weaponHandler[p.player]:updateCurrent(megaMan.weaponHandler[p.player]:currentWE() + 10)
      if not self.despawn then
        energy.banIds[#energy.banIds+1] = self.id
      end
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
  self.anim:update(defaultFramerate)
end

function energy:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function energy:draw()
  local offy = 0
  if self.gravity < 0 then
    offy = 11
  end
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y)+offy, 0, 1, math.sign(self.gravity))
  end
end

life = entity:extend()

addObjects.register("life", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(life, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

life.banIds = {}

function life:new(x, y, despwn, id, spawner)
  life.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.id = id
  self.spawner = spawner
  self.tex = megautils.getResource("particles")
  self.texTwo = megautils.getResource("particlesTwo")
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.quad = {}
  self.quad.mega = quad(104, 12, 16, 16, 128, 98)
  self.quad.proto = quad(56, 31, 16, 15, 128, 98)
  self.quad.bass = quad(54, 16, 18, 15, 128, 98)
  self.quad.roll = quad(38, 16, 16, 16, 128, 98)
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function life:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(life.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function life:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function life:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      if megautils.hasInfiniteLives() then
        p:addHealth(9999)
        if not self.despawn then
          life.banIds[#life.banIds+1] = self.id
        end
        section.removeEntity(self.spawner)
        megautils.removeq(self.spawner)
        megautils.removeq(self)
      else
        globals.lives = math.min(globals.lives+1, globals.maxLives)
        if not self.despawn then
          life.banIds[#life.banIds+1] = self.id
        end
        megautils.playSoundFromFile("assets/sfx/life.ogg")
        section.removeEntity(self.spawner)
        megautils.removeq(self.spawner)
        megautils.removeq(self)
      end
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
end

function life:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function life:draw()
  local ox, oy = 0, 0
  if self.gravity < 0 then
    oy = 15
  end
  if megaMan.mainPlayer then
    if megaMan.mainPlayer.playerName == "proto" then
      oy = 1
      if self.gravity < 0 then
        oy = 14
      end
    elseif megaMan.mainPlayer.playerName == "bass" then
      ox = -1
      oy = 1
      if self.gravity < 0 then
        oy = 14
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.tex,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.texTwo,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.texOutline,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.quad[megaMan.mainPlayer.playerName]:draw(self.texOne,
      math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
  else
    if megautils.getPlayer(1) == "proto" then
      oy = 1
      if self.gravity < 0 then
        oy = 14
      end
    elseif megautils.getPlayer(1) == "bass" then
      ox = -1
      oy = 1
      if self.gravity < 0 then
        oy = 14
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    self.quad[megautils.getPlayer(1)]:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.quad[megautils.getPlayer(1)]:draw(self.texTwo, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 0, 0, 1)
    self.quad[megautils.getPlayer(1)]:draw(self.texOutline, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.quad[megautils.getPlayer(1)]:draw(self.texOne, math.round(self.transform.x+ox), math.round(self.transform.y)+oy, 0, 1, math.sign(self.gravity))
  end
end

eTank = entity:extend()

addObjects.register("eTank", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(eTank, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

eTank.banIds = {}

function eTank:new(x, y, despwn, id, spawner)
  eTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = megautils.newAnimation("tankGrid", {1, 1, 2, 2}, 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function eTank:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(eTank.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function eTank:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function eTank:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      globals.eTanks = math.min(globals.eTanks+1, globals.maxETanks)
      if not self.despawn then
        eTank.banIds[#eTank.banIds+1] = self.id
      end
      megautils.playSoundFromFile("assets/sfx/life.ogg")
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
  self.anim:update(defaultFramerate)
end

function eTank:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function eTank:draw()
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
  end
end

wTank = entity:extend()

addObjects.register("wTank", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(wTank, s.transform.x, s.transform.y, false, v.id, s)
  end)
end, 0, true)

wTank.banIds = {}

function wTank:new(x, y, despwn, id, spawner)
  wTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = megautils.newAnimation("tankGrid", {2, 2, 2, 1}, 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.velocity = velocity()
  self.timer = 0
  self.blockCollision = true
  self:setGravityMultiplier("flipWithPlayer", 1)
end

function wTank:begin()
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
  if not self.despawn then
    if table.contains(wTank.banIds, self.id) then
      megautils.removeq(self)
    else
      self:addToGroup("despawnable")
    end
  end
end

function wTank:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function wTank:update(dt)
  if megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  collision.doGrav(self)
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = megaMan.allPlayers[i]
    if self:collision(p) then
      globals.wTanks = math.min(globals.wTanks+1, globals.maxWTanks)
      if not self.despawn then
        wTank.banIds[#wTank.banIds+1] = self.id
      end
      megautils.playSoundFromFile("assets/sfx/life.ogg")
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.canDraw.global = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      section.removeEntity(self.spawner)
      megautils.removeq(self.spawner)
      megautils.removeq(self)
    end
  end
  self.anim:update(defaultFramerate)
end

function wTank:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function wTank:draw()
  if megaMan.mainPlayer then
    love.graphics.setColor(megaMan.colorTwo[megaMan.mainPlayer.player][1]/255, megaMan.colorTwo[megaMan.mainPlayer.player][2]/255,
      megaMan.colorTwo[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaMan.colorOutline[megaMan.mainPlayer.player][1]/255, megaMan.colorOutline[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOutline[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaMan.colorOne[megaMan.mainPlayer.player][1]/255, megaMan.colorOne[megaMan.mainPlayer.player][2]/255,
      megaMan.colorOne[megaMan.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
  end
end

megautils.resetGameObjectsFuncs.pickups = function()
  wTank.banIds = {}
  eTank.banIds = {}
  life.banIds = {}
  energy.banIds = {}
  smallEnergy.banIds = {}
  health.banIds = {}
  smallHealth.banIds = {}
end