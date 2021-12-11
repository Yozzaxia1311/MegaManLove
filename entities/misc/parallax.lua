parallax = basicEntity:extend()

parallax.autoClean = false
parallax.invisibleToHash = true

mapEntity.register("parallax", function(v)
    megautils.add(parallax, v.x, v.y, v.width, v.height, v.properties.image, v.properties.animate, v.properties.animSpeed,
      v.properties.animWidth, v.properties.animHeight, v.properties.speedMultX, v.properties.speedMultY,
      v.properties.speedX, v.properties.speedY, v.properties.wrapX, v.properties.wrapY,
      v.properties.centerOffX, v.properties.centerOffY, v.properties.layer)
  end, 0, true)

function parallax:new(x, y, w, h, bg, a, as, aw, ah, spdMultX, spdMultY, sx, sy, wrapx, wrapy, cntx, cnty, l)
  parallax.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 64, h or 64)
  self.bg = bg
  self.tex = megautils.loadResource(self.bg, self.bg)
  if a then
    local frames = {}
    for y=1, math.floor(self.tex:getHeight()/ah) do
      for x=1, math.floor(self.tex:getWidth()/aw) do
        frames[#frames+1] = x
        frames[#frames+1] = y
      end
    end
    if not megautils.getResource(self.bg .. "Anim") then
      loader.resources[self.bg .. "Anim"] = {
          data = anim8.newGrid(aw, ah),
          frames = frames,
          durations = as or 0.5
        }
    end
    self.animWidth = aw
    self.animHeight = ah
    self.anim = animation(self.bg .. "Anim")
  end
  self.spdMultX = spdMultX or 0.5
  self.spdMultY = spdMultY or 0.5
  self._velX = sx or 0
  self._velY = sy or 0
  self.ox = 0
  self.oy = 0
  self.wrapX = (wrapx == nil) or wrapx
  self.wrapY = (wrapy == nil) or wrapy
  self.centerOffX = cntx or 0
  self.centerOffY = cnty or 0
  self.offX = 0
  self.offY = 0
  self.spawnEarlyDuringTransition = true
  self.despawnLateDuringTransition = true
  self:setLayer(l or -110)
  self.visibleDuringPause = true
end

function parallax:added()
  self:addToGroup("handledBySections")
end

function parallax:update()
  local imgw, imgh
  if self.anim then
    self.anim:update(1/60)
    imgw = self.animWidth
    imgh = self.animHeight
  else
    imgw, imgh = self.tex:getDimensions()
  end
  self.ox = math.wrap(self.ox + self._velX, 0, imgw-1)
  self.oy = math.wrap(self.oy + self._velY, 0, imgh-1)
end

function parallax:draw()
  if not megautils.outside(self) then
    local tx, ty = cscreen.getOffsets()
    love.graphics.setScissor(tx + self.x - view.x, ty + self.y - view.y,
      self.collisionShape.w * cscreen.getScale(), self.collisionShape.h * cscreen.getScale())
    local imgw, imgh
    if self.anim then
      imgw = self.animWidth
      imgh = self.animHeight
    else
      imgw, imgh = self.tex:getDimensions()
    end
    if self.wrapX and self.wrapY then
      self.offX = math.wrap(self.ox + (((view.x+(view.w/2)) - (self.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.x + (self.collisionShape.w/2) - (imgw/2) + self.centerOffX, 0, imgw-1)
      self.offY = math.wrap(self.oy + (((view.y+(view.h/2)) - (self.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.y + (self.collisionShape.h/2) - (imgh/2) + self.centerOffY, 0, imgh-1)
      for x=self.x-imgw, self.x+self.collisionShape.w, imgw do
        for y=self.y-imgh, self.y+self.collisionShape.h, imgh do
          if rectOverlapsRect(x+self.offX, y+self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
            if self.anim then
              self.tex:draw(self.anim, x+self.offX, y+self.offY)
            else
              self.tex:draw(x+self.offX, y+self.offY)
            end
          end
        end
      end
    elseif self.wrapX and not self.wrapY then
      self.offX = math.wrap(self.ox + (((view.x+(view.w/2)) - (self.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.x + (self.collisionShape.w/2) - (imgw/2) + self.centerOffX, 0, imgw-1)
      self.offY = self.oy + (((view.y+(view.h/2)) - (self.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.y + (self.collisionShape.h/2) - (imgh/2) + self.centerOffY
      
      for x=self.x-imgw, self.x+self.collisionShape.w, imgw do
        if rectOverlapsRect(x+self.offX, self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          if self.anim then
            self.tex:draw(self.anim, x+self.offX, self.offY)
          else
            self.tex:draw(x+self.offX, self.offY)
          end
        end
      end
    elseif not self.wrapX and self.wrapY then
      self.offX = self.ox + (((view.x+(view.w/2)) - (self.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.x + (self.collisionShape.w/2) - (imgw/2) + self.centerOffX
      self.offY = math.wrap(self.oy + (((view.y+(view.h/2)) - (self.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.y + (self.collisionShape.h/2) - (imgh/2) + self.centerOffY, 0, imgh-1)
      
      for y=self.y-imgh, self.y+self.collisionShape.h, imgh do
        if rectOverlapsRect(self.offX, y+self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          if self.anim then
            self.tex:draw(self.anim, self.offX, y+self.offY)
          else
            self.tex:draw(self.offX, y+self.offY)
          end
        end
      end
    else
      self.offX = self.ox + (((view.x+(view.w/2)) - (self.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.x + (self.collisionShape.w/2) - (imgw/2) + self.centerOffX
      self.offY = self.oy + (((view.y+(view.h/2)) - (self.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.y + (self.collisionShape.h/2) - (imgh/2) + self.centerOffY
      
      for y=self.y-imgh, self.y+self.collisionShape.h, imgh do
        if rectOverlapsRect(self.offX, self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          if self.anim then
            self.tex:draw(self.anim, self.offX, self.offY)
          else
            self.tex:draw(self.offX, self.offY)
          end
        end
      end
    end
    love.graphics.setScissor()
  end
end