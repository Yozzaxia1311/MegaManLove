death = basicEntity:extend()

death.autoClean = false

binser.register(death, "death", function(o)
    local result = {}
    
    death.super.transfer(o, result)
    
    result.damage = o.damage
    
    return result
  end, function(o)
    local result = death(nil, nil, nil, nil, o.damage)
    
    death.super.transfer(o, result)
    
    return result
  end)

mapEntity.register("death", function(v)
  megautils.add(death, v.x, v.y, v.width, v.height, v.properties.damage)
end, 0, true)

function death:new(x, y, w, h, damage)
  death.super.new(self, true)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.damage = damage or -99999
  self.damage = -math.abs(self.damage)
  self.solidType = collision.SOLID
  self.death = true
end

function death:added()
  self:addToGroup("handledBySections")
  self:addToGroup("collision")
end