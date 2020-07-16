megautils.loadResource("assets/global/entities/moveAcrossPlatform.png", "moveArossPlatform")

addObjects.register("moveAcrossPlatform", function(v)
  megautils.add(spawner, v.x-4, v.y-4, 40, 24, nil,
    moveAcrossPlatform, v.x, v.y, v.properties.toX, v.properties.toY)
end)

moveAcrossPlatform = entity:extend()

function moveAcrossPlatform:new(x, y, toX, toY)
  moveAcrossPlatform.super.new(self)
  self.solidType = collision.SOLID
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(32, 16)
  self.tex = megautils.getResource("moveArossPlatform")
  self.quad = quad(0, 0, 32, 16)
  self.velocity = velocity()
  self.tween = tween.new(1, self.transform, {x=toX, y=toY}, "inOutBack")
  self.state = 0
end

function moveAcrossPlatform:begin()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("solid")
end

function moveAcrossPlatform:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

function moveAcrossPlatform:update(dt)
  if self.state == 0 then
    for i=1, #megaMan.allPlayers do
      local p = megaMan.allPlayers[i]
      if p.ground and p:collision(self, 0, p.gravity < 0 and -1 or 1) then
        self.state = 1
      end
    end
  elseif self.state == 1 then
    self.tween:update(defaultFramerate)
    self.transform.x = math.round(self.transform.x)
    self.transform.y = math.round(self.transform.y)
  end
  collision.doCollision(self)
  if megautils.outside(self, 4, 4) then
    megautils.removeq(self)
  end
end

megautils.cleanFuncs.moveAcrossPlatform = function()
  moveAcrossPlatform = nil
  megautils.cleanFuncs.moveAcrossPlatform = nil
end
