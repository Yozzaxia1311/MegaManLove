loader.load("assets/sfx/gravityFlip.ogg")

gravFlip = basicEntity:extend()

gravFlip.invisibleToHash = true

mapEntity.register("gravFlip", function(v)
    entities.add(gravFlip, v.x, v.y, v.width, v.height, v.properties.dir)
  end)

function gravFlip:new(x, y, w, h, dir)
  gravFlip.super.new(self)
  self.x = x
  self.y = y
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
    for _, v in ipairs(tmp) do
      if v.gravityMultipliers.gravityFlip ~= self.dir then
        v:setGravityMultiplier("gravityFlip", self.dir)
        ds = true
      end
    end
    if ds then
      entities.add(fade, false, 4, {255, 255, 255}, fade.remove)
      sfx.play("assets/sfx/gravityFlip.ogg")
    end
  end
end