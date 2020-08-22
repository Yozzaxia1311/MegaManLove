megautils.loadResource("assets/sfx/gravityFlip.ogg", "gravityFlip")

gravFlip = basicEntity:extend()

binser.register(gravFlip, "gravFlip", function(o)
    local result = {}
    
    gravFlip.super.transfer(o, result)
    
    result.dir = o.dir
    
    return result
  end, function(o)
    local result = gravFlip()
    
    gravFlip.super.transfer(o, result)
    
    result.dir = o.dir
    
    return result
  end)

mapEntity.register("gravFlip", function(v)
    megautils.add(gravFlip, v.x, v.y, v.width, v.height, v.properties.dir)
  end)

function gravFlip:new(x, y, w, h, dir)
  gravFlip.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.dir = dir or 1
end

function gravFlip:added()
  self:addToGroup("handledBySections")
end

function gravFlip:update(dt)
  local tmp = self:collisionTable(megaMan.allPlayers)
  if #tmp ~= 0 then
    local ds = false
    for k, v in ipairs(tmp) do
      if v.gravityMultipliers.gravityFlip ~= self.dir then
        v:setGravityMultiplier("gravityFlip", self.dir)
        ds = true
      end
    end
    if ds then
      megautils.add(fade, false, 4, {255, 255, 255}, fade.remove)
      megautils.playSound("gravityFlip")
    end
  end
end