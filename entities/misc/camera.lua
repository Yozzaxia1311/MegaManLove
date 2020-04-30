camera = basicEntity:extend()

megautils.resetStateFuncs.camera = function()
  camera.main = nil
  section.hash = {}
  section.names = {}
  section.activated = {}
end

function camera:new(x, y, doScrollX, doScrollY)
  camera.super.new(self)
  self.transform.x = x
  self.transform.y = y
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
  self.doScrollY = doScrollY == nil and true or doScrollY
  self.doScrollX = doScrollX == nil and true or doScrollX
  self.transX = 0
  self.transY = 0
  self.approachX = self.transform.x
  self.approachY = self.transform.y
  self.speed = 1
  self.once = false
  self.player = nil
  view.x, view.y = self.transform.x, self.transform.y
  self.funcs = {}
  camera.main = self
  megautils.state().system.cameraUpdate = function()
      if camera.main then
        camera.main:updateBounds()
      end
    end
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
      self.transform.x = math.round(self.transform.x)
      self.transform.y = math.round(self.transform.y)
      self.approachX = self.transform.x
      self.approachY = self.transform.y
      view.x, view.y = self.approachX, self.approachY
      camera.main:updateFuncs()
    elseif not self.once then
      if megautils.groups().removeOnTransition then
        for k, v in pairs(megautils.groups().removeOnTransition) do
          if not v.dontRemove then
            megautils.removeq(v)
          end
        end
      end
      if self.freeze then
        megautils.freeze(globals.allPlayers)
        for k, v in pairs(globals.allPlayers) do
          v.control = false
        end
      end 
      if self.player then
        local lx, ly = self.transform.x, self.transform.y
        local lsx, lsy, lsw, lsh, lb = self.scrollx, self.scrolly, self.scrollw, self.scrollh, self.bounds
        if self.transitionDirection == "right" then
          self.transform.x = self.transform.x + self.collisionShape.w
        elseif self.transitionDirection == "left" then
          self.transform.x = self.transform.x - self.collisionShape.w
        elseif self.transitionDirection == "down" then
          self.transform.y = self.transform.y + self.collisionShape.h
        elseif self.transitionDirection == "up" then
          self.transform.y = self.transform.y - self.collisionShape.h
        end
        self:updateBounds(true)
        if self.bounds then
          for k, v in ipairs(self.bounds) do
            for i, j in ipairs(v.group) do
              if j.spawnEarlyDuringTransition and not j.isAdded then
                megautils.adde(j)
              end
            end
          end
        end
        self.transform.x, self.transform.y = lx, ly
        self.scrollx, self.scrolly, self.scrollw, self.scrollh, self.bounds = lsx, lsy, lsw, lsh, lb
        local sx, sy, sw, sh = self.scrollx, self.scrolly, self.scrollw, self.scrollh
        if self.transitionDirection == "right" then
          if self.doScrollY then
            local ny = self.player.transform.y - (view.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
            ny = math.clamp(ny, sy, sy+sh-view.h)
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x+self.collisionShape.w, y=ny})
          else
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x+self.collisionShape.w})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.transX, y=self.player.transform.y})
          end
        elseif self.transitionDirection == "left" then
          if self.doScrollY then
            local ny = self.player.transform.y - (view.h/2) + (self.player.collisionShape.h/2) + self.player:camOffY()
            ny = math.clamp(ny, sy, sy+sh-view.h)
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w, y=ny})
          else
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.transX, y=self.player.transform.y})
          end
        elseif self.transitionDirection == "down" then
          if self.doScrollX then
            local nx = self.player.transform.x - (view.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
            nx = math.clamp(nx, sx, sx+sw-view.w)
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y+self.collisionShape.h, x=nx})
          else
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y+self.collisionShape.h})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.player.transform.x, y=self.transY})
          end
        elseif self.transitionDirection == "up" then
          if self.doScrollX then
            local nx = self.player.transform.x - (view.w/2) + (self.player.collisionShape.w/2) + self.player:camOffX()
            nx = math.clamp(nx, sx, sx+sw-view.w)
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h, x=nx})
          else
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.player.transform.x, y=self.transY})
          end
        end
      end
      if self.player.onMovingFloor then
        self.flx = self.player.onMovingFloor.transform.x - self.player.transform.x
      end
      self.once = true
      megautils.state().system.cameraUpdate = function(s)
        for i=1, #globals.allPlayers do
          camera.main.tween2[i]:update(1/60)
        end
        if camera.main.tween:update(1/60) then
          camera.main.tweenFinished = true
          if not camera.main.dontUpdateSections then
            camera.main:updateBounds()
          end
          camera.main.transition = false
          camera.main.once = false
          camera.main.tweenFinished = nil
          camera.main.preTrans = false
          if camera.main.freeze then
            megautils.unfreeze(globals.allPlayers)
            for k, v in pairs(globals.allPlayers) do
              v.control = true
            end
          end
          if camera.main.player and camera.main.player.onMovingFloor then
            camera.main.player.onMovingFloor.dontRemove = nil
          end
          for i=1, #globals.allPlayers do
            if globals.allPlayers[i] ~= camera.main.player then
              camera.main.player:transferState(globals.allPlayers[i])
            end
          end
          camera.main.tween = nil
          camera.main.tween2 = nil
          megautils.state().system.cameraUpdate = function()
              if camera.main then
                camera.main:updateBounds()
              end
            end
        end
        if camera.main.player and camera.main.player.onMovingFloor then
          camera.main.player.onMovingFloor.transform.x = camera.main.player.transform.x + camera.main.flx
          camera.main.player.onMovingFloor.transform.y = camera.main.player.transform.y + camera.main.player.collisionShape.h
        end
        camera.main.transform.x = math.round(camera.main.transform.x)
        camera.main.transform.y = math.round(camera.main.transform.y)
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
  if #globals.allPlayers <= 1 then
    local o = globals.allPlayers[1]
    if self.doScrollX then
      self.transform.x = math.round(o.transform.x) - (view.w/2) + (o.collisionShape.w/2) + o:camOffX()
    end
    if self.doScrollY then
      self.transform.y = math.round(o.transform.y) - (view.h/2) + (o.collisionShape.h/2) + o:camOffY()
    end
  else
    local avx, avy = 0, 0
    for i=1, #globals.allPlayers do
      local p = globals.allPlayers[i]
      if p ~= without then
        if self.doScrollX then
          avx = avx+(p.transform.x + o:camOffX() - (view.w/2) + (p.collisionShape.w/2))
        end
        if self.doScrollY then
          avy = avy+(p.transform.y + o:camOffY() - (view.h/2) + (p.collisionShape.h/2))
        end
      end
    end
    if self.doScrollX then
      self.transform.x = avx/#globals.allPlayers
    end
    if self.doScrollY then
      self.transform.y = avy/#globals.allPlayers
    end
  end
  
  self:updateBounds(true)
  
  local sx, sy, sw, sh = self.scrollx, self.scrolly, self.scrollw, self.scrollh
  
  self.transform.x = math.clamp(self.transform.x, sx, sx+sw-self.collisionShape.w)
  self.transform.y = math.clamp(self.transform.y, sy, sy+sh-self.collisionShape.h)
  
  self.approachX = math.approach(self.approachX, self.transform.x, spdx or 8)
  self.approachY = math.approach(self.approachY, self.transform.y, spdy or 8)
  view.x, view.y = math.round(self.approachX), math.round(self.approachY)
  self:updateFuncs()
