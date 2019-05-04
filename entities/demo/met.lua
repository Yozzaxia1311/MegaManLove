client_met = entity:extend()

client_met.netName = "c_met"
megautils.netNames[client_met.netName] = client_met

function client_met:new(x, y, id)
  client_met.super.new(self)
  self.t = loader.get("demo_objects")
  self.quads = {}
  self.quads["safe"] = love.graphics.newQuad(32, 0, 18, 15, 100, 100)
  self.quads["up"] = love.graphics.newQuad(50, 0, 18, 15, 100, 100)
  self:setLayer(2)
  
  self.side = -1
  self.c = "safe"
  self.transform.y = x
  self.transform.x = y
  self.networkID = id
end

function client_met:update(dt)
  if self.networkData then
    self.side = self.networkData.s or -1
    self.c = self.networkData.c == 0 and "safe" or "up"
    self.transform.x = self.networkData.x or self.transform.x
    self.transform.y = self.networkData.y or self.transform.y
    if self.networkData.r then
      megautils.remove(self, true)
    end
  end
end

function client_met:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.side == -1 then
    love.graphics.draw(self.t, self.quads[self.c], self.transform.x-2, self.transform.y)
  else
    love.graphics.draw(self.t, self.quads[self.c], self.transform.x+16, self.transform.y, 0, -1, 1)
  end
end

met = entity:extend()

met.netName = "met"
megautils.netNames[met.netName] = met

addobjects.register("met", function(v)
  megautils.add(spawner, {v.x, v.y+2, 14, 14, function(s)
      local id = megautils.nextID()
      megautils.add(met, {s.transform.x, s.transform.y, s, id})
      if megautils.networkMode == "server" and megautils.networkGameStarted then
        megautils.sendEntityToClients(client_met, {s.transform.x, s.transform.y, id})
      end
    end})
end)

function met:new(x, y, s, id)
  met.super.new(self)
  self.added = function(self)
    self:addToGroup("hurtable")
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(14, 14)
  self.t = loader.get("demo_objects")
  self.spawner = s
  self.c = "safe"
  self.quads = {}
  self.quads["safe"] = love.graphics.newQuad(32, 0, 18, 15, 100, 100)
  self.quads["up"] = love.graphics.newQuad(50, 0, 18, 15, 100, 100)
  self.side = -1
  self.s = 0
  self.health = 2
  self.inv = true
  self.timer = 0
  self:setLayer(2)
  self.networkID = id
end

function met:healthChanged(o, c, i)
  if c < 0 and not self.inv and not o:is(megaChargedBuster) then
    megautils.remove(o, true)
  end
  if not self:iFrameIsDone() then return end
  if self.inv and not o.dink then
    mmSfx.play("dink")
    o.dink = true
    self.iFrame = self.maxIFrame
    return
  end
  if self.inv then return end
  self.changeHealth = c
  self.health = self.health + self.changeHealth
  self.maxIFrame = i
  self.iFrame = 0
  if self.health <= 0 then
    megautils.add(smallBlast, {self.transform.x-4, self.transform.y-4})
    megautils.dropItem(self.transform.x, self.transform.y-4)
    megautils.remove(self, true)
    mmSfx.play("enemy_explode")
  elseif self.changeHealth < 0 then
    self.hitTimer = 0
    mmSfx.play("enemy_hit")
    if o:is(megaChargedBuster) then
      megautils.remove(o, true)
    end
  end
end

function met:update(dt)
  local near = megautils.autoFace(self, globals.allPlayers)
  if self.s == 0 then
    if near and math.between(near.transform.x, 
      self.transform.x - 120, self.transform.x + 120) then
      self.timer = math.min(self.timer+1, 80)
    else
      self.timer = 0
    end
    if self.timer == 80 then
      self.timer = 0
      self.s = 1
      self.inv = false
      self.c = "up"
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.timer = 0
      self.s = 2
      megautils.add(metBullet, {self.transform.x+4, self.transform.y+4, self.side*megautils.calcX(45)*2, -megautils.calcY(45)*2})
      megautils.add(metBullet, {self.transform.x+4, self.transform.y+4, self.side*megautils.calcX(45)*2, megautils.calcY(45)*2})
      megautils.add(metBullet, {self.transform.x+4, self.transform.y+4, self.side*2, 0})
      mmSfx.play("buster")
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.c = "safe"
      self.inv = true
      self.timer = 0
      self.s = 0
    end
  end
  self:hurt(self:collisionTable(globals.allPlayers), -2, 80)
  self:updateIFrame()
  self:updateFlash()
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {x=self.transform.x, y=self.transform.y, s=self.side, c=self.c=="safe" and 0 or 1, id=self.networkID})
  end
end

function met:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.side == -1 then
    love.graphics.draw(self.t, self.quads[self.c], self.transform.x-2, self.transform.y)
  else
    love.graphics.draw(self.t, self.quads[self.c], self.transform.x+16, self.transform.y, 0, -1, 1)
  end
  --self:drawCollision()
end

function met:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {r=true, id=self.networkID})
  end
end

metBullet = entity:extend()

function metBullet:new(x, y, vx, vy)
  metBullet.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(6, 6)
  self.tex = loader.get("demo_objects")
  self.quad = love.graphics.newQuad(68, 0, 6, 6, 100, 100)
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self.velocity = velocity()
  self.velocity.velx = vx
  self.velocity.vely = vy
end

function metBullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

function metBullet:update(dt)
  self:moveBy(self.velocity.velx, self.velocity.vely)
  self:hurt(self:collisionTable(globals.allPlayers), -2, 80)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

megautils.cleanFuncs["unload_met"] = function()
  met = nil
  metBullet = nil
  addobjects.unregister("met")
  megautils.cleanFuncs["unload_met"] = nil
end