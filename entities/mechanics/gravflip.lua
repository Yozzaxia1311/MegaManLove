gravFlip = basicEntity:extend()

addobjects.register("gravFlip", function(v)
    megautils.add(gravFlip, v.x, v.y, v.width, v.height, v.properties.dir)
  end)

function gravFlip:new(x, y, w, h, dir)
  gravFlip.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.dir = dir or 1
  self.doEffect = false
  
  self.added = function(self)
      self:addToGroup("despawnable")
    end
end

function gravFlip:update(dt)
  local tmp = self:collisionTable(globals.allPlayers)
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

megautils.cleanFuncs.gravFlip = function()
  gravFlip = nil
  addobjects.unregister("gravFlip")
  megautils.cleanFuncs.gravFlip = nil
end