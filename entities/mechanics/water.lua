megautils.loadResource("assets/sfx/splash.ogg", "splash")
megautils.loadResource(0, 70, 32, 28, "splashGrid")

splash = particle:extend()

function splash:new(offx, offy, p, side)
  splash.super.new(self, p)
  self.offx = offx or 0
  self.offy = offy or 0
  self.side = side or -1
  self:setRectangleCollision(32, 28)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("splashGrid", {"1-4", 1}, 1/8)
  self.rot = math.rad(self.side==-1 and 0 or 180)
  if self.user then
    self.transform.x = self.user.transform.x + self.offx
    self.transform.y = self.user.transform.y + self.offy
  end
  self.autoCollision = false
end

function splash:update()
  self.anim:update(defaultFramerate)
  if self.user then
    self.transform.x = self.user.transform.x + self.offx
    self.transform.y = self.user.transform.y + self.offy
  end
  if not self.user or self.user.isRemoved or self.anim:looped() then
    megautils.removeq(self)
  end
end

function splash:draw()
  self.anim:draw(self.tex, math.round(self.transform.x)+16, math.round(self.transform.y), self.rot, 1, 1, 16, 8)
end

water = basicEntity:extend()

addObjects.register("water", function(v)
  megautils.add(water, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function water:new(x, y, w, h, grav)
  water.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.current = false
  self.grav = grav or 0.4
end

function water:added()
  self:addToGroup("handledBySections")
  self:addToGroup("water")
  self:addToGroup("freezable")
end

function water:removed()
  if megautils.groups().submergable and self.current then
    self:removeFromAllGroups()
    for k, v in ipairs(megautils.groups().submergable) do
      if v:collisionNumber(megautils.groups().water) == 0 then
        v:setGravityMultiplier("water", nil)
        self.current = false
      end
    end
  end
end

function water:update()
  if megautils.groups().submergable then
    for k, v in ipairs(megautils.groups().submergable) do
      if v:collision(self) and not v.gravityMultipliers.water then
        self.current = true
        v:setGravityMultiplier("water", self.grav)
        if v.doSplashing == nil or v.doSplashing then
          if v.transform.y-v.velocity.vely <= self.transform.y then
            megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2)-16, -8, self, -1)
            megautils.playSound("splash")
          elseif v.transform.y-v.velocity.vely >= self.transform.y+self.collisionShape.h then
            megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2)-16, 
              self.collisionShape.h+8, self, 1)
            megautils.playSound("splash")
          end
        end
      elseif self.current and v.gravityMultipliers.water and v:collisionNumber(megautils.groups().water) == 0 then
        v:setGravityMultiplier("water", nil)
        if v.doSplashing == nil or v.doSplashing then
          if v.transform.y < self.transform.y then
            megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2)-16, -8, self, -1)
            megautils.playSound("splash")
          elseif v.transform.y > self.transform.y+self.collisionShape.h then
            megautils.add(splash, (v.transform.x-self.transform.x)+(v.collisionShape.w/2)-16, 
              self.collisionShape.h+8, self, 1)
            megautils.playSound("splash")
          end
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

addObjects.register("space", function(v)
  megautils.add(space, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function space:new(x, y, w, h, grav)
  space.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.grav = grav or 0.4
end

function space:added()
  self:addToGroup("handledBySections")
  self:addToGroup("space")
  self:addToGroup("freezable")
end

function space:removed()
  if megautils.groups().submergable then
    self:removeFromAllGroups()
    for k, v in ipairs(megautils.groups().submergable) do
      if v.gravityMultipliers.space and v:collisionNumber(megautils.groups().space) == 0 then
        v:setGravityMultiplier("space", nil)
      end
    end
  end
end

function space:update(dt)
  if megautils.groups().submergable then
    for k, v in ipairs(megautils.groups().submergable) do
      if v:collision(self) and v.gravityMultipliers.space ~= self.grav then
        v:setGravityMultiplier("space", self.grav)
      else
        v:setGravityMultiplier("space", nil)
      end
    end
  end
end

megautils.cleanFuncs.water = function()
    splash = nil
    water = nil
    space = nil
    megautils.cleanFuncs.water = nil
  end