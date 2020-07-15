megautils.loadResource("assets/global/entities/moveAcrossPlatform.png", "moveArossPlatform")

addObjects.register("moveAcrossPlatform", function(v)
  megautils.add(spawner, v.x-4, v.y-4, 32+8, 16+8, function(s)
    megautils.add(moveAcrossPlatform, s.transform.x+4, s.transform.y+4, v.properties.toX, v.properties.toY, s)
  end)
end)

moveAcrossPlatform = entity:extend()

function moveAcrossPlatform:new(x, y, toX, toY, s)
  moveAcrossPlatform.super.new(self)
  self.solidType = collision.SOLID
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(32, 16)
  self.tex = megautils.getResource("moveArossPlatform")
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 32, 16)
  self.spawner = s
  self.velocity = velocity()
  self.tween = tween.new(1, self.transform, {x=toX, y=toY}, "inOutBack")
  self.state = 0
end

function moveAcrossPlatform:begin()
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("solid")
end

function moveAcrossPlatform:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

function moveAcrossPlatform:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
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
