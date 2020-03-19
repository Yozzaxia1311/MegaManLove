smallHealth = entity:extend()

addobjects.register("smallHealth", function(v)
  megautils.add(spawner, v.x, v.y+10, 8, 6, function(s)
    megautils.add(smallHealth, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

smallHealth.banIds = {}

function smallHealth:new(x, y, despwn, id, spawner)
  smallHealth.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = anim8.newAnimation(loader.get("smallHealthGrid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.t = loader.get("particles")
  self.tOutline = loader.get("particlesOutline")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function smallHealth:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function smallHealth:update(dt)
  if not self.despawn and table.contains(smallHealth.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      p:addHealth(2)
      if not self.despawn then
        smallHealth.banIds[#smallHealth.banIds+1] = self.id
      end
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
    end
  end
  self.anim:update(1/60)
end

function smallHealth:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function smallHealth:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y))
  if globals.mainPlayer then
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y))
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y))
  end
end

health = entity:extend()

addobjects.register("health", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(health, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

health.banIds = {}

function health:new(x, y, despwn, id, spawner)
  health.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 14)
  self.anim = anim8.newAnimation(loader.get("healthGrid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.t = loader.get("particles")
  self.tOutline = loader.get("particlesOutline")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function health:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function health:update(dt)
  if not self.despawn and table.contains(health.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      p:addHealth(10)
      if not self.despawn then
        health.banIds[#health.banIds+1] = self.id
      end
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
    end
  end
  self.anim:update(1/60)
end

function health:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function health:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y))
  if globals.mainPlayer then
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y))
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y))
  end
end

smallEnergy = entity:extend()