end

function camera:updateFuncs()
  for k, v in pairs(self.funcs) do
    v(self)
  end
end

function camera:updateBounds(dae)
  local bounds
  
  if self.curBoundName and section.names[self.curBoundName] then
    if not dae then
      section.doSpatialUpdate(self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h)
    end
    bounds = section.names[self.curBoundName]
  else
    local sects
    if dae then
      sects = section.getSections(self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h)
    else
      section.doSpatialUpdate(self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h)
      sects = section.activated
    end
    
    local biggestArea = 0
    local lx, ly = self.transform.x, self.transform.y
    
    for k, s in ipairs(sects) do
      local x, y, x2, y2 = s.transform.x, s.transform.y, s.transform.x+s.collisionShape.w, s.transform.y+s.collisionShape.h
      local p = {}
      
      if megautils.groups().sectionTransitionStopper then
        for k, v in ipairs(globals.allPlayers) do
          if #v:collisionTable(megautils.groups().sectionTransitionStopper) == 0 then
            p[#p+1] = v
          end
        end
      end
      
      local cont = not self:collision(s) and #s:collisionTable(p) < #globals.allPlayers
        
      if not cont then
        if x < self.transform.x then
          x = self.transform.x
        end
        if x2 > self.transform.x+self.collisionShape.w then
          x2 = self.transform.x+self.collisionShape.w
        end
        if y < self.transform.y then
          y = self.transform.y
        end
        if y2 > self.transform.y+self.collisionShape.h then
          y2 = self.transform.y+self.collisionShape.h
        end
        
        if (x2-x)*(y2-y) > biggestArea then
          biggestArea = (x2-x)*(y2-y)
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
    self.bounds = bounds
  else
    self.scrollx = self.transform.x
    self.scrolly = self.transform.y
    self.scrollw = self.collisionShape.w
    self.scrollh = self.collisionShape.h
    self.bounds = nil
  end
end

section = basicEntity:extend()

addobjects.register("section", function(v)
  section.addSection(section(v.x, v.y, v.width, v.height, v.properties.lockLeft, v.properties.lockRight,
    v.properties.lockUp, v.properties.lockDown, v.properties.name))
end, 1)

function section:new(x, y, w, h, lx, ly, lw, lh, n)
  section.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.lockLeft = (lx==nil) or lx
  self.lockUp = (ly==nil) or ly
  self.lockRight = (lw==nil) or lw
  self.lockDown = (lh==nil) or lh
  self.active = true
  if n then
    self.name = n
    section.names[self.name] = self
  end
  self.group = self:collisionTable(megautils.groups().despawnable)  
  self.cells = {}
end

function section:activate()
  self.active = true
  for k, v in ipairs(self.group) do
    if not v.isAdded and not megautils.inAddQueue(v) then
      megautils.adde(v)
    end
  end
end

function section:deactivate()
  --self.active = false
  for k, v in ipairs(self.group) do
    if not v.isRemoved and not v.dontRemove and not megautils.inRemoveQueue(v) then
      megautils.remove(v)
    end
  end
end

section.hash = {}
section.names = {}
section.activated = {}

function section.doSpatialUpdate(xx, yy, ww, hh)
  local cx, cy = math.floor(xx/view.w), math.floor(yy/view.h)
  local cx2, cy2 = math.floor((xx+ww)/view.w), math.floor((yy+hh)/view.h)
  
  for x=cx, cx2 do
    for y=cy, cy2 do
      if section.hash[x] and section.hash[x][y] then
        for k, v in ipairs(section.hash[x][y]) do
          if not table.contains(section.activated, self) then
            section.activated[#section.activated+1] = self
          end
        end
      end
    end
  end
  
  for k, v in ipairs(section.activated) do
    if v.active then
      v:deactivate()
    end
  end
  
  for k, v in ipairs(section.activated) do
    if rectOverlapsRect(v.transform.x, v.transform.y, v.collisionShape.w, v.collisionShape.h, xx, yy, ww, hh) and not v.active then
      v:activate()
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
          result[#result+1] = v
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
  table.quickremovevaluearray(section.activated, self)
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
      section.activated[#section.activated+1] = s
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