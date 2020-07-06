checkpoint = basicEntity:extend()

addobjects.register("checkpoint", function(v)
  megautils.add(checkpoint, v.x, v.y, v.width, v.height, v.properties.name, v.properties.stage)
end)

function checkpoint:new(x, y, w, h, c, s)
  checkpoint.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.name = c
  self.stage = s
end

function checkpoint:added()
  self:addToGroup("despawnable")
end

function checkpoint:update(dt)
  if globals.checkpoint ~= self.name and not megautils.outside(self) then
    globals.checkpoint = self.name
    globals.deathState = self.s or states.current
  end
end

collisionCheckpoint = basicEntity:extend()

addobjects.register("collisionCheckpoint", function(v)
  megautils.add(collisionCheckpoint, v.x, v.y, v.width, v.height, v.properties.name, v.properties.stage)
end)

function collisionCheckpoint:new(x, y, w, h, c, s)
  collisionCheckpoint.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.name = c
  self.stage = s
end

function collisionCheckpoint:added()
  self:addToGroup("despawnable")
end

function collisionCheckpoint:update(dt)
  if globals.checkpoint ~= self.name and megaMan.mainPlayer and self:collision(megaMan.mainPlayer) then
    globals.checkpoint = self.name
    globals.deathState = self.s or states.current
  end
end

megautils.cleanFuncs.checkpoint = function()
    checkpoint = nil
    collisionCheckpoint = nil
    addobjects.unregister("checkpoint")
    addobjects.unregister("collisionCheckpoint")
    megautils.cleanFuncs.checkpoint = nil
  end