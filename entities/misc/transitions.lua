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
  self.spd = spd or 0.8
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
      camera.main.transitiondirection = "right"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transX = camera.main.scrollx+camera.main.scrollw+16
      camera.main.toSection = self:collisionTable(megautils.groups().lock, 2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, 2)[1]
      camera.main.transform.x = (camera.main.scrollx+camera.main.scrollw)-view.w
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
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
  self.spd = spd or 0.8
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
      camera.main.transitiondirection = "left"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transX = camera.main.scrollx-camera.main.player.collisionShape.w-16
      camera.main.toSection = self:collisionTable(megautils.groups().lock, -2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, -2)[1]
      camera.main.transform.x = camera.main.scrollx
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
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
      camera.main.transitiondirection = "down"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly+camera.main.scrollh+8
      camera.main.toSection = self:collisionTable(megautils.groups().lock, 0, 2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, 0, 2)[1]
      camera.main.transform.y = (camera.main.scrolly+camera.main.scrollh)-view.h
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
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
  self.spd = spd or 0.8
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function up:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and player.control and not camera.main.transition
      and self:collision(player, 0, -2) and (not self.platform or (self.platform and 
        player.onMovingFloor)) then
      camera.main.transitiondirection = "up"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
      camera.main.toSection = self:collisionTable(megautils.groups().lock, 0, -2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
      camera.main.transform.y = camera.main.scrolly
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
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
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.spd = spd or 0.8
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
      (self.ladder or (not self.platform or (self.platform and player.onMovingFloor))) then
      if player.control and (player.climb or player.treble == 2) and self:collision(player, 0, -2) then
        camera.main.transitiondirection = "up"
        camera.main.transition = true
        camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
        camera.main.toSection = self:collisionTable(megautils.groups().lock, 0, -2)[1] or
          self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
        camera.main.transform.y = camera.main.scrolly
        break
      end
    end
  end
end

lockChange = basicEntity:extend()

addobjects.register("lockChange", function(v)
  megautils.add(lockChange, v.x, v.y, v.width, v.height, v.properties.name)
end)

function lockChange:new(x, y, w, h, name)
  lockChange.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.name = name
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function lockChange:update(dt)
  if #self:collisionTable(globals.allPlayers) == #globals.allPlayers and self.name ~= camera.main.curLock then
    camera.main.curLock = self.name
  end
end

lockChangeBorderX = basicEntity:extend()

addobjects.register("lockChangeBorderX", function(v)
  megautils.add(lockChangeBorderX, v.x, v.y, v.width, v.height, v.properties.leftName, v.properties.rightName)
end)

function lockChangeBorderX:new(x, y, w, h, lname, rname)
  lockChangeBorderX.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.lname = lname
  self.rname = rname
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function lockChangeBorderX:getSide()
  local same = 0
  for k, v in ipairs(self:collisionTable(globals.allPlayers)) do
    if v.transform.x > self.transform.x then
      same = same + 1
    end
  end
  
  if same == #globals.allPlayers then
    return self.rname
  elseif same == 0 then
    return self.lname
  end
end

function lockChangeBorderX:update(dt)
  local s = self:getSide()
  if #self:collisionTable(globals.allPlayers) == #globals.allPlayers and s then
    camera.main.curLock = s
  end
end

lockChangeBorderY = basicEntity:extend()

addobjects.register("lockChangeBorderY", function(v)
  megautils.add(lockChangeBorderY, v.x, v.y, v.width, v.height, v.properties.upName, v.properties.downName)
end)

function lockChangeBorderY:new(x, y, h, uname, dname)
  lockChangeBorderY.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.uname = uname
  self.dname = dname
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function lockChangeBorderY:getSide()
  local same = 0
  for k, v in ipairs(self:collisionTable(globals.allPlayers)) do
    if v.transform.y > self.transform.y then
      same = same + 1
    end
  end
  
  if same == #globals.allPlayers then
    return self.dname
  elseif same == 0 then
    return self.uname
  end
end

function lockChangeBorderY:update(dt)
  local s = self:getSide()
  if #self:collisionTable(globals.allPlayers) == #globals.allPlayers and s then
    camera.main.curLock = s
  end
end