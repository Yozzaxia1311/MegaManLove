camera = basicEntity:extend()

camera.autoClean = false

megautils.reloadStateFuncs.camera = {func=function()
    camera.main = nil
    section.hash = {}
    section.names = {}
    section.init = {}
  end, autoClean=false}

function camera:new(x, y, doScrollX, doScrollY)
  camera.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(view.w, view.h)
  self.transition = false
  self.transitionDirection = "right"
  self.freeze = true
  self.scrollx = self.x
  self.scrolly = self.y
  self.scrollw = self.collisionShape.w
  self.scrollh = self.collisionShape.h
  self.curPriority = nil
  self.dontUpdateSections = false
  self.tweenFinished = false
  self.doScrollY = doScrollY == nil and true or doScrollY
  self.doScrollX = doScrollX == nil and true or doScrollX
  self.transX = 0
  self.transY = 0
  self.approachX = self.x
  self.approachY = self.y
  self.speed = 1
  self.once = false
  self.player = nil
  self.funcs = {}
  self.spawners = {}
  megautils.state().system.cameraUpdate = nil
end

function camera:added()
  view.x, view.y = self.x, self.y
  if megautils.groups().camera then
    for _, v in ipairs(megautils.groups().camera) do
      megautils.remove(v)
    end
  end
  self:addToGroup("camera")
  camera.main = self
  
  self.spawners = {}
  local se = self:getSurroundingEntities()
  
  for i = 1, #se do
    if se[i].updateSpawner and not table.icontains(self.spawners, se[i]) then
      self.spawners[#self.spawners + 1] = se[i]
    end
  end
  
  for _, v in ipairs(self.spawners) do
    if v.static then
      v:updateSpawner()
    end
    
    if not table.icontains(se, v) then
      table.quickremovevaluearray(self.spawners, v)
    end
  end
end

function camera:removed()
  local se = self:getSurroundingEntities()
  
  for _, v in ipairs(self.spawners) do
    if not table.icontains(se, v) then
      v:updateSpawner()
    end
  end
  
  self.spawners = {}
  
  camera.main = nil
end

function camera:updateCam(spdx, spdy)
  if self.transition then
    if not self.preTrans then
      if not self.once then
        self.once = true
        for i = 1, #megautils.getAllEntities() do
          local v = megautils.getAllEntities()[i]
          
          if v.updateFlash then
            v:updateFlash()
          end
        end
      end
      if not self.toPos then
        self:updateBounds(true)
        if self.transitionDirection == "up" or self.transitionDirection == "down" then
          self.toPos = math.round(self.player.x) - (view.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
          self.toPos = math.clamp(self.toPos, self.scrollx, self.scrollx+self.scrollw-view.w)
        elseif self.transitionDirection == "left" or self.transitionDirection == "right" then
          self.toPos = math.round(self.player.y) - (view.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
          self.toPos = math.clamp(self.toPos, self.scrolly, self.scrolly+self.scrollh-view.h)
        end
      end
      if self.transitionDirection == "up" or self.transitionDirection == "down" then
        self.x = math.approach(self.x, self.toPos, spdx or 4)
        if self.x == self.toPos then
          self.toPos = nil
          self.preTrans = true
          self.once = false
        end
      elseif self.transitionDirection == "left" or self.transitionDirection == "right" then
        self.y = math.approach(self.y, self.toPos, spdy or 4)
        if self.y == self.toPos then
          self.toPos = nil
          self.preTrans = true
          self.once = false
        end
      end
      self.x = math.floor(self.x)
      self.y = math.floor(self.y)
      self.approachX = self.x
      self.approachY = self.y
      view.x, view.y = self.approachX, self.approachY
      camera.main:updateFuncs()
    elseif not self.once then
      if megautils.groups().removeOnTransition then
        for _, v in pairs(megautils.groups().removeOnTransition) do
          if not v.dontRemoveOnTransition then
            megautils.remove(v)
          end
        end
      end
      if self.freeze then
        for _, v in pairs(megaMan.allPlayers) do
          v.canControl.trans = false
          v.noFreeze = true
        end
        megautils.freeze("trans")
      end 
      if self.player then
        local sx, sy, sw, sh, sn
        local nx, ny = self.x, self.y
        if self.toSection then
          sx, sy, sw, sh, sn = self.toSection.x, self.toSection.y, self.toSection.collisionShape.w, self.toSection.collisionShape.h,
            self.toSection.name
        end
        if self.transitionDirection == "right" then
          if self.doScrollY then
            ny = self.player.y - (self.collisionShape.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
            if self.toSection then
              ny = math.clamp(ny, sy, sy+sh-self.collisionShape.h)
            end
            nx = self.x+self.collisionShape.w
            self.tween = tween.new(self.speed, self, {x=nx, y=ny})
          else
            nx = self.x+self.collisionShape.w
            self.tween = tween.new(self.speed, self, {x=nx})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i], {x=self.transX, y=self.player.y})
          end
        elseif self.transitionDirection == "left" then
          if self.doScrollY then
            local ny = self.player.y - (self.collisionShape.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
            if self.toSection then
              ny = math.clamp(ny, sy, sy+sh-self.collisionShape.h)
            end
            nx = self.x-self.collisionShape.w
            self.tween = tween.new(self.speed, self, {x=nx, y=ny})
          else
            nx = self.x-self.collisionShape.w
            self.tween = tween.new(self.speed, self, {x=self.x-self.collisionShape.w})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i], {x=self.transX, y=self.player.y})
          end
        elseif self.transitionDirection == "down" then
          if self.doScrollX then
            local nx = self.player.x - (self.collisionShape.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
            if self.toSection then
              nx = math.clamp(nx, sx, sx+sw-self.collisionShape.w)
            end
            ny = self.y+self.collisionShape.h
            self.tween = tween.new(self.speed, self, {y=ny, x=nx})
          else
            ny = self.y+self.collisionShape.h
            self.tween = tween.new(self.speed, self, {y=ny})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i], {x=self.player.x, y=self.transY})
          end
        elseif self.transitionDirection == "up" then
          if self.doScrollX then
            local nx = self.player.x - (self.collisionShape.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
            if self.toSection then
              nx = math.clamp(nx, sx, sx+sw-self.collisionShape.w)
            end
            ny = self.y-self.collisionShape.h
            self.tween = tween.new(self.speed, self, {y=ny, x=nx})
          else
            ny = self.y-self.collisionShape.h
            self.tween = tween.new(self.speed, self, {y=self.y-self.collisionShape.h})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i], {x=self.player.x, y=self.transY})
          end
        end
        local lx, ly = self.x, self.y
        local lsx, lsy, lsw, lsh, lb, lbn = self.scrollx, self.scrolly, self.scrollw, self.scrollh, self.bounds, self.curBoundName
        self.x = nx
        self.y = ny
        self.curBoundName = sn
        self:updateBounds(true)
        if self.bounds then
          for _, v in ipairs(self.bounds.group) do
            if v.spawnEarlyDuringTransition and not v.isAdded then
              megautils.adde(v)
            end
          end
        end
        self.x, self.y = lx, ly
        self.scrollx, self.scrolly, self.scrollw, self.scrollh, self.bounds, self.curBoundName = lsx, lsy, lsw, lsh, lb, lbn
      end
      
      if self.player.onMovingFloor then
        self.flx = self.player.onMovingFloor.x - self.player.x
        self.player.onMovingFloor._oldDontRemoveOnTransition = self.player.onMovingFloor.dontRemoveOnTransition
        self.player.onMovingFloor._oldDontRemoveOnSectionChange = self.player.onMovingFloor.dontRemoveOnSectionChange
        self.player.onMovingFloor.dontRemoveOnTransition = true
        self.player.onMovingFloor.dontRemoveOnSectionChange = true
      end
      self.once = true
      megautils.state().system.cameraUpdate = function(s)
        for i=1, #megaMan.allPlayers do
          camera.main.tween2[i]:update(1/60)
        end
        if camera.main.tween:update(1/60) then
          camera.main.tweenFinished = true
          if not camera.main.dontUpdateSections then
            camera.main.curBoundName = camera.main.toSection.name
            camera.main.toSection = nil
            camera.main:updateBounds()
            camera.main.transition = false
            camera.main.once = false
            camera.main.preTrans = false
            camera.main.tweenFinished = false
            megautils.state().system.cameraUpdate = nil
          end
          if camera.main.freeze then
            for _, v in pairs(megaMan.allPlayers) do
              v.canControl.trans = nil
              v.noFreeze = nil
            end
            megautils.unfreeze("trans")
          end
          if camera.main.player and camera.main.player.onMovingFloor then
            camera.main.player.onMovingFloor.dontRemoveOnTransition = camera.main.player.onMovingFloor._oldDontRemoveOnTransition
            camera.main.player.onMovingFloor.dontRemoveOnSectionChange = camera.main.player.onMovingFloor._oldDontRemoveOnSectionChange
            camera.main.player.onMovingFloor._oldDontRemoveOnTransition = nil
            camera.main.player.onMovingFloor._oldDontRemoveOnSectionChange = nil
          end
          for i=1, #megaMan.allPlayers do
            if megaMan.allPlayers[i] ~= camera.main.player then
              camera.main.player:transferState(megaMan.allPlayers[i])
            end
          end
        end
        if camera.main.player and camera.main.player.onMovingFloor then
          camera.main.player.onMovingFloor.x = camera.main.player.x + camera.main.flx
          camera.main.player.onMovingFloor.y = camera.main.player.y + camera.main.player.collisionShape.h
        end
        camera.main.x = math.floor(camera.main.x)
        camera.main.y = math.floor(camera.main.y)
        camera.main.approachX = camera.main.x
        camera.main.approachY = camera.main.y
        view.x, view.y = camera.main.approachX, camera.main.approachY
        camera.main:updateFuncs()
      end
    end
  else
    self:doView(spdx, spdy)
  end
