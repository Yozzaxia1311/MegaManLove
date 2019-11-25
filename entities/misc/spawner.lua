spawner = entity:extend()

function spawner:new(x, y, w, h, func)
  spawner.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self:setLayer(-5)
  self.func = func
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("freezable")
    self.wasOutside = true
    self.canSpawn = true
  end
end

function spawner:update(dt)
  if megautils.outside(self) and self.canSpawn then
    self.wasOutside = true
  end
  if self.wasOutside and self.canSpawn and not megautils.outside(self) then
    self.canSpawn = false
    self.wasOutside = false
    self.func(self)
  end
end

intervalSpawner = entity:extend()

function intervalSpawner:new(x, y, w, h, time, func)
  intervalSpawner.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self:setLayer(-5)
  self.func = func
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("freezable")
  end
  self.time = time
  self.timer = 0
end

function intervalSpawner:update(dt)
  if not megautils.outside(self) then
    self.timer = math.min(self.timer+1, self.time)
    if self.timer == self.time then
      self.timer = 0
      self.func(self)
    end
  else
    self.timer = 0
  end
end