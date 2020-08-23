camera = basicEntity:extend()

camera.autoClean = false

binser.register(camera, "camera", function(o)
    local result = {}
    
    camera.super.transfer(o, result)
    
    result.transition = o.transition
    result.transitionDirection = o.transitionDirection
    result.freeze = o.freeze
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.scrollw = o.scrollw
    result.scrollh = o.scrollh
    result.curPriority = o.curPriority
    result.dontUpdateSections = o.dontUpdateSections
    result.tweenFinished = o.tweenFinished
    result.doScrollY = o.doScrollY
    result.doScrollX = o.doScrollX
    result.transX = o.transX
    result.transY = o.transY
    result.approachX = o.approachX
    result.approachY = o.approachY
    result.speed = o.speed
    result.once = o.once
    result.player = o.player
    result.funcs = o.funcs
    result.preTrans = o.preTrans
    result.toPos = o.toPos
    result.once = o.once
    result.toSection = o.toSection
    result.tween = o.tween
    result.tween2 = o.tween2
    
    return result
  end, function(o)
    local result = camera()
    
    camera.super.transfer(o, result)
    
    result.transition = o.transition
    result.transitionDirection = o.transitionDirection
    result.freeze = o.freeze
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.scrollw = o.scrollw
    result.scrollh = o.scrollh
    result.curPriority = o.curPriority
    result.dontUpdateSections = o.dontUpdateSections
    result.tweenFinished = o.tweenFinished
    result.doScrollY = o.doScrollY
    result.doScrollX = o.doScrollX
    result.transX = o.transX
    result.transY = o.transY
    result.approachX = o.approachX
    result.approachY = o.approachY
    result.speed = o.speed
    result.once = o.once
    result.player = o.player
    result.funcs = o.funcs
    result.preTrans = o.preTrans
    result.toPos = o.toPos
    result.once = o.once
    result.toSection = o.toSection
    result.tween = o.tween
    result.tween2 = o.tween2
    
    return result
  end)

megautils.reloadStateFuncs.camera = {func=function()
    camera.main = nil
    section.hash = {}
    section.names = {}
    section.init = {}
  end, autoClean=false}

function camera:new(x, y, doScrollX, doScrollY)
  camera.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(view.w, view.h)
  self.transition = false
  self.transitionDirection = "right"
  self.freeze = true
  self.scrollx = self.transform.x
  self.scrolly = self.transform.y
  self.scrollw = self.collisionShape.w
  self.scrollh = self.collisionShape.h
  self.curPriority = nil
  self.dontUpdateSections = false
  self.tweenFinished = false
  self.doScrollY = doScrollY == nil and true or doScrollY
  self.doScrollX = doScrollX == nil and true or doScrollX
  self.transX = 0
  self.transY = 0
  self.approachX = self.transform.x
  self.approachY = self.transform.y
  self.speed = 1
  self.once = false
  self.player = nil
  self.funcs = {}
  megautils.state().system.cameraUpdate = nil
end

function camera:added()
  view.x, view.y = self.transform.x, self.transform.y
  camera.main = self
end

function camera:removed()
  camera.main = nil
end

