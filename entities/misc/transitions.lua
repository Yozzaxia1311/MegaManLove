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
  if camera.main ~= nil and globals.mainPlayer ~= nil and
    globals.mainPlayer.control and not camera.main.transition and self:collision(globals.mainPlayer)
    and (not self.platform or (self.platform and globals.mainPlayer.onMovingFloor)) then
    camera.main.transitiondirection = "right"
    camera.main.transition = true
    camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
    camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
    camera.main.player = globals.mainPlayer
    camera.main.speed = self.spd
    camera.main.transX = camera.main.scrollx+camera.main.scrollw+16
    camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 2)[1]
    camera.main.transform.x = (camera.main.scrollx+camera.main.scrollw)-view.w
    if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
      camera.main.player.onMovingFloor.dontRemove = true
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
  if camera.main ~= nil and globals.mainPlayer ~= nil and globals.mainPlayer.control and not camera.main.transition
    and self:collision(globals.mainPlayer) and (not self.platform or (self.platform and globals.mainPlayer.onMovingFloor)) then
    camera.main.transitiondirection = "left"
    camera.main.transition = true
    camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
    camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
    camera.main.player = globals.mainPlayer
    camera.main.speed = self.spd
    camera.main.transX = camera.main.scrollx-camera.main.player.collisionShape.w-16
    camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, -2)[1]
    camera.main.transform.x = camera.main.scrollx
    if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
      camera.main.player.onMovingFloor.dontRemove = true
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
  if camera.main ~= nil and globals.mainPlayer ~= nil and globals.mainPlayer.control and not camera.main.transition
    and self:collision(globals.mainPlayer) and (not self.platform or (self.platform and globals.mainPlayer.onMovingFloor)) then
    camera.main.transitiondirection = "down"
    camera.main.transition = true
    camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
    camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
    camera.main.player = globals.mainPlayer
    camera.main.speed = self.spd
    camera.main.transY = camera.main.scrolly+camera.main.scrollh+8
    camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 0, 2)[1]
    camera.main.transform.y = (camera.main.scrolly+camera.main.scrollh)-view.h
    if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
      camera.main.player.onMovingFloor.dontRemove = true
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
  if camera.main ~= nil and globals.mainPlayer ~= nil and globals.mainPlayer.control and not camera.main.transition
    and self:collision(globals.mainPlayer) and (not self.platform or (self.platform and 
      globals.mainPlayer.onMovingFloor)) then
    camera.main.transitiondirection = "up"
    camera.main.transition = true
    camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
    camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
    camera.main.player = globals.mainPlayer
    camera.main.speed = self.spd
    camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
    camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
    camera.main.transform.y = camera.main.scrolly
    if camera.main.player.onMovingFloor and not camera.main.player.onMovingFloor:is(rushJet) then
      camera.main.player.onMovingFloor.dontRemove = true
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
  if camera.main ~= nil and globals.mainPlayer ~= nil and not camera.main.transition and
    (self.ladder ~= nil or (not self.platform or (self.platform and globals.mainPlayer.onMovingFloor))) then
    if globals.mainPlayer.control and globals.mainPlayer.climb and globals.mainPlayer.transform.y < self.transform.y then
      camera.main.transitiondirection = "up"
      camera.main.transition = true
      camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
      camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
      camera.main.player = globals.mainPlayer
      camera.main.speed = self.spd
      camera.main.transY = camera.main.scrolly-camera.main.player.collisionShape.h-8
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 0, -2)[1]
      camera.main.transform.y = camera.main.scrolly
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
    if globals.mainPlayer ~= nil and globals.mainPlayer.control and self:collision(globals.mainPlayer)
      and not camera.main.doScrollY then
      self.once = true
      self.tween = tween.new(self.speed, camera.main.transform, {y=math.clamp(globals.mainPlayer.transform.y
          - (view.h/2) + (globals.mainPlayer.collisionShape.h/2), camera.main.scrolly, 
          camera.main.scrolly+camera.main.scrollh-view.h)})
      globals.mainPlayer.control = false
      megautils.freeze({globals.mainPlayer})
    end
  end
  if self.tween ~= nil and self.tween:update(1/60) then
    camera.main.doScrollY = true
    if globals.mainPlayer ~= nil then
      globals.mainPlayer.control = true
    end
    megautils.unfreeze({globals.mainPlayer})
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
  if not self.once and not camera.main.transition and globals.mainPlayer ~= nil and self:collision(globals.mainPlayer) and 
  globals.mainPlayer.control and not camera.main.doScrollX then
    self.once = true
    self.tween = tween.new(self.speed, camera.main.transform, {x=math.clamp(globals.mainPlayer.transform.x
        - (view.w/2) + (globals.mainPlayer.collisionShape.w/2), camera.main.scrollx,
        camera.main.scrollx+camera.main.scrollw-view.w)})
    globals.mainPlayer.control = false
    megautils.freeze({globals.mainPlayer})
  end
  if self.tween ~= nil and self.tween:update(1/60) then
    self.once2 = true
    camera.main.doScrollX = true
    globals.mainPlayer.control = true
    megautils.unfreeze({globals.mainPlayer})
    megautils.remove(self, true)
  elseif self.tween ~= nil then
    camera.main.transform.x = math.round(camera.main.transform.x)
  end
