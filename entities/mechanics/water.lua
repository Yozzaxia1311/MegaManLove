splash = entity:extend()

function splash:new(offx, offy, follow, side)
  splash.super.new(self)
  self.added = function(self)
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
  end
  self.offx = offx
  self.offy = offy
  self.side = side
  self:setRectangleCollision(32, 28)
  self.tex = megautils.getResource("particles")
  self.anim = anim8.newAnimation(megautils.getResource("splashGrid")("1-4", 1), 1/8)
  self.rot = math.rad(side==-1 and 0 or 180)
  self.follow = follow
  if self.follow then
    self.transform.x = self.follow.transform.x + self.offx
    self.transform.y = self.follow.transform.y + self.offy
  end
end

function splash:recycle(offx, offy, follow, side)
  self.offx = offx
  self.offy = offy
  self.side = side
  self.follow = follow
  if self.follow then
    self.transform.x = self.follow.transform.x + self.offx
    self.transform.y = self.follow.transform.y + self.offy
  end
  self.rot = math.rad(side==-1 and 0 or 180)
  self.anim:gotoFrame(1)
end

function splash:update(dt)
  self.anim:update(1/60)
  if self.follow then
    self.transform.x = self.follow.transform.x + self.offx
    self.transform.y = self.follow.transform.y + self.offy
  end
  if megautils.outside(self) or self.anim.looped then
    megautils.remove(self, true)
  end
end

function splash:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y), self.rot, 1, 1, 16, 8)
end

water = entity:extend()

addobjects.register("water", function(v)
  megautils.add(water, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function water:new(x, y, w, h, grav)
  water.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.current = false
  self.checked = false
  self.grav = grav or 0.4
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("water")
    self:addToGroup("freezable")
  end
end

function water:removed()
  if megautils.groups().submergable and self.current then
    for k, v in ipairs(megautils.groups().submergable) do
      if #v:collisionTable(megautils.groups().water) == 0 then
        v:setGravityMultiplier("water", nil)
        self.current = false
      end
    end
  end
  self:removeFromAllGroups()
end

function water:update(dt)
  if megautils.groups().submergable then
    if not self.checked then
      self.checked = true
      for k, v in pairs(self:collisionTable(megautils.groups().submergable)) do
        if not v.gravityMultipliers.water then
          self.current = true
          v:setGravityMultiplier("water", self.grav)
        end
      end
    end
    for k, v in ipairs(megautils.groups().submergable) do
      if v:collision(self) and not v.gravityMultipliers.water then
        self.current = true
        v:setGravityMultiplier("water", self.grav)
        if v.transform.y-v.velocity.vely <= self.transform.y then
          megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2), -8, self, -1)
          megautils.playSound("splash")
        elseif v.transform.y-v.velocity.vely >= self.transform.y+self.collisionShape.h then
          megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2), 
            self.collisionShape.h+8, self, 1)
          megautils.playSound("splash")
        end
      elseif self.current and v.gravityMultipliers.water and #v:collisionTable(megautils.groups().water) == 0 then
        v:setGravityMultiplier("water", nil)
        if v.transform.y < self.transform.y then
          megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2), -8, self, -1)
          megautils.playSound("splash")
        elseif v.transform.y > self.transform.y+self.collisionShape.h then
          megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2), 
            self.collisionShape.h+8, self, 1)
          megautils.playSound("splash")
        end
        self.current = false
      end
      if not self.current and v.gravityMultipliers.water and v:collision(self) then
        for k, i in ipairs(megautils.groups().water) do
          i.current = false
        end
        self.current = true
      end
    end
  end
end

space = entity:extend()

addobjects.register("space", function(v)
  megautils.add(space, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function space:new(x, y, w, h, grav)
  space.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.current = false
  self.checked = false
  self.grav = grav or 0.4
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("space")
    self:addToGroup("freezable")
  end
end

function space:removed()
  if megautils.groups().submergable and self.current then
    for k, v in ipairs(megautils.groups().submergable) do
      if #v:collisionTable(megautils.groups().space) == 0 then
        v:setGravityMultiplier("space", nil)
        self.current = false
      end
    end
  end
  self:removeFromAllGroups()
end

function space:update(dt)
  if megautils.groups().submergable then
    if not self.checked then
      self.checked = true
      for k, v in pairs(self:collisionTable(megautils.groups().submergable)) do
        if not v.gravityMultipliers.space then
          self.current = true
          v:setGravityMultiplier("space", self.grav)
        end
      end
    end
    for k, v in ipairs(megautils.groups().submergable) do
      if v:collision(self) and not v.gravityMultipliers.space then
        self.current = true
        v:setGravityMultiplier("space", self.grav)
      elseif self.current and v.gravityMultipliers.space and #v:collisionTable(megautils.groups().space) == 0 then
        v:setGravityMultiplier("space", nil)
        self.current = false
      end
      if not self.current and v.gravityMultipliers.space and v:collision(self) then
        for k, i in ipairs(megautils.groups().space) do
          i.current = false
        end
        self.current = true
      end
    end
  end
end