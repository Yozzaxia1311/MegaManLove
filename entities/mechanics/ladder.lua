ladder = basicEntity:extend()

ladder.autoClean = false

mapEntity.register("ladder", function(v)
    megautils.add(ladder, v.x, v.y, v.width, v.height)
  end, 0, true)

function ladder:new(x, y, w, h)
  ladder.super.new(self)
  self.transform.x = x or 0
  self.transform.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.solidType = collision.ONEWAY
  self.ladder = true
end

function ladder:added()
  ladder.super.added(self)
  
  self:addToGroup("handledBySections")
end