smallHealth = entity:extend()

addobjects.register("small_health", function(v)
  local tmp = spawner(v.x, v.y+10, 8, 8, function(s)
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
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.mainPlayer:addHealth(2)
    if not self.despawn then
      smallHealth.banIds[#smallHealth.banIds+1] = self.id
    end
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.tOutline, self.transform.x, self.transform.y)
end

health = entity:extend()

addobjects.register("health", function(v)
  local tmp = spawner(v.x, v.y, 16, 16, function(s)
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
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.mainPlayer:addHealth(10)
    if not self.despawn then
      health.banIds[#health.banIds+1] = self.id
    end
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.tOutline, self.transform.x, self.transform.y)
end

smallEnergy = entity:extend()

addobjects.register("small_energy", function(v)
  local tmp = spawner(v.x, v.y+10, 8, 8, function(s)
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
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.mainPlayer.weaponHandler.change = 2
    globals.mainPlayer.weaponHandler:updateThis()
    if not self.despawn then
      smallEnergy.banIds[#smallEnergy.banIds+1] = self.id
    end
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255,
    megaman.colorTwo[3]/255, 1)
  self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255,
    megaman.colorOne[3]/255, 1)
  self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
end

energy = entity:extend()

addobjects.register("energy", function(v)
  local tmp = spawner(v.x, v.y, 16, 16, function(s)
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
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.mainPlayer.weaponHandler.change = 10
    globals.mainPlayer.weaponHandler:updateThis()
    if not self.despawn then
      energy.banIds[#energy.banIds+1] = self.id
    end
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255,
    megaman.colorTwo[3]/255, 1)
  self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255,
    megaman.colorOne[3]/255, 1)
  self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
end

life = entity:extend()

addobjects.register("life", function(v)
  local tmp = spawner(v.x, v.y, 16, 16, function(s)
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
  self:setRectangleCollision(16, 14)
  self.quad = love.graphics.newQuad(104, 12, 16, 15, 128, 96)
  self.id = id
  self.spawner = spawner
  self.tex = loader.get("particles")
  self.texTwo = loader.get("particles_two")
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.lives = math.min(globals.lives+1, globals.maxLives)
    if not self.despawn then
      life.banIds[#life.banIds+1] = self.id
    end
    mmSfx.play("life")
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255,
    megaman.colorTwo[3]/255, 1)
  love.graphics.draw(self.texTwo, self.quad, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  love.graphics.draw(self.texOutline, self.quad, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255,
    megaman.colorOne[3]/255, 1)
  love.graphics.draw(self.texOne, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

eTank = entity:extend()

addobjects.register("e_tank", function(v)
  local tmp = spawner(v.x, v.y, 16, 16, function(s)
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
  self:setRectangleCollision(16, 14)
  self.anim = anim8.newAnimation(loader.get("tank_grid")(1, 1, 2, 2), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.eTanks = math.min(globals.eTanks+1, globals.maxETanks)
    if not self.despawn then
      eTank.banIds[#eTank.banIds+1] = self.id
    end
    mmSfx.play("life")
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255,
    megaman.colorTwo[3]/255, 1)
  self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255,
    megaman.colorOne[3]/255, 1)
  self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
end

wTank = entity:extend()

addobjects.register("w_tank", function(v)
  local tmp = spawner(v.x, v.y, 16, 16, function(s)
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
  self:setRectangleCollision(16, 14)
  self.anim = anim8.newAnimation(loader.get("tank_grid")(2, 2, 2, 1), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.despawn = despwn
  self.added = function()
    self:addToGroup("removeOnCutscene")
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.wTanks = math.min(globals.wTanks+1, globals.maxWTanks)
    if not self.despawn then
      wTank.banIds[#wTank.banIds+1] = self.id
    end
    mmSfx.play("life")
    megautils.remove(self, true)
  end
  if self.despawn then
    self.timer = math.min(self.timer+1, 400)
    if self.timer > 400-120 then
      self.render = math.wrap(self.timer, 0, 8) > 4
    end
    if self.timer == 400 then
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
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255,
    megaman.colorTwo[3]/255, 1)
  self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255,
    megaman.colorOne[3]/255, 1)
  self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
end

heartTank = entity:extend()

heartTank.list = {}

addobjects.register("heart_tank", function(v)
  local tmp = spawner(v.x, v.y, 16, 16, function(s)
    megautils.add(heartTank(s.transform.x, s.transform.y, s.id, s))
  end)
  tmp.id = v.properties["id"]
  megautils.add(tmp)
end)

function heartTank:new(x, y, id, spawner)
  heartTank.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 14)
  self.anim = anim8.newAnimation(loader.get("tank_grid")(1, 2, 2, 2), 1/8)
  self.id = id
  self.spawner = spawner
  self.texOutline = loader.get("particles_outline")
  self.texOne = loader.get("particles_one")
  self.texTwo = loader.get("particles_two")
  self.added = function(self)
    self:addToGroup("removeOnCutscene")
    self:addToGroup("freezable")
    self:addToGroup("despawnable")
  end
  self.velocity = velocity()
  self.timer = 0
  self.render = false
  self.once = false
  self.timer = 0
  self.start = false
end

function heartTank:update(dt)
  if heartTank.list[self.id] then
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
  if globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) then
    globals.lifeSegments = math.min(globals.lifeSegments+1, globals.maxLifeSegments)
    self.render = false
    heartTank.list[self.id] = true
    mmSfx.play("life")
    self.start = true
    megautils.freeze(nil, "global")
    megautils.add(timer(80, function(s)
      if globals.mainPlayer ~= nil then
        globals.mainPlayer.healthHandler.segments = globals.lifeSegments
        globals.mainPlayer.healthHandler.change = 4
        globals.mainPlayer.healthHandler:updateThis()
      end
      megautils.unfreeze(nil, "global")
      megautils.remove(self, true)
      megautils.remove(s, true)
    end))
  end
  self.anim:update(1/60)
end

function heartTank:removed()
  if self.spawner ~= nil then
    self.spawner.canSpawn = true
  end
end

function heartTank:draw()
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255,
    megaman.colorTwo[3]/255, 1)
  self.anim:draw(self.texTwo, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255,
    megaman.colorOutline[3]/255, 1)
  self.anim:draw(self.texOutline, math.round(self.transform.x), math.round(self.transform.y))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255,
    megaman.colorOne[3]/255, 1)
  self.anim:draw(self.texOne, math.round(self.transform.x), math.round(self.transform.y))
end