parallax = basicEntity:extend()

parallax.autoClean = false

mapEntity.register("parallax", function(v)
    megautils.add(parallax, v.x, v.y, v.width, v.height, v.properties.image, v.properties.animate, v.properties.animSpeed,
      v.properties.animWidth, v.properties.animHeight, v.properties.speedMultX, v.properties.speedMultY,
      v.properties.speedX, v.properties.speedY, v.properties.wrapX, v.properties.wrapY, v.properties.layer)
  end, 0, true)

function parallax:new(x, y, w, h, bg, a, as, aw, ah, spdMultX, spdMultY, sx, sy, wrapx, wrapy, l)
  parallax.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(w or 64, h or 64)
  self.tex = megautils.loadResource(bg, bg)
  if a then
    local frames = {}
    for y=1, math.floor(self.tex:getHeight()/ah) do
      for x=1, math.floor(self.tex:getWidth()/aw) do
        frames[#frames+1] = x
        frames[#frames+1] = y
      end
    end
    if not megautils.getResource(bg .. "Grid") then
      megautils.loadResource(0, 0, aw, ah, bg .. "Grid")
    end
    self.animWidth = aw
    self.animHeight = ah
    self.anim = megautils.newAnimation(bg .. "Grid", frames, as or 0.5)
  end
  self.spdMultX = spdMultX or 0.5
  self.spdMultY = spdMultY or 0.5
  self.velx = sx or 0
  self.vely = sy or 0
  self.ox = 0
  self.oy = 0
  self.wrapX = (wrapx == nil) or wrapx
  self.wrapY = (wrapy == nil) or wrapy
  self.offX = 0
  self.offY = 0
  self.spawnEarlyDuringTransition = true
  self.despawnLateDuringTransition = true
  self:setLayer(l or -110)
end

function parallax:added()
  self:addToGroup("handledBySections")
end

function parallax:update()
  if self.anim then
    self.anim:update(defaultFramerate)
  end
end

function parallax:draw()
  if not megautils.outside(self) then
    megautils.rectStencil(self.transform.x, self.transform.y, self.collisionShape.w, self.collisionShape.h)
    love.graphics.stencil(megautils.rectStencil, "replace", 1)
    love.graphics.setStencilTest("equal", 1)
    local imgw, imgh
    if self.anim then
      imgw = self.animWidth
      imgh = self.animHeight
    else
      imgw, imgh = self.tex:getDimensions()
    end
    if self.wrapX and self.wrapY then
      self.ox = math.wrap(self.ox + self.velx, 0, imgw)
      self.oy = math.wrap(self.oy + self.vely, 0, imgh)
      self.offX = math.wrap(self.ox + (((view.x+(view.w/2)) - (self.transform.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.transform.x + (self.collisionShape.w/2) - (imgw/2), 0, imgw)
      self.offY = math.wrap(self.oy + (((view.y+(view.h/2)) - (self.transform.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.transform.y + (self.collisionShape.h/2) - (imgh/2), 0, imgh)
      
      for x=self.transform.x-imgw, self.transform.x+self.collisionShape.w, imgw do
        for y=self.transform.y-imgh, self.transform.y+self.collisionShape.h, imgh do
          if rectOverlapsRect(x+self.offX, y+self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
            if self.anim then
              self.anim:draw(self.tex, x+math.round(self.offX), y+math.round(self.offY))
            else
              love.graphics.draw(self.tex, x+math.round(self.offX), y+math.round(self.offY))
            end
          end
        end
      end
    elseif self.wrapX and not self.wrapY then
      self.ox = math.wrap(self.ox + self.velx, 0, imgw)
      self.oy = math.wrap(self.oy + self.vely, 0, imgh)
      self.offX = math.wrap(self.ox + (((view.x+(view.w/2)) - (self.transform.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.transform.x + (self.collisionShape.w/2) - (imgw/2), 0, imgw)
      self.offY = self.oy + (((view.y+(view.h/2)) - (self.transform.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.transform.y + (self.collisionShape.h/2) - (imgh/2)
      
      for x=self.transform.x-imgw, self.transform.x+self.collisionShape.w, imgw do
        if rectOverlapsRect(x+self.offX, self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          if self.anim then
            self.anim:draw(self.tex, x+math.round(self.offX), math.round(self.offY))
          else
            love.graphics.draw(self.tex, x+math.round(self.offX), math.round(self.offY))
          end
        end
      end
    elseif not self.wrapX and self.wrapY then
      self.ox = math.wrap(self.ox + self.velx, 0, imgw)
      self.oy = math.wrap(self.oy + self.vely, 0, imgh)
      self.offX = self.ox + (((view.x+(view.w/2)) - (self.transform.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.transform.x + (self.collisionShape.w/2) - (imgw/2)
      self.offY = math.wrap(self.oy + (((view.y+(view.h/2)) - (self.transform.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.transform.y + (self.collisionShape.h/2) - (imgh/2), 0, imgh)
      
      for y=self.transform.y-imgh, self.transform.y+self.collisionShape.h, imgh do
        if rectOverlapsRect(self.offX, y+self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          if self.anim then
            self.anim:draw(self.tex, math.round(self.offX), y+math.round(self.offY))
          else
            love.graphics.draw(self.tex, math.round(self.offX), y+math.round(self.offY))
          end
        end
      end
    else
      self.ox = math.wrap(self.ox + self.velx, 0, imgw)
      self.oy = math.wrap(self.oy + self.vely, 0, imgh)
      self.offX = self.ox + (((view.x+(view.w/2)) - (self.transform.x+(self.collisionShape.w/2)))*self.spdMultX) +
        self.transform.x + (self.collisionShape.w/2) - (imgw/2)
      self.offY = self.oy + (((view.y+(view.h/2)) - (self.transform.y+(self.collisionShape.h/2)))*self.spdMultY) +
        self.transform.y + (self.collisionShape.h/2) - (imgh/2)
      
      for y=self.transform.y-imgh, self.transform.y+self.collisionShape.h, imgh do
        if rectOverlapsRect(self.offX, self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          if self.anim then
            self.anim:draw(self.tex, math.round(self.offX), math.round(self.offY))
          else
            love.graphics.draw(self.tex, math.round(self.offX), math.round(self.offY))
          end
        end
      end
    end
    love.graphics.setStencilTest()
  end
end