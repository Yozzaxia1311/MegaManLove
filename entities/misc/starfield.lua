loader.load("assets/misc/starField.png")
loader.load("assets/misc/starFieldOne.png")

banner = basicEntity:extend()

banner.invisibleToHash = true

function banner.ser()
  return {
      outline = banner.colorOutline,
      one = banner.colorOne,
      two = banner.colorTwo
    }
end

function banner.deser(t)
  banner.colorOutline = t.outline
  banner.colorOne = t.one
  banner.colorTwo = t.two
end

banner.colorOutline = {0, 0, 0}
banner.colorOne = {0, 120, 248}
banner.colorTwo = {0, 232, 216}

function banner:new()
  banner.super.new(self)
  self.x = 0
  self.y = 240
  self.tTwo = loader.get("assets/misc/starField.png")
  self.tOne = loader.get("assets/misc/starFieldOne.png")
  self.quad = quad(0, 0, 256, 103)
  self:setLayer(0)
  self.noFreeze = true
end

function banner:update(dt)
  self.y = math.max(self.y-10, 64)
end

function banner:draw()
  love.graphics.setColor(banner.colorOne[1]/255, banner.colorOne[2]/255, banner.colorOne[3]/255, 1)
  self.tOne:draw(self.quad, self.x, self.y)
  love.graphics.setColor(banner.colorTwo[1]/255, banner.colorTwo[2]/255, banner.colorTwo[3]/255, 1)
  self.tTwo:draw(self.quad, self.x, self.y)
end

smallStar = basicEntity:extend()

smallStar.invisibleToHash = true

function smallStar:new(x, y, angle, spd)
  smallStar.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self.t = loader.get("assets/misc/starField.png")
  self.quad = quad(25, 120, 3, 3)
  self.velX = 0
  self.velY = 0
  self.velX = megautils.calcX(angle or 0) * (spd or 1)
  self.velY = megautils.calcY(angle or 0) * (spd or 1)
  self:setLayer(-1)
  self.noFreeze = true
end

function smallStar:update()
  self.x = math.wrap(self.x+self.velX, -3, view.w)
  self.y = math.wrap(self.y+self.velY, -3, view.h)
end

function smallStar:draw()
  self.t:draw(self.quad, self.x, self.y)
end

star = basicEntity:extend()

star.invisibleToHash = true

function star:new(x, y, angle, spd)
  star.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self.t = loader.get("assets/misc/starField.png")
  self.quad = quad(0, 120, 10, 6)
  self.velX = 0
  self.velY = 0
  self.velX = megautils.calcX(angle or 0) * (spd or 1)
  self.velY = megautils.calcY(angle or 0) * (spd or 1)
  self:setLayer(-1)
  self.noFreeze = true
end

function star:update()
  self.x = math.wrap(self.x+self.velX, -10, view.w)
  self.y = math.wrap(self.y+self.velY, -6, view.h)
end

function star:draw()
  self.t:draw(self.quad, self.x, self.y)
end

largeStar = basicEntity:extend()

largeStar.invisibleToHash = true

function largeStar:new(x, y, angle, spd)
  largeStar.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self.t = loader.get("assets/misc/starField.png")
  self.quad = quad(10, 120, 15, 11)
  self.velX = 0
  self.velY = 0
  self.velX = megautils.calcX(angle or 0) * (spd or 1)
  self.velY = megautils.calcY(angle or 0) * (spd or 1)
  self:setLayer(-1)
  self.noFreeze = true
end

function largeStar:update()
  self.x = math.wrap(self.x+self.velX, -15, view.w)
  self.y = math.wrap(self.y+self.velY, -11, view.h)
end

function largeStar:draw()
  self.t:draw(self.quad, math.round(self.x), math.round(self.y))
end