function camera:updateCam(spdx, spdy)
  if self.transition then
    if not self.preTrans then
      if not self.toPos then
        self:updateBounds(true)
        if self.transitionDirection == "up" or self.transitionDirection == "down" then
          self.toPos = math.round(self.player.transform.x) - (view.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
          self.toPos = math.clamp(self.toPos, self.scrollx, self.scrollx+self.scrollw-view.w)
        elseif self.transitionDirection == "left" or self.transitionDirection == "right" then
          self.toPos = math.round(self.player.transform.y) - (view.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
          self.toPos = math.clamp(self.toPos, self.scrolly, self.scrolly+self.scrollh-view.h)
        end
      end
      if self.transitionDirection == "up" or self.transitionDirection == "down" then
        self.transform.x = math.approach(self.transform.x, self.toPos, spdx or 4)
        if self.transform.x == self.toPos then
          self.toPos = nil
          self.preTrans = true
        end
      elseif self.transitionDirection == "left" or self.transitionDirection == "right" then
        self.transform.y = math.approach(self.transform.y, self.toPos, spdy or 4)
        if self.transform.y == self.toPos then
          self.toPos = nil
          self.preTrans = true
        end
      end
      self.transform.x = math.floor(self.transform.x)
      self.transform.y = math.floor(self.transform.y)
      self.approachX = self.transform.x
      self.approachY = self.transform.y
      view.x, view.y = self.approachX, self.approachY
      camera.main:updateFuncs()
    elseif not self.once then
      if megautils.groups().removeOnTransition then
        for k, v in pairs(megautils.groups().removeOnTransition) do
          if not v.dontRemoveOnTransition then
            megautils.removeq(v)
          end
        end
      end
      if self.freeze then
        megautils.freeze(megaMan.allPlayers)
        for k, v in pairs(megaMan.allPlayers) do
          v.canControl.trans = false
        end
      end 
      if self.player then
        local sx, sy, sw, sh
        local nx, ny = self.transform.x, self.transform.y
        if self.toSection then
          sx, sy, sw, sh = self.toSection.transform.x, self.toSection.transform.y, self.toSection.collisionShape.w, self.toSection.collisionShape.h
        end
        if self.transitionDirection == "right" then
          if self.doScrollY then
            ny = self.player.transform.y - (self.collisionShape.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
            if self.toSection then
              ny = math.clamp(ny, sy, sy+sh-self.collisionShape.h)
            end
            nx = self.transform.x+self.collisionShape.w
            self.tween = tween.new(self.speed, self.transform, {x=nx, y=ny})
          else
            nx = self.transform.x+self.collisionShape.w
            self.tween = tween.new(self.speed, self.transform, {x=nx})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i].transform, {x=self.transX, y=self.player.transform.y})
          end
        elseif self.transitionDirection == "left" then
          if self.doScrollY then
            local ny = self.player.transform.y - (self.collisionShape.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
            if self.toSection then
              ny = math.clamp(ny, sy, sy+sh-self.collisionShape.h)
            end
            nx = self.transform.x-self.collisionShape.w
            self.tween = tween.new(self.speed, self.transform, {x=nx, y=ny})
          else
            nx = self.transform.x-self.collisionShape.w
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i].transform, {x=self.transX, y=self.player.transform.y})
          end
        elseif self.transitionDirection == "down" then
          if self.doScrollX then
            local nx = self.player.transform.x - (self.collisionShape.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
            if self.toSection then
              nx = math.clamp(nx, sx, sx+sw-self.collisionShape.w)
            end
            ny = self.transform.y+self.collisionShape.h
            self.tween = tween.new(self.speed, self.transform, {y=ny, x=nx})
          else
            ny = self.transform.y+self.collisionShape.h
            self.tween = tween.new(self.speed, self.transform, {y=ny})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i].transform, {x=self.player.transform.x, y=self.transY})
          end
        elseif self.transitionDirection == "up" then
          if self.doScrollX then
            local nx = self.player.transform.x - (self.collisionShape.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
            if self.toSection then
              nx = math.clamp(nx, sx, sx+sw-self.collisionShape.w)
            end
            ny = self.transform.y-self.collisionShape.h
            self.tween = tween.new(self.speed, self.transform, {y=ny, x=nx})
          else
            ny = self.transform.y-self.collisionShape.h
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h})
          end
          self.tween2 = {}
          for i=1, #megaMan.allPlayers do
            self.tween2[i] = tween.new(self.speed, megaMan.allPlayers[i].transform, {x=self.player.transform.x, y=self.transY})
          end
        end
        local lx, ly = self.transform.x, self.transform.y
        local lsx, lsy, lsw, lsh, lb = self.scrollx, self.scrolly, self.scrollw, self.scrollh, self.bounds
        self.transform.x = nx
        self.transform.y = ny
        self:updateBounds(true)
        if self.bounds then
          for k, v in ipairs(self.bounds.group) do
            if v.spawnEarlyDuringTransition and not v.isAdded and not megautils.inAddQueue(v) then
              megautils.adde(v)
            end
          end
        end
        self.transform.x, self.transform.y = lx, ly
        self.scrollx, self.scrolly, self.scrollw, self.scrollh, self.bounds = lsx, lsy, lsw, lsh, lb
      end
      
      self.toSection = nil
      if self.player.onMovingFloor then
        self.flx = self.player.onMovingFloor.transform.x - self.player.transform.x
        self.player.onMovingFloor._oldDontRemoveOnTransition = self.player.onMovingFloor.dontRemoveOnTransition
        self.player.onMovingFloor._oldDontRemoveOnSectionChange = self.player.onMovingFloor.dontRemoveOnSectionChange
        self.player.onMovingFloor.dontRemoveOnTransition = true
        self.player.onMovingFloor.dontRemoveOnSectionChange = true
      end
      self.once = true
      megautils.state().system.cameraUpdate = function(s)
        for i=1, #megaMan.allPlayers do
          camera.main.tween2[i]:update(defaultFramerate)
        end
        if camera.main.tween:update(defaultFramerate) then
          camera.main.tweenFinished = true
          if not camera.main.dontUpdateSections then
            camera.main:updateBounds()
            camera.main.transition = false
            camera.main.once = false
            camera.main.preTrans = false
            camera.main.tweenFinished = false
            megautils.state().system.cameraUpdate = nil
          end
          if camera.main.freeze then
            megautils.unfreeze(megaMan.allPlayers)
            for k, v in pairs(megaMan.allPlayers) do
              v.canControl.trans = true
            end
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
          camera.main.player.onMovingFloor.transform.x = camera.main.player.transform.x + camera.main.flx
          camera.main.player.onMovingFloor.transform.y = camera.main.player.transform.y + camera.main.player.collisionShape.h
        end
        camera.main.transform.x = math.floor(camera.main.transform.x)
        camera.main.transform.y = math.floor(camera.main.transform.y)
        camera.main.approachX = camera.main.transform.x
        camera.main.approachY = camera.main.transform.y
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
      self.transform.x = math.round(o.transform.x) - (self.collisionShape.w/2) + (o.collisionShape.w/2) + o:camOffX()
    end
    if self.doScrollY then
      self.transform.y = math.round(o.transform.y) - (self.collisionShape.h/2) + (o.collisionShape.h/2) + o:camOffY()
    end
  else
    local avx, avy = 0, 0
    local pStuffX, pStuffY = 0, 0
    for i=1, #megaMan.allPlayers do
      local p = megaMan.allPlayers[i]
      if p ~= without then
        if self.doScrollX then
          pStuffX = pStuffX + 1
          avx = avx+(p.transform.x + p:camOffX() - (self.collisionShape.w/2) + (p.collisionShape.w/2))
        end
        if self.doScrollY then
          pStuffY = pStuffY + 1
          avy = avy+(p.transform.y + p:camOffY() - (self.collisionShape.h/2) + (p.collisionShape.h/2))
        end
      end
    end
    if self.doScrollX then
      self.transform.x = avx/pStuffX
    end
    if self.doScrollY then
      self.transform.y = avy/pStuffY
    end
  end
  
  self:updateBounds()
  local sx, sy, sw, sh = self.scrollx, self.scrolly, self.scrollw, self.scrollh
  
  self.transform.x = math.clamp(self.transform.x, sx, sx+sw-self.collisionShape.w)
  self.transform.y = math.clamp(self.transform.y, sy, sy+sh-self.collisionShape.h)
  
  self.approachX = math.approach(self.approachX, self.transform.x, spdx or 8)
  self.approachY = math.approach(self.approachY, self.transform.y, spdy or 8)
  
  if self.despawnLateBounds and self.approachX == self.transform.x and self.approachY == self.transform.y then
    for k, v in ipairs(self.despawnLateBounds.group) do
      if self.bounds and not table.contains(self.bounds.group, v) then
        if v.despawnLateDuringTransition and not v.isRemoved and not megautils.inRemoveQueue(v) then
          megautils.removeq(v)
        end
      end
    end
    self.despawnLateBounds = nil
  end
  
  view.x, view.y = math.floor(self.approachX), math.floor(self.approachY)
  
  self:updateFuncs()
