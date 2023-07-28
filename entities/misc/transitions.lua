right = basicEntity:extend()

right.autoClean = false
right.invisibleToHash = true

mapEntity.register("right", function(v)
  entities.add(right, v.x, v.y, v.height,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform, v.properties.toSection)
end, 0, true)

function right:new(x, y, h, scrollx, scrolly, spd, p, n)
  right.super.new(self)
  self:setRectangleCollision(2, h or view.h)
  self.x = (x or 0) + 14
  self.y = y or 0
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd or 0.8
  self.platform = p
  self.name = n
  if self.name == "" then
    self.name = nil
  end
  self.isLocked = {global=false}
end

function right:added()
  self:addToGroup("handledBySections")
end

function right:update(dt)
  if not checkTrue(self.isLocked) then
    for i=1, #megaMan.allPlayers do
      local player = megaMan.allPlayers[i]
      self:setRectangleCollision(32, self.collisionShape.h)
      local pCheck = self:collision(player, 2, 0)
      self:setRectangleCollision(2, self.collisionShape.h)
      
      if camera.main and checkFalse(player.canControl) and not camera.main.transition and pCheck
        and (not self.platform or (self.platform and player.onMovingFloor)) then
        camera.main.transitionDirection = "right"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s
        for _, v in ipairs(self:collisionTable(section.getSections(self.x+2, self.y,
          self.collisionShape.w, self.collisionShape.h), 2, 0)) do
          if v.name == self.name then
            s = v
            break
          end
          s = v
        end
        camera.main.toSection = s
        camera.main.x = self.x+2-camera.main.collisionShape.w
        camera.main.transX = camera.main.x+camera.main.collisionShape.w+8
        break
      end
    end
  end
end

left = basicEntity:extend()

left.autoClean = false
left.invisibleToHash = true

mapEntity.register("left", function(v)
  entities.add(left, v.x, v.y, v.height,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform, v.properties.toSection)
end, 0, true)

function left:new(x, y, h, scrollx, scrolly, spd, p, n)
  left.super.new(self)
  self:setRectangleCollision(2, h or view.h)
  self.x = x or 0
  self.y = y or 0
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd or 0.8
  self.platform = p
  self.name = n
  if self.name == "" then
    self.name = nil
  end
  self.isLocked = {global=false}
end

function left:added()
  self:addToGroup("handledBySections")
end

function left:update(dt)
  if not checkTrue(self.isLocked) then
    for i=1, #megaMan.allPlayers do
      local player = megaMan.allPlayers[i]
      self:setRectangleCollision(32, self.collisionShape.h)
      local pCheck = self:collision(player, -self.collisionShape.w, 0)
      self:setRectangleCollision(2, self.collisionShape.h)
      
      if camera.main and checkFalse(player.canControl) and not camera.main.transition
        and pCheck and (not self.platform or (self.platform and player.onMovingFloor)) then
        camera.main.transitionDirection = "left"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s
        for _, v in ipairs(self:collisionTable(section.getSections(self.x-2, self.y,
          self.collisionShape.w, self.collisionShape.h), -2, 0)) do
          if v.name == self.name then
            s = v
            break
          end
          s = v
        end
        camera.main.toSection = s
        camera.main.x = self.x
        camera.main.transX = camera.main.x-camera.main.player.collisionShape.w-8
        break
      end
    end
  end
end

down = basicEntity:extend()

down.autoClean = false
down.invisibleToHash = true

mapEntity.register("down", function(v)
  entities.add(down, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed,
    v.properties.platform, v.properties.toSection, v.properties.checkLadder)
end, 0, true)

function down:new(x, y, w, scrollx, scrolly, spd, p, n, cl)
  down.super.new(self)
  self:setRectangleCollision(w or view.w, 2)
  self.x = x or 0
  self.y = (y or 0) + 14
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd or 0.8
  self.platform = p
  self.name = n
  if self.name == "" then
    self.name = nil
  end
  self.checkLadder = cl
  self.isLocked = {global=false}
end

function down:added()
  self:addToGroup("handledBySections")
end

function down:update(dt)
  if not checkTrue(self.isLocked) then
    for i=1, #megaMan.allPlayers do
      local player = megaMan.allPlayers[i]
      self:setRectangleCollision(self.collisionShape.w, 32)
      local pCheck = self:collision(player, 0, 2)
      self:setRectangleCollision(self.collisionShape.w, 2)
      
      if camera.main and checkFalse(player.canControl) and not camera.main.transition
        and pCheck and (not self.platform or (self.platform and player.onMovingFloor)) and
        (not self.checkLadder or (self.checkLadder and (player.climb or player.gravity >= 0))) then
        camera.main.transitionDirection = "down"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s
        for _, v in ipairs(self:collisionTable(section.getSections(self.x, self.y+2,
          self.collisionShape.w, self.collisionShape.h), 0, 2)) do
          if v.name == self.name then
            s = v
            break
          end
          s = v
        end
        camera.main.toSection = s
        camera.main.y = self.y+2-camera.main.collisionShape.h
        camera.main.transY = camera.main.y+camera.main.collisionShape.h+8
        break
      end
    end
  end