addobjects.register("smallEnergy", function(v)
  megautils.add(spawner, v.x, v.y+10, 8, 6, function(s)
    megautils.add(smallEnergy, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

smallEnergy.banIds = {}

function smallEnergy:new(x, y, despwn, id, spawner)
  smallEnergy.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = anim8.newAnimation(loader.get("smallEnergyGrid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particlesOutline")
  self.texOne = loader.get("particlesOne")
  self.texTwo = loader.get("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function smallEnergy:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function smallEnergy:update(dt)
  if not self.despawn and table.contains(smallEnergy.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      megaman.weaponHandler[p.player].change = 2
      megaman.weaponHandler[p.player]:updateThis()
      if not self.despawn then
        smallEnergy.banIds[#smallEnergy.banIds+1] = self.id
      end
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
    end
  end
  self.anim:update(1/60)
end

function smallEnergy:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function smallEnergy:draw()
  if globals.mainPlayer then
    love.graphics.setColor(megaman.colorTwo[globals.mainPlayer.player][1]/255, megaman.colorTwo[globals.mainPlayer.player][2]/255,
      megaman.colorTwo[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOne[globals.mainPlayer.player][1]/255, megaman.colorOne[globals.mainPlayer.player][2]/255,
      megaman.colorOne[globals.mainPlayer.player][3]/255, 1)
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

energy = entity:extend()

addobjects.register("energy", function(v)
  megautils.add(spawner, v.x, v.y, 16, 10, function(s)
    megautils.add(energy, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

energy.banIds = {}

function energy:new(x, y, despwn, id, spawner)
  energy.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.anim = anim8.newAnimation(loader.get("energyGrid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particlesOutline")
  self.texOne = loader.get("particlesOne")
  self.texTwo = loader.get("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function energy:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function energy:update(dt)
  if not self.despawn and table.contains(energy.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      megaman.weaponHandler[p.player].change = 10
      megaman.weaponHandler[p.player]:updateThis()
      if not self.despawn then
        energy.banIds[#energy.banIds+1] = self.id
      end
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
    end
  end
  self.anim:update(1/60)
end

function energy:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function energy:draw()
  if globals.mainPlayer then
    love.graphics.setColor(megaman.colorTwo[globals.mainPlayer.player][1]/255, megaman.colorTwo[globals.mainPlayer.player][2]/255,
      megaman.colorTwo[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOne[globals.mainPlayer.player][1]/255, megaman.colorOne[globals.mainPlayer.player][2]/255,
      megaman.colorOne[globals.mainPlayer.player][3]/255, 1)
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

life = entity:extend()

addobjects.register("life", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(life, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

life.banIds = {}

function life:new(x, y, despwn, id, spawner)
  life.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.quad = love.graphics.newQuad(104, 12, 16, 16, 128, 98)
  self.id = id
  self.spawner = spawner
  self.tex = loader.get("particles")
  self.texTwo = loader.get("particlesTwo")
  self.texOutline = loader.get("particlesOutline")
  self.texOne = loader.get("particlesOne")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.quad = {}
  self.quad["mega"] = love.graphics.newQuad(104, 12, 16, 16, 128, 98)
  self.quad["proto"] = love.graphics.newQuad(56, 31, 16, 15, 128, 98)
  self.quad["bass"] = love.graphics.newQuad(54, 16, 18, 15, 128, 98)
  self.quad["roll"] = love.graphics.newQuad(38, 16, 16, 16, 128, 98)
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function life:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function life:update(dt)
  if not self.despawn and table.contains(life.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      if globals.infiniteLives then
        p:addHealth(9999)
        if not self.despawn then
          life.banIds[#life.banIds+1] = self.id
        end
        megautils.state().sectionHandler:removeEntity(self.spawner)
        megautils.remove(self.spawner, true)
        megautils.remove(self, true)
      else
        globals.lives = math.min(globals.lives+1, globals.maxLives)
        if not self.despawn then
          life.banIds[#life.banIds+1] = self.id
        end
        mmSfx.play("life")
        megautils.state().sectionHandler:removeEntity(self.spawner)
        megautils.remove(self.spawner, true)
        megautils.remove(self, true)
      end
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
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
  if globals.mainPlayer then
    if globals.player[globals.mainPlayer.player] == "proto" then
      oy = 1
    elseif globals.player[globals.mainPlayer.player] == "bass" then
      ox = -1
      oy = 1
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.tex, self.quad[globals.player[globals.mainPlayer.player]],
      math.round(self.transform.x+ox), math.round(self.transform.y+oy))
    love.graphics.setColor(megaman.colorTwo[globals.mainPlayer.player][1]/255, megaman.colorTwo[globals.mainPlayer.player][2]/255,
      megaman.colorTwo[globals.mainPlayer.player][3]/255, 1)
    love.graphics.draw(self.texTwo, self.quad[globals.player[globals.mainPlayer.player]],
      math.round(self.transform.x+ox), math.round(self.transform.y+oy))
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    love.graphics.draw(self.texOutline, self.quad[globals.player[globals.mainPlayer.player]],
      math.round(self.transform.x+ox), math.round(self.transform.y+oy))
    love.graphics.setColor(megaman.colorOne[globals.mainPlayer.player][1]/255, megaman.colorOne[globals.mainPlayer.player][2]/255,
      megaman.colorOne[globals.mainPlayer.player][3]/255, 1)
    love.graphics.draw(self.texOne, self.quad[globals.player[globals.mainPlayer.player]],
      math.round(self.transform.x+ox), math.round(self.transform.y+oy))
  else
    if globals.player[1] == "proto" then
      oy = 1
    elseif globals.player[1] == "bass" then
      ox = -1
      oy = 1
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.tex, self.quad[globals.player[1]], math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 232/255, 216/255, 1)
    love.graphics.draw(self.texTwo, self.quad[globals.player[1]], math.round(self.transform.x+ox), math.round(self.transform.y+oy))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(self.texOutline, self.quad[globals.player[1]], math.round(self.transform.x+ox), math.round(self.transform.y+oy))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    love.graphics.draw(self.texOne, self.quad[globals.player[1]], math.round(self.transform.x+ox), math.round(self.transform.y+oy))
  end
end

eTank = entity:extend()

addobjects.register("eTank", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(eTank, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

eTank.banIds = {}

function eTank:new(x, y, despwn, id, spawner)
  eTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = anim8.newAnimation(loader.get("tankGrid")(1, 1, 2, 2), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particlesOutline")
  self.texOne = loader.get("particlesOne")
  self.texTwo = loader.get("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function eTank:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function eTank:update(dt)
  if not self.despawn and table.contains(eTank.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      globals.eTanks = math.min(globals.eTanks+1, globals.maxETanks)
      if not self.despawn then
        eTank.banIds[#eTank.banIds+1] = self.id
      end
      mmSfx.play("life")
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
    end
  end
  self.anim:update(1/60)
end

function eTank:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function eTank:draw()
  if globals.mainPlayer then
    love.graphics.setColor(megaman.colorTwo[globals.mainPlayer.player][1]/255, megaman.colorTwo[globals.mainPlayer.player][2]/255,
      megaman.colorTwo[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOne[globals.mainPlayer.player][1]/255, megaman.colorOne[globals.mainPlayer.player][2]/255,
      megaman.colorOne[globals.mainPlayer.player][3]/255, 1)
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

addobjects.register("wTank", function(v)
  megautils.add(spawner, v.x, v.y, 16, 15, function(s)
    megautils.add(wTank, s.transform.x, s.transform.y, false, v.id, s)
  end)
end)

wTank.banIds = {}

function wTank:new(x, y, despwn, id, spawner)
  wTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = anim8.newAnimation(loader.get("tankGrid")(2, 2, 2, 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particlesOutline")
  self.texOne = loader.get("particlesOne")
  self.texTwo = loader.get("particlesTwo")
  self.despawn = despwn == nil and self.id == nil or despwn
  self.added = function()
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
    if not self.despawn then
      self:addToGroup("despawnable")
    end
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.blockCollision = true
end

function wTank:grav()
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clamp(7)
end

function wTank:update(dt)
  if not self.despawn and table.contains(wTank.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  collision.doCollision(self)
  for i=1, globals.playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      globals.wTanks = math.min(globals.wTanks+1, globals.maxWTanks)
      if not self.despawn then
        wTank.banIds[#wTank.banIds+1] = self.id
      end
      mmSfx.play("life")
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
      return
    end
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
      megautils.state().sectionHandler:removeEntity(self.spawner)
      megautils.remove(self.spawner, true)
      megautils.remove(self, true)
    end
  end
  self.anim:update(1/60)
end

function wTank:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function wTank:draw()
  if globals.mainPlayer then
    love.graphics.setColor(megaman.colorTwo[globals.mainPlayer.player][1]/255, megaman.colorTwo[globals.mainPlayer.player][2]/255,
      megaman.colorTwo[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOne[globals.mainPlayer.player][1]/255, megaman.colorOne[globals.mainPlayer.player][2]/255,
      megaman.colorOne[globals.mainPlayer.player][3]/255, 1)
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