end

function camera:doView(spdx, spdy, without)
  if #megaMan.allPlayers <= 1 then
    local o = megaMan.allPlayers[1]
    if self.doScrollX then
      self.x = math.floor(o.x) - math.round(self.collisionShape.w/2) + math.round(o.collisionShape.w/2) + o:camOffX()
    end
    if self.doScrollY then
      self.y = math.floor(o.y) - math.round(self.collisionShape.h/2) + math.round(o.collisionShape.h/2) + o:camOffY()
    end
  else
    local avx, avy = 0, 0
    local pStuffX, pStuffY = 0, 0
    for i=1, #megaMan.allPlayers do
      local p = megaMan.allPlayers[i]
      if p ~= without then
        if self.doScrollX then
          pStuffX = pStuffX + 1
          avx = avx+(p.x + p:camOffX() - (self.collisionShape.w/2) + (p.collisionShape.w/2))
        end
        if self.doScrollY then
          pStuffY = pStuffY + 1
          avy = avy+(p.y + p:camOffY() - (self.collisionShape.h/2) + (p.collisionShape.h/2))
        end
      end
    end
    if self.doScrollX then
      self.x = avx/pStuffX
    end
    if self.doScrollY then
      self.y = avy/pStuffY
    end
  end
  
  self:updateBounds()
  local sx, sy, sw, sh = self.scrollx, self.scrolly, self.scrollw, self.scrollh
  
  self.x = math.clamp(self.x, sx, sx+sw-self.collisionShape.w)
  self.y = math.clamp(self.y, sy, sy+sh-self.collisionShape.h)
  
  self.approachX = math.approach(self.approachX, self.x, spdx or 8)
  self.approachY = math.approach(self.approachY, self.y, spdy or 8)
  
  if self.despawnLateBounds and self.approachX == self.x and self.approachY == self.y then
    for _, v in ipairs(self.despawnLateBounds.group) do
      if self.bounds and not table.icontains(self.bounds.group, v) then
        if v.despawnLateDuringTransition and not v.isRemoved then
          megautils.remove(v)
        end
      end
    end
    self.despawnLateBounds = nil
  end
  
  view.x, view.y = math.floor(self.approachX), math.floor(self.approachY)
  
  local se = self:getSurroundingEntities()
  
  for i = 1, #se do
    if se[i].updateSpawner and not table.icontains(self.spawners, se[i]) then
      self.spawners[#self.spawners + 1] = se[i]
    end
  end
  
  for _, v in ipairs(self.spawners) do
    if v.static then
      v:updateSpawner()
    end
    
    if not table.icontains(se, v) then
      table.quickremovevaluearray(self.spawners, v)
    end
  end
  
  self:updateFuncs()
end

function camera:updateFuncs()
  for _, v in pairs(self.funcs) do
    v(self)
  end
end

function camera:updateBounds(noBounds)
  local bounds
  
  if self.curBoundName and section.names[self.curBoundName] then
    bounds = section.names[self.curBoundName]
  else
    local tmp = section.getSections(self.x, self.y, self.collisionShape.w, self.collisionShape.h)
    local biggestArea = 0
    local lastArea = 0
    local lx, ly = self.x, self.y
    local sects
    
    if self.bounds and self:collision(self.bounds) then
      sects = self.bounds:collisionTable(tmp)
    else
      sects = tmp
    end
    
    if self.bounds and self:collision(self.bounds) then
      local left, top, right, bottom = self.bounds.x, self.bounds.y,
        self.bounds.x+self.bounds.collisionShape.w, self.bounds.y+self.bounds.collisionShape.h
      local cleft, ctop, cright, cbottom = self.x, self.y, self.x+self.collisionShape.w, self.y+self.collisionShape.h
      biggestArea = math.max(0, math.min(right, cright) - math.max(left, cleft)) * math.max(0, math.min(bottom, cbottom) - math.max(top, ctop))
      bounds = self.bounds
    end
    
    for k, s in ipairs(sects) do
      if self:collision(s) then
        local left, top, right, bottom = s.x, s.y, s.x+s.collisionShape.w, s.y+s.collisionShape.h
        local cleft, ctop, cright, cbottom = self.x, self.y, self.x+self.collisionShape.w, self.y+self.collisionShape.h
        local area = math.max(0, math.min(right, cright) - math.max(left, cleft)) * math.max(0, math.min(bottom, cbottom) - math.max(top, ctop))
        
        if area > biggestArea then
          biggestArea = area
          bounds = s
        end
      end
    end
  end
  
  if bounds then
    self.scrollx = bounds.x
    self.scrolly = bounds.y
    self.scrollw = bounds.collisionShape.w
    self.scrollh = bounds.collisionShape.h
    if self.bounds ~= bounds then
      if not noBounds then
        if self.bounds then
          self.bounds:deactivate(bounds.group)
          self.despawnLateBounds = self.bounds
        end
        bounds:activate(self.bounds and self.bounds.group)
        for _, v in pairs(megautils.sectionChangeFuncs) do
          if type(v) == "function" then
            v()
          else
            v.func()
          end
        end
      end
      self.bounds = bounds
      
      collectgarbage()
      collectgarbage()
    end
  else
    self.scrollx = self.x
    self.scrolly = self.y
    self.scrollw = self.collisionShape.w
    self.scrollh = self.collisionShape.h
    if not noBounds and self.bounds then
      self.bounds:deactivate()
      self.despawnLateBounds = self.bounds
    end
    self.bounds = nil
    
    collectgarbage()
    collectgarbage()
  end
end

section = basicEntity:extend()

section.autoClean = false

function section.ser()
  return {
      hash = section.hash,
      names = section.names,
      init = section.init
    }
end

function section.deser(t)
  section.hash = t.hash
  section.names = t.names
  section.init = t.init
end

section.hash = {}
section.names = {}
section.init = {}

mapEntity.register("section", function(v)
    section.addSection(section(v.x, v.y, v.width, v.height, v.properties.name))
  end, 1, true)

mapEntity.register("section", function(v)
    if #section.init ~= 0 then
      for _, v in ipairs(section.init) do
        v:initSection()
      end
      section.init = {}
    end
  end, 2, true)

function section:new(x, y, w, h, n)
  section.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or view.w, h or view.h)
  if n and n ~= "" then
    self.name = n
    section.names[self.name] = self
  end
  self.cells = {}
  self.group = self:collisionTable(megautils.groups().handledBySections)
  section.init[#section.init+1] = self
end

function section:activate(ignore)
  for _, v in ipairs(self.group) do
    if not v.isAdded and
      (not ignore or not table.icontains(ignore, v)) then
      megautils.adde(v)
    end
  end
end

function section:deactivate(ignore)
  for _, v in ipairs(self.group) do
    if not v.isRemoved and not v.dontRemoveOnSectionChange and
      (not ignore or not table.icontains(ignore, v)) then
      megautils.remove(v)
    end
  end
end

function section:initSection()
  for _, v in ipairs(self.group) do
    if not v.isRemoved then
      megautils.remove(v)
    end
  end
end

function section.getSections(xx, yy, ww, hh)
  local result = {}
  local cx, cy = math.floor(xx/view.w), math.floor(yy/view.h)
  local cx2, cy2 = math.floor((xx+ww)/view.w), math.floor((yy+hh)/view.h)
  
  for x=cx, cx2 do
    for y=cy, cy2 do
      if section.hash[x] and section.hash[x][y] then
        for _, v in ipairs(section.hash[x][y]) do
          if not table.icontains(result, v) then
            result[#result+1] = v
          end
        end
      end
    end
  end
  
  return result
end

function section.removeSection(s)
  s:deactivate()
  for _, v in ipairs(s.cells) do
    if section.hash[v.x][v.y] then
      table.quickremovevaluearray(section.hash[v.x][v.y], s)
      if #section.hash[v.x][v.y] == 0 then
        section.hash[v.x][v.y] = nil
      end
      if #section.hash[v.x] == 0 then
        section.hash[v.x] = nil
      end
    end
  end
end

function section.addSection(s)
  local xx, yy, ww, hh = s.x, s.y, s.collisionShape.w, s.collisionShape.h
  local cx, cy = math.floor(xx/view.w), math.floor(yy/view.h)
  local cx2, cy2 = math.floor((xx+ww)/view.w), math.floor((yy+hh)/view.h)
  
  for x=cx, cx2 do
    for y=cy, cy2 do
      if not section.hash[x] then
        section.hash[x] = {}
      end
      if not section.hash[x][y] then
        section.hash[x][y] = {}
      end
      section.hash[x][y][#section.hash[x][y]+1] = s
      s.cells[#s.cells+1] = {x=x, y=y}
    end
  end
end

function section.iterate(func)
  for x, _ in pairs(section.hash) do
    for y, _ in pairs(section.hash[x]) do
      if section.hash[x][y] then
        for _, s in pairs(section.hash[x][y]) do
          for _, v in pairs(s.group) do
            func(v)
          end
        end
      end
    end
  end
end

function section.removeEntity(e)
  if e and e.actualSectionGroups then
    for k, v in ipairs(e.actualSectionGroups) do
      table.quickremovevaluearray(e.actualSectionGroups[k], e)
      table.quickremovevaluearray(e.actualSectionGroups, v)
    end
    if #e.actualSectionGroups == 0 then
      e.actualSectionGroups = nil
    end
  end
end

function section.addEntity(e)
  if e then
    local b = sections.getSections(e.x, e.y, e.collisionShape.w, e.collisionShape.h)
    for _, v in ipairs(b) do
      if not e.actualSectionGroups then
        e.actualSectionGroups = {}
      end
      if not table.icontains(e.actualSectionGroups, v.group) then
        e.actualSectionGroups[#e.actualSectionGroups+1] = v.group
      end
      v.group[#v.group+1] = e
    end
  end
end