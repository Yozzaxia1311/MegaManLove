smallHealth = entity:extend()

addobjects.register("small_health", function(v)
  local tmp = spawner(v.x, v.y+10, 8, 6, function(s)
    megautils.add(smallHealth(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
end)

smallHealth.banIds = {}

function smallHealth:new(x, y, despwn, id, spawner)
  smallHealth.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = anim8.newAnimation(loader.get("small_health_grid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.t = loader.get("particles")
  self.tOutline = loader.get("particles_outline")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function smallHealth:update(dt)
  if not self.despawn and table.contains(smallHealth.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
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
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function smallHealth:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y))
  if globals.mainPlayer ~= nil then
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
  local tmp = spawner(v.x, v.y, 16, 14, function(s)
    megautils.add(health(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
end)

health.banIds = {}

function health:new(x, y, despwn, id, spawner)
  health.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 14)
  self.anim = anim8.newAnimation(loader.get("health_grid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.t = loader.get("particles")
  self.tOutline = loader.get("particles_outline")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function health:update(dt)
  if not self.despawn and table.contains(health.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
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
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function health:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.t, math.round(self.transform.x), math.round(self.transform.y))
  if globals.mainPlayer ~= nil then
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y))
  else
    love.graphics.setColor(0, 0, 0, 1)
    self.anim:draw(self.tOutline, math.round(self.transform.x), math.round(self.transform.y))
  end
end

smallEnergy = entity:extend()

addobjects.register("small_energy", function(v)
  local tmp = spawner(v.x, v.y+10, 8, 6, function(s)
    megautils.add(smallEnergy(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
end)

smallEnergy.banIds = {}

function smallEnergy:new(x, y, despwn, id, spawner)
  smallEnergy.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.anim = anim8.newAnimation(loader.get("small_energy_grid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function smallEnergy:update(dt)
  if not self.despawn and table.contains(smallEnergy.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
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
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function smallEnergy:draw()
  if globals.mainPlayer ~= nil then
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
  local tmp = spawner(v.x, v.y, 16, 10, function(s)
    megautils.add(energy(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
end)

energy.banIds = {}

function energy:new(x, y, despwn, id, spawner)
  energy.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.anim = anim8.newAnimation(loader.get("energy_grid")("1-2", 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function energy:update(dt)
  if not self.despawn and table.contains(energy.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
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
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function energy:draw()
  if globals.mainPlayer ~= nil then
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
  local tmp = spawner(v.x, v.y, 16, 15, function(s)
    megautils.add(life(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
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
  self.texTwo = loader.get("particles_two")
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function life:update(dt)
  if not self.despawn and table.contains(life.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
    local p = globals.allPlayers[i]
    if self:collision(p) then
      globals.lives = math.min(globals.lives+1, globals.maxLives)
      if not self.despawn then
        life.banIds[#life.banIds+1] = self.id
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
end

function life:removed()
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function life:draw()
  if globals.mainPlayer ~= nil then
    love.graphics.setColor(megaman.colorTwo[globals.mainPlayer.player][1]/255, megaman.colorTwo[globals.mainPlayer.player][2]/255,
      megaman.colorTwo[globals.mainPlayer.player][3]/255, 1)
    love.graphics.draw(self.texTwo, self.quad, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOutline[globals.mainPlayer.player][1]/255, megaman.colorOutline[globals.mainPlayer.player][2]/255,
      megaman.colorOutline[globals.mainPlayer.player][3]/255, 1)
    love.graphics.draw(self.texOutline, self.quad, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(megaman.colorOne[globals.mainPlayer.player][1]/255, megaman.colorOne[globals.mainPlayer.player][2]/255,
      megaman.colorOne[globals.mainPlayer.player][3]/255, 1)
    love.graphics.draw(self.texOne, self.quad, math.round(self.transform.x), math.round(self.transform.y))
  else
    love.graphics.setColor(0, 232/255, 216/255, 1)
    love.graphics.draw(self.texTwo, self.quad, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(self.texOutline, self.quad, math.round(self.transform.x), math.round(self.transform.y))
    love.graphics.setColor(0, 120/255, 248/255, 1)
    love.graphics.draw(self.texOne, self.quad, math.round(self.transform.x), math.round(self.transform.y))
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

eTank = entity:extend()

addobjects.register("e_tank", function(v)
  local tmp = spawner(v.x, v.y, 16, 15, function(s)
    megautils.add(eTank(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
end)

eTank.banIds = {}

function eTank:new(x, y, despwn, id, spawner)
  eTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = anim8.newAnimation(loader.get("tank_grid")(1, 1, 2, 2), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function eTank:update(dt)
  if not self.despawn and table.contains(eTank.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
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
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function eTank:draw()
  if globals.mainPlayer ~= nil then
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

addobjects.register("w_tank", function(v)
  local tmp = spawner(v.x, v.y, 16, 15, function(s)
    megautils.add(wTank(s.transform.x, s.transform.y, false, s.id, s))
  end)
  tmp.id = v.id
  megautils.add(tmp)
end)

wTank.banIds = {}

function wTank:new(x, y, despwn, id, spawner)
  wTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 15)
  self.anim = anim8.newAnimation(loader.get("tank_grid")(2, 2, 2, 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.despawn = ternary(despwn ~= nil, despwn, self.id == nil)
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
end

function wTank:update(dt)
  if not self.despawn and table.contains(wTank.banIds, self.id) then
    megautils.remove(self, true)
    return
  elseif not self.once then
    self.once = true
    self.render = true
  end
  if not self.onSlope then
    self.velocity.vely = math.min(self.velocity.vely + .25, 7)
  end
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, table.merge({megautils.groups()["solid"], megautils.groups()["death"]}),
    self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  for i=1, playerCount do
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
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function wTank:draw()
  if globals.mainPlayer ~= nil then
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