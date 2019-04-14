entitysystem = class:extend()

entitysystem.drawCollision = false

function entitysystem:new()
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.static = {}
  self.layers = {}
  self.all = {}
  self.addQueue = nil
  self.removeQueue = nil
  self.doSort = false
end

function entitysystem:sortLayers()
  local keys = {}
  local vals = {}
  for k, v in pairs(self.entities) do
    keys[#keys+1] = v.layer
    vals[v.layer] = v
    self.entities[k] = nil
  end
  table.sort(keys)
  for i=1, #keys do
    self.entities[i] = vals[keys[i]]
  end
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
      local done = false
      for k, v in pairs(self.entities) do
        if v.layer == e.layer then
          v.data[#v.data+1] = e
          e.actualLayer = v
          done = true
          break
        end
      end
      if not done then
        self.entities[#self.entities+1] = {["layer"]=e.layer, ["data"]={e}}
        e.actualLayer = self.entities[#self.entities]
        e.layer = e.actualLayer.layer
        self.doSort = true
      end
      self.updates[#self.updates+1] = e
    end
    self.all[#self.all+1] = e
    e.isRemoved = false
    e.isAdded = true
    e:added()
    e.previousX = e.transform.x
    e.previousY = e.transform.y
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
  table.removevaluearray(self.updates, e)
  table.removevaluearray(e.actualLayer.data, e)
  self.static[#self.static+1] = e
  e.static = true
end

function entitysystem:removeStatic(e)
  if e.static then
    table.removevaluearray(self.static, e)
    local done = false
    for k, v in pairs(self.entities) do
      if v.layer == e.layer then
        v.data[#v.data+1] = e
        e.actualLayer = v
        done = true
        break
      end
    end
    if not done then
      self.entities[#self.entities+1] = {["layer"]=e.layer, ["data"]={e}}
      e.actualLayer = self.entities[#self.entities]
      e.layer = e.actualLayer.layer
      self.doSort = true
    end
    self.updates[#self.updates+1] = e
    e.static = false
  end
end

function entitysystem:setLayer(e, l)
  table.removevaluearray(e.actualLayer.data, e)
  e.layer = l
  local done = false
  for k, v in pairs(self.entities) do
    if v.layer == e.layer then
      v.data[#v.data+1] = e
      e.actualLayer = v
      done = true
      break
    end
  end
  if not done then
    self.entities[#self.entities+1] = {["layer"]=e.layer, ["data"]={e}}
    e.actualLayer = self.entities[#self.entities]
    e.layer = e.actualLayer.layer
    self.doSort = true
  end
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
    table.removevaluearray(e.actualLayer.data, e)
    table.removevaluearray(self.updates, e)
    table.removevaluearray(self.all, e)
    e.isAdded = false
  end
end

function entitysystem:clear()
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
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      local v = self.entities[i].data[k]
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

function entitysystem:update(dt)
  for i=1, #self.updates do
    local t = self.updates[i]
    if t.updated and not t.isRemoved then
      t:beforeUpdate(dt)
      if states.switched then
        return
      end
    end
  end
  for i=1, #self.updates do
    local t = self.updates[i]
    t.previousX = t.transform.x
    t.previousY = t.transform.y
    if t.updated and not t.isRemoved then
      t:update(dt)
      if states.switched then
        return
      end
    end
  end
  for i=1, #self.updates do
    local t = self.updates[i]
    if t.updated and not t.isRemoved then
      t:afterUpdate(dt)
      if states.switched then
        return
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
  if self.doSort then
    self.doSort = false
    self:sortLayers()
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
  self.flashRender = true
  self.layer = 0
  self.updateLayer = 0
  self.isRemoved = false
  self.updated = true
  self.render = true
  self.isSolid = 0
  self.velocity = velocity()
  self.gravity = 0.25
  self.blockCollision = false
  self.ground = false
  self.xcoll = 0
  self.ycoll = 0
  self.maxIFrame = 80
  self.iFrame = self.maxIFrame
  self.health = 28
  self.changeHealth = 0
  self.shakeX = 0
  self.shakeY = 0
  self.shakeTime = 0
  self.maxShakeTime = 5
  self.shakeSide = 1
  self.doShake = false
  self.moveByMoveX = 0
  self.moveByMoveY = 0
  self.inv = false
  self.spikesHurt = false
  self.canSink = true
end

function entity:grav() end

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

function entity:removeFromGroup(g)
  megautils.state().system:removeFromGroup(self, g)
end

function entity:inGroup(g)
  return table.contains(states.currentstate.system.groups[g], self)
end

function entity:removeFromAllGroups()
  megautils.state().system:removeFromAllGroups(self, g)
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
      return imageRectOverlaps(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
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

function entity:collisionTable(t, x, y, func)
  local result = {}
  if t == nil then return result end
  for k=1, #t do
    local v = t[k]
    if self:collision(v, x, y) and (func == nil and true or func(v)) then
      result[#result+1] = v
    end
  end
  return result
end

function entity:beforeUpdate(dt) end
function entity:update(dt) end
function entity:afterUpdate(dt) end
function entity:draw() end
function entity:removed() end
function entity:added() end

mapentity = entity:extend()

mapentity.layers = {}

megautils.cleanFuncs["mapentity_clean"] = function()
  mapentity.layers = {}
end

function mapentity:new(name, map)
  mapentity.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.name = name
  self.map = map
  mapentity.layers[self.name] = self
end

function mapentity:drawAt(x, y)
  love.graphics.push()
  love.graphics.translate(x, y)
  self.map.layers[self.name]:draw()
  love.graphics.pop()
end

function mapentity:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self:drawAt(math.round(self.transform.x), math.round(self.transform.y))
end