end

function camera:updateFuncs()
  for k, v in pairs(self.funcs) do
    v(self)
  end
end

function camera:updateBounds(noBounds)
  local bounds
  
  if self.curBoundName and section.names[self.curBoundName] then
    bounds = section.names[self.curBoundName]
  else
    local tmp = section.getSections(self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h)
    local biggestArea = 0
    local lastArea = 0
    local lx, ly = self.transform.x, self.transform.y
    local sects
    
    if self.bounds and self:collision(self.bounds) then
      sects = self.bounds:collisionTable(tmp)
    else
      sects = tmp
    end
    
    if self.bounds and self:collision(self.bounds) then
      local left, top, right, bottom = self.bounds.transform.x, self.bounds.transform.y,
        self.bounds.transform.x+self.bounds.collisionShape.w, self.bounds.transform.y+self.bounds.collisionShape.h
      local cleft, ctop, cright, cbottom = self.transform.x, self.transform.y, self.transform.x+self.collisionShape.w, self.transform.y+self.collisionShape.h
      biggestArea = math.max(0, math.min(right, cright) - math.max(left, cleft)) * math.max(0, math.min(bottom, cbottom) - math.max(top, ctop))
      bounds = self.bounds
    end
    
    for k, s in ipairs(sects) do
      if self:collision(s) then
        local left, top, right, bottom = s.transform.x, s.transform.y, s.transform.x+s.collisionShape.w, s.transform.y+s.collisionShape.h
        local cleft, ctop, cright, cbottom = self.transform.x, self.transform.y, self.transform.x+self.collisionShape.w, self.transform.y+self.collisionShape.h
        local area = math.max(0, math.min(right, cright) - math.max(left, cleft)) * math.max(0, math.min(bottom, cbottom) - math.max(top, ctop))
        
        if area > biggestArea then
          biggestArea = area
          bounds = s
        end
      end
    end
  end
  
  if bounds then
    self.scrollx = bounds.transform.x
    self.scrolly = bounds.transform.y
    self.scrollw = bounds.collisionShape.w
    self.scrollh = bounds.collisionShape.h
    if self.bounds ~= bounds then
      if not noBounds then
        if self.bounds then
          self.bounds:deactivate(bounds.group)
          self.despawnLateBounds = self.bounds
        end
        bounds:activate(self.bounds and self.bounds.group)
        for k, v in pairs(megautils.sectionChangeFuncs) do
          if type(v) == "function" then
            v()
          else
            v.func()
          end
        end
      end
      self.bounds = bounds
    end
  else
    self.scrollx = self.transform.x
    self.scrolly = self.transform.y
    self.scrollw = self.collisionShape.w
    self.scrollh = self.collisionShape.h
    if not noBounds and self.bounds then
      self.bounds:deactivate()
      self.despawnLateBounds = self.bounds
    end
    self.bounds = nil
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
      for k, v in ipairs(section.init) do
        v:initSection()
      end
      section.init = {}
    end
  end, 2, true)

