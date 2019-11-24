loader.load("assets/misc/star_field.png", "star_field", "texture")
loader.load("assets/misc/star_field_one.png", "star_field_one", "texture")

banner = entity:extend()

banner.colorOutline = {0, 0, 0}
banner.colorOne = {0, 120, 248}
banner.colorTwo = {0, 232, 216}

function banner:new()
  banner.super.new(self)
  self.transform.y = 240
  self.transform.x = 0
  self.tTwo = loader.get("star_field")
  self.tOne = loader.get("star_field_one")
  self.quad = love.graphics.newQuad(0, 0, 256, 103, 256, 187)
  self:setLayer(2)
end

function banner:update(dt)
  self.transform.y = math.max(self.transform.y-10, 64)
end

function banner:draw()
  love.graphics.setColor(banner.colorOne[1]/255, banner.colorOne[2]/255, banner.colorOne[3]/255, 1)
  love.graphics.draw(self.tOne, self.quad, self.transform.x, self.transform.y)
  love.graphics.setColor(banner.colorTwo[1]/255, banner.colorTwo[2]/255, banner.colorTwo[3]/255, 1)
  love.graphics.draw(self.tTwo, self.quad, self.transform.x, self.transform.y)
end

smallStar = entity:extend()

function smallStar:new(x, y, angle, spd)
  smallStar.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self.t = loader.get("star_field")
  self.quad = love.graphics.newQuad(25, 120, 3, 3, 256, 187)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle) * spd
  self.velocity.vely = megautils.calcY(angle) * spd
end

function smallStar:update()
  self.transform.x = math.wrap(self.transform.x+self.velocity.velx, -3, view.w)
  self.transform.y = math.wrap(self.transform.y+self.velocity.vely, -3, view.h)
end

function smallStar:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.quad, self.transform.x, self.transform.y)
end

star = entity:extend()

function star:new(x, y, angle, spd)
  star.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self.t = loader.get("star_field")
  self.quad = love.graphics.newQuad(0, 120, 10, 6, 256, 187)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle) * spd
  self.velocity.vely = megautils.calcY(angle) * spd
end

function star:update()
  self.transform.x = math.wrap(self.transform.x+self.velocity.velx, -10, view.w)
  self.transform.y = math.wrap(self.transform.y+self.velocity.vely, -6, view.h)
end

function star:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.quad, self.transform.x, self.transform.y)
end

largeStar = entity:extend()

function largeStar:new(x, y, angle, spd)
  largeStar.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self.t = loader.get("star_field")
  self.quad = love.graphics.newQuad(10, 120, 15, 11, 256, 187)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle) * spd
  self.velocity.vely = megautils.calcY(angle) * spd
end

function largeStar:update()
  self.transform.x = math.wrap(self.transform.x+self.velocity.velx, -15, view.w)
  self.transform.y = math.wrap(self.transform.y+self.velocity.vely, -11, view.h)
end

function largeStar:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.t, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megautils.cleanFuncs["unload_starfield"] = function()
  smallStar = nil
  star = nil
  largeStar = nil
  banner = nil
  megautils.cleanFuncs["unload_starfield"] = nil
end