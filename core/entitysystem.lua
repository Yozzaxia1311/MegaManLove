entitysystem = class:extend()

entitysystem.drawCollision = false

function entitysystem:new()
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.static = {}
  self.all = {}
  self.addQueue = nil
  self.removeQueue = nil
  self.last = 0
  self.first = 0
  self.lastUpdate = 0
  self.firstUpdate = 0
end

function entitysystem:add(e, queue)
  if e == nil then return end
  if queue then
    if self.addQueue == nil then self.addQueue = {} end
    if not table.contains(self.addQueue, e) then
      self.addQueue[#self.addQueue+1] = e
    end
  else
    if not e.static then
      if self.entities[e.layer] == nil then self.entities[e.layer] = {} end
      if self.updates[e.updateLayer] == nil then self.updates[e.updateLayer] = {} end
      self.entities[e.layer][#self.entities[e.layer]+1] = e
      self.updates[e.updateLayer][#self.updates[e.updateLayer]+1] = e
      if self.last < e.layer then self.last = e.layer end
      if self.first > e.layer then self.first = e.layer end
      if self.lastUpdate < e.updateLayer then self.lastUpdate = e.updateLayer end
      if self.firstUpdate > e.updateLayer then self.firstUpdate = e.updateLayer end
    end
    self.all[#self.all+1] = e
    e.isRemoved = false
    e.isAdded = true
    e:added()
  end
end

function entitysystem:removeFromGroup(e, g)
  table.removevaluearray(self.groups[g], e)
  if #self.groups[g] == 0 then
    self.groups[g] = nil
  end
end

function entitysystem:removeFromAllGroups(e)
  for k, v in pairs(self.groups) do
    self:removeFromGroup(e, k)
  end
end

function entitysystem:addStatic(e)
  table.removevaluearray(self.updates[e.updateLayer], e)
  table.removevaluearray(self.entities[e.layer], e)
  self.static[#self.static+1] = e
  e.static = true
end

function entitysystem:removeStatic(e)
  table.removevaluearray(self.static, e)
  if self.entities[e.layer] == nil then self.entities[e.layer] = {} end
  if self.updates[e.updateLayer] == nil then self.updates[e.updateLayer] = {} end
  self.entities[e.layer][#self.entities[e.layer]+1] = e
  self.updates[e.updateLayer][#self.updates[e.updateLayer]+1] = e
  if self.last < e.layer then self.last = e.layer end
  if self.first > e.layer then self.first = e.layer end
  if self.lastUpdate < e.updateLayer then self.lastUpdate = e.updateLayer end
  if self.firstUpdate > e.updateLayer then self.firstUpdate = e.updateLayer end
  e.static = false
end

function entitysystem:setLayer(e, l)
  table.removevaluearray(self.entities[e.layer], e)
  e.layer = l
  if self.entities[e.layer] == nil then self.entities[e.layer] = {} end
  self.entities[e.layer][#self.entities[e.layer]+1] = e
  if self.last < e.layer then self.last = e.layer end
  if self.first > e.layer then self.first = e.layer end
end

function entitysystem:setUpdateLayer(e, l)
  table.removevaluearray(self.updates[e.updateLayer], e)
  e.updateLayer = l
  if self.updates[e.updateLayer] == nil then self.updates[e.updateLayer] = {} end
  self.updates[e.updateLayer][#self.updates[e.updateLayer]+1] = e
  if self.lastUpdate < e.updateLayer then self.lastUpdate = e.updateLayer end
  if self.firsUpdate > e.updateLayer then self.firstUpdate = e.updateLayer end
end

function entitysystem:remove(e, queue)
  if e == nil then return end
  if queue then
    if self.removeQueue == nil then self.removeQueue = {} end
    if not table.contains(self.removeQueue, e) then
      self.removeQueue[#self.removeQueue+1] = e
    end
  else
    e.isRemoved = true
    e:removed()
    e:removeFromAllGroups()
    e:removeStatic()
    table.removevaluearray(self.entities[e.layer], e)
    table.removevaluearray(self.updates[e.updateLayer], e)
    table.removevaluearray(self.all, e)
    e.isAdded = false
  end
end

function entitysystem:clear()
  for i, j in ipairs(self.all) do
    self:remove(j)
  end
  section.sections = {}
  section.current = nil
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.all = {}
  self.static = {}
  self.afterUpdate = nil
end

function entitysystem:draw()
  for i=self.first, self.last, 1 do
    if self.entities[i] ~= nil then
      for k=1, #self.entities[i] do
        local v = self.entities[i][k]
        if v.render and v.flashRender and not v.isRemoved then
          if states.switched then
            return
          end
          v:draw()
          love.graphics.setColor(1, 1, 1, 1)
          if entitysystem.drawCollision then
            v:drawCollision()
          end
        end
      end
    end
  end
end

function entitysystem:drawQuality()
  for i=self.first, self.last, 1 do
    if self.entities[i] ~= nil then
      for k=1, #self.entities[i] do
        local v = self.entities[i][k]
        if v.render and v.flashRender and not v.isRemoved then
          if states.switched then
            return
          end
          v:drawQuality()
        end
      end
    end
  end
end

function entitysystem:update(dt)
  self.localUpdate = true
  for i=self.firstUpdate, self.lastUpdate, 1 do
    if self.updates[i] ~= nil then
      for k=1, #self.updates[i] do
        local t = self.updates[i][k]
        if table.length(t.otherUpdates) ~= 0 then
          for s, h in pairs(t.otherUpdates) do
            if not h then 
              self.localUpdate = false
              break
            end
          end
        end
        if t.updated and self.localUpdate and not t.isRemoved then
          if states.switched then
            return
          end
          t:update(dt)
        end
        self.localUpdate = true
      end
    end
  end
  for i=self.firstUpdate, self.lastUpdate, 1 do
    if self.updates[i] ~= nil then
      for k=1, #self.updates[i] do
        local t = self.updates[i][k]
        if t.updated and not t.isRemoved then
          if states.switched then
            return
          end
          t:afterUpdate(dt)
        end
      end
    end
  end
  if self.afterUpdate then
    self.afterUpdate(self)
  end
  if self.addQueue then
    for k, v in ipairs(self.addQueue) do
      self:add(v)
    end
    self.addQueue = nil
  end
  if self.removeQueue then
    for k, v in ipairs(self.removeQueue) do
      self:remove(v)
    end
    self.removeQueue = nil
  end
end

velocity = class:extend()

function velocity:new()
  self.velx = 0
  self.vely = 0
end
function velocity:clampX(v)
  self.velx = math.clamp(self.velx, -v, v)
end
function velocity:clampY(v)
  self.vely = math.clamp(self.vely, -v, v)
end

function velocity:slowX(v)
  if self.velx < 0 then 
		self.velx = math.min(self.velx + v, 0)
  elseif self.velx > 0 then
    self.velx = math.max(self.velx - v, 0)
  end
end
function velocity:slowY(v)
  if self.vely < 0 then 
		self.vely = math.min(self.vely + v, 0)
  elseif self.vely > 0 then
    self.vely = math.max(self.vely - v, 0)
  end
end

entity = class:extend()

function entity:new(basic)
  self.isAdded = false
  self.transform = {}
  self.transform.x = 0
  self.transform.y = 0
  self.collisionShape = nil
  self.layer = 0
  self.updateLayer = 0
  self.isRemoved = false
  self.updated = true
  self.otherUpdates = {["global"]=true}
  self.render = true
  self.flashRender = true
  
  if not basic then
    self.maxIFrame = 80
    self.iFrame = self.maxIFrame
    self.health = 28
    self.changeHealth = 0
    self.collisionChecks = {}
    self.collisionChecks.ground = false
    self.collisionChecks.ceiling = false
    self.collisionChecks.leftWall = false
    self.collisionChecks.rightWall = false
    self.collisionChecks.touching = false
    self.shakeX = 0
    self.shakeY = 0
    self.shakeTime = 0
    self.maxShakeTime = 5
    self.shakeSide = 1
    self.doShake = false
    self.moveByMoveX = 0
    self.moveByMoveY = 0
  end
end

function entity:updateShake()
  if self.doShake then
    self.shakeTime = math.min(self.shakeTime+1, self.maxShakeTime)
    if self.shakeTime == self.maxShakeTime then
      self.shakeTime = 0
      self.shakeX = math.abs(self.shakeX) * self.shakeSide
      self.shakeY = math.abs(self.shakeY) * self.shakeSide
      self.shakeSide = -self.shakeSide
    end
  end
end

function entity:setShake(x, y, t)
  self.shakeX = x
  self.shakeY = y
  self.maxShakeTime = t or self.maxShakeTime
  self.doShake = x ~= 0 or y ~= 0
end

function entity:resetCollisionChecks()
  self.collisionChecks.ground = false
  self.collisionChecks.ceiling = false
  self.collisionChecks.leftWall = false
  self.collisionChecks.rightWall = false
  self.collisionChecks.touching = false
end

function entity:updateFlash(length, range)
  if self.iFrame == self.maxIFrame then
    self.flashRender = true
  else
    self.flashRender = math.wrap(self.iFrame, 0, length or 8) > (range or 4)
  end
end

function entity:iFrameIsDone()
  return self.iFrame == self.maxIFrame
end

function entity:hurt(t, h, f)
  for k, v in pairs(t) do
    v:healthChanged(self, h, f or 80)
  end
end

function entity:healthChanged(other, c, i) end

function entity:updateIFrame()
  self.iFrame = math.min(self.iFrame+1, self.maxIFrame)
end

function entity:setLayer(l)
  if not self.isAdded or self.static then
    self.layer = l
  else
    megautils.state().system:setLayer(self, l)
  end
end

function entity:addStatic()
  megautils.state().system:addStatic(self)
end

function entity:removeStatic()
  megautils.state().system:removeStatic(self)
end

function entity:setUpdateLayer(l)
  if not self.isAdded or self.static then
    self.updateLayer = l
  else
    megautils.state().system:setUpdateLayer(self, l)
  end
end

function entity:removeFromGroup(g)
  megautils.state().system:removeFromGroup(self, g)
end

function entity:inGroup(g)
  return table.contains(states.currentstate.system.groups[g], self)
end

function entity:removeFromAllGroups()
  megautils.state().system:removeFromAllGroups(self, g)
end

function entity:block(velocity)
  if self.collisionChecks.ground or self.collisionChecks.ceiling then
    velocity.vely = 0
  end
  if self.collisionChecks.leftWall or self.collisionChecks.rightWall then
    velocity.velx = 0
  end
end

function entity:addToGroup(g)
  if states.currentstate.system.groups[g] == nil then
    states.currentstate.system.groups[g] = {}
  end
  if not table.contains(states.currentstate.system.groups[g], self) then
    table.insert(states.currentstate.system.groups[g], self)
  end
end

function entity:setRectangleCollision(w, h)
  self.collisionShape = {}
  self.collisionShape.type = 0
  self.collisionShape.w = w
  self.collisionShape.h = h
  if w == nil then error() end
end

function entity:setImageCollision(data)
  self.collisionShape = {}
  self.collisionShape.type = 1
  self.collisionShape.data = table.convert1Dto2D(data[1], data[2])
  self.collisionShape.w = #self.collisionShape.data[1]
  self.collisionShape.h = #self.collisionShape.data
end

function entity:moveBy(xx, yy, round)
  local x, y = xx or 0, yy or 0
  if round then
    self.moveByMoveX = self.moveByMoveX + x
    self.moveByMoveY = self.moveByMoveY + y
    x = math.round(self.moveByMoveX)
    y = math.round(self.moveByMoveY)
    self.moveByMoveX = self.moveByMoveX - x
    self.moveByMoveY = self.moveByMoveY - y
  end
  self.transform.x = self.transform.x + x
  self.transform.y = self.transform.y + y
end

function entity:collision(e, x, y)
  if e == nil or self.collisionShape == nil or e.collisionShape == nil then return false end
  if self.collisionShape.type == 0 then
    if e.collisionShape.type == 0 then
      return rectOverlaps(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageRectOverlaps(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.w, self.collisionShape.h)
    end
  elseif self.collisionShape.type == 1 then
    if e.collisionShape.type == 0 then
      return rectOverlaps(self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return false --image/image collision
    end
  end
  return false
end

function entity:drawCollision()
  if self.collisionShape == nil then return false end
  if self.collisionShape.type == 0 then
    love.graphics.rectangle("line", self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 1 then
    --image collision drawing not implemented
  end
end

function entity:collisionRect(e, x, y)
  return rectOverlaps(self.transform.x, self.transform.y, self:width(), self:height(), 
    e.transform.x, e.transform.y, e:width(), e:height())
end

function entity:collisionTable(t, x, y)
  local result = {}
  if t == nil then return result end
  for k=1, #t do
    local v = t[k]
    if self:collision(v, x, y) then
      result[#result+1] = v
    end
  end
  return result
end

function entity:update(dt) end
function entity:afterUpdate(dt) end
function entity:draw() end
function entity:drawQuality() end
function entity:removed() end
function entity:added() end

mapentity = entity:extend()

mapentity.layers = {}

megautils.cleanFuncs["mapentity_clean"] = function()
  mapentity.layers = {}
end

function mapentity:new(l, map, tran)
  mapentity.super.new(self, tran)
  self.l = l
  self.map = map
  mapentity.layers[self.l.name] = self
end

function mapentity:drawAt(x, y)
  love.graphics.push()
  love.graphics.translate(x, y)
  self.map:drawTileLayer(self.l)
  love.graphics.pop()
end

function mapentity:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self:drawAt(math.round(self.transform.x), math.round(self.transform.y))
end