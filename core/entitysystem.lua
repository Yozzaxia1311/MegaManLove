entitySystem = class:extend()

entitySystem.drawCollision = false
entitySystem.doBeforeUpdate = true
entitySystem.doAfterUpdate = true
entitySystem.doDrawQuality = false
entitySystem.doDrawFlicker = true

function entitySystem:new()
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.static = {}
  self.all = {}
  self.addQueue = {}
  self.removeQueue = {}
  self.recycle = {}
  self.doSort = false
end

function entitySystem:sortLayers()
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

function entitySystem:emptyRecycling(c, num)
  if not num or num < 1 then
    self.recycling[c] = {}
  elseif num < self.recycling[c] then
    for i=num, #self.recycling[c] do
      self.recycling[c][i] = nil
    end
  end
end

function entitySystem:getRecycled(c, ...)
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

function entitySystem:add(c, ...)
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
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
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
  e.epX = e.previousX
  e.epY = e.previousY
  return e
end

function entitySystem:adde(e)
  if not e or not e.isRemoved or e.isAdded then return end
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
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
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
  e.epX = e.previousX
  e.epY = e.previousY
  return e
end

function entitySystem:addq(c, ...)
  if not c then return end
  self.addQueue[#self.addQueue+1] = self:getRecycled(c, ...)
  return self.addQueue[#self.addQueue]
end

function entitySystem:addeq(e)
  if not e or not e.isRemoved or e.isAdded or table.contains(self.addQueue, e) then return end
  self.addQueue[#self.addQueue+1] = e
  return self.addQueue[#self.addQueue]
end

function entitySystem:addToGroup(e, g)
  if not self.groups[g] then
    self.groups[g] = {}
  end
  if not table.contains(self.groups[g], e) then
    self.groups[g][#self.groups[g]+1] = e
  end
end

function entitySystem:removeFromGroup(e, g)
  table.quickremovevaluearray(self.groups[g], e)
  if #self.groups[g] == 0 then
    self.groups[g] = nil
  end
end

function entitySystem:removeFromAllGroups(e)
  for k, v in pairs(self.groups) do
    self:removeFromGroup(e, k)
  end
end

function entitySystem:makeStatic(e)
  table.quickremovevaluearray(self.updates, e)
  table.quickremovevaluearray(e.actualLayer.data, e)
  if #e.actualLayer.data == 0 then
    table.removevaluearray(self.entities, e.actualLayer)
  end
  self.static[#self.static+1] = e
  e.static = true
  e:staticToggled()
end

function entitySystem:revertFromStatic(e)
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
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
      e.actualLayer = self.entities[#self.entities]
      e.layer = e.actualLayer.layer
      self.doSort = true
    end
    self.updates[#self.updates+1] = e
    e.static = false
    e:staticToggled()
  end
end

function entitySystem:setLayer(e, l)
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
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
      e.actualLayer = self.entities[#self.entities]
      e.layer = e.actualLayer.layer
      self.doSort = true
    end
  end
end

function entitySystem:setLayerFlicker(l, b)
  for i=1, #self.entities do
    if self.entities[i].layer == l then
      self.entities[i].flicker = b
      break
    end
  end
end

function entitySystem:remove(e)
  if not e or e.isRemoved then return end
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

function entitySystem:removeq(e)
  if not e or e.isRemoved or table.contains(self.removeQueue, e) then return end
  self.removeQueue[#self.removeQueue+1] = e
end

function entitySystem:clear()
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
  self.cameraUpdate = nil
  self.doSort = false
end

function entitySystem:draw()
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      local v = self.entities[i].data[k]
      if checkFalse(v.canDraw) and not v.isRemoved and v.draw then
        v:draw()
        love.graphics.setColor(1, 1, 1, 1)
        if entitySystem.drawCollision then
          v:drawCollision()
        end
      end
    end
  end
end

function entitySystem:drawQuality()
  if not entitySystem.doDrawQuality then return end
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      local v = self.entities[i].data[k]
      if checkFalse(v.canDraw) and not v.isRemoved and v.drawQuality then
        v:drawQuality()
      end
    end
  end
end

function entitySystem:update(dt)
  if entitySystem.doBeforeUpdate then
    for i=1, #self.updates do
      local t = self.updates[i]
      t.previousX = t.transform.x
      t.previousY = t.transform.y
      t.epX = t.previousX
      t.epY = t.previousY
      if not t.isRemoved and t.beforeUpdate and checkFalse(t.canUpdate) then
        t:beforeUpdate(dt)
      end
    end
  end
  for i=1, #self.updates do
    local t = self.updates[i]
    t.previousX = t.transform.x
    t.previousY = t.transform.y
    t.epX = t.previousX
    t.epY = t.previousY
    if not t.isRemoved and t.update and checkFalse(t.canUpdate) then
      t:update(dt)
    end
  end
  if entitySystem.doAfterUpdate then
    for i=1, #self.updates do
      local t = self.updates[i]
      t.previousX = t.transform.x
      t.previousY = t.transform.y
      t.epX = t.previousX
      t.epY = t.previousY
      if not t.isRemoved and t.afterUpdate and checkFalse(t.canUpdate) then
        t:afterUpdate(dt)
      end
    end
  end
  if self.cameraUpdate then
    self.cameraUpdate(self)
  end
  for i=#self.removeQueue, 1, -1 do
    self:remove(self.removeQueue[i])
    self.removeQueue[i] = nil
  end
  for i=#self.addQueue, 1, -1 do
    self:adde(self.addQueue[i])
    self.addQueue[i] = nil
  end
  if self.doSort then
    self.doSort = false
    self:sortLayers()
  end
  if entitySystem.doDrawFlicker then
    for i=1, #self.entities do
      if self.entities[i].flicker and #self.entities[i].data > 1 then
        table.shuffle(self.entities[i].data)
      end
    end
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

basicEntity = class:extend()

function basicEntity:new()
  self.transform = {}
  self.transform.x = 0
  self.transform.y = 0
  self.collisionShape = nil
  self.layer = 1
  self.isRemoved = true
  self.isAdded = false
  self.iFrames = 0
  self.changeHealth = 0
  self.canUpdate = {global=true}
  self.canDraw = {global=true}
end

function basicEntity:baseRecycle()
  self.transform.x = 0
  self.transform.y = 0
  self.isRemoved = true
  self.isAdded = false
  self.changeHealth = 0
  self.iFrames = 0
  self.canUpdate = {global=true}
  self.canDraw = {global=true}
end

function basicEntity:hurt(t, h, f, single)
  if single then
    t:gettingHurt(self, h, f or 80)
  else
    for i=1, #t do
      t[i]:gettingHurt(self, h, f or 80)
    end
  end
end

function basicEntity:updateIFrame()
  self.iFrames = math.max(self.iFrames-1, 0)
end

function basicEntity:gettingHurt(other, c, i) end

function basicEntity:setLayer(l)
  if not self.isAdded or self.static then
    self.layer = l or self.layer
  else
    megautils.state().system:setLayer(self, l)
  end
end

function basicEntity:makeStatic()
  megautils.state().system:makeStatic(self)
end

function basicEntity:revertFromStatic()
  megautils.state().system:revertFromStatic(self)
end

function basicEntity:removeFromGroup(g)
  megautils.state().system:removeFromGroup(self, g)
end

function basicEntity:inGroup(g)
  return table.contains(states.currentState.system.groups[g], self)
end

function basicEntity:removeFromAllGroups()
  megautils.state().system:removeFromAllGroups(self, g)
end

function basicEntity:addToGroup(g)
  megautils.state().system:addToGroup(self, g)
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
  if data and type(data[2]) == "string" then
    self.collisionShape.type = 1
    self.collisionShape.data = data[1]
    self.collisionShape.image = data[3]
    self.collisionShape.w = #self.collisionShape.data[1]
    self.collisionShape.h = #self.collisionShape.data
  else
    self.collisionShape.type = 1
    self.collisionShape.data = data
    self.collisionShape.w = #self.collisionShape.data[1]
    self.collisionShape.h = #self.collisionShape.data
  end
end

function basicEntity:collision(e, x, y)
  if not e or not self.collisionShape or not e.collisionShape then return false end
  if self.collisionShape.type == 0 then
    if e.collisionShape.type == 0 then
      return rectOverlapsRect(math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h,
        math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsRect(math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0), self.collisionShape.w, self.collisionShape.h)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsRect(math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.r,
        math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0), self.collisionShape.w, self.collisionShape.h)
    end
  elseif self.collisionShape.type == 1 then
    if e.collisionShape.type == 0 then
      return imageOverlapsRect(math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsImage(math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.w, e.collisionShape.h, e.collisionShape.data)
    elseif e.collisionShape.type == 2 then
      return imageOverlapsCircle(math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.r)
    end
  elseif self.collisionShape.type == 2 then
    if e.collisionShape.type == 0 then
      return circleOverlapsRect(math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0), self.collisionShape.r,
        math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsCircle(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0), self.collisionShape.r)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsCircle(math.round(self.transform.x) + (x or 0), math.round(self.transform.y) + (y or 0), self.collisionShape.r,
        math.round(e.transform.x), math.round(e.transform.y), e.collisionShape.r)
    end
  end
  return false
end

function basicEntity:drawCollision()
  if not self.collisionShape then return end
  love.graphics.setColor(1, 1, 1, 0.8)
  if self.collisionShape.type == 0 then
    love.graphics.rectangle("line", math.round(self.transform.x), math.round(self.transform.y),
      self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 1 and self.collisionShape.image then
    love.graphics.draw(self.collisionShape.image, math.round(self.transform.x), math.round(self.transform.y))
  elseif self.collisionShape.type == 2 then
    love.graphics.circle("line", math.round(self.transform.x), math.round(self.transform.y), self.collisionShape.r)
  end
  love.graphics.setColor(1, 1, 1, 0.8)
end

function basicEntity:collisionTable(t, x, y, func)
  local result = {}
  if not t then return result end
  for k=1, #t do
    local v = t[k]
    if self:collision(v, x, y) and (func == nil and true or func(v)) then
      result[#result+1] = v
    end
  end
  return result
end

function basicEntity:collisionNumber(t, x, y, func)
  local result = 0
  if not t then return result end
  for k=1, #t do
    local v = t[k]
    if self:collision(v, x, y) and (func == nil and true or func(v)) then
      result = result + 1
    end
  end
  return result
end

function basicEntity:beforeUpdate(dt) end
function basicEntity:update(dt) end
function basicEntity:afterUpdate(dt) end
function basicEntity:draw() end
function basicEntity:drawQuality() end
function basicEntity:removed() end
function basicEntity:added() end
function basicEntity:staticToggled() end

entity = basicEntity:extend()

function entity:new()
  entity.super.new(self)
  self.canDraw.flash = true
  self.solidType = collision.NONE
  self.velocity = velocity()
  self.normalGravity = 0.25
  self.gravityMultipliers = {global=1}
  self:calcGrav()
  self.blockCollision = false
  self.ground = false
  self.xColl = 0
  self.yColl = 0
  self.shakeX = 0
  self.shakeY = 0
  self.shakeTime = 0
  self.maxShakeTime = 5
  self.shakeSide = 1
  self.doShake = false
  self.moveByMoveX = 0
  self.moveByMoveY = 0
  self.canBeInvincible = {global=false}
  self.canStandSolid = {global=true}
end

function entity:baseRecycle()
  entity.super.baseRecycle(self)
  self.canDraw.flash = true
  self.velocity.velx = 0
  self.velocity.vely = 0
  self.normalGravity = 0.25
  self.gravityMultipliers = {global=1}
  self:calcGrav()
  self.ground = false
  self.xColl = 0
  self.yColl = 0
  self.shakeX = 0
  self.shakeY = 0
  self.shakeTime = 0
  self.maxShakeTime = 5
  self.shakeSide = 1
  self.doShake = false
  self.moveByMoveX = 0
  self.moveByMoveY = 0
  self.canBeInvincible = {global=true}
  self.canStandSolid = {global=true}
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

function entity:setGravityMultiplier(name, to)
  local old = self.gravityMultipliers[name]
  self.gravityMultipliers[name] = to
  if old ~= self.gravityMultipliers[name] then
    self:calcGrav()
  end
end

function entity:calcGrav()
  self.gravity = self.normalGravity
  for k, v in pairs(self.gravityMultipliers) do
    self.gravity = self.gravity*v
  end
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
  if self.iFrames == 0 then
    self.canDraw.flash = true
  else
    self.canDraw.flash = math.wrap(self.iFrames, 0, length or 8) > (range or 4)
  end
end

mapEntity = basicEntity:extend()

function mapEntity:new(map, x, y)
  mapEntity.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.map = map
  self.path = self.map.path
  self:setLayer(-5)
end

function mapEntity:added()
  self:addToGroup("freezable")
  self:addToGroup("map")
  for k, v in pairs(megautils.addMapFuncs) do
    v(self)
  end
end

function mapEntity:removed()
  for k, v in pairs(megautils.removeMapFuncs) do
    v(self)
  end
end

function mapEntity:recursiveChecker(tab, index, name)
  if tab and tab.layers then
    for k, v in pairs(tab.layers) do
      if v[index] == name then
        return v
      elseif v.type == "group" then
        return self:recursiveChecker(v, index, name)
      end
    end
  end
end

function mapEntity:recursiveObjectFinder(tab, otab)
  for k, v in pairs(tab.layers) do
    if v.type == "objectgroup" then
      for i, j in pairs(v.objects) do
        otab[#otab+1] = j
      end
    elseif v.type == "group" then
      self:recursiveObjectFinder(v, otab)
    end
  end
  return otab
end

function mapEntity:getLayerByName(name)
  return self:recursiveChecker(self.map, "name", name)
end

function mapEntity:getLayerByID(id)
  return self:recursiveChecker(self.map, "id", name)
end

function mapEntity:addObjects()
  addobjects.add(self:recursiveObjectFinder(self.map, {}))
end

function mapEntity:update(dt)
  self.map:update(defaultFramerate)
end

function mapEntity:draw()
  love.graphics.push()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.translate(-self.transform.x, -self.transform.y)
  self.map:setDrawRange(view.x, view.y, view.w, view.h)
  self.map:draw()
  love.graphics.pop()
end