end

up = basicEntity:extend()

up.autoClean = false
up.invisibleToHash = true

mapEntity.register("up", function(v)
  entities.add(up, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed,
    v.properties.platform, v.properties.toSection, v.properties.checkLadder)
end, 0, true)

function up:new(x, y, w, scrollx, scrolly, spd, p, n, cl)
  up.super.new(self)
  self:setRectangleCollision(w or view.w, 2)
  self.x = x or 0
  self.y = y or 0
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd or 0.8
  self.platform = p
  self.name = n
  if self.name == "" then
    self.name = nil
  end
  self.checkLadder = cl
  self.isLocked = {global=false}
end

function up:added()
  self:addToGroup("handledBySections")
end

function up:update(dt)
  if not checkTrue(self.isLocked) then
    for i=1, #megaMan.allPlayers do
      local player = megaMan.allPlayers[i]
      self:setRectangleCollision(self.collisionShape.w, 32)
      local pCheck = self:collision(player, 0, -self.collisionShape.h)
      self:setRectangleCollision(self.collisionShape.w, 2)
      
      if camera.main and checkFalse(player.canControl) and not camera.main.transition
        and pCheck and (not self.platform or (self.platform and player.onMovingFloor)) and
        (not self.checkLadder or (self.checkLadder and (player.climb or player.gravity < 0))) then
        camera.main.transitionDirection = "up"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s
        for _, v in ipairs(self:collisionTable(section.getSections(self.x, self.y-2,
          self.collisionShape.w, self.collisionShape.h), 0, -2)) do
          if v.name == self.name then
            s = v
            break
          end
          s = v
        end
        camera.main.toSection = s
        camera.main.y = self.y
        camera.main.transY = camera.main.y-camera.main.player.collisionShape.h-8
        break
      end
    end
  end
end

sectionPrioritySetter = basicEntity:extend()

sectionPrioritySetter.autoClean = false
sectionPrioritySetter.invisibleToHash = true

mapEntity.register("sectionPrioritySetter", function(v)
  entities.add(sectionPrioritySetter, v.x, v.y, v.width, v.height, v.properties.toSection)
end, 0, true)

function sectionPrioritySetter:new(x, y, w, h, name)
  sectionPrioritySetter.super.new(self)
  self:setRectangleCollision(w or 32, h or 32)
  self.x = x or 0
  self.y = y or 0
  self.name = name
  if self.name == "" then
    self.name = nil
  end
end

function sectionPrioritySetter:added()
  self:addToGroup("handledBySections")
end

function sectionPrioritySetter:check()
  local count = 0
  local sx, sy, sw, sh = self.x-1, self.y-1, self.collisionShape.w+2, self.collisionShape.h+2
  
  for _, v in ipairs(megaMan.allPlayers) do
    local x, y, w, h = v.x, v.y, v.collisionShape.w, v.collisionShape.h
    if pointOverlapsRect(x, y, sx, sy, sw, sh) and pointOverlapsRect(x+w, y, sx, sy, sw, sh) and
      pointOverlapsRect(x+w, y+h, sx, sy, sw, sh) and pointOverlapsRect(x, y+h, sx, sy, sw, sh) then
      count = count + 1
    end
  end
  
  return count
end

function sectionPrioritySetter:update(dt)
  if camera.main and not camera.main.transition and self.name ~= camera.main.curBoundName and self:check() == #megaMan.allPlayers then
    camera.main.curBoundName = self.name
  end
end

sectionPrioritySetterXBorder = basicEntity:extend()

sectionPrioritySetterXBorder.autoClean = false
sectionPrioritySetterXBorder.invisibleToHash = true

mapEntity.register("sectionPrioritySetterXBorder", function(v)
  entities.add(sectionPrioritySetterXBorder, v.x, v.y, v.height, v.properties.lname, v.properties.rname)
end, 0, true)

function sectionPrioritySetterXBorder:new(x, y, h, lname, rname)
  sectionPrioritySetterXBorder.super.new(self)
  self:setRectangleCollision(32, h or view.h)
  self.x = x or 0
  self.y = y or 0
  self.lname = lname
  if self.lname == "" then
    self.lname = nil
  end
  self.rname = rname
  if self.rname == "" then
    self.rname = nil
  end
