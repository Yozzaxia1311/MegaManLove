client_moveAcrossPlatform = entity:extend()

client_moveAcrossPlatform.netName = "c_mvp"
megautils.netNames[client_moveAcrossPlatform.netName] = client_moveAcrossPlatform

function client_moveAcrossPlatform:new(x, y, id)
  client_moveAcrossPlatform.super.new(self)
  self.tex = loader.get("demo_objects")
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 100, 100)
  self:setLayer(2)
  
  self.transform.y = x
  self.transform.x = y
  self.isSolid = 1
  self.networkID = id
end

function client_moveAcrossPlatform:update(dt)
  if self.networkData then
    self.transform.x = self.networkData.x or self.transform.x
    self.transform.y = self.networkData.y or self.transform.y
    if self.networkData.r then
      megautils.remove(self, true)
    end
  end
  collision.doCollision(self)
end

function client_moveAcrossPlatform:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

addobjects.register("move_across_platform", function(v)
  megautils.add(spawner, v.x, v.y, 32, 16, function(s)
    megautils.add(moveAcrossPlatform, s.transform.x, s.transform.y, v.properties["to_x"], v.properties["to_y"], s, megautils.nextID())
  end)
end)

moveAcrossPlatform = entity:extend()

function moveAcrossPlatform:new(x, y, toX, toY, s, id)
  moveAcrossPlatform.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
    if megautils.networkMode == "server" and megautils.networkGameStarted then
      megautils.sendEntityToClients(client_moveAcrossPlatform, {self.transform.x, self.transform.y, self.networkID})
    end
  end
  self.isSolid = 1
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(32, 16)
  self.tex = loader.get("demo_objects")
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 100, 100)
  self.spawner = s
  self.velocity = velocity()
  self.tween = tween.new(1, self.transform, {x=toX, y=toY}, "inOutBack")
  self.state = 0
  self.networkID = id
end

function moveAcrossPlatform:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {r=true, id=self.networkID})
  end
end

function moveAcrossPlatform:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

function moveAcrossPlatform:update(dt)
  if self.state == 0 then
    for i=1, #globals.allPlayers do
      local p = globals.allPlayers[i]
      if p.transform.y == self.transform.y - p.collisionShape.h then
        self.state = 1
      end
    end
  elseif self.state == 1 then
    self.tween:update(1/60)
  end
  collision.doCollision(self)
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {x=self.transform.x, y=self.transform.y, id=self.networkID})
  end
end

megautils.cleanFuncs["unload_move_across_platform"] = function()
  moveAcrossPlatform = nil
  client_moveAcrossPlatform = nil
  megautils.netNames[client_moveAcrossPlatform.netName] = nil
  addobjects.unregister("move_across_platform")
  megautils.cleanFuncs["unload_move_across_platform"] = nil
end