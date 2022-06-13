death = basicEntity:extend()

death.autoClean = false

mapEntity.register("death", function(v)
  entities.add(death, v.x, v.y, v.width, v.height, v.properties.damage)
end, 0, true)

function death:new(x, y, w, h, damage)
  death.super.new(self, true)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.damage = damage
  self.damage = -math.abs(self.damage)
  self.solidType = collision.SOLID
  self.death = true
end

function death:added()
  self:addToGroup("handledBySections")
end