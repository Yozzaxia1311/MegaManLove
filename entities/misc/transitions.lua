right = basicEntity:extend()

addobjects.register("right", function(v)
  megautils.add(right, v.x, v.y, v.height,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform)
end)

function right:new(x, y, h, scrollx, scrolly, spd, p)
  right.super.new(self)
  self:setRectangleCollision(2, h)
  self.transform.x = x + 14
  self.transform.y = y
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function right:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and player.control and not camera.main.transition and self:collision(player, 2, 0)
      and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitionDirection = "right"
      camera.main.transition = true
      camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd or 0.8
      local s = self:collisionTable(section.getSections(self.transform.x+2, self.transform.y, 2, self.collisionShape.h), 2, 0)[1]
      camera.main.toSection = s
      camera.main.transform.x = self.transform.x+2-camera.main.collisionShape.w
      camera.main.transX = camera.main.transform.x+camera.main.collisionShape.w+8
      camera.main.curBoundName = s.name
      break
    end
  end
end

left = basicEntity:extend()

addobjects.register("left", function(v)
  megautils.add(left, v.x, v.y, v.height,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform)
end)

function left:new(x, y, h, scrollx, scrolly, spd, p)
  left.super.new(self)
  self:setRectangleCollision(2, h)
  self.transform.x = x
  self.transform.y = y
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function left:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and player.control and not camera.main.transition
      and self:collision(player, -2, 0) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitionDirection = "left"
      camera.main.transition = true
      camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd or 0.8
      local s = self:collisionTable(section.getSections(self.transform.x-2, self.transform.y, 2, self.collisionShape.h), -2, 0)[1]
      camera.main.toSection = s
      camera.main.transform.x = self.transform.x
      camera.main.transX = camera.main.transform.x-camera.main.player.collisionShape.w-8
      camera.main.curBoundName = s.name
      break
    end
  end
end

down = basicEntity:extend()

addobjects.register("down", function(v)
  megautils.add(down, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform)
end)

function down:new(x, y, w, scrollx, scrolly, spd, p)
  down.super.new(self)
  self:setRectangleCollision(w, 2)
  self.transform.y = y + 14
  self.transform.x = x
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd or 0.8
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function down:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and player.control and not camera.main.transition
      and self:collision(player, 0, 2) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitionDirection = "down"
      camera.main.transition = true
      camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd or 0.8
      local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y+2, self.collisionShape.w, 2), 0, 2)[1]
      camera.main.toSection = s
      camera.main.transform.y = self.transform.y+2-camera.main.collisionShape.h
      camera.main.transY = camera.main.transform.y+camera.main.collisionShape.h+8
      camera.main.curBoundName = s.name
      break
    end
  end
end

up = basicEntity:extend()

addobjects.register("up", function(v)
  megautils.add(up, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform)
end)

function up:new(x, y, w, scrollx, scrolly, spd, p)
  up.super.new(self)
  self:setRectangleCollision(w, 2)
  self.transform.y = y
  self.transform.x = x
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function up:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and player.control and not camera.main.transition
      and self:collision(player, 0, -2) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitionDirection = "up"
      camera.main.transition = true
      camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd or 0.8
      local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y-2, self.collisionShape.w, 2), 0, -2)[1]
      camera.main.toSection = s
      camera.main.transform.y = self.transform.y
      camera.main.transY = camera.main.transform.y-camera.main.player.collisionShape.h-8
      camera.main.curBoundName = s.name
      break
    end
  end
end

upLadder = basicEntity:extend()

addobjects.register("upLadder", function(v)
  megautils.add(upLadder, v.x, v.y, v.width,
    v.properties.doScrollX, v.properties.doScrollY, v.properties.speed, v.properties.platform)
end)

function upLadder:new(x, y, w, scrollx, scrolly, spd, p)
  upLadder.super.new(self)
  self:setRectangleCollision(w, 2)
  self.transform.y = y
  self.transform.x = x
  self.scrollx = scrollx ~= nil
  self.scrolly = scrolly
  self.spd = spd
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
    self.ladder = self:collisionTable(megautils.groups().ladder)[1]
  end
end

function upLadder:update(dt)
  if not self.ladder then
    self.ladder = self:collisionTable(megautils.groups().ladder)[1]
  end
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and not camera.main.transition and
      (self.ladder or (not self.platform or (self.platform and player.onMovingFloor))) and
      player.control and (player.climb or player.treble == 2) and self:collision(player, 0, -2) then
      camera.main.transitionDirection = "up"
      camera.main.transition = true
      camera.main.doScrollY = (self.scrolly~=nil) and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = (self.scrollx~=nil) and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd or 0.8
      local s = self:collisionTable(section.getSections(self.transform.x, self.transform.y-2, self.collisionShape.w, 2), 0, -2)[1]
      camera.main.toSection = s
      camera.main.transform.y = self.transform.y
      camera.main.transY = camera.main.transform.y-camera.main.player.collisionShape.h-8
      camera.main.curBoundName = s.name
      break
    end
  end
