sinkIn = basicEntity:extend()

binser.register(sinkIn, "sinkIn", function(o)
    local result = {}
    
    sinkIn.super.transfer(o, result)
    
    result.sink = o.sink
    
    return result
  end, function(o)
    local result = sinkIn()
    
    sinkIn.super.transfer(o, result)
    
    result.sink = o.sink
    
    return result
  end)

mapEntity.register("sinkIn", function(v)
  megautils.add(sinkIn, v.x, v.y, v.width, v.height, v.properties.speed)
end)

function sinkIn:new(x, y, w, h, s)
  sinkIn.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.sink = s or 0.125
  self.solidType = collision.STANDIN
end

function sinkIn:added()
  self:addToGroup("handledBySections")
  self:addToGroup("freezable")
  self:addToGroup("collision")
end

function sinkIn:update(dt)
  for i=1, #megaMan.allPlayers do
    local p = megaMan.allPlayers[i]
    if p:collision(self, 0, (p.gravity >= 0 and 1 or -1)) or p:collision(self) then
      collision.shiftObject(p, 0, self.sink * (p.gravity >= 0 and 1 or -1), true)
    end
  end
end