checkpoint = entity:extend()

addobjects.register("checkpoint", function(v)
  megautils.add(checkpoint(v.x, v.y, v.width, v.height, v.properties["name"]))
end)

function checkpoint:new(x, y, w, h, c)
  checkpoint.super.new(self, tran)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.added = function(self)
    self:addToGroup("despawnable")
  end
  self.name = c
end

function checkpoint:update(dt)
  if not megautils.outside(self) then
    globals.checkpoint = self.name
  end
end