function section:new(x, y, w, h, n)
  section.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
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
  for k, v in ipairs(self.group) do
    if not v.isAdded and not megautils.inAddQueue(v) and
      (not ignore or not table.contains(ignore, v)) then
      megautils.adde(v)
    end
  end
end

function section:deactivate(ignore)
  for k, v in ipairs(self.group) do
    if not v.isRemoved and not v.dontRemoveOnSectionChange and not megautils.inRemoveQueue(v) and
      (not ignore or not table.contains(ignore, v)) then
      megautils.removeq(v)
    end
  end
end

function section:initSection()
  for k, v in ipairs(self.group) do
    if not v.isRemoved then
      megautils.stopRemoveQueue(v)
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
      if section.hash[x] and section.hash[x][y] and not table.contains(result, section.hash[x][y]) then
        for k, v in ipairs(section.hash[x][y]) do
          if not table.contains(result, v) then
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
  for k, v in ipairs(s.cells) do
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
  local xx, yy, ww, hh = s.transform.x, s.transform.y, s.collisionShape.w, s.collisionShape.h
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
      s.cells[#s.cells+1] = {["x"]=x, ["y"]=y}
    end
  end
end

function section.iterate(func)
  for x, _ in pairs(section.hash) do
    for y, _ in pairs(section.hash[x]) do
      if section.hash[x][y] then
        for _, s in pairs(section.hash[x][y]) do
          for k, v in pairs(s.group) do
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
    local b = sections.getSections(e.transform.x, e.transform.y, e.collisionShape.w, e.collisionShape.h)
    for k, v in ipairs(b) do
      if not e.actualSectionGroups then
        e.actualSectionGroups = {}
      end
      if not table.contains(e.actualSectionGroups, v.group) then
        e.actualSectionGroups[#e.actualSectionGroups+1] = v.group
      end
      v.group[#v.group+1] = e
    end
  end
end