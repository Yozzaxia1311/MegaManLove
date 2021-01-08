megautils.loadResource("assets/global/entities/moveAcrossPlatform.png", "moveArossPlatform")

moveAcrossPlatform = advancedEntity:extend()

mapEntity.register("moveAcrossPlatform", function(v)
    megautils.add(spawner, v.x, v.y, 32, 16, nil,
      moveAcrossPlatform, v.x, v.y, v.properties.toX, v.properties.toY)
  end)

function moveAcrossPlatform:new(x, y, toX, toY)
  moveAcrossPlatform.super.new(self)
  self.solidType = collision.SOLID
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(32, 16)
  self.tex = megautils.getResource("moveArossPlatform")
  self.quad = quad(0, 0, 32, 16)
  self.tween = tween.new(1, self, {x=toX or (self.x+32), y=toY or (self.y-32)}, "inOutBack")
  self.state = 0
  self.hurtable = false
  self.autoGravity.global = false
end

function moveAcrossPlatform:update()
  if self.state == 0 then
    for i=1, #megaMan.allPlayers do
      local p = megaMan.allPlayers[i]
      if p.ground and p:collision(self, 0, p.gravity < 0 and -1 or 1) then
        self.state = 1
      end
    end
  elseif self.state == 1 then
    self.tween:update(1/60)
    self.x = math.round(self.x)
    self.y = math.round(self.y)
  end
end

function moveAcrossPlatform:draw()
  self.tex:draw(self.quad, math.floor(self.x), math.floor(self.y))
end