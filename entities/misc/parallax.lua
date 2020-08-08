mapEntity.register("parallax", function(v)
    megautils.add(parallax, v.x, v.y, v.width, v.height, v.properties.image, v.properties.speedMult,
      v.properties.speedX, v.properties.speedY, v.properties.wrapX, v.properties.wrapY, v.properties.layer)
  end, 0, true)

parallax = basicEntity:extend()

function parallax:new(x, y, w, h, bg, spdMult, sx, sy, wrapx, wrapy, l)
  parallax.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(w or 64, h or 64)
  self.tex = megautils.loadResource(bg, bg)
  self.spdMult = spdMult or 0.5
  self.velx = sx or 0
  self.vely = sy or 0
  self.wrapX = (wrapx == nil) or wrapx
  self.wrapY = (wrapy == nil) or wrapy
  self.offX = 0
  self.offY = 0
  self.nwOffX = 0
  self.nwOffY = 0
  self.dx = 0
  self.dy = 0
  self.spawnEarlyDuringTransition = true
  self.despawnLateDuringTransition = true
  self:setLayer(l or -1)
end

function parallax:added()
  self:addToGroup("handledBySections")
end

function parallax:beforeUpdate()
  self.dx = view.x
  self.dy = view.y
end

parallax.x = 0
parallax.y = 0
parallax.w = 0
parallax.h = 0

function parallax.stencil()
  love.graphics.rectangle("fill", parallax.x, parallax.y, parallax.w, parallax.h)
end

function parallax:draw()
  if not megautils.outside(self) then
    parallax.x = self.transform.x
    parallax.y = self.transform.y
    parallax.w = self.collisionShape.w
    parallax.h = self.collisionShape.h
    love.graphics.stencil(parallax.stencil, "replace", 1)
    love.graphics.setStencilTest("equal", 1)
    local imgw, imgh = self.tex:getDimensions()
    if self.wrapX and self.wrapY then
      self.offX = math.wrap(self.offX + self.velx + ((view.x - self.dx) * self.spdMult), 0, imgw)
      self.offY = math.wrap(self.offY + self.vely + ((view.y - self.dy) * self.spdMult), 0, imgh)
      
      for x=self.transform.x-imgw, self.transform.x+self.collisionShape.w, imgw do
        for y=self.transform.y-imgh, self.transform.y+self.collisionShape.h, imgh do
          if rectOverlapsRect(x+self.offX, y+self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
            love.graphics.draw(self.tex, x+self.offX, y+self.offY)
          end
        end
      end
    elseif self.wrapX and not self.wrapY then
      self.offX = math.wrap(self.offX + self.velx + ((view.x - self.dx) * self.spdMult), 0, imgw)
      self.nwOffY = self.nwOffY + ((view.y - self.dy) * self.spdMult)
      
      for x=self.transform.x-imgw, self.transform.x+self.collisionShape.w, imgw do
        if rectOverlapsRect(x+self.offX, self.transform.y+self.nwOffY, imgw, imgh, view.x, view.y, view.w, view.h) then
          love.graphics.draw(self.tex, x+self.offX, self.transform.y+self.nwOffY)
        end
      end
    elseif not self.wrapX and self.wrapY then
      self.nwOffX = self.nwOffX + ((view.x - self.dx) * self.spdMult)
      self.offY = math.wrap(self.offY + self.vely + ((view.y - self.dy) * self.spdMult), 0, imgh)
      
      for y=self.transform.y-imgh, self.transform.y+self.collisionShape.h, imgh do
        if rectOverlapsRect(self.transform.x+self.nwOffX, y+self.offY, imgw, imgh, view.x, view.y, view.w, view.h) then
          love.graphics.draw(self.tex, self.transform.x+self.nwOffX, y+self.offY)
        end
      end
    else
      self.nwOffX = self.nwOffX + ((view.x - self.dx) * self.spdMult)
      self.nwOffY = self.nwOffY + ((view.y - self.dy) * self.spdMult)
      
      if rectOverlapsRect(self.transform.x+self.nwOffX, self.transform.y+self.nwOffY, imgw, imgh, view.x, view.y, view.w, view.h) then
        love.graphics.draw(self.tex, self.transform.x+self.nwOffX, self.transform.y+self.nwOffY)
      end
    end
    love.graphics.setStencilTest()
  end
end