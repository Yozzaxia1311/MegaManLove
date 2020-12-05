megautils.loadResource("assets/global/entities/moveAcrossPlatform.png", "moveArossPlatform")

moveAcrossPlatform = advancedEntity:extend()

mapEntity.register("moveAcrossPlatform", function(v)
    megautils.add(spawner, v.x-4, v.y-4, 40, 24, nil,
      moveAcrossPlatform, v.x, v.y, v.properties.toX, v.properties.toY)
  end)

function moveAcrossPlatform:new(x, y, toX, toY)
  moveAcrossPlatform.super.new(self)
  self.solidType = collision.SOLID
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(32, 16)
  self.tex = megautils.getResource("moveArossPlatform")
  self.quad = quad(0, 0, 32, 16)
  self.tween = tween.new(1, self.transform, {x=toX or (self.transform.x+32), y=toY or (self.transform.y-32)}, "inOutBack")
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
    self.transform.x = math.round(self.transform.x)
    self.transform.y = math.round(self.transform.y)
  end
end

function moveAcrossPlatform:draw()
  self.tex:draw(self.quad, math.floor(self.transform.x), math.floor(self.transform.y))
end