end

function sectionPrioritySetterXBorder:added()
  self:addToGroup("handledBySections")
end

function sectionPrioritySetterXBorder:getSide()
  local same = 0
  for _, v in ipairs(megaMan.allPlayers) do
    if v.x+(v.collisionShape.w/2) > self.x+16 and
      math.between(v.y, self.y, self.y+self.collisionShape.h-v.collisionShape.h) then
      same = same + 1
    end
  end
  
  if same == #megaMan.allPlayers then
    return self.rname
  elseif same == 0 then
    return self.lname
  end
end

function sectionPrioritySetterXBorder:update(dt)
  local s = self:getSide()
  if camera.main and not camera.main.transition and not megautils.outside(self) then
    camera.main.curBoundName = s
  end
end

sectionPrioritySetterYBorder = basicEntity:extend()

sectionPrioritySetterYBorder.autoClean = false
sectionPrioritySetterYBorder.invisibleToHash = true

mapEntity.register("sectionPrioritySetterYBorder", function(v)
  entities.add(sectionPrioritySetterYBorder, v.x, v.y, v.width, v.properties.uname, v.properties.dname)
end, 0, true)

function sectionPrioritySetterYBorder:new(x, y, w, uname, dname)
  sectionPrioritySetterYBorder.super.new(self)
  self:setRectangleCollision(w or view.w, 32)
  self.x = x or 0
  self.y = y or 0
  self.uname = uname
  if self.uname == "" then
    self.name = nil
  end
  self.dname = dname
  if self.dname == "" then
    self.name = nil
  end
end

function sectionPrioritySetterYBorder:added()
  self:addToGroup("handledBySections")
end

function sectionPrioritySetterYBorder:getSide()
  local same = 0
  for _, v in ipairs(megaMan.allPlayers) do
    if v.y+(v.collisionShape.h/2) > self.y+16 and
      math.between(v.x, self.x, self.x+self.collisionShape.w-v.collisionShape.w) then
      same = same + 1
    end
  end
  
  if same == #megaMan.allPlayers then
    return self.dname
  elseif same == 0 then
    return self.uname
  end
end

function sectionPrioritySetterYBorder:update(dt)
  local s = self:getSide()
  if camera.main and not camera.main.transition and not megautils.outside(self) then
    camera.main.curBoundName = s
  end
end

sectionPrioritySetterArea = basicEntity:extend()

sectionPrioritySetterArea.autoClean = false
sectionPrioritySetterArea.invisibleToHash = true

mapEntity.register("sectionPrioritySetterArea", function(v)
  entities.add(sectionPrioritySetterArea, v.x, v.y, v.width, v.height, v.properties.inname, v.properties.outname)
end, 0, true)

function sectionPrioritySetterArea:new(x, y, w, h, name, name2)
  sectionPrioritySetterArea.super.new(self)
  self:setRectangleCollision(w or 32, h or 32)
  self.x = x or 0
  self.y = y or 0
  self.inName = name
  if self.inName == "" then
    self.inName = nil
  end
  self.outName = name2
  if self.outName == "" then
    self.outName = nil
  end
end

function sectionPrioritySetterArea:added()
  self:addToGroup("handledBySections")
  self:addToGroup("sectionPriorityArea")
end

function sectionPrioritySetterArea:check()
  local count = 0
  local checker = {}
  for i=1, #megaMan.allPlayers do
    checker[i] = megaMan.allPlayers[i]
  end
  for _, j in ipairs(entities.groups.sectionPriorityArea) do
    if self.inName == j.inName then
      local sx, sy, sw, sh = j.x-1, j.y-1, j.collisionShape.w+2, j.collisionShape.h+2
      
      for k, v in safepairs(checker) do
        local x, y, w, h = v.x, v.y, v.collisionShape.w, v.collisionShape.h
        if pointOverlapsRect(x, y, sx, sy, sw, sh) and pointOverlapsRect(x+w, y, sx, sy, sw, sh) and
          pointOverlapsRect(x+w, y+h, sx, sy, sw, sh) and pointOverlapsRect(x, y+h, sx, sy, sw, sh) then
          checker[k] = nil
          count = count + 1
        end
      end
    end
  end
  
  return count
end

function sectionPrioritySetterArea:update(dt)
  if not megautils.outside(self) and camera.main and not camera.main.transition then
    local c = self:check()
    if c == #megaMan.allPlayers then
      camera.main.curBoundName = self.name
    else
      camera.main.curBoundName = self.outName
    end
  end
end
