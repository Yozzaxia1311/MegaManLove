right = basicEntity:extend()

right.autoClean = false

binser.register(right, "right", function(o)
    local result = {}
    
    right.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    
    return result
  end, function(o)
    local result = right()
    
    right.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    
    return result
  end)

mapEntity.register("right", function(v)
  megautils.add(right, v.x, v.y, v.height,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform, v.properties.toSection)
end, 0, true)

function right:new(x, y, h, scrollx, scrolly, spd, p, n)
  right.super.new(self)
  self:setRectangleCollision(2, h or view.h)
  self.transform.x = (x or 0) + 14
  self.transform.y = y or 0
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
      if camera.main and checkFalse(player.canControl) and not camera.main.transition and self:collision(player, 2, 0)
        and (not self.platform or (self.platform and player.onMovingFloor)) then
        camera.main.transitionDirection = "right"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s = self:collisionTable(section.getSections(self.transform.x+2, self.transform.y, 2, self.collisionShape.h), 2, 0)[1]
        camera.main.toSection = s
        camera.main.transform.x = self.transform.x+2-camera.main.collisionShape.w
        camera.main.transX = camera.main.transform.x+camera.main.collisionShape.w+8
        camera.main.curBoundName = self.name
        break
      end
    end
  end
end

left = basicEntity:extend()

left.autoClean = false

binser.register(left, "left", function(o)
    local result = {}
    
    left.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    
    return result
  end, function(o)
    local result = left()
    
    left.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    
    return result
  end)

mapEntity.register("left", function(v)
  megautils.add(left, v.x, v.y, v.height,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform, v.properties.toSection)
end, 0, true)

function left:new(x, y, h, scrollx, scrolly, spd, p, n)
  left.super.new(self)
  self:setRectangleCollision(2, h or view.h)
  self.transform.x = x or 0
  self.transform.y = y or 0
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
      if camera.main and checkFalse(player.canControl) and not camera.main.transition
        and self:collision(player, -2, 0) and (not self.platform or (self.platform and player.onMovingFloor)) then
        camera.main.transitionDirection = "left"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s = self:collisionTable(section.getSections(self.transform.x-2, self.transform.y, 2, self.collisionShape.h), -2, 0)[1]
        camera.main.toSection = s
        camera.main.transform.x = self.transform.x
        camera.main.transX = camera.main.transform.x-camera.main.player.collisionShape.w-8
        camera.main.curBoundName = self.name
        break
      end
    end
  end
end

down = basicEntity:extend()

down.autoClean = false

binser.register(down, "down", function(o)
    local result = {}
    
    down.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    result.checkLadder = o.checkLadder
    
    return result
  end, function(o)
    local result = down()
    
    down.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    result.checkLadder = o.checkLadder
    
    return result
  end)

mapEntity.register("down", function(v)
  megautils.add(down, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed,
    v.properties.platform, v.properties.toSection, v.properties.checkLadder)
end, 0, true)

function down:new(x, y, w, scrollx, scrolly, spd, p, n, cl)
  down.super.new(self)
  self:setRectangleCollision(w or view.w, 2)
  self.transform.x = x or 0
  self.transform.y = (y or 0) + 14
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
      if camera.main and checkFalse(player.canControl) and not camera.main.transition
        and self:collision(player, 0, 2) and (not self.platform or (self.platform and player.onMovingFloor)) and
        (not self.checkLadder or (self.checkLadder and (player.climb or player.gravity >= 0))) then
        camera.main.transitionDirection = "down"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y+2, self.collisionShape.w, 2), 0, 2)[1]
        camera.main.toSection = s
        camera.main.transform.y = self.transform.y+2-camera.main.collisionShape.h
        camera.main.transY = camera.main.transform.y+camera.main.collisionShape.h+8
        camera.main.curBoundName = self.name
        break
      end
    end
  end
end

up = basicEntity:extend()

up.autoClean = false

binser.register(up, "up", function(o)
    local result = {}
    
    up.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    result.checkLadder = o.checkLadder
    
    return result
  end, function(o)
    local result = up()
    
    up.super.transfer(o, result)
    
    result.scrollx = o.scrollx
    result.scrolly = o.scrolly
    result.spd = o.spd
    result.platform = o.platform
    result.name = o.name
    result.isLocked = o.isLocked
    result.checkLadder = o.checkLadder
    
    return result
  end)

mapEntity.register("up", function(v)
  megautils.add(up, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed,
    v.properties.platform, v.properties.toSection, v.properties.checkLadder)
end, 0, true)

function up:new(x, y, w, scrollx, scrolly, spd, p, n, cl)
  up.super.new(self)
  self:setRectangleCollision(w or view.w, 2)
  self.transform.x = x or 0
  self.transform.y = y or 0
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
      if camera.main and checkFalse(player.canControl) and not camera.main.transition
        and self:collision(player, 0, -2) and (not self.platform or (self.platform and player.onMovingFloor)) and
        (not self.checkLadder or (self.checkLadder and (player.climb or player.gravity < 0))) then
        camera.main.transitionDirection = "up"
        camera.main.transition = true
        camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y-2, self.collisionShape.w, 2), 0, -2)[1]
        camera.main.toSection = s
        camera.main.transform.y = self.transform.y
        camera.main.transY = camera.main.transform.y-camera.main.player.collisionShape.h-8
        camera.main.curBoundName = self.name
        break
      end
    end
  end
end

sectionPrioritySetter = basicEntity:extend()

sectionPrioritySetter.autoClean = false

binser.register(sectionPrioritySetter, "sectionPrioritySetter", function(o)
    local result = {}
    
    sectionPrioritySetter.super.transfer(o, result)
    
    result.name = o.name
    
    return result
  end, function(o)
    local result = sectionPrioritySetter()
    
    sectionPrioritySetter.super.transfer(o, result)
    
    result.name = o.name
    
    return result
  end)

