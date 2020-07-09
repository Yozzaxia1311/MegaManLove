checkpoint = basicEntity:extend()

addObjects.register("checkpoint", function(v)
  megautils.add(checkpoint, v.x, v.y, v.width, v.height, v.properties.name)
end, 0, true)

function checkpoint:new(x, y, w, h, c)
  checkpoint.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.name = c
end

function checkpoint:added()
  self:addToGroup("despawnable")
end

function checkpoint:update(dt)
  if globals.checkpoint ~= self.name and not megautils.outside(self) then
    globals.checkpoint = self.name
  end
end

collisionCheckpoint = basicEntity:extend()

addObjects.register("collisionCheckpoint", function(v)
  megautils.add(collisionCheckpoint, v.x, v.y, v.width, v.height, v.properties.name)
end)

function collisionCheckpoint:new(x, y, w, h, c)
  collisionCheckpoint.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.name = c
end

function collisionCheckpoint:added()
  self:addToGroup("despawnable")
end

function collisionCheckpoint:update(dt)
  if globals.checkpoint ~= self.name and megaMan.mainPlayer and self:collision(megaMan.mainPlayer) then
    globals.checkpoint = self.name
  end
end