end

shiftZone = entity:extend()

addobjects.register("shift_zone", function(v)
  megautils.add(shiftZone(v.x, v.y, v.width, v.height, v.properties["speed"],
    v.properties["toX"], v.properties["toY"], v.properties["lockX"], v.properties["shiftX"], v.properties["shiftY"]))
end)

function shiftZone:new(x, y, w, h, speed, x2, y2, lockx, shiftx, shifty)
  shiftZone.super.new(self)
  self:setRectangleCollision(w, h)
  self.transform.y = y
  self.transform.x = x
  self.speed = speed or 0.2
  self.x, self.y = x2, y2
  self.shiftX = ternary(shiftx ~= nil, shiftx, false)
  self.shiftY = ternary(shifty ~= nil, shifty, false)
  self.lockx = ternary(lockx ~= nil, lockx, false)
  self.state = 0
  self.player = nil
  self.added = function(self)
    self:addToGroup("despawnable")
    self.once = false
    self.updated = true
    self.tween = nil
  end
end

function shiftZone:update(dt)
  if self.state == 0 then
    if not self.once and camera.main ~= nil and not camera.main.transition then
      local tmp = self:collisionTable(megautils.groups()["hurtableOther"])
      if #tmp ~= 0 and tmp[1].control then
        self.once = true
        self.player = tmp[1]
        camera.main.doScrollX = false
        camera.main.doScrollY = false
        self.tween = tween.new(self.speed, camera.main.transform, {x=self.x, y=self.y})
        if globals.mainPlayer ~= nil then
          globals.mainPlayer.control = false
        end
        megautils.freeze({self, globals.mainPlayer})
        self.state = 1
      end
    end
  elseif self.state == 1 then
    if not self.once2 and self.tween ~= nil and self.tween:update(1/60) then
      self.once2 = true
      if self.shiftX or self.shiftY then
        self.state = 2
        if self.shiftX then
          self.tween = tween.new(self.speed, camera.main.transform, {x=math.round(self.player.transform.x)
            - (view.w/2) + (self.player.collisionShape.w/2)})
        elseif self.shiftY then
          self.tween = tween.new(self.speed, camera.main.transform, {y=math.round(self.player.transform.y)
            - (view.h/2) + (self.player.collisionShape.h/2)})
        end
        return
      else
        self.state = -1
      end
      if self.lockx then
        camera.main.doScrollX = false
        camera.main.doScrollY = true
      else
        camera.main.doScrollX = true
        camera.main.doScrollY = false
      end
      if globals.mainPlayer ~= nil then
        globals.mainPlayer.control = true
      end
    elseif self.tween ~= nil then
      camera.main.transform.x = math.round(camera.main.transform.x)
      camera.main.transform.y = math.round(camera.main.transform.y)
    end
  elseif self.state == 2 then
    if self.tween:update(1/60) then
      if self.lockx then
        camera.main.doScrollX = false
        camera.main.doScrollY = true
      else
        camera.main.doScrollX = true
        camera.main.doScrollY = false
      end
      for k, v in pairs(globals.mainPlayers) do
        v.control = true
      end
      megautils.unfreeze({self, globals.mainPlayer})
      megautils.remove(self, true)
    else
      camera.main.transform.x = math.round(camera.main.transform.x)
      camera.main.transform.y = math.round(camera.main.transform.y)
    end
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
    local tmp = self:collisionTable(megautils.groups()["hurtableOther"])
    if #tmp ~= 0 and tmp[1].control then
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
    local tmp = self:collisionTable(megautils.groups()["hurtableOther"])
    if #tmp ~= 0 and tmp[1].control then
      self.once = true
      camera.main.doScrollY = false
    end
  end
end