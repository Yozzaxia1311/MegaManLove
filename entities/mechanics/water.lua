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
  self.tex = loader.get("particles")
  self.anim = anim8.newAnimation(loader.get("splash_grid")("1-4", 1), 1/8)
  self.rot = math.rad(ternary(side==-1, 0, 180))
  self.follow = follow
end

function splash:update(dt)
  self.anim:update(1/60)
  if self.follow ~= nil then
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
  megautils.add(water(v.x, v.y, v.width, v.height))
end)

function water:new(x, y, w, h)
  water.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(w, h)
  self.current = false
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("water")
    self:addToGroup("freezable")
  end
end

function water:removed()
  if megautils.groups()["submergable"] ~= nil and self.current then
    for k, v in ipairs(megautils.groups()["submergable"]) do
      v.isInWater = #v:collisionTable(megautils.groups()["water"]) ~= 0
      if not v.isInWater then
        v.gravity = 0.25
        self.current = false
      end
    end
  end
  self:removeFromAllGroups()
end

function water:update(dt)
  if megautils.groups()["submergable"] ~= nil then
    for k, v in ipairs(megautils.groups()["submergable"]) do
      if v:collision(self) and not v.isInWater then
        self.current = true
        v.gravity = v.gravity - .15
        if v.transform.y < self.transform.y then
          megautils.add(splash((v.transform.x-self.transform.x)+(v.collisionShape.w/2), -8, self, -1))
          mmSfx.play("splash")
        elseif v.transform.y-v.velocity.vely > self.transform.y+self.collisionShape.h then
          megautils.add(splash((v.transform.x-self.transform.x)+(v.collisionShape.w/2), 
            self.collisionShape.h+8, self, 1))
          mmSfx.play("splash")
        end
        v.isInWater = true
      elseif self.current and v.isInWater and #v:collisionTable(megautils.groups()["water"]) == 0 then
        v.gravity = v.gravity + .15
        if v.transform.y < self.transform.y then
          megautils.add(splash((v.transform.x-self.transform.x)+(v.collisionShape.w/2), -8, self, -1))
          mmSfx.play("splash")
        elseif v.transform.y > self.transform.y+self.collisionShape.h then
          megautils.add(splash((v.transform.x-self.transform.x)+(v.collisionShape.w/2), 
            self.collisionShape.h+8, self, 1))
          mmSfx.play("splash")
        end
        v.isInWater = false
        self.current = false
      end
      if not self.current and v.isInWater and v:collision(self) then
        for k, i in ipairs(megautils.groups()["water"]) do
          i.current = false
        end
        self.current = true
      end
    end
  end
end