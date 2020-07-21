ladder = entity:extend()

addObjects.register("ladder", function(v)
    megautils.add(ladder, v.x, v.y, v.width, v.height)
  end, 0, true)

function ladder:new(x, y, w, h)
  ladder.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.dspwn = dspwn
  self.solidType = collision.ONEWAY
  self.ladder = true
end

function ladder:added()
  self:addToGroup("ladder")
  self:addToGroup("handledBySections")
  self:addToGroup("collision")
end

function ladder:update(dt)
  collision.doCollision(self)
end