megautils.loadResource("demo/moveAcrossPlatform.png", "moveAcrossPlatform")

moveAcrossPlatform = advancedEntity:extend()
mapEntity.register(moveAcrossPlatform, {collision={w=32, h=16}, spawnerType="spawner"})

function moveAcrossPlatform:new(x, y, toX, toY)
  moveAcrossPlatform.super.new(self)
  
  if not self.regValues then
    self.x = x or self.x
    self.y = y or self.y
  end
  
  self.solidType = collision.SOLID
  self:addGFX("tex", image("moveAcrossPlatform", quad(0, 0, 32, 16)))
  self.applyAutoFace = false
  self.t = {x = self.x, y = self.y}
  self.tween = tween.new(1, self.t, {x=toX or self.toX or (self.x+32), y=toY or self.toY or (self.y-32)}, "inOutBack")
  self.state = 0
  self.hurtable = false
  self.autoGravity.global = false
  self.blockCollision.global = false
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
    local x = math.floor(self.t.x)
    local y = math.floor(self.t.y)
    self.velX = x - self.x
    self.velY = y - self.y
  end
end