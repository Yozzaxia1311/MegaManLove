entitySystem = class:extend()

function entitySystem.ser()
  return {
      drawCollision = entitySystem.drawCollision,
      doDrawFlicker = entitySystem.doDrawFlicker
    }
end

function entitySystem.deser(t)
  entitySystem.drawCollision = t.drawCollision
  entitySystem.doDrawFlicker = t.doDrawFlicker
end

entitySystem.drawCollision = false
entitySystem.doDrawFlicker = true

entitySystem.hashSize = 96

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
  self.frozen = {}
  self.hashes = {}
  self._HS =  {}
  self.doSort = false
  self.inLoop = false
end

function entitySystem:updateHashForEntity(e)
  if e.collisionShape then
    local xx, yy, ww, hh = e.x, e.y, e.collisionShape.w, e.collisionShape.h
    local hs = entitySystem.hashSize
    local cx, cy = math.floor((xx - 2) / hs), math.floor((yy - 2) / hs)
    local cx2, cy2 = math.floor((xx + ww + 2) / hs), math.floor((yy + hh + 2) / hs)
    
    for x = cx, cx2 do
      for y = cy, cy2 do
        if not self.hashes[x] then
          self.hashes[x] = {}
          self._HS[x] = 0
        end
        
        if not self.hashes[x][y] then
          self.hashes[x][y] = {x = x, y = y, data = {e}}
          self._HS[x] = self._HS[x] + 1
        elseif not table.icontains(self.hashes[x][y].data, e) then
          self.hashes[x][y].data[#self.hashes[x][y].data+1] = e
        end
        
        if not table.icontains(e.currentHashes, self.hashes[x][y]) then
          e.currentHashes[#e.currentHashes+1] = self.hashes[x][y]
        end
      end
    end
    
    for _, v in ipairs(e.currentHashes) do
      if not math.between(v.x, cx, cx2) or not math.between(v.y, cy, cy2) then
        if self.hashes[v.x] and self.hashes[v.x][v.y] then
          table.quickremovevaluearray(self.hashes[v.x][v.y].data, e)
          
          if #self.hashes[v.x][v.y].data == 0 then
            self.hashes[v.x][v.y] = nil
            self._HS[v.x] = self._HS[v.x] - 1
            
            if self._HS[v.x] <= 0 then
              self.hashes[v.x] = nil
              self._HS[v.x] = nil
            end
          end
        end
        
        table.quickremovevaluearray(e.currentHashes, v)
      end
    end
  else -- If there's no collision, then remove from hash.
    for _, v in ipairs(e.currentHashes) do
      if not math.between(v.x, cx, cx2) or not math.between(v.y, cy, cy2) then
        if self.hashes[v.x] and self.hashes[v.x][v.y] then
          table.quickremovevaluearray(self.hashes[v.x][v.y].data, e)
          
          if #self.hashes[v.x][v.y].data == 0 then
            self.hashes[v.x][v.y] = nil
            self._HS[v.x] = self._HS[v.x] - 1
            
            if self._HS[v.x] <= 0 then
              self.hashes[v.x] = nil
              self._HS[v.x] = nil
            end
          end
        end
        
        table.quickremovevaluearray(e.currentHashes, v)
      end
    end
  end
end

function entitySystem:getSurroundingEntities(xx, yy, ww, hh)
  local hs = entitySystem.hashSize
  local cx, cy = math.floor((xx - 2) / hs), math.floor((yy - 2) / hs)
  local cx2, cy2 = math.floor((xx + ww + 2) / hs), math.floor((yy + hh + 2) / hs)
  
  local result
  
  for x = cx, cx2 do
    for y = cy, cy2 do
      if self.hashes[x] and self.hashes[x][y] then
        if not result and #self.hashes[x][y].data > 0 then
          result = {unpack(self.hashes[x][y].data)}
        else
          for i = 1, #self.hashes[x][y].data do
            if not table.icontains(result, self.hashes[x][y].data[i]) then
              result[#result+1] = self.hashes[x][y].data[i]
            end
          end
        end
      end
    end
  end
  
  return result or {}
end

function entitySystem:freeze(n)
  if not table.icontains(self.frozen, n or "global") then
    self.frozen[#self.frozen+1] = n or "global"
  end
end

function entitySystem:unfreeze(n)
  table.quickremovevaluearray(self.frozen, n or "global")
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
    e.recycling = false
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

function entitySystem:getLayer(l)
  for i=1, #self.entities do
    local v = self.entities[i]
    
    if v.layer == l then
      return v
    end
  end
end

function entitySystem:add(c, ...)
  local e = self:getRecycled(c, ...)
  
  if not e.static then
    local done = false
    
    for i=1, #self.entities do
      local v = self.entities[i]
      if v.layer == e.layer then
        v.data[#v.data+1] = e
        done = true
        break
      end
    end
    
    if not done then
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
      self.doSort = true
    end
    
    self.updates[#self.updates+1] = e
  end
  
  self.all[#self.all+1] = e
  
  e.isRemoved = false
  e.isAdded = true
  e.justAddedIn = true
  e.currentHashes = {}
  if not e.invisibleToHash then e:updateHash(true) end
  e:added()
  
  if self.inLoop then
    e:begin()
  else
    self.beginQueue[#self.beginQueue+1] = e
  end
  
  e.previousX = e.x
  e.previousY = e.y
  e.epX = e.previousX
  e.epY = e.previousY
  
  if e.calcGrav then
    e:calcGrav()
  end
  
  return e
end

function entitySystem:adde(e)
  if e.isAdded then return e end
  if not e or e.isAdded then return end
  
  if not e.static then
    local done = false
    
    for i=1, #self.entities do
      local v = self.entities[i]
      if v.layer == e.layer then
        v.data[#v.data+1] = e
        done = true
        break
      end
    end
    
    if not done then
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
      self.doSort = true
    end
    
    self.updates[#self.updates+1] = e
  end
  
  self.all[#self.all+1] = e
  
  e.isRemoved = false
  e.isAdded = true
  e.justAddedIn = true
  e.currentHashes = {}
  if not e.invisibleToHash then e:updateHash(true) end
  e:added()
  
  if self.inLoop then
    e:begin()
  else
    self.beginQueue[#self.beginQueue+1] = e
  end
  
  e.previousX = e.x
  e.previousY = e.y
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
  if not e or not e.isRemoved or e.isAdded or table.icontains(self.addQueue, e) then return end
  self.addQueue[#self.addQueue+1] = e
  return self.addQueue[#self.addQueue]
end

function entitySystem:addToGroup(e, g)
  if not self.groups[g] then
    self.groups[g] = {}
  end
  
  if not table.icontains(self.groups[g], e) then
    self.groups[g][#self.groups[g]+1] = e
    e.groupNames[#e.groupNames + 1] = g
  end
end

function entitySystem:removeFromGroup(e, g)
  table.quickremovevaluearray(self.groups[g], e)
  table.quickremovevaluearray(e.groupNames, g)
  
  if #self.groups[g] == 0 then
    self.groups[g] = nil
  end
end

function entitySystem:removeFromAllGroups(e)
  for k, _ in pairs(self.groups) do
    self:removeFromGroup(e, k)
  end
end

function entitySystem:makeStatic(e)
  table.quickremovevaluearray(self.updates, e)
  
  local al = self:getLayer(e.layer)
  
  table.quickremovevaluearray(al.data, e)
  
  if #al.data == 0 then
    table.removevaluearray(self.entities, al)
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
        done = true
        break
      end
    end
    
    if not done then
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
      self.doSort = true
    end
    
    self.updates[#self.updates+1] = e
    
    e.static = false
    e:staticToggled()
  end
end

function entitySystem:setLayer(e, l)
  if l and e.layer ~= l then
    local al = self:getLayer(e.layer)
    
    table.quickremovevaluearray(al.data, e)
    
    if #al.data == 0 then
      table.removevaluearray(self.entities, al)
    end
    
    e.layer = l
    
    local done = false
    
    for i=1, #self.entities do
      local v = self.entities[i]
      
      if v.layer == e.layer then
        v.data[#v.data+1] = e
        done = true
        break
      end
    end
    
    if not done then
      self.entities[#self.entities+1] = {layer=e.layer, data={e}, flicker=true}
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
  
  local al = self:getLayer(e.layer)
  
  if e.static then
    table.quickremovevaluearray(self.static, e)
  else
    table.quickremovevaluearray(al.data, e)
    table.quickremovevaluearray(self.updates, e)
  end
  
  if #al.data == 0 then
    table.removevaluearray(self.entities, al)
  end
  
  table.quickremovevaluearray(self.all, e)
  table.quickremovevaluearray(self.beginQueue, e)
  
  for _, v in ipairs(e.currentHashes) do
    if self.hashes[v.x] and self.hashes[v.x][v.y] then
      table.quickremovevaluearray(self.hashes[v.x][v.y].data, e)
      
      if #self.hashes[v.x][v.y].data == 0 then
        self.hashes[v.x][v.y] = nil
        self._HS[v.x] = self._HS[v.x] - 1
        
        if self._HS[v.x] <= 0 then
          self.hashes[v.x] = nil
          self._HS[v.x] = nil
        end
      end
    end
  end
  
  e.currentHashes = {}
  
  e.isAdded = false
  e.justAddedIn = false
  
  if e.recycle then
    if not self.recycle[e.__index] then
      self.recycle[e.__index] = {e}
    elseif not table.icontains(self.recycle[e.__index], e) then
      self.recycle[e.__index][#self.recycle[e.__index]+1] = e
    end
  end
end

function entitySystem:removeq(e)
  if not e or e.isRemoved or table.icontains(self.removeQueue, e) then return end
  self.removeQueue[#self.removeQueue+1] = e
end

function entitySystem:clear()
  for i=1, #self.all do
    self.all[i].isRemoved = true
  end
  for _, v in pairs(self.all) do
    v:removed()
  end
  for i=1, #self.all do
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
  self.frozen = {}
  self.hashes = {}
  self._HS = {}
  self.cameraUpdate = nil
  self.doSort = false
  self.beginQueue = {}
  
  collectgarbage()
  collectgarbage()
end

function entitySystem:draw()
  for i=1, #self.entities do
    for k=1, #self.entities[i].data do
      if states.switched then
        return
      end
      local v = self.entities[i].data[k]
      if checkFalse(v.canDraw) and not v.isRemoved and v.draw then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(mmFont)
        v:draw()
      end
    end
  end
  if entitySystem.drawCollision and not states.switched then
    love.graphics.setColor(1, 1, 1, 1)
    for i=1, #self.entities do
      for k=1, #self.entities[i].data do
        self.entities[i].data[k]:drawCollision()
      end
    end
  end
end

function entitySystem:update(dt)
  while self.beginQueue[1] do
    self.beginQueue[1]:begin()
    table.remove(self.beginQueue, 1)
  end
  
  self.inLoop = true
  
  for i=1, #self.updates do
    if states.switched then
      return
    end
    local v = self.updates[i]
    if (type(v.noFreeze) == "table" and table.intersects(v.noFreeze, self.frozen)) or v.noFreeze == true or not checkTrue(self.frozen) then
      v.previousX = v.x
      v.previousY = v.y
      v.epX = v.previousX
      v.epY = v.previousY
      if not v.isRemoved and v.beforeUpdate and checkFalse(v.canUpdate) then
        v:beforeUpdate(dt)
        if not v.invisibleToHash then v:updateHash() end
      end
    end
  end
  
  for i=1, #self.updates do
    if states.switched then
      return
    end
    local v = self.updates[i]
    if ((type(v.noFreeze) == "table" and table.intersects(v.noFreeze, self.frozen)) or v.noFreeze == true or not checkTrue(self.frozen)) and
      not v.isRemoved and v.update and checkFalse(v.canUpdate) then
      v:update(dt)
      if not v.invisibleToHash then v:updateHash() end
    end
  end
  
  for i=1, #self.updates do
    if states.switched then
      return
    end
    local v = self.updates[i]
    if ((type(v.noFreeze) == "table" and table.intersects(v.noFreeze, self.frozen)) or v.noFreeze or not checkTrue(self.frozen)) and
      not v.isRemoved and v.afterUpdate and checkFalse(v.canUpdate) then
      v:afterUpdate(dt)
      if not v.invisibleToHash then v:updateHash() end
    end
    v.justAddedIn = false
  end
  
  self.inLoop = false
  
  if states.switched then
    return
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

binser.register(velocity, "velocity", function(o)
    return {velx = o.velx, vely = o.vely}
  end, function(o)
    local result = velocity()
    result.velx = o.velx
    result.vely = o.vely
    return result
  end)

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

basicEntity.autoClean = false

function basicEntity:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  cls.autoClean = true
  setmetatable(cls, self)
  return cls
end

function basicEntity:__tostring()
  return "Entity"
end

function basicEntity:new()
  if not self.recycling then
    self.collisionShape = nil
    self.layer = 1
    self.isRemoved = true
    self.isAdded = false
    self.suggestedIFrameForInteracted = nil
    self.recycle = false
  end
  
  self.currentHashes = {}
  self.groupNames = {}
  self.x = 0
  self.y = 0
  self.iFrames = 0
  self.changeHealth = 0
  self.canUpdate = {global=true}
  self.canDraw = {global=true}
  self.lastHashX = nil
  self.lastHashY = nil
  self.lastHashX2 = nil
  self.lastHashY2 = nil
end

function basicEntity:determineIFrames(o)
  return o.suggestedIFrameForInteracted or 2
end

function basicEntity:interact(t, h, single)
  if single then
    t:interactedWith(self, h)
  else
    for _, v in pairs(t) do
      v:interactedWith(self, h)
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
  return table.icontains(states.currentState.system.groups[g], self)
end

function basicEntity:removeFromAllGroups()
  megautils.state().system:removeFromAllGroups(self, g)
end

function basicEntity:addToGroup(g)
  megautils.state().system:addToGroup(self, g)
end

function basicEntity:setRectangleCollision(w, h)
  if not self.collisionShape then
    self.collisionShape = {}
  end
  
  self.collisionShape.type = 0
  self.collisionShape.w = w or 1
  self.collisionShape.h = h or 1
  
  self.collisionShape.r = nil
  self.collisionShape.data = nil
  
  self:updateHash()
end

function basicEntity:setImageCollision(resource)
  local res = megautils.getResourceTable(resource)
  
  if not self.collisionShape then
    self.collisionShape = {}
  end
  
  self.collisionShape.type = 1
  self.collisionShape.w = res.data:getWidth()
  self.collisionShape.h = res.data:getHeight()
  self.collisionShape.data = res.data
  
  self.collisionShape.r = nil
  
  self:updateHash()
end

function basicEntity:setCircleCollision(r)
  if not self.collisionShape then
    self.collisionShape = {}
  end
  
  self.collisionShape.type = 2
  self.collisionShape.w = (r or 1) * 2
  self.collisionShape.h = (r or 1) * 2
  self.collisionShape.r = r or 1
  
  self.collisionShape.data = nil
  
  self:updateHash()
end

function basicEntity:collision(e, x, y, notme)
  if not e or (notme and e == self) or not self.collisionShape or not e.collisionShape then return false end
  if self.collisionShape.type == 0 then
    if e.collisionShape.type == 0 then
      return rectOverlapsRect(math.round(self.x) + (x or 0), math.round(self.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h,
        math.round(e.x), math.round(e.y), e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsRect(math.round(e.x), math.round(e.y), e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        math.round(self.x) + (x or 0), math.round(self.y) + (y or 0), self.collisionShape.w, self.collisionShape.h)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsRect(math.round(e.x), math.round(e.y), e.collisionShape.r,
        math.round(self.x) + (x or 0), math.round(self.y) + (y or 0), self.collisionShape.w, self.collisionShape.h)
    end
  elseif self.collisionShape.type == 1 then
    if e.collisionShape.type == 0 then
      return imageOverlapsRect(math.round(self.x) + (x or 0), math.round(self.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        math.round(e.x), math.round(e.y), e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsImage(math.round(self.x) + (x or 0), math.round(self.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        math.round(e.x), math.round(e.y), e.collisionShape.w, e.collisionShape.h, e.collisionShape.data)
    elseif e.collisionShape.type == 2 then
      return imageOverlapsCircle(math.round(self.x) + (x or 0), math.round(self.y) + (y or 0),
        self.collisionShape.w, self.collisionShape.h, self.collisionShape.data,
        math.round(e.x), math.round(e.y), e.collisionShape.r)
    end
  elseif self.collisionShape.type == 2 then
    if e.collisionShape.type == 0 then
      return circleOverlapsRect(math.round(self.x) + (x or 0), math.round(self.y) + (y or 0), self.collisionShape.r,
        math.round(e.x), math.round(e.y), e.collisionShape.w, e.collisionShape.h)
    elseif e.collisionShape.type == 1 then
      return imageOverlapsCircle(math.round(e.x), math.round(e.y), e.collisionShape.w, e.collisionShape.h, e.collisionShape.data,
        math.round(self.x) + (x or 0), math.round(self.y) + (y or 0), self.collisionShape.r)
    elseif e.collisionShape.type == 2 then
      return circleOverlapsCircle(math.round(self.x) + (x or 0), math.round(self.y) + (y or 0), self.collisionShape.r,
        math.round(e.x), math.round(e.y), e.collisionShape.r)
    end
  end
  return false
end

function basicEntity:drawCollision()
  if not self.collisionShape or megautils.outside(self) then return end
  if self.collisionShape.type == 0 then
    love.graphics.rectangle("line", math.round(self.x), math.round(self.y),
      self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 1 and self.collisionShape.image then
    self.collisionShape.image:draw(math.round(self.x), math.round(self.y))
  elseif self.collisionShape.type == 2 then
    love.graphics.circle("line", math.round(self.x), math.round(self.y), self.collisionShape.r)
  end
end

function basicEntity:collisionTable(t, x, y, notme, func)
  local result = {}
  if not t then return result end
  for i=1, #t do
    local v = t[i]
    if self:collision(v, x, y, notme) and (func == nil or func(v)) then
      result[#result+1] = v
    end
  end
  return result
end

function basicEntity:collisionNumber(t, x, y, notme, func)
  local result = 0
  if not t then return result end
  for i=1, #t do
    if self:collision(t[i], x, y, notme) and (func == nil or func(t[i])) then
      result = result + 1
    end
  end
  return result
end

function basicEntity:updateHash(doAnyway)
  if (doAnyway or self.isAdded) and self.collisionShape then
    local xx, yy, ww, hh = self.x, self.y, self.collisionShape.w, self.collisionShape.h
    local hs = entitySystem.hashSize
    local cx, cy = math.floor((xx - 2) / hs), math.floor((yy - 2) / hs)
    local cx2, cy2 = math.floor((xx + ww + 2) / hs), math.floor((yy + hh + 2) / hs)
    
    if doAnyway or self.lastHashX ~= cx or self.lastHashY ~= cy or self.lastHashX2 ~= cx2 or self.lastHashY2 ~= cy2 then
      self.lastHashX = cx
      self.lastHashY = cy
      self.lastHashX2 = cx2
      self.lastHashY2 = cy2
      
      megautils.state().system:updateHashForEntity(self)
    end
  end
end

function basicEntity:getSurroundingEntities(dxx, dyy)
  if dxx or dyy or self.invisibleToHash then
    local dx, dy = dxx or 0, dyy or 0
    local xx, yy, ww, hh = self.x - math.min(dx, 0), self.y - math.min(dy, 0),
      self.collisionShape.w + math.max(dx, 0), self.collisionShape.h + math.max(dy, 0)
    
    return megautils.getSurroundingEntities(self.x, self.y, self.collisionShape.w, self.collisionShape.h)
  end
  
  local result = self.currentHashes[1] and {unpack(self.currentHashes[1].data)} or {}
  
  for i = 2, #self.currentHashes do
    for j = 1, #self.currentHashes[i].data do
      if not table.icontains(result, self.currentHashes[i].data[j]) then
        result[#result + 1] = self.currentHashes[i].data[j]
      end
    end
  end
  
  return result
end

function basicEntity:beforeUpdate() end
function basicEntity:update() end
function basicEntity:afterUpdate() end
function basicEntity:draw() end
function basicEntity:drawQuality() end
function basicEntity:added() end
function basicEntity:removed() end
function basicEntity:begin() end
function basicEntity:staticToggled() end

megautils.cleanFuncs.autoCleaner = {func=function()
    for k, v in pairs(_G) do
      if type(v) == "table" and tostring(v) == "Entity" and v.autoClean then
        _G[k] = nil
      end
    end
  end, autoClean=false}

entity = basicEntity:extend()

entity.autoClean = false

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
  self.snapToMovingFloor = true
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
  self.x = self.x + x
  self.y = self.y + y
end

function entity:calcGrav()
  self.gravity = self.normalGravity
  for _, v in pairs(self.gravityMultipliers) do
    self.gravity = self.gravity * v
  end
end

function entity:setGravityMultiplier(name, to)
  local old = self.gravityMultipliers[name]
  self.gravityMultipliers[name] = to
  if old ~= self.gravityMultipliers[name] then
    self:calcGrav()
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

function entity:updateFlash(length, range)
  if self.iFrames == 0 then
    self.canDraw.flash = true
  else
    self.canDraw.flash = math.wrap(self.iFrames, 0, length or 4) > (range or 2)
  end
end

mapEntity = basicEntity:extend()

mapEntity.autoClean = false
mapEntity.invisibleToHash = true

function mapEntity.ser()
  return {
      registered = mapEntity.registered,
      doSort = mapEntity.doSort
    }
end

function mapEntity.deser(t)
  mapEntity.registered = t.registered
  mapEntity.doSort = t.doSort
end

mapEntity.registered = {}
mapEntity.doSort = false

function mapEntity:new(map, x, y)
  mapEntity.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self.map = map
  self.path = self.map.path
  self.layers = {}
  self:setLayer(-200)
  self.visibleDuringPause = true
  self.didDrawRange = false
end

function mapEntity:begin()
  self:addToGroup("map")
  
  for i=1, #self.map.layers do
    local v = self.map.layers[i]
    if v.draw then
      self.layers[#self.layers+1] = megautils.add(trigger, nil, function(s)
          if s.l.visible then
            s.l:draw()
          end
        end)
      self.layers[#self.layers].l = v
      self.layers[#self.layers]:setLayer(v.properties.layer or (i-100))
      self.layers[#self.layers].visibleDuringPause = true
    end
  end
  
  for _, v in pairs(megautils.addMapFuncs) do
    if type(v) == "function" then
      v(self)
    else
      v.func(self)
    end
  end
end

function mapEntity:removed()
  for _, v in ipairs(self.layers) do
    megautils.remove(v)
  end
  
  for _, v in pairs(megautils.removeMapFuncs) do
    if type(v) == "function" then
      v(self)
    else
      v.func(self)
    end
  end
  
  self.map:release()
end

function mapEntity:recursiveChecker(tab, index, name)
  if tab and tab.layers then
    for _, v in pairs(tab.layers) do
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
  for _, v in pairs(tab.layers) do
    if v.type == "objectgroup" then
      for _, j in pairs(v.objects) do
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
  mapEntity.add(self:recursiveObjectFinder(self.map), self.map)
  for _, v in pairs(megautils.postAddObjectsFuncs) do
    if type(v) == "function" then
      v(self)
    else
      v.func(self)
    end
  end
end

function mapEntity:update()
  self.didDrawRange = true
  self.map:setDrawRange((view.x - self.x) - self.map.tilewidth, (view.y - self.y) - self.map.tileheight,
    view.w + (self.map.tilewidth * 2), view.h + (self.map.tileheight * 2))
  self.map:update(1/60)
end

function mapEntity:draw()
  love.graphics.push()
  love.graphics.translate(-self.x, -self.y)
  if not self.didDrawRange then
    self.map:setDrawRange((view.x - self.x) - self.map.tilewidth, (view.y - self.y) - self.map.tileheight,
      view.w + (self.map.tilewidth * 2), view.h + (self.map.tileheight * 2))
  else
    self.didDrawRange = false
  end
  self.map:drawBackground()
  love.graphics.pop()
end

function mapEntity.register(n, f, l, lock)
  local done = false
  for i=1, #mapEntity.registered do
    if mapEntity.registered[i].layer == (l or 0) then
      mapEntity.registered[i].data[#mapEntity.registered[i].data+1] = {func=f, name=n, locked=lock}
      done = true
      break
    end
  end
  if not done then
    mapEntity.registered[#mapEntity.registered+1] = {layer=l or 0, data={{func=f, name=n, locked=lock}}}
    mapEntity.doSort = true
  end
end

function mapEntity.sortReg()
  local keys = {}
  local vals = {}
  for k, v in pairs(mapEntity.registered) do
    keys[#keys+1] = v.layer
    vals[v.layer] = v
    mapEntity.registered[k] = nil
  end
  table.sort(keys)
  for i=1, #keys do
    mapEntity.registered[i] = vals[keys[i]]
  end
end

function mapEntity.iterReg(f, dir)
  if not dir or dir == 1 then
    for i=1, #mapEntity.registered do
      for j=1, #mapEntity.registered[i].data do
        if f then f(mapEntity.registered[i].data[j]) end
      end
    end
  elseif dir and dir == -1 then
    for i=#mapEntity.registered, 1, -1 do
      for j=#mapEntity.registered[i].data, 1, -1 do
        if f then f(mapEntity.registered[i].data[j]) end
      end
    end
  end
end

function mapEntity.unregister(name)
  mapEntity.iterReg(function(r)
      if r.name == name then
        if r.locked then
          error("Cannot unregister \"" .. name .. "\", a locked register.")
        else
          for i=1, #mapEntity.registered do
            table.quickremovevaluearray(mapEntity.registered[i].data, r)
            if #mapEntity.registered[i].data == 0 then
              table.quickremovevaluearray(mapEntity.registered, mapEntity.registered[i])
            end
          end
        end
      end
    end)
end

function mapEntity.add(ol, map)
  if mapEntity.doSort then
    mapEntity.sortReg()
    mapEntity.doSort = false
  end
  for i=1, #mapEntity.registered do
    local layer = mapEntity.registered[i]
    for _, v in ipairs(ol) do
      if v.properties.run then
        megautils.runFile(v.properties.run, true)
      end
      for j=1, #layer.data do
        if layer.data[j].name == v.name then
          layer.data[j].func(v, map)
        end
      end
    end
  end
end

megautils.cleanFuncs.mapEntity = {func=function()
    mapEntity.iterReg(function(r)
        if not r.locked then
          for i=1, #mapEntity.registered do
            table.quickremovevaluearray(mapEntity.registered[i].data, r)
            if #mapEntity.registered[i].data == 0 then
              table.quickremovevaluearray(mapEntity.registered, mapEntity.registered[i])
            end
          end
        end
      end, -1)
  end, autoClean=false}

pierce = {}

pierce.NOPIERCE = 0
pierce.PIERCE = 1
pierce.PIERCEIFKILLING = 2

megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit", true)
megautils.loadResource("assets/sfx/enemyExplode.ogg", "enemyExplode", true)
megautils.loadResource("assets/sfx/hugeExplode.ogg", "enemyHugeExplode", true)

advancedEntity = entity:extend()

advancedEntity.autoClean = false

advancedEntity.SMALLBLAST = 1
advancedEntity.BIGBLAST = 2
advancedEntity.DEATHBLAST = 3

function advancedEntity:new()
  advancedEntity.super.new(self)
  
  if not self.recycling then
    self:setRectangleCollision(16, 16)
    self.explosionType = advancedEntity.SMALLBLAST
    self.removeOnDeath = true
    self.dropItem = true
    self.health = 1
    self.soundOnHit = "enemyHit"
    self.soundOnDeath = "enemyExplode"
    self.autoHitPlayer = true
    self.damage = -1
    self.hurtable = true
    self.flipWithPlayer = true
    self.defeatSlot = nil
    self.defeatSlotValue = nil
    self.removeWhenOutside = true
    self.removeHealthBarWithSelf = true
    self.barRelativeToView = true
    self.barOffsetX = (view.w - 24)
    self.barOffsetY = 80
    self.applyAutoFace = true
    self.pierceType = pierce.PIERCE
    self.autoCollision = {global = true}
    self.autoGravity = {global = true}
    self.doAutoCollisionBeforeUpdate = false
    self.autoCrush = true
    self.blockCollision.global = true
    self.maxFallingSpeed = 7
    self.noSlope = false
  end
  
  self.dead = false
  self.closest = nil
  self._didCol = false
  self.healthHandler = nil
  self.autoFace = -1
  self.side = -1
end

function advancedEntity:added()
  self:addToGroup("removeOnTransition")
  self:addToGroup("handledBySections")
  self:addToGroup("interactable")
  self:addToGroup("advancedEntity")
end

function advancedEntity:useHealthBar(oneColor, twoColor, outlineColor, add)
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
    camera.main.funcs.advancedEntity = function(s)
        if megautils.groups().advancedEntity then
          for _, v in ipairs(megautils.groups().advancedEntity) do
            v.healthHandler.x = (v.barRelativeToView and view.x or 0) + v.barOffsetX
            v.healthHandler.y = (v.barRelativeToView and view.y or 0) + v.barOffsetY
          end
        end
      end
  end
end

function advancedEntity:removed()
  if self.removeHealthBarWithSelf and self.healthHandler then
    if not self.healthHandler.isRemoved then
      megautils.remove(self.healthHandler)
    end
  end
end

function advancedEntity:grav()
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(self.maxFallingSpeed)
end

function advancedEntity:crushed(o)
  if self.autoCrush and self.hurtable then
    local oldInv, oldIF = table.clone(self.canBeInvincible), self.iFrames
    self.iFrames = 0
    for k, _ in pairs(self.canBeInvincible) do
      self.canBeInvincible[k] = false
    end
    o:interact(self, -99999, true)
    if not self.dead then
      self.iFrames = oldIF
      self.canBeInvincible = oldInv
    end
  end
end

function advancedEntity:getHealth()
  return self.healthHandler and self.healthHandler.health or self.health
end

function advancedEntity:hit(o) end
function advancedEntity:die(o) end
function advancedEntity:determineDink(o) end
function advancedEntity:weaponTable(o) end

function advancedEntity:beforeUpdate()
  if self.flipWithPlayer and megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  if checkFalse(self.autoGravity) then
    collision.doGrav(self, self.noSlope)
  end
  self._didCol = false
  if self.doAutoCollisionBeforeUpdate and checkFalse(self.autoCollision) then
    collision.doCollision(self, self.noSlope)
    self._didCol = true
  end
  local s, n = megautils.side(self, megaMan.allPlayers)
  self.autoFace = s or self.autoFace
  if self.applyAutoFace then
    self.side = self.autoFace
  end
  self.closest = n
  self:updateFlash()
  self:updateIFrame()
  self:updateShake()
end

function advancedEntity:afterUpdate()
  if not self.doAutoCollisionBeforeUpdate and checkFalse(self.autoCollision) and not self._didCol then
    collision.doCollision(self, self.noSlope)
  end
  if self.autoHitPlayer then
    self:interact(self:collisionTable(megaMan.allPlayers), self.damage)
  end
  if self.removeWhenOutside and megautils.outside(self) then
    megautils.removeq(self)
  end
end

function advancedEntity:interactedWith(o, c)
  if self.dead then return end
  
  local doDink = self:determineDink(o)
  
  if checkTrue(self.canBeInvincible) or doDink or not self.hurtable then
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
      self.iFrames = self:determineIFrames(o)
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
    if self.explosionType == advancedEntity.SMALLBLAST then
      megautils.add(smallBlast, self.x+(self.collisionShape.w/2)-12, self.y+(self.collisionShape.h/2)-12, self)
    elseif self.explosionType == advancedEntity.BIGBLAST then
      megautils.add(blast, self.x+(self.collisionShape.w/2)-12, self.y+(self.collisionShape.h/2)-12, self)
    elseif self.explosionType == advancedEntity.DEATHBLAST then
      deathExplodeParticle.createExplosion(self.x+((self.collisionShape.w/2)-12),
        self.y+((self.collisionShape.h/2)-12), self)
    end
    if self.dropItem then
      local item
      if self.dropItem == true then
        item = megautils.dropItem(self.x, self.y)
      else
        item = megautils.adde(self.dropItem)
      end
      if item then
        item.x = self.x+(self.collisionShape.w/2)-(item.collisionShape.w/2)
        item.y = self.y+(self.collisionShape.h/2)-(item.collisionShape.h/2) + (self.gravity >= 0 and -8 or 8)
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

bossEntity = advancedEntity:extend()

bossEntity.autoClean = false

function bossEntity:new()
  bossEntity.super.new(self)
  self.soundOnDeath = "assets/sfx/dieExplode.ogg"
  self.dropItem = false
  self.explosionType = advancedEntity.DEATHBLAST
  self.defeatSlot = nil
  self.flipWithPlayer = false
  self.removeWhenOutside = false
  self.removeHealthBarWithSelf = false
  self.state = 0
  self._subState = 0
  self.skipBoss = nil
  self.skipBossState = globals.menuState
  self.doIntro = true
  self.strikePose = true
  self.continueAfterDeath = false
  self.afterDeathState = globals.weaponGetState
  self.weaponGetMenuState = globals.menuState
  self.doBossIntro = megautils.getCurrentState() == globals.bossIntroState
  self.bossIntroText = nil
  self.weaponGetText = "WEAPON GET... (NAME HERE)"
  self.stageState = nil
  self.mugshotPath = nil
  self.bossIntroWaitTime = 400
  self.health = 28
  self.lockBossDoors = true
  self.weaponGetBehaviour = function(s)
      return true
    end
  self.skipStart = false
  self.replayMusicWhenContinuing = true
  self.lastMusic = mmMusic.curID
  self.lastVol = mmMusic.vol
  self:setMusic("assets/sfx/music/boss.ogg")
  self:setBossIntroMusic("assets/sfx/music/stageStart.ogg")
end

function bossEntity:added()
  bossEntity.super.added(self)
  
  self.canDraw.firstFrame = false
  self.canBeInvincible.firstFrame = true
  self.autoCollision.firstFrame = false
  self.autoGravity.firstFrame = false
end

function bossEntity:useHealthBar(oneColor, twoColor, outlineColor, add)
  bossEntity.super.useHealthBar(self, oneColor, twoColor, outlineColor, add or add ~= nil)
end

function bossEntity:setMusic(p, v)
  self.musicPath = p
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
    self.dOff = view.y-self.y
    self.oldY = self.y
    self.y = self.oldY + self.dOff
  elseif self.ds == 1 then
    self.screen.o = math.min(self.screen.o+0.05, 0.4)
    self.dOff = math.min(self.dOff+1, 0)
    self.y = self.oldY + self.dOff
    if self.y == self.oldY then
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
  if not self.continueAfterDeath then
    timer.winCutscene(function()
        megautils.reloadState = true
        megautils.resetGameObjects = true
        megautils.gotoState(self.skipBossState)
      end)
    megautils.stopMusic()
  end
  megautils.removeq(self)
  return true
end

function bossEntity:act() end

function bossEntity:start()
  if self._subState == 0 then
    if megaMan.allPlayers then
      for _, v in ipairs(megaMan.allPlayers) do
        v.canControl.boss = false
        v.canBeInvincible.intro = true
        v.velocity.velx = 0
        v:resetStates()
        v.side = megautils.side(v, self, true)
      end
      self._subState = 1
    end
    
    self.canDraw.intro = false
    self.canBeInvincible.intro = true
    self.autoCollision.intro = false
    self.autoGravity.intro = false
    
    megautils.stopMusic()
  elseif self._subState == 1 then
    local result = {}
    for k, v in ipairs(megaMan.allPlayers) do
      if not v.drop and not v.rise then
        collision.doGrav(v)
        collision.doCollision(v)
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
      megautils.playMusic(self.musicPath, self.musicVolume)
      self.canDraw.intro = nil
      if not self.doIntro or self:intro() then
        self._subState = 3
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
        for _, v in ipairs(megaMan.allPlayers) do
          v.canControl.boss = nil
          v.canBeInvincible.intro = nil
        end
        self.canBeInvincible.intro = nil
        self.autoCollision.intro = nil
        self.autoGravity.intro = nil
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
  else
    if megautils.groups().bossDoor then
      for _, v in ipairs(megautils.groups().bossDoor) do
        v.isLocked.boss = nil
      end
    end
    if self.replayMusicWhenContinuing and not self._onceReplay then
      self._onceReplay = true
      megautils.playMusic(self.lastMusic, self.lastVol)
    end
  end
end

function bossEntity:determineIFrames(o)
  return o.suggestedIFrameForInteracted or 50
end

function bossEntity:hit(o)
  megautils.add(harm, self, 50)
end

function bossEntity:bossIntro()
  if self._subState == 0 then
    self.autoCollision.intro = false
    self.autoGravity.intro = false
    self.x = math.floor(view.w/2)-(self.collisionShape.w/2)
    self.y = -self.collisionShape.h
    self._timer = 0
    self._textPos = 0
    self._textTimer = 0
    self._subState = 1
    self._halfWidth = love.graphics.newText(mmFont, self.bossIntroText):getWidth()/2
    if self.musicBIPath then
      megautils.playMusic(self.musicBIPath, self.musicBIVolume)
    end
  elseif self._subState == 1 then
    self.y = math.min(self.y+10, math.floor(view.h/2)-(self.collisionShape.h/2))
    if self.y == math.floor(view.h/2)-(self.collisionShape.h/2) then
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
    if not self.didOnce then
      self.didOnce = true
      if (self.skipBoss == nil and self.defeatSlot and globals.defeats[self.defeatSlot]) or self.skipBoss then
        if self:skip() then
          self.skipStart = true
          return
        end
      else
        if self.lockBossDoors and megautils.groups().bossDoor then
          for _, v in ipairs(megautils.groups().bossDoor) do
            v.isLocked.boss = true
          end
        end
        if self.musicPath then
          megautils.playMusic(self.musicPath, self.musicVolume)
        end
      end
    end
    if not self.didIntro and (self.skipStart or self:start()) then
      self._subState = nil
      self.didIntro = true
      
      if self.healthHandler then
        local lh = self.healthHandler.health
        self.healthHandler:instantUpdate(0)
        self.healthHandler:updateThis(lh)
      
        if not self.healthHandler.isAdded then
          megautils.adde(self.healthHandler)
        end
      end
    elseif self.didIntro then
      self:act()
    end
  end
  self.canDraw.firstFrame = nil
  self.canBeInvincible.firstFrame = nil
  self.autoCollision.firstFrame = nil
  self.autoGravity.firstFrame = nil
end

function bossEntity:draw()
  if self.doBossIntro and self.bossIntroText and self._halfWidth then
    love.graphics.print(self.bossIntroText:sub(0, self._textPos or 0), (view.w/2)-self._halfWidth, 142)
  end
end