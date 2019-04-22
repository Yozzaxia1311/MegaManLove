ladder = entity:extend()

addobjects.register("ladder", function(v)
  megautils.add(ladder, {v.x, v.y, v.width, v.height})
end)

function ladder:new(x, y, w, h)
  ladder.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.dspwn = dspwn
  self.isSolid = 2
  self.added = function(self)
    self:addToGroup("ladder")
    self:addToGroup("despawnable")
  end
end