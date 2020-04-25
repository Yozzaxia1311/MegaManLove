checkpoint = basicEntity:extend()

addobjects.register("checkpoint", function(v)
  megautils.add(checkpoint, v.x, v.y, v.width, v.height, v.properties.name)
end)

function checkpoint:new(x, y, w, h, c)
  checkpoint.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.added = function(self)
    self:addToGroup("despawnable")
  end
  self.name = c
end

function checkpoint:update(dt)
  if globals.checkpoint ~= self.name and not megautils.outside(self) then
    globals.checkpoint = self.name
  end
end

collisionCheckpoint = basicEntity:extend()

addobjects.register("collisionCheckpoint", function(v)
  megautils.add(collisionCheckpoint, v.x, v.y, v.width, v.height, v.properties.name)
end)

function collisionCheckpoint:new(x, y, w, h, c)
  collisionCheckpoint.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.added = function(self)
    self:addToGroup("despawnable")
  end
  self.name = c
end

function collisionCheckpoint:update(dt)
  if globals.checkpoint ~= self.name and globals.mainPlayer and self:collision(globals.mainPlayer) then
    globals.checkpoint = self.name
  end
end