mapEntity.register("sectionPrioritySetter", function(v)
  megautils.add(sectionPrioritySetter, v.x, v.y, v.width, v.height, v.properties.toSection)
end, 0, true)

function sectionPrioritySetter:new(x, y, w, h, name)
  sectionPrioritySetter.super.new(self)
  self:setRectangleCollision(w or 32, h or 32)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.name = name
end

function sectionPrioritySetter:added()
  self:addToGroup("handledBySections")
end

function sectionPrioritySetter:check()
  local count = 0
  local sx, sy, sw, sh = self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h
  
  for k, v in ipairs(megaMan.allPlayers) do
    local x, y, w, h = v.transform.x, v.transform.y, v.collisionShape.w, v.collisionShape.h
    if pointOverlapsRect(x, y, sx, sy, sw, sh) and pointOverlapsRect(x+w, y, sx, sy, sw, sh) and
      pointOverlapsRect(x+w, y+h, sx, sy, sw, sh) and pointOverlapsRect(x, y+h, sx, sy, sw, sh) then
      count = count + 1
    end
  end
  
  return count
end

function sectionPrioritySetter:update(dt)
  if camera.main and not camera.main.transition and self.name ~= camera.main.curBoundName and self:check() == #megaMan.allPlayers then
    camera.main.curBoundName = self.name == "" and nil or self.name
  end
end

sectionPrioritySetterXBorder = basicEntity:extend()

sectionPrioritySetterXBorder.autoClean = false

binser.register(sectionPrioritySetterXBorder, "sectionPrioritySetterXBorder", function(o)
    local result = {}
    
    sectionPrioritySetterXBorder.super.transfer(o, result)
    
    result.lname = o.lname
    result.rname = o.rname
    
    return result
  end, function(o)
    local result = sectionPrioritySetterXBorder()
    
    sectionPrioritySetterXBorder.super.transfer(o, result)
    
    result.lname = o.lname
    result.rname = o.rname
    
    return result
  end)

mapEntity.register("sectionPrioritySetterXBorder", function(v)
  megautils.add(sectionPrioritySetterXBorder, v.x, v.y, v.height, v.properties.lname, v.properties.rname)
end, 0, true)

function sectionPrioritySetterXBorder:new(x, y, h, lname, rname)
  sectionPrioritySetterXBorder.super.new(self)
  self:setRectangleCollision(32, h or view.h)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.lname = lname
  self.rname = rname
end

function sectionPrioritySetterXBorder:added()
  self:addToGroup("handledBySections")
end

function sectionPrioritySetterXBorder:getSide()
  local same = 0
  for k, v in ipairs(megaMan.allPlayers) do
    if v.transform.x+(v.collisionShape.w/2) > self.transform.x+16 and
      math.between(v.transform.y, self.transform.y, self.transform.y+self.collisionShape.h-v.collisionShape.h) then
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

binser.register(sectionPrioritySetterYBorder, "sectionPrioritySetterYBorder", function(o)
    local result = {}
    
    sectionPrioritySetterYBorder.super.transfer(o, result)
    
    result.uname = o.uname
    result.dname = o.dname
    
    return result
  end, function(o)
    local result = sectionPrioritySetterYBorder()
    
    sectionPrioritySetterYBorder.super.transfer(o, result)
    
    result.uname = o.uname
    result.dname = o.dname
    
    return result
  end)

mapEntity.register("sectionPrioritySetterYBorder", function(v)
  megautils.add(sectionPrioritySetterYBorder, v.x, v.y, v.width, v.properties.uname, v.properties.dname)
end, 0, true)

function sectionPrioritySetterYBorder:new(x, y, w, uname, dname)
  sectionPrioritySetterYBorder.super.new(self)
  self:setRectangleCollision(w or view.w, 32)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.uname = uname
  self.dname = dname
end

function sectionPrioritySetterYBorder:added()
  self:addToGroup("handledBySections")
end

function sectionPrioritySetterYBorder:getSide()
  local same = 0
  for k, v in ipairs(megaMan.allPlayers) do
    if v.transform.y+(v.collisionShape.h/2) > self.transform.y+16 and
      math.between(v.transform.x, self.transform.x, self.transform.x+self.collisionShape.w-v.collisionShape.w) then
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

binser.register(sectionPrioritySetterArea, "sectionPrioritySetterArea", function(o)
    local result = {}
    
    sectionPrioritySetterArea.super.transfer(o, result)
    
    result.inName = o.inName
    result.outName = o.outName
    
    return result
  end, function(o)
    local result = sectionPrioritySetterArea()
    
    sectionPrioritySetterArea.super.transfer(o, result)
    
    result.inName = o.inName
    result.outName = o.outName
    
    return result
  end)

mapEntity.register("sectionPrioritySetterArea", function(v)
  megautils.add(sectionPrioritySetterArea, v.x, v.y, v.width, v.height, v.properties.inname, v.properties.outname)
end, 0, true)

function sectionPrioritySetterArea:new(x, y, w, h, name, name2)
  sectionPrioritySetterArea.super.new(self)
  self:setRectangleCollision(w or 32, h or 32)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.inName = name
  self.outName = name2
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
  for i, j in ipairs(megautils.groups().sectionPriorityArea) do
    if self.inName == j.inName then
      local sx, sy, sw, sh = j.transform.x, j.transform.y, j.collisionShape.w, j.collisionShape.h
      
      for k, v in pairs(checker) do
        local x, y, w, h = v.transform.x, v.transform.y, v.collisionShape.w, v.collisionShape.h
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