end

sectionPrioritySetter = basicEntity:extend()

addobjects.register("sectionPrioritySetter", function(v)
  megautils.add(sectionPrioritySetter, v.x, v.y, v.width, v.height, v.properties.name)
end)

function sectionPrioritySetter:new(x, y, w, h, name)
  sectionPrioritySetter.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.name = name
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function sectionPrioritySetter:check()
  local count = 0
  local sx, sy, sw, sh = self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h
  
  for k, v in ipairs(globals.allPlayers) do
    local x, y, w, h = v.transform.x, v.transform.y, v.collisionShape.w, v.collisionShape.h
    if pointOverlapsRect(x, y, sx, sy, sw, sh) and pointOverlapsRect(x+w, y, sx, sy, sw, sh) and
      pointOverlapsRect(x+w, y+h, sx, sy, sw, sh) and pointOverlapsRect(x, y+h, sx, sy, sw, sh) then
      count = count + 1
    end
  end
  
  return count
end

function sectionPrioritySetter:update(dt)
  if camera.main and self.name ~= camera.main.curBoundName and self:check() == #globals.allPlayers then
    camera.main.curBoundName = self.name
  end
end

sectionPrioritySetterXBorder = basicEntity:extend()

addobjects.register("sectionPrioritySetterXBorder", function(v)
  megautils.add(sectionPrioritySetterXBorder, v.x, v.y, v.height, v.properties.lname, v.properties.rname)
end)

function sectionPrioritySetterXBorder:new(x, y, h, lname, rname)
  sectionPrioritySetterXBorder.super.new(self)
  self:setRectangleCollision(32, h)
  self.transform.y = y
  self.transform.x = x
  self.lname = lname
  self.rname = rname
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function sectionPrioritySetterXBorder:getSide()
  local same = 0
  for k, v in ipairs(globals.allPlayers) do
    if v.transform.x+(v.collisionShape.w/2) > self.transform.x+16 and
      math.between(v.transform.y, self.transform.y, self.transform.y+self.collisionShape.h-v.collisionShape.h) then
      same = same + 1
    end
  end
  
  if same == #globals.allPlayers then
    return self.rname
  elseif same == 0 then
    return self.lname
  end
end

function sectionPrioritySetterXBorder:update(dt)
  local s = self:getSide()
  if camera.main and not megautils.outside(self) and s then
    camera.main.curBoundName = s
  end
end

sectionPrioritySetterYBorder = basicEntity:extend()

addobjects.register("sectionPrioritySetterYBorder", function(v)
  megautils.add(sectionPrioritySetterYBorder, v.x, v.y, v.width, v.properties.uname, v.properties.dname)
end)

function sectionPrioritySetterYBorder:new(x, y, w, uname, dname)
  sectionPrioritySetterYBorder.super.new(self)
  self:setRectangleCollision(w, 32)
  self.transform.y = y
  self.transform.x = x
  self.uname = uname
  self.dname = dname
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function sectionPrioritySetterYBorder:getSide()
  local same = 0
  for k, v in ipairs(globals.allPlayers) do
    if v.transform.x+(v.collisionShape.w/2) > self.transform.x+16 and
      math.between(v.transform.y, self.transform.y, self.transform.y+self.collisionShape.h-v.collisionShape.h) then
      same = same + 1
    end
  end
  
  if same == #globals.allPlayers then
    return self.dname
  elseif same == 0 then
    return self.uname
  end
end

function sectionPrioritySetterYBorder:update(dt)
  local s = self:getSide()
  if camera.main and not megautils.outside(self) and s then
    camera.main.curBoundName = s
  end
end

sectionPrioritySetterArea = basicEntity:extend()

addobjects.register("sectionPrioritySetterArea", function(v)
  megautils.add(sectionPrioritySetterArea, v.x, v.y, v.width, v.height, v.properties.inname, v.properties.outname)
end)

function sectionPrioritySetterArea:new(x, y, w, h, name, name2)
  sectionPrioritySetterArea.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.inName = name
  self.outName = name2
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function sectionPrioritySetterArea:check()
  local count = 0
  local sx, sy, sw, sh = self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h
  
  for k, v in ipairs(globals.allPlayers) do
    local x, y, w, h = v.transform.x, v.transform.y, v.collisionShape.w, v.collisionShape.h
    if pointOverlapsRect(x, y, sx, sy, sw, sh) and pointOverlapsRect(x+w, y, sx, sy, sw, sh) and
      pointOverlapsRect(x+w, y+h, sx, sy, sw, sh) and pointOverlapsRect(x, y+h, sx, sy, sw, sh) then
      count = count + 1
    end
  end
  
  return count
end

function sectionPrioritySetterArea:update(dt)
  if not megautils.outside(self) and camera.main then
    local c = self:check()
    if c == #globals.allPlayers then
      camera.main.curBoundName = self.name
    else
      camera.main.curBoundName = self.outName
    end
  end
end