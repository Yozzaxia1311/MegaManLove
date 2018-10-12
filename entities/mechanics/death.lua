death = entity:extend()

addobjects.register("death", function(v)
  megautils.add(death(v.x, v.y, v.width, v.height, v.properties["harm"]))
end)

function death:new(x, y, w, h, harm)
  death.super.new(self, true)
  self.w, self.h = w, h
  self.transform.y = y
  self.transform.x = x
  self.harm = harm or -99
  self.harm = -math.abs(self.harm)
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("death")
    self:setRectangleCollision(self.w, self.h)
  end
end