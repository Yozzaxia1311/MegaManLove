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
  self.spd = spd or 1
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function right:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main ~= nil and player.control and not camera.main.transition and self:collision(player)
      and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitiondirection = "right"
      camera.main.transition = true
      camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
      camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transX = camera.main.scrollx+camera.main.scrollw+16
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 2)[1]
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
  self.spd = spd or 1
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function left:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main ~= nil and player.control and not camera.main.transition
      and self:collision(player) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitiondirection = "left"
      camera.main.transition = true
      camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
      camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transX = camera.main.scrollx-camera.main.player.collisionShape.w-16
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, -2)[1]
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
  self.spd = spd or 1
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function down:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main ~= nil and player.control and not camera.main.transition
      and self:collision(player) and (not self.platform or (self.platform and player.onMovingFloor)) then
      camera.main.transitiondirection = "down"
      camera.main.transition = true
      camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
      camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly+camera.main.scrollh+8
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 0, 2)[1]
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
  self.spd = spd or 1
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function up:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main ~= nil and player.control and not camera.main.transition
      and self:collision(player) and (not self.platform or (self.platform and 
        player.onMovingFloor)) then
      camera.main.transitiondirection = "up"
      camera.main.transition = true
      camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
      camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
      camera.main.player = player
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
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
  self.spd = spd or 1
  self.platform = p
  self.added = function(self)
    self:addToGroup("despawnable")
    self.ladder = self:collisionTable(megautils.groups()["ladder"])[1]
  end
end

function upLadder:update(dt)
  if self.ladder == nil then
    self.ladder = self:collisionTable(megautils.groups()["ladder"])[1]
  end
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if camera.main ~= nil and not camera.main.transition and
      (self.ladder ~= nil or (not self.platform or (self.platform and player.onMovingFloor))) then
      if player.control and player.climb and player.transform.y < self.transform.y then
        camera.main.transitiondirection = "up"
        camera.main.transition = true
        camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
        camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
        camera.main.player = player
        camera.main.speed = self.spd
        camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
        camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
        camera.main.transform.y = camera.main.scrolly
        break
      end
    end
  end
end

shiftYZone = entity:extend()

addobjects.register("shift_y_zone", function(v)
  megautils.add(shiftYZone(v.x, v.y, v.width, v.height, v.properties["speed"]))
end)

function shiftYZone:new(x, y, w, h, speed)
  shiftYZone.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.speed = speed or 0.2
  self.added = function(self)
    self:addToGroup("despawnable")
    self.once = false
    self.updated = true
    self.tween = nil
  end
end

function shiftYZone:update(dt)
  if not self.once and camera.main ~= nil and not camera.main.transition then
    for i=1, #globals.allPlayers do
      local player = globals.allPlayers[i]
      if player.control and self:collision(player)
        and not camera.main.doScrollY then
        self.once = true
        self.tween = tween.new(self.speed, camera.main.transform, {y=math.clamp(player.transform.y
            - (view.h/2) + (player.collisionShape.h/2), camera.main.scrolly, 
            camera.main.scrolly+camera.main.scrollh-view.h)})
        megautils.freeze()
        break
      end
    end
  end
  if self.tween ~= nil and self.tween:update(1/60) then
    camera.main.doScrollY = true
    megautils.unfreeze()
    megautils.remove(self, true)
  elseif self.tween ~= nil then
    camera.main.transform.y = math.round(camera.main.transform.y)
  end
end

shiftXZone = entity:extend()

addobjects.register("shift_x_zone", function(v)
  megautils.add(shiftXZone(v.x, v.y, v.width, v.height, v.properties["speed"]))
end)

function shiftXZone:new(x, y, w, h, speed)
  shiftXZone.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.speed = speed or 0.2
  self.added = function(self)
    self:addToGroup("despawnable")
    self.once = false
    self.tween = nil
    self.updated = true
  end
end

function shiftXZone:update(dt)
  for i=1, #globals.allPlayers do
    local player = globals.allPlayers[i]
    if not self.once and not camera.main.transition and self:collision(player) and 
      player.control and not camera.main.doScrollX then
      self.once = true
      self.tween = tween.new(self.speed, camera.main.transform, {x=math.clamp(player.transform.x
          - (view.w/2) + (player.collisionShape.w/2), camera.main.scrollx,
          camera.main.scrollx+camera.main.scrollw-view.w)})
      megautils.freeze()
      break
    end
  end
  if self.tween ~= nil and self.tween:update(1/60) then
    self.once2 = true
    camera.main.doScrollX = true
    megautils.unfreeze()
    megautils.remove(self, true)
  elseif self.tween ~= nil then
    camera.main.transform.x = math.round(camera.main.transform.x)
  end
end

lockXZone = entity:extend()

addobjects.register("lock_x_zone", function(v)
  megautils.add(lockXZone(v.x, v.y, v.width, v.height))
end)

function lockXZone:new(x, y, w, h)
  lockXZone.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.added = function(self)
    self:addToGroup("despawnable")
    self.once = false
    self.updated = true
  end
end

function lockXZone:update(dt)
  if not self.once and camera.main ~= nil and not camera.main.transition then
    local tmp = self:collisionTable(globals.allPlayers)
    if #tmp ~= 0 then
      self.once = true
      camera.main.doScrollX = false
    end
  end
end

lockYZone = entity:extend()

addobjects.register("lock_y_zone", function(v)
  megautils.add(lockYZone(v.x, v.y, v.width, v.height))
end)

function lockYZone:new(x, y, w, h)
  lockYZone.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.added = function(self)
    self:addToGroup("despawnable")
    self.once = false
    self.updated = true
  end
end

function lockYZone:update(dt)
  if not self.once and camera.main ~= nil and not camera.main.transition then
    local tmp = self:collisionTable(globals.allPlayers)
    if #tmp ~= 0 then
      self.once = true
      camera.main.doScrollY = false
    end
  end
end