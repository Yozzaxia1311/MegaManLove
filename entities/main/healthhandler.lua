healthhandler = entity:extend()

function healthhandler:new(colorOne, colorTwo, colorOutline, side, r, segments)
  healthhandler.super.new(self)
  self.barOne = loader.get("bar_one")
  self.barTwo = loader.get("bar_two")
  self.barOutline = loader.get("bar_outline")
  self.colorOne = colorOne
  self.colorTwo = colorTwo
  self.colorOutline = colorOutline
  self.quads = {}
  self.quads[0] = love.graphics.newQuad(0, 48, 8, 8, 232, 56)
  self.quads[1] = love.graphics.newQuad(8, 48, 8, 8, 232, 56)
  self.quads[2] = love.graphics.newQuad(8*2, 48, 8, 8, 232, 56)
  self.quads[3] = love.graphics.newQuad(8*3, 48, 8, 8, 232, 56)
  self.quads[4] = love.graphics.newQuad(8*4, 48, 8, 8, 232, 56)
  self.segments = segments or 1
  self.side = side or 1
  self.health = self.segments*4
  self.change = 0
  self.rise = 0
  self.riseTimer = 4
  self:setLayer(9)
  self.rot = r or "y"
  self.onceA = false
  self.me = {self}
end

function healthhandler:updateThis()
  if self.change > 0 then
    if self.health ~= 4*self.segments then
      megautils.freeze(self.me)
      self.rise = self.change
      self.riseTimer = 0
    end
  elseif self.change < 0 then
    self.health = self.health + self.change
  end
  self.change = 0
end

function healthhandler:update(dt)
  self.riseTimer = math.min(self.riseTimer+1, 4)
  if self.rise > 0 and self.riseTimer == 4 then
    megautils.freeze(self.me)
    self.change = 0
    self.health = self.health + 1
    self.riseTimer = 0
    self.rise = self.rise - 1
    mmSfx.play("heal")
    if self.rise == 0 or self.health >= 4*self.segments or self.health <= 0 then
      megautils.unfreeze({self})
      self.rise = 0
      mmSfx.stop("heal")
    end
  end
  self.health = math.clamp(self.health, 0, 4*self.segments)
end

function healthhandler:draw()
  love.graphics.setColor(1, 1, 1, 1)
  local curSeg = math.ceil(self.health/4)
  for i=1, self.segments do
    local bit = 0
    if i == curSeg then
      bit = 4 + (self.health-(i*4))
    elseif i > curSeg then
      bit = 0
    elseif i < curSeg then
      bit = 4
    end
    love.graphics.setColor(self.colorOutline[1]/255, 
      self.colorOutline[2]/255,
      self.colorOutline[3]/255, 1)
    love.graphics.draw(self.barOutline, self.quads[bit], 
      self.transform.x-ternary(self.rot=="x",(8*i)*self.side, 0), 
      self.transform.y-ternary(self.rot=="y",(8*i)*self.side, 0), math.rad(ternary(self.rot=="x",90, 0)))
    love.graphics.setColor(self.colorOne[1]/255, 
      self.colorOne[2]/255,
      self.colorOne[3]/255, 1)
    love.graphics.draw(self.barOne, self.quads[bit], 
      self.transform.x-ternary(self.rot=="x",(8*i)*self.side, 0), 
      self.transform.y-ternary(self.rot=="y",(8*i)*self.side, 0), math.rad(ternary(self.rot=="x",90, 0)))
    love.graphics.setColor(self.colorTwo[1]/255, 
      self.colorTwo[2]/255,
      self.colorTwo[3]/255, 1)
    love.graphics.draw(self.barTwo, self.quads[bit], 
      self.transform.x-ternary(self.rot=="x",(8*i)*self.side, 0), 
      self.transform.y-ternary(self.rot=="y",(8*i)*self.side, 0), math.rad(ternary(self.rot=="x",90, 0)))
  end
end