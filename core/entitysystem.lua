entitysystem = class:extend()

entitysystem.drawCollision = false
entitysystem.doBeforeUpdate = true
entitysystem.doAfterUpdate = true
entitysystem.doDrawQuality = false

function entitysystem:new()
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.static = {}
  self.layers = {}
  self.all = {}
  self.addQueue = {}
  self.removeQueue = {}
  self.recycle = {}
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

function entitysystem:emptyRecycling(c, num)
  if not num or num < 1 then
    self.recycling[c] = {}
  elseif num < self.recycling[c] then
    for i=num, #self.recycling[c] do
      self.recycling[c][i] = nil
    end
  end
end

function entitysystem:getRecycled(c, ...)
  local e
  local vr = self.recycle[c]
  if vr and #vr > 0 then
    e = vr[#vr]
    e:baseRecycle()
    e:recycle(...)
    vr[#vr] = nil
  end
  if not e then e = c(...) end
  return e
end

function entitysystem:add(c, ...)
  if not c then return end
  local e = self:getRecycled(c, ...)
  if not e.static then
    local done = false
    for i=1, #self.entities do
      local v = self.entities[i]
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
  return e
end

function entitysystem:adde(e)
  if not e then return end
  if not e.static then
    local done = false
    for i=1, #self.entities do
      local v = self.entities[i]
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
  return e
end

function entitysystem:addq(c, ...)
  if not c then return end
  if not table.contains(self.addQueue, c) then
    self.addQueue[#self.addQueue+1] = self:getRecycled(c, ...)
    return self.addQueue[#self.addQueue]
  end
end

function entitysystem:removeFromGroup(e, g)
  table.quickremovevaluearray(self.groups[g], e)
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
  table.quickremovevaluearray(self.updates, e)
  table.quickremovevaluearray(e.actualLayer.data, e)
  if #e.actualLayer.data == 0 then
    table.removevaluearray(self.entities, e.actualLayer)
  end
  self.static[#self.static+1] = e
  e.static = true
  e:staticToggled()
end

function entitysystem:removeStatic(e)
  if e.static then
    table.quickremovevaluearray(self.static, e)
    local done = false
    for i=1, #self.entities do
      local v = self.entities[i]
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
    e:staticToggled()
  end
end

function entitysystem:setLayer(e, l)
  if l and e.layer ~= l then
    table.quickremovevaluearray(e.actualLayer.data, e)
    if #e.actualLayer.data == 0 then
      table.removevaluearray(self.entities, e.actualLayer)
    end
    e.layer = l
    local done = false
    for i=1, #self.entities do
      local v = self.entities[i]
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
end

function entitysystem:remove(e, queue)
  if e == nil then return end
  if queue then
    if not table.contains(self.removeQueue, e) then
      self.removeQueue[#self.removeQueue+1] = e
    end
  elseif not e.isRemoved and e.isAdded then
    e.isRemoved = true
    e:removed()
    e:removeFromAllGroups()
    if e.static then
      table.quickremovevaluearray(self.static, e)
      e.static = false
      e:staticToggled()
    else
      table.quickremovevaluearray(e.actualLayer.data, e)
      table.quickremovevaluearray(self.updates, e)
    end
    if #e.actualLayer.data == 0 then
      table.removevaluearray(self.entities, e.actualLayer)
    end
    table.quickremovevaluearray(self.all, e)
    e.isAdded = false
    if e.recycle then
      if not self.recycle[e.__index] then
        self.recycle[e.__index] = {e}
      elseif not table.contains(self.recycle[e.__index], e) then
        self.recycle[e.__index][#self.recycle[e.__index]+1] = e
      end
    end
  end
end

function entitysystem:clear()
  for i=1, #self.all do
    self.all[i].isRemoved = true
    self.all[i]:removed()
    self.all[i].isAdded = false
  end
  section.sections = {}
  section.current = nil
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.static = {}
  self.addQueue = {}
  self.removeQueue = {}
  self.recycle = {}
  self.afterUpdate = nil
end

function entitysystem:draw()
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      local v = self.entities[i].data[k]
      if v.render and (v.flashRender == nil and true or v.flashRender) and not v.isRemoved and v.draw then
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

function entitysystem:drawQuality()
  if not entitysystem.doDrawQuality then return end
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      local v = self.entities[i].data[k]
      if v.render and (v.flashRender == nil and true or v.flashRender) and not v.isRemoved and v.drawQuality then
        if states.switched then
          return
        end
        v:drawQuality()
      end
    end
  end
end

function entitysystem:update(dt)
  if entitysystem.doBeforeUpdate then
    for i=1, #self.updates do
      local t = self.updates[i]
      if t.updated and not t.isRemoved and t.beforeUpdate then
        t:beforeUpdate(dt)
        if states.switched then
          return
        end
      end
    end
  end
  for i=1, #self.updates do
    local t = self.updates[i]
    t.previousX = t.transform.x
    t.previousY = t.transform.y
    if t.updated and not t.isRemoved and t.update then
      t:update(dt)
      if states.switched then
        return
      end
    end
  end
  if entitysystem.doAfterUpdate then
    for i=1, #self.updates do
      local t = self.updates[i]
      if t.updated and not t.isRemoved and t.afterUpdate then
        t:afterUpdate(dt)
        if states.switched then
          return
        end
      end
    end
  end
  if self.afterUpdate then
    self.afterUpdate(self)
  end
  for i=1, #self.addQueue do
    self:adde(self.addQueue[i])
    self.addQueue[i] = nil
  end
  for i=1, #self.removeQueue do
    self:remove(self.removeQueue[i])
    self.removeQueue[i] = nil
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

function entity:new()
  self.isAdded = false
  self.transform = {}
  self.transform.x = 0
  self.transform.y = 0
  self.collisionShape = nil
  self.flashRender = true
  self.layer = 0
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
  self.canBeInvincible = {["global"]=true}
  self.canStandSolid = {["global"]=true}
end

function entity:baseRecycle()
  self.transform.x = 0
  self.transform.y = 0
  self.flashRender = true
  self.updated = true
  self.render = true
  self.isSolid = 0
  self.velocity.velx = 0
  self.velocity.vely = 0
  self.gravity = 0.25
  self.blockCollision = false
  self.ground = false
  self.xcoll = 0
  self.ycoll = 0
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
  self.canBeInvincible = {["global"]=true}
  self.canStandSolid = {["global"]=true}
end

function entity:checkTrue(w)
  for k, v in pairs(w) do
    if v then return true end
  end
  return false
end

function entity:checkFalse(w)
  for k, v in pairs(w) do
    if not v then return false end
  end
  return true
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

function entity:hurt(t, h, f, single)
  if single then
    t:healthChanged(self, h, f or 80)
  else
    for i=1, #t do
      t[i]:healthChanged(self, h, f or 80)
    end
  end
end

function entity:healthChanged(other, c, i) end

function entity:updateIFrame()
  self.iFrame = math.min(self.iFrame+1, self.maxIFrame)
end

function entity:setLayer(l)
  if not self.isAdded or self.static then
    self.layer = l or self.layer
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

function entity:setCircleCollision(r)
  self.collisionShape = {}
  self.collisionShape.type = 2
  self.collisionShape.r = r
  self.collisionShape.w = r
  self.collisionShape.h = r
end

function entity:setImageCollision(data)
  self.collisionShape = {}
  self.collisionShape.type = 1
  self.collisionShape.data = data[1]
  self.collisionShape.image = data[2]
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
      return rectOverlapsRect(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsRect(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.w, self.collisionShape.h)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsRect(e.transform.x, e.transform.y, e.collisionShape.r,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.w, self.collisionShape.h)
    end
  elseif self.collisionShape.type == 1 then
    if e.collisionShape.type == 0 then
      return imageOverlapsRect(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsImage(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data)
    elseif e.collisionShape.type == 2 then
      return imageOverlapsCircle(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.r)
    end
  elseif self.collisionShape.type == 2 then
    if e.collisionShape.type == 0 then
      return circleOverlapsRect(self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.r,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsCircle(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.r)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsCircle(self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.r,
        e.transform.x, e.transform.y, e.collisionShape.r)
    end
  end
  return false
end

function entity:drawCollision()
  if self.collisionShape == nil then return false end
  love.graphics.setColor(1, 1, 1, 1)
  if self.collisionShape.type == 0 then
    love.graphics.rectangle("line", math.round(self.transform.x), math.round(self.transform.y),
      self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 1 then
    love.graphics.draw(self.collisionShape.image, math.round(self.transform.x), math.round(self.transform.y))
  elseif self.collisionShape.type == 2 then
    love.graphics.circle("line", math.round(self.transform.x), math.round(self.transform.y), self.collisionShape.r)
  end
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
function entity:drawQuality() end
function entity:removed() end
function entity:added() end
function entity:staticToggled() end

basicEntity = class:extend()

function basicEntity:new()
  self.isAdded = false
  self.transform = {}
  self.transform.x = 0
  self.transform.y = 0
  self.collisionShape = nil
  self.layer = 0
  self.isRemoved = false
  self.updated = true
  self.render = true
  self.gravity = 0
end

function basicEntity:baseRecycle()
  self.transform.x = 0
  self.transform.y = 0
  self.updated = true
  self.render = true
  self.gravity = 0
end

function basicEntity:hurt(t, h, f, single)
  if single then
    t:healthChanged(self, h, f or 80)
  else
    for i=1, #t do
      t[i]:healthChanged(self, h, f or 80)
    end
  end
end

function basicEntity:setLayer(l)
  if not self.isAdded or self.static then
    self.layer = l or self.layer
  else
    megautils.state().system:setLayer(self, l)
  end
end

function basicEntity:addStatic()
  megautils.state().system:addStatic(self)
end

function basicEntity:removeStatic()
  megautils.state().system:removeStatic(self)
end

function basicEntity:removeFromGroup(g)
  megautils.state().system:removeFromGroup(self, g)
end

function basicEntity:inGroup(g)
  return table.contains(states.currentstate.system.groups[g], self)
end

function basicEntity:removeFromAllGroups()
  megautils.state().system:removeFromAllGroups(self, g)
end

function basicEntity:addToGroup(g)
  if states.currentstate.system.groups[g] == nil then
    states.currentstate.system.groups[g] = {}
  end
  if not table.contains(states.currentstate.system.groups[g], self) then
    table.insert(states.currentstate.system.groups[g], self)
  end
end

function basicEntity:setRectangleCollision(w, h)
  self.collisionShape = {}
  self.collisionShape.type = 0
  self.collisionShape.w = w
  self.collisionShape.h = h
end

function basicEntity:setCircleCollision(r)
  self.collisionShape = {}
  self.collisionShape.type = 2
  self.collisionShape.r = r
  self.collisionShape.w = r
  self.collisionShape.h = r
end

function basicEntity:setImageCollision(data)
  self.collisionShape = {}
  self.collisionShape.type = 1
  self.collisionShape.data = data[1]
  self.collisionShape.image = data[2]
  self.collisionShape.w = #self.collisionShape.data[1]
  self.collisionShape.h = #self.collisionShape.data
end

function basicEntity:collision(e, x, y)
  if e == nil or self.collisionShape == nil or e.collisionShape == nil then return false end
  if self.collisionShape.type == 0 then
    if e.collisionShape.type == 0 then
      return rectOverlapsRect(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsRect(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.w, self.collisionShape.h)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsRect(e.transform.x, e.transform.y, e.collisionShape.r,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.w, self.collisionShape.h)
    end
  elseif self.collisionShape.type == 1 then
    if e.collisionShape.type == 0 then
      return imageOverlapsRect(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsImage(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data)
    elseif e.collisionShape.type == 2 then
      return imageOverlapsCircle(self.transform.x + (x or 0), self.transform.y + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        e.transform.x, e.transform.y, e.collisionShape.r)
    end
  elseif self.collisionShape.type == 2 then
    if e.collisionShape.type == 0 then
      return circleOverlapsRect(self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.r,
        e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsCircle(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.r)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsCircle(self.transform.x + (x or 0), self.transform.y + (y or 0), self.collisionShape.r,
        e.transform.x, e.transform.y, e.collisionShape.r)
    end
  end
  return false
end

function basicEntity:drawCollision()
  if self.collisionShape == nil then return false end
  love.graphics.setColor(1, 1, 1, 0.8)
  if self.collisionShape.type == 0 then
    love.graphics.rectangle("line", math.round(self.transform.x), math.round(self.transform.y),
      self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 1 then
    love.graphics.draw(self.collisionShape.image, math.round(self.transform.x), math.round(self.transform.y))
  elseif self.collisionShape.type == 2 then
    love.graphics.circle("line", math.round(self.transform.x), math.round(self.transform.y), self.collisionShape.r)
  end
  love.graphics.setColor(1, 1, 1, 0.8)
end

function basicEntity:collisionTable(t, x, y, func)
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

function basicEntity:update(dt) end
function basicEntity:draw() end
function basicEntity:removed() end
function basicEntity:added() end
function basicEntity:staticToggled() end

mapentity = basicEntity:extend()

mapentity.layers = {}
mapentity.cache = {}

megautils.cleanFuncs["mapentity_clean"] = function()
  mapentity.layers = {}
  mapentity.cache = {}
end

function mapentity:new(name, map)
  mapentity.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.name = name
  if type(map) == "string" and not mapentity.cache[map] then
    mapentity.cache[map] = cartographer.load(map)
  end
  self.map = type(map) == "string" and mapentity.cache[map] or map
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
