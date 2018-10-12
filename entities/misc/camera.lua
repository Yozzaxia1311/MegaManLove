camera = entity:extend()

addobjects.register("megacam", function(v)
  if v.properties["checkpoint"] == globals.checkpoint then
    megautils.add(camera(v.x, v.y, v.properties["doScrollX"], v.properties["doScrollY"]))
    camera.once = false
  end
end, -1)

addobjects.register("megacam", function(v)
  if v.properties["checkpoint"] == globals.checkpoint and not camera.once and camera.main ~= nil then
    camera.once = true
    camera.main:updateBounds()
  end
end, 2)

megautils.resetStateFuncs["camera"] = function() camera.main = nil end

function camera:new(x, y, doScrollX, doScrollY)
  camera.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(view.w, view.h)
  self.transition = false
  self.transitiondirection = "right"
  self.doShift = false
  self.freeze = true
  self.updateSections = true
  self.shiftX = 0
  self.shiftY = 0
  self.scrollx = 0
  self.scrollw = 0
  self.scrolly = 0
  self.scrollh = 0
  self.doScrollY = ternary(doScrollY ~= nil, doScrollY, true)
  self.doScrollX = ternary(doScrollX ~= nil, doScrollX, true)
  self.transX = 0
  self.transY = 0
  self.speed = 1
  self.toSection = nil
  self.once = false
  self.updateOnce = false
  self.transitionDone = false
  camera.main = self
  self.player = nil
  view.x, view.y = self.transform.x, self.transform.y
  self.funcs = {}
end

function camera:updateBounds()
  if self.toSection == nil then
    self.toSection = self:collisionTable(megautils.state().sectionHandler.sections)[1]
  end
  if self.toSection ~= nil then
    megautils.state().sectionHandler.next = self.toSection
    megautils.state().sectionHandler:updateAll()
    self.scrollx = self.toSection.transform.x
    self.scrollw = self.toSection.collisionShape.w
    self.scrolly = self.toSection.transform.y
    self.scrollh = self.toSection.collisionShape.h
  else
    self.scrollx = -math.huge
    self.scrollw = math.huge
    self.scrolly = -math.huge
    self.scrollh = math.huge
  end
end

function camera:updateCam(o, offX, offY, w, h, px, py, delay)
  if self.transition then
    self.transitionDone = false
    if not self.once then
      if megautils.groups()["removeOnCutscene"] ~= nil then
        for k, v in pairs(megautils.groups()["removeOnCutscene"]) do
          if not v.dontRemove then
            megautils.remove(v, true)
          end
        end
      end
      if self.freeze then
        megautils.freeze(megautils.groups()["hurtableOther"])
        for k, v in pairs(megautils.groups()["hurtableOther"]) do
          v.control = false
        end
      end 
      if self.player ~= nil then
        if self.toSection == nil then self.toSection = megautils.state().sectionHandler.current end
        local sx, sy, sw, sh = self.toSection.transform.x, self.toSection.transform.y,
          self.toSection.collisionShape.w, self.toSection.collisionShape.h
        if self.transitiondirection == "right" then
          if self.doScrollY then
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x+self.collisionShape.w,
              y=math.clamp(self.player.transform.y
              - (view.h/2) + (h/2), sy, (sy+sh)-view.h)})
          else
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x+self.collisionShape.w})
          end
          self.tween2 = tween.new(self.speed, self.player.transform, {x=self.transX})
        elseif self.transitiondirection == "left" then
          if self.doScrollY then
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w,
              y=math.clamp(self.player.transform.y
              - (view.h/2) + (h/2), sy, (sy+sh)-view.h)})
          else
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w})
          end
          self.tween2 = tween.new(self.speed, self.player.transform, {x=self.transX})
        elseif self.transitiondirection == "down" then
          if self.doScrollX then
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y+self.collisionShape.h,
              x=math.clamp(self.player.transform.x
              - (view.w/2) + (w/2), sx, (sx+sw)-view.w)})
          else
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y+self.collisionShape.h})
          end
          self.tween2 = tween.new(self.speed, self.player.transform, {y=self.transY})
        elseif self.transitiondirection == "up" then
          if self.doScrollX then
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h,
              x=math.clamp(self.player.transform.x
              - (view.w/2) + (w/2), sx, (sx+sw)-view.w)})
          else
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h})
          end
          self.tween2 = tween.new(self.speed, self.player.transform, {y=self.transY})
        end
      end
      if self.player.onMovingFloor then
        self.flx = self.player.onMovingFloor.transform.x - self.player.transform.x
      end
      self.once = true
      megautils.state().system.afterUpdate = function(s)
        camera.main.tween2:update(1/60)
        if camera.main.tween:update(1/60) then
          camera.main.transitionDone = true
          camera.main.transition = false
          camera.main.once = false
          camera.main.scrollx, camera.main.scrolly, camera.main.scrollw, camera.main.scrollh = camera.main.toSection.transform.x,
            camera.main.toSection.transform.y, camera.main.toSection.collisionShape.w, camera.main.toSection.collisionShape.h
          if camera.main.updateSections then
            camera.main:updateBounds()
            camera.main.toSection = nil
            if camera.main.freeze then
              megautils.unfreeze(megautils.groups()["hurtableOther"])
              for k, v in pairs(megautils.groups()["hurtableOther"]) do
                v.control = true
              end
            end
            if camera.main.player ~= nil and camera.main.player.onMovingFloor then
              camera.main.player.onMovingFloor.dontRemove = nil
            end
          end
          camera.main.tween = nil
          camera.main.tween2 = nil
          camera.main.transitionDone = true
          megautils.state().system.afterUpdate = nil
        end
        if camera.main.player ~= nil and camera.main.player.onMovingFloor then
          camera.main.player.onMovingFloor.transform.x = camera.main.player.transform.x + camera.main.flx
          camera.main.player.onMovingFloor.transform.y = camera.main.player.transform.y + camera.main.player.collisionShape.h
        end
        camera.main.transform.x = math.round(camera.main.transform.x)
        camera.main.transform.y = math.round(camera.main.transform.y)
        view.x, view.y = math.round(camera.main.transform.x), math.round(camera.main.transform.y)
        camera.main:updateFuncs()
      end
    end
  else
    if o ~= nil and self.doScrollX and o.collisionShape ~= nil then
      self.transform.x = math.round(o.transform.x) - (view.w/2) + ((w or o.collisionShape.w)/2)
      self.transform.x = math.clamp(self.transform.x+(offX or 0), self.scrollx, self.scrollx+self.scrollw-view.w)
    end
    if o ~= nil and self.doScrollY and o.collisionShape ~= nil then
      self.transform.y = math.round(o.transform.y) - (view.h/2) + ((h or o.collisionShape.h)/2)
      self.transform.y = math.clamp(self.transform.y+(offY or 0), self.scrolly, self.scrolly+self.scrollh-view.h)
    end
    view.x, view.y = math.round(self.transform.x), math.round(self.transform.y)
    self:updateFuncs()
  end
end

function camera:updateFuncs()
  for k, v in pairs(self.funcs) do
    v(self)
  end
end