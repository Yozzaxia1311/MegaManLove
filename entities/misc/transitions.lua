right = entity:extend()

addobjects.register("right", function(v)
  megautils.add(right(v.x, v.y, v.height,
    v.properties["doScrollX"], v.properties["doScrollY"], v.properties["speed"], v.properties["platform"]))
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
    if camera.main and player.control and not camera.main.transition and self:collision(player)
      and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitiondirection = "right"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transX = camera.main.scrollx+camera.main.scrollw+16
      camera.main.toSection = self:collisionTable(megautils.groups()["lock"], 2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, 2)[1]
      if camera.main.toSection:is(lockSection) then
        camera.main.toSection.section = self:collisionTable(megautils.state().sectionHandler.sections, 2)[1]
      end
      camera.main.transform.x = (camera.main.scrollx+camera.main.scrollw)-view.w
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
      break
    end
  end
end

left = entity:extend()

addobjects.register("left", function(v)
  megautils.add(left(v.x, v.y, v.height,
    v.properties["doScrollX"], v.properties["doScrollY"], v.properties["speed"], v.properties["platform"]))
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
      and self:collision(player) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitiondirection = "left"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transX = camera.main.scrollx-camera.main.player.collisionShape.w-16
      camera.main.toSection = self:collisionTable(megautils.groups()["lock"], -2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, -2)[1]
      if camera.main.toSection:is(lockSection) then
        camera.main.toSection.section = self:collisionTable(megautils.state().sectionHandler.sections, -2)[1]
      end
      camera.main.transform.x = camera.main.scrollx
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
      break
    end
  end
end

down = entity:extend()

addobjects.register("down", function(v)
  megautils.add(down(v.x, v.y, v.width,
    v.properties["doScrollX"], v.properties["doScrollY"], v.properties["speed"], v.properties["platform"]))
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
      and self:collision(player) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitiondirection = "down"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly+camera.main.scrollh+8
      camera.main.toSection = self:collisionTable(megautils.groups()["lock"], 0, 2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, 0, 2)[1]
      if camera.main.toSection:is(lockSection) then
        camera.main.toSection.section = self:collisionTable(megautils.state().sectionHandler.sections, 0, 2)[1]
      end
      camera.main.transform.y = (camera.main.scrolly+camera.main.scrollh)-view.h
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
      break
    end
  end
end

up = entity:extend()

addobjects.register("up", function(v)
  megautils.add(up(v.x, v.y, v.width,
    v.properties["doScrollX"], v.properties["doScrollY"], v.properties["speed"], v.properties["platform"]))
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
      and self:collision(player) and (not self.platform or (self.platform and 
        player.onMovingFloor)) then
      camera.main.transitiondirection = "up"
      camera.main.transition = true
      camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
      camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
      camera.main.toSection = self:collisionTable(megautils.groups()["lock"], 0, -2)[1] or
        self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
      if camera.main.toSection:is(lockSection) then
        camera.main.toSection.section = self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
      end
      camera.main.transform.y = camera.main.scrolly
      if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
        camera.main.player.onMovingFloor.dontRemove = true
      end
      break
    end
  end
end

upLadder = entity:extend()

addobjects.register("up_ladder", function(v)
  megautils.add(upLadder(v.x, v.y, v.width,
    v.properties["doScrollX"], v.properties["doScrollY"], v.properties["speed"], v.properties["platform"]))
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
    self.ladder = self:collisionTable(megautils.groups()["ladder"])[1]
  end
end

function upLadder:update(dt)
  if not self.ladder then
    self.ladder = self:collisionTable(megautils.groups()["ladder"])[1]
  end
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main and not camera.main.transition and
      (self.ladder or (not self.platform or (self.platform and player.onMovingFloor))) then
      if player.control and player.climb and player.transform.y < self.transform.y then
        camera.main.transitiondirection = "up"
        camera.main.transition = true
        camera.main.doScrollY = self.scrolly and self.scrolly or camera.main.doScrollY
        camera.main.doScrollX = self.scrollx and self.scrollx or camera.main.doScrollX
        camera.main.player = player
        camera.main.speed = self.spd
        camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
        camera.main.toSection = self:collisionTable(megautils.groups()["lock"], 0, -2)[1] or
          self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
        if camera.main.toSection:is(lockSection) then
          camera.main.toSection.section = self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
        end
        camera.main.transform.y = camera.main.scrolly
        break
      end
    end
  end
end

lockSection = entity:extend()

addobjects.register("lock_section", function(v)
  megautils.add(lockSection(v.x, v.y, v.width, v.height, v.properties["name"]))
end)

function lockSection:new(x, y, w, h, name)
  lockSection.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.name = name
  self.added = function(self)
    self:addToGroup("lock")
    self:addStatic()
  end
end

lockShift = entity:extend()

addobjects.register("lock_shift", function(v)
  megautils.add(lockShift(v.x, v.y, v.width, v.height, v.properties["name"], v.properties["dir"], v.properties["speed"]))
end)

function lockShift:new(x, y, w, h, name, spd)
  lockShift.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.name = name
  self.spd = spd or 0.4
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function lockShift:update(dt)
  if #self:collisionTable(globals.allPlayers) >= math.floor(globals.playerCount/2)+1 and self.name ~= camera.main.curLock and not self.tween then
    megautils.freeze(globals.allPlayers)
    for k, v in pairs(globals.allPlayers) do
      v.control = false
      v.cameraFocus = false
    end
    local l = camera.main.curLock
    camera.main.curLock = self.name
    camera.main:doView()
    self.tween = tween.new(self.spd, camera.main.transform, {x=camera.main.transform.x, y=camera.main.transform.y})
    self.pTween = {}
    for i=1, #globals.allPlayers do
      local v = globals.allPlayers[i]
      if v.transform.x < camera.main.lockx+(-v.collisionShape.w/2)+2 or
        v.transform.x > (camera.main.lockx+camera.main.lockw)+(-v.collisionShape.w/2)-2 or
        v.transform.y < camera.main.locky-(v.collisionShape.h*1.4) or
        v.transform.y > camera.main.locky+camera.main.lockh+4 then
        local p
        for j=1 #globals.allPlayers do
          p = globals.allPlayers[i]
          if p ~= v and p.transform.x >= camera.main.lockx+(-p.collisionShape.w/2)+2 or
            p.transform.x <= (camera.main.lockx+camera.main.lockw)+(-p.collisionShape.w/2)-2 or
            p.transform.y >= camera.main.locky-(p.collisionShape.h*1.4) or
            p.transform.y <= camera.main.locky+camera.main.lockh+4 then
            break
          end
        end
        self.pTween[#self.pTween+1] = tween.new(self.spd, v.transform, {x=p.transform.x, y=p.transform.y})
      end
    end
    camera.main.curLock = l
    camera.main:doView()
  end
  if self.pTween then
    for i=1, #self.pTween do
      self.pTween[i]:update(1/60)
    end
  end
  if self.tween then
    if self.tween:update(1/60) then
      self.tween = nil
      self.pTween = nil
      megautils.unfreeze()
      for k, v in pairs(globals.allPlayers) do
        v.control = true
        v.cameraFocus = true
      end
      camera.main.curLock = self.name
      camera.main:doView()
    else
      camera.main.transform.x = math.round(camera.main.transform.x)
      camera.main.transform.y = math.round(camera.main.transform.y)
      view.x, view.y = math.round(camera.main.transform.x), math.round(camera.main.transform.y)
      camera.main:updateFuncs()
    end
  end
end
