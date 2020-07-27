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
  self.beginQueue = {}
  self.recycle = {}
  self.doSort = false
  self.inLoop = false
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
  if not c then error("Class does not exist.") end
  local e
  local vr = self.recycle[c]
  if vr and #vr > 0 then
    e = vr[#vr]
    e.recycling = true
    e:new(...)
    e.recycling = nil
    vr[#vr] = nil
  end
  if not e then e = c(...) end
  return e
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
  if self.inLoop then
    e:begin()
  else
    self.beginQueue[#self.beginQueue+1] = e
  end
  e.previousX = e.transform.x
  e.previousY = e.transform.y
  e.epX = e.previousX
  e.epY = e.previousY
  if e.calcGrav then
    e:calcGrav()
  end
  return e
end

function entitySystem:adde(e)
  if not e or not e.isRemoved or e.isAdded or table.contains(self.updates, e) then return end
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
  if self.inLoop then
    e:begin()
  else
    self.beginQueue[#self.beginQueue+1] = e
  end
  e.previousX = e.transform.x
  e.previousY = e.transform.y
  e.epX = e.previousX
  e.epY = e.previousY
  if e.calcGrav then
    e:calcGrav()
  end
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
  table.quickremovevaluearray(self.beginQueue, e)
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
  self.all = {}
  section.sections = {}
  section.current = nil
  self.entities = {}
  self.updates = {}
  self.groups = {}
  self.static = {}
  self.addQueue = {}
  self.removeQueue = {}
  self.cameraUpdate = nil
  self.doSort = false
  self.beginQueue = {}
end

function entitySystem:draw()
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      if states.switched then
        return
      end
      local v = self.entities[i].data[k]
      if checkFalse(v.canDraw) and not v.isRemoved and v.draw then
        v:draw()
        if entitySystem.drawCollision then
          love.graphics.setColor(1, 1, 1, 1)
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
      if states.switched then
        return
      end
      local v = self.entities[i].data[k]
      if checkFalse(v.canDraw) and not v.isRemoved and v.drawQuality then
        v:drawQuality()
      end
    end
  end
end

function entitySystem:update(dt)
  for i=#self.beginQueue, 1, -1 do
    self.beginQueue[i]:begin()
    self.beginQueue[i] = nil
  end
  self.inLoop = true
  if entitySystem.doBeforeUpdate then
    for i=1, #self.updates do
      if states.switched then
        return
      end
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
    if states.switched then
      return
    end
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
      if states.switched then
        return
      end
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
  self.inLoop = false
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
  if not self.recycling then
    self.transform = {}
    self.collisionShape = nil
    self.layer = 1
    self.isRemoved = true
    self.isAdded = false
    self.recycle = false
  end
  
  self.transform.x = 0
  self.transform.y = 0
  self.iFrames = 0
  self.changeHealth = 0
  self.canUpdate = {global=true}
  self.canDraw = {global=true}
end

function basicEntity:determineIFrames(o)
  if megaMan.allPlayers and table.contains(megaMan.allPlayers, o) then
    return 80
  end
  return 2
end

function basicEntity:interact(t, h, single)
  if single then
    t:interactedWith(self, h)
  else
    for i=1, #t do
      t[i]:interactedWith(self, h)
    end
  end
end

function basicEntity:updateIFrame()
  self.iFrames = math.max(self.iFrames-1, 0)
end

function basicEntity:interactedWith(other, c) end

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

function basicEntity:collision(e, x, y, notme)
  if not e or (notme and e == self) or not self.collisionShape or not e.collisionShape then return false end
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
  if self.collisionShape.type == 0 then
    love.graphics.rectangle("line", math.round(self.transform.x), math.round(self.transform.y),
      self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 1 and self.collisionShape.image then
    love.graphics.draw(self.collisionShape.image, math.round(self.transform.x), math.round(self.transform.y))
  elseif self.collisionShape.type == 2 then
    love.graphics.circle("line", math.round(self.transform.x), math.round(self.transform.y), self.collisionShape.r)
  end
end

function basicEntity:collisionTable(t, x, y, notme, func)
  local result = {}
  if not t then return result end
  for k=1, #t do
    local v = t[k]
    if self:collision(v, x, y, notme) and (func == nil and true or func(v)) then
      result[#result+1] = v
    end
  end
  return result
end

function basicEntity:collisionNumber(t, x, y, notme, func)
  local result = 0
  if not t then return result end
  for k=1, #t do
    local v = t[k]
    if self:collision(v, x, y, notme) and (func == nil and true or func(v)) then
      result = result + 1
    end
  end
  return result
end

function basicEntity:beforeUpdate() end
function basicEntity:update() end
function basicEntity:afterUpdate() end
function basicEntity:draw() end
function basicEntity:drawQuality() end
function basicEntity:removed() end
function basicEntity:added() end
function basicEntity:begin() end
function basicEntity:staticToggled() end

entity = basicEntity:extend()

function entity:new()
  entity.super.new(self)
  
  self.gravityMultipliers = {global=1}
  
  if self.recycling then
    self.velocity.velx = 0
    self.velocity.vely = 0
  else
    self.solidType = collision.NONE
    self.velocity = velocity()
    self.normalGravity = 0.25
    self:calcGrav()
    self.doShake = false
    self.maxShakeTime = 5
  end
  
  self.canDraw.flash = true
  self.blockCollision = {global=false}
  self.ground = false
  self.xColl = 0
  self.yColl = 0
  self.shakeX = 0
  self.shakeY = 0
  self.shakeTime = 0
  self.shakeSide = 1
  self.moveByMoveX = 0
  self.moveByMoveY = 0
  self.canBeInvincible = {global=false}
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
    self.canDraw.flash = math.wrap(self.iFrames, 0, length or 4) > (range or 2)
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

function mapEntity:begin()
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
  if not otab then
    otab = {}
  end
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
  addObjects.add(self:recursiveObjectFinder(self.map), self.map)
  for k, v in pairs(megautils.postAddObjectsFuncs) do
    v(self)
  end
end

function mapEntity:update()
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

pierce = {}

pierce.NOPIERCE = 0
pierce.PIERCE = 1
pierce.PIERCEIFKILLING = 2

enemyEntity = entity:extend()

enemyEntity.SMALLBLAST = 1
enemyEntity.BIGBLAST = 2
enemyEntity.DEATHBLAST = 3

function enemyEntity:new()
  enemyEntity.super.new(self)
  if not self.recycling then
    self:setRectangleCollision(16, 16)
    self.explosionType = enemyEntity.SMALLBLAST
    self.removeOnDeath = true
    self.dropItem = true
    self.health = 1
    self.soundOnHit = "enemyHit"
    self.soundOnDeath = "enemyExplode"
    self.autoHitPlayer = true
    self.damage = -1
    self.flipWithPlayer = true
    self.defeatSlot = nil
    self.defeatSlotValue = nil
    self.removeWhenOutside = true
    self.removeHealthBarWithSelf = true
    self.barRelativeToView = true
    self.barOffsetX = (view.w - 24)
    self.barOffsetY = 80
    self.applyAutoFace = true
    self.pierceType = pierce.NOPIERCE
    self.autoCollision = true
    self.autoGravity = true
    self.doAutoCollisionBeforeUpdate = false
  end
  
  self.dead = false
  self.closest = nil
  self._didCol = false
  self.healthHandler = nil
  self.blockCollision.global = true
  self.autoFace = -1
  self.side = -1
end

function enemyEntity:added()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("collision")
  self:addToGroup("handledBySection")
  self:addToGroup("hurtable")
end

function enemyEntity:useHealthBar(oneColor, twoColor, outlineColor, add)
  if (add == nil) or add then
    self.healthHandler = megautils.add(healthHandler, oneColor or {128, 128, 128}, twoColor or {255, 255, 255}, outlineColor or {0, 0, 0},
      nil, nil, math.ceil(self.health/4))
  else
    self.healthHandler = healthHandler(oneColor or {128, 128, 128}, twoColor or {255, 255, 255}, outlineColor or {0, 0, 0},
      nil, nil, math.ceil(self.health/4))
  end
  self.healthHandler:instantUpdate(self.health)
  self.health = nil
  if camera.main then
    camera.main.funcs[self] = function(s)
        self.healthHandler.transform.x = (self.barRelativeToView and view.x or 0) + self.barOffsetX
        self.healthHandler.transform.y = (self.barRelativeToView and view.y or 0) + self.barOffsetY
      end
  end
end

function enemyEntity:removed()
  if self.removeHealthBarWithSelf and self.healthHandler then
    if camera.main then
      camera.main.funcs[self] = nil
    end
    if not self.healthHandler.isRemoved then
      megautils.removeq(self.healthHandler)
    end
  end
end

function enemyEntity:begin()
  self:addToGroup("hurtable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("freezable")
end

function enemyEntity:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(7)
end

function enemyEntity:getHealth()
  return self.healthHandler and self.healthHandler.health or self.health
end

function enemyEntity:hit(o) end
function enemyEntity:die(o) end
function enemyEntity:determineDink(o) end
function enemyEntity:weaponTable(o) end

function enemyEntity:beforeUpdate()
  if self.flipWithPlayer and megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  local s, n = megautils.side(self, megaMan.allPlayers)
  self.autoFace = s or self.autoFace
  if self.applyAutoFace then
    self.side = self.autoFace
  end
  self.closest = n
  if self.autoGravity then
    collision.doGrav(self)
  end
  self._didCol = false
  if self.doAutoCollisionBeforeUpdate then
    collision.doCollision(self)
    self._didCol = true
  end
end

function enemyEntity:afterUpdate()
  if self.autoCollision and not self.doAutoCollisionBeforeUpdate and not self._didCol then
    collision.doCollision(self)
  end
  self:updateFlash()
  self:updateIFrame()
  self:updateShake()
  if self.autoHitPlayer then
    self:interact(self:collisionTable(megaMan.allPlayers), self.damage)
  end
  if self.removeWhenOutside and megautils.outside(self) then
    megautils.removeq(self)
  end
end

function enemyEntity:determineIFrames(o)
  if megaMan.allPlayers and table.contains(megaMan.allPlayers, o) then
    return 80
  end
  return 2
end

function enemyEntity:interactedWith(o, c)
  local doDink = self:determineDink(o)
  
  if checkTrue(self.canBeInvincible) or doDink then
    if doDink and o.dink and not o.dinked then
      o:dink(self)
    end
    return
  end
  
  local health = self.healthHandler and self.healthHandler.health or self.health
  
  self.changeHealth = c
  self.changeHealth = self:weaponTable(o) or self.changeHealth
  
  if self.changeHealth < 0 then
    if o.pierceType == pierce.NOPIERCE or (o.pierceType == pierce.PIERCEIFKILLING and health + self.changeHealth > 0) then
      megautils.removeq(o)
    end
    if self.iFrames <= 0 then
      self.iFrames = o:determineIFrames(self)
    else
      return
    end
  end
  
  if health + self.changeHealth <= 0 then
    self.dead = true
    if self.healthHandler then
      self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
    else
      self.health = math.max(self.health + self.changeHealth, 0)
    end
    self:die(o)
    if self.defeatSlot then
      globals.defeats[self.defeatSlot] = self.defeatSlotValue or true
    end
    if self.explosionType == enemyEntity.SMALLBLAST then
      megautils.add(smallBlast, self.transform.x+(self.collisionShape.w/2)-12, self.transform.y+(self.collisionShape.h/2)-12)
    elseif self.explosionType == enemyEntity.BIGBLAST then
      megautils.add(blast, self.transform.x+(self.collisionShape.w/2)-12, self.transform.y+(self.collisionShape.h/2)-12)
    elseif self.explosionType == enemyEntity.DEATHBLAST then
      explodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-12),
        self.transform.y+((self.collisionShape.h/2)-12))
    end
    if self.dropItem then
      local item
      if self.dropItem == true then
        item = megautils.dropItem(self.transform.x, self.transform.y)
      else
        item = megautils.adde(self.dropItem)
      end
      if item then
        item.transform.x = self.transform.x+(self.collisionShape.w/2)-(item.collisionShape.w/2)
        item.transform.y = self.transform.y+(self.collisionShape.h/2)-(item.collisionShape.h/2) - 8
      end
    end
    if self.removeOnDeath then
      megautils.removeq(self)
    end
    if self.soundOnDeath then
      if megautils.getResource(self.soundOnDeath) then
        megautils.playSound(self.soundOnDeath)
      else
        megautils.playSoundFromFile(self.soundOnDeath)
      end
    end
  elseif self.changeHealth < 0 then
    if self.healthHandler then
      self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
    else
      self.health = math.max(self.health + self.changeHealth, 0)
    end
    self:hit(o)
    if o.pierceIfKilling then
      megautils.removeq(o)
    end
    if self.soundOnHit then
      if megautils.getResource(self.soundOnHit) then
        megautils.playSound(self.soundOnHit)
      else
        megautils.playSoundFromFile(self.soundOnHit)
      end
    end
  else
    if self.healthHandler then
      self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
    else
      self.health = math.max(self.health + self.changeHealth, 0)
    end
  end
end

bossEntity = enemyEntity:extend()

function bossEntity:new()
  bossEntity.super.new(self)
  self.soundOnDeath = "assets/sfx/dieExplode.ogg"
  self.dropItem = false
  self.state = 0
  self._subState = 0
  self.canDraw.global = false
  self.canBeInvincible.intro = true
  self.skipBoss = false
  self.skipBossState = "assets/states/menus/menu.state.tmx"
  self.doIntro = true
  self.strikePose = true
  self.continueAfterDeath = false
  self.afterDeathState = weaponGetState
  self.weaponGetMenuState = "assets/states/menus/menu.state.tmx"
  self.defeatSlot = nil
  self.doBossIntro = megautils.getCurrentState() == globals.bossIntroState
  self.bossIntroText = nil
  self.weaponGetText = "WEAPON GET... (NAME HERE)"
  self.stageState = nil
  self.bossIntroWaitTime = 400
  self.removeHealthBarWithSelf = false
  self.weaponGetBehaviour = function(m)
      return true
    end
  self.explosionType = enemyEntity.DEATHBLAST
  self.soundOnDeath = "assets/sfx/dieExplode.ogg"
  self.flipWithPlayer = false
  self.removeWhenOutside = false
  self:setMusic("assets/sfx/music/boss.wav", true, 162898, 444759)
  self:setBossIntroMusic("assets/sfx/music/stageStart.ogg")
end

function bossEntity:useHealthBar(oneColor, twoColor, outlineColor, add)
  bossEntity.super.useHealthBar(self, oneColor, twoColor, outlineColor, add or add ~= nil)
end

function bossEntity:setMusic(p, l, lp, lep, v)
  self.musicPath = p
  self.musicLoop = l == nil or l
  self.musicLoopPoint = lp
  self.musicLoopEndPoint = lep
  self.musicVolume = v or 1
end

function bossEntity:setBossIntroMusic(p, v)
  self.musicBIPath = p
  self.musicBIVolume = v or 1
end

function bossEntity:intro()
  if not self.ds then
    self.screen = megautils.add(trigger, nil, function(s)
      love.graphics.setColor(0, 0, 0, s.o)
      love.graphics.rectangle("fill", view.x-1, view.y-1, view.w+2, view.h+2)
    end)
    self.screen.o = 0
    self.screen:setLayer(0)
    self.ds = 1
    self.dOff = view.y-self.transform.y
    self.oldY = self.transform.y
  elseif self.ds == 1 then
    self.canDraw.global = true
    self.screen.o = math.min(self.screen.o+0.05, 0.4)
    self.dOff = math.min(self.dOff+1, 0)
    self.transform.y = self.oldY + self.dOff
    if self.transform.y == self.oldY then
      self.ds = 2
    end
  elseif self.ds == 2 then
    self.screen.o = math.max(self.screen.o-0.05, 0)
    if self.screen.o == 0 then
      megautils.removeq(self.screen)
      self.screen = nil
      self.dOff = nil
      self.oldY = nil
      self.ds = nil
      return true
    end
  end
end

function bossEntity:pose()
  return true
end

function bossEntity:skip()
  timer.winCutscene(function()
      megautils.reloadState = true
      megautils.resetGameObjects = true
      megautils.gotoState(self.skipBossState)
    end)
  megautils.removeq(self)
  megautils.stopMusic()
  return true
end

function bossEntity:act() end

function bossEntity:start()
  if self._subState == 0 then
    if self.skipBoss == nil and (self.defeatSlot and globals.defeats[self.defeatSlot]) or self.skipBoss then
      self:skip()
    elseif megaMan.allPlayers then
      megautils.autoFace(self, megaMan.allPlayers)
      for k, v in ipairs(megaMan.allPlayers) do
        v.canControl.boss = false
        v.canBeInvincible.intro = true
        v.velocity.velx = 0
        v:resetStates()
        megautils.autoFace(v, self, true)
      end
      self._subState = 1
    end
  elseif self._subState == 1 then
    local result = {}
    for k, v in ipairs(megaMan.allPlayers) do
      if not v.drop and not v.rise then
        v:phys()
        if v.ground then
          result[k] = true
          v.anims:set("idle")
        else
          result[k] = false
        end
      else
        result[k] = false
      end
    end
    if not table.contains(result, false) then
      self._subState = 2
      if self.musicPath then
        megautils.playMusic(self.musicPath, self.musicLoop, self.musicLoopPoint, self.musicLoopEndPoint, self.musicVolume)
      end
    end
  elseif self._subState == 2 then
    if not self.doIntro or self:intro() then
      self._subState = 3
    end
  elseif self._subState == 3 then
    if not self.strikePose or self:pose() then
      self._subState = nil
      if megaMan.allPlayers then
        for k, v in ipairs(megaMan.allPlayers) do
          v.canControl.boss = nil
          v.canBeInvincible.intro = nil
        end
        self.canBeInvincible.intro = nil
      end
      return true
    end
  end
end

function bossEntity:die(o)
  megautils.removeEnemyShots()
  if not self.continueAfterDeath then
    timer.absorbCutscene(function()
        if self.afterDeathState == globals.weaponGetState then
          globals.weaponGetText = self.weaponGetText
          globals.weaponGetBehaviour = self.weaponGetBehaviour
          globals.wgMenuState = self.weaponGetMenuState
          globals.wgValue = self.defeatSlotValue
        end
        megautils.reloadState = true
        megautils.resetGameObjects = true
        megautils.gotoState(self.afterDeathState)
      end)
    megautils.stopMusic()
  end
end

function bossEntity:hit(o)
  megautils.add(harm, self, 50)
  self.iFrames = 50
end

function bossEntity:bossIntro()
  if self._subState == 0 then
    self.transform.x = math.floor(view.w/2)-(self.collisionShape.w/2)
    self.transform.y = -self.collisionShape.h
    self.canDraw.global = true
    self._timer = 0
    self._textPos = 0
    self._textTimer = 0
    self._subState = 1
    self._textObj = love.graphics.newText(mmFont, self.bossIntroText)
    self._halfWidth = self._textObj:getWidth()/2
    self._textObj:set("")
    if self.musicBIPath then
      megautils.playMusic(self.musicBIPath, false, nil, nil, self.musicBIVolume)
    end
  elseif self._subState == 1 then
    self.transform.y = math.min(self.transform.y+10, math.floor(view.h/2)-(self.collisionShape.h/2))
    if self.transform.y == math.floor(view.h/2)-(self.collisionShape.h/2) then
      self._subState = 2
    end
  elseif self._subState == 2 then
    if self:pose() then
      self._subState = 3
    end
  elseif self._subState == 3 then
    self._timer = self._timer + 1
    if self._timer < self.bossIntroWaitTime then
      if self.bossIntroText then
        self._textTimer = math.min(self._textTimer+1, 8)
        if self._textTimer == 8 then
          self._textTimer = 0
          self._textPos = math.min(self._textPos+1, self.bossIntroText:len())
        end
      end
    else
      megautils.transitionToState(self.stageState)
    end
  end
end

function bossEntity:update()
  if self.doBossIntro then
    self:bossIntro()
  else
    if not self.didIntro and self:start() then
      self._subState = nil
      self.didIntro = true
      local h = self.healthHandler.health
      self.healthHandler:instantUpdate(0)
      self.healthHandler:updateThis(h)
      if not self.healthHandler.isAdded then
        megautils.adde(self.healthHandler)
      end
    else
      self:act()
    end
  end
end

function bossEntity:draw()
  if self.doBossIntro and self.bossIntroText and self._textObj then
    love.graphics.setFont(mmFont)
    self._textObj:set(self.bossIntroText:sub(0, self._textPos or 0))
    love.graphics.draw(self._textObj, (view.w/2)-self._halfWidth, 142)
  end
end