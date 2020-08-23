megautils.loadResource("assets/misc/starField.png", "starField")
megautils.loadResource("assets/misc/starFieldOne.png", "starFieldOne")

banner = basicEntity:extend()

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

binser.register(banner, "banner", function(o)
    local result = {}
    
    banner.super.transfer(o, result)
    
    return result
  end, function(o)
    local result = banner()
    
    banner.super.transfer(o, result)
    
    return result
  end)

banner.colorOutline = {0, 0, 0}
banner.colorOne = {0, 120, 248}
banner.colorTwo = {0, 232, 216}

function banner:new()
  banner.super.new(self)
  self.transform.x = 0
  self.transform.y = 240
  self.tTwo = megautils.getResource("starField")
  self.tOne = megautils.getResource("starFieldOne")
  self.quad = quad(0, 0, 256, 103)
  self:setLayer(0)
end

function banner:update(dt)
  self.transform.y = math.max(self.transform.y-10, 64)
end

function banner:draw()
  love.graphics.setColor(banner.colorOne[1]/255, banner.colorOne[2]/255, banner.colorOne[3]/255, 1)
  self.quad:draw(self.tOne, self.transform.x, self.transform.y)
  love.graphics.setColor(banner.colorTwo[1]/255, banner.colorTwo[2]/255, banner.colorTwo[3]/255, 1)
  self.quad:draw(self.tTwo, self.transform.x, self.transform.y)
end

smallStar = basicEntity:extend()

binser.register(smallStar, "smallStar", function(o)
    local result = {}
    
    smallStar.super.transfer(o, result)
    
    result.velocity = o.velocity
    
    return result
  end, function(o)
    local result = smallStar()
    
    smallStar.super.transfer(o, result)
    
    result.velocity = o.velocity
    
    return result
  end)

function smallStar:new(x, y, angle, spd)
  smallStar.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.t = megautils.getResource("starField")
  self.quad = quad(25, 120, 3, 3)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle or 0) * (spd or 1)
  self.velocity.vely = megautils.calcY(angle or 0) * (spd or 1)
  self:setLayer(-1)
end

function smallStar:update()
  self.transform.x = math.wrap(self.transform.x+self.velocity.velx, -3, view.w)
  self.transform.y = math.wrap(self.transform.y+self.velocity.vely, -3, view.h)
end

function smallStar:draw()
  self.quad:draw(self.t, self.transform.x, self.transform.y)
end

star = basicEntity:extend()

binser.register(star, "star", function(o)
    local result = {}
    
    star.super.transfer(o, result)
    
    result.velocity = o.velocity
    
    return result
  end, function(o)
    local result = star()
    
    star.super.transfer(o, result)
    
    result.velocity = o.velocity
    
    return result
  end)

function star:new(x, y, angle, spd)
  star.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.t = megautils.getResource("starField")
  self.quad = quad(0, 120, 10, 6)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle or 0) * (spd or 1)
  self.velocity.vely = megautils.calcY(angle or 0) * (spd or 1)
  self:setLayer(-1)
end

function star:update()
  self.transform.x = math.wrap(self.transform.x+self.velocity.velx, -10, view.w)
  self.transform.y = math.wrap(self.transform.y+self.velocity.vely, -6, view.h)
end

function star:draw()
  self.quad:draw(self.t, self.transform.x, self.transform.y)
end

largeStar = basicEntity:extend()

binser.register(largeStar, "largeStar", function(o)
    local result = {}
    
    largeStar.super.transfer(o, result)
    
    result.velocity = o.velocity
    
    return result
  end, function(o)
    local result = largeStar()
    
    largeStar.super.transfer(o, result)
    
    result.velocity = o.velocity
    
    return result
  end)

function largeStar:new(x, y, angle, spd)
  largeStar.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.t = megautils.getResource("starField")
  self.quad = quad(10, 120, 15, 11)
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(angle or 0) * (spd or 1)
  self.velocity.vely = megautils.calcY(angle or 0) * (spd or 1)
  self:setLayer(-1)
end

function largeStar:update()
  self.transform.x = math.wrap(self.transform.x+self.velocity.velx, -15, view.w)
  self.transform.y = math.wrap(self.transform.y+self.velocity.vely, -11, view.h)
end

function largeStar:draw()
  self.quad:draw(self.t, math.round(self.transform.x), math.round(self.transform.y))
end