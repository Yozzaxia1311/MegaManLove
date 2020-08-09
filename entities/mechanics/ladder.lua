ladder = entity:extend()

ladder.autoClean = false

mapEntity.register("ladder", function(v)
    megautils.add(ladder, v.x, v.y, v.width, v.height)
  end, 0, true)

function ladder:new(x, y, w, h)
  ladder.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.dspwn = dspwn
  self.solidType = collision.ONEWAY
  self.autoCollision = false
  self.autoGravity = false
  self.ladder = true
end

function ladder:added()
  self:addToGroup("ladder")
  self:addToGroup("handledBySections")
  self:addToGroup("collision")
end

function ladder:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely + self.gravity
  self.velocity:clampY(7)
end

function ladder:update(dt)
  if self.autoGravity then
    collision.doGrav(self)
  end
  if self.autoCollision then
    collision.doCollision(self)
  end
end