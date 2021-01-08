megautils.loadResource("assets/sfx/splash.ogg", "splash")
megautils.loadResource(0, 70, 32, 28, "splashGrid")

splash = particle:extend()

splash.autoClean = false

function splash:new(offx, offy, p, rot)
  splash.super.new(self, p)
  self.offx = offx or 0
  self.offy = offy or 0
  self:setRectangleCollision(32, 28)
  self.tex = megautils.getResource("particles")
  self.anim = megautils.newAnimation("splashGrid", {"1-4", 1}, 1/8)
  self.rot = math.rad(rot or 0)
  if self.user then
    self.x = self.user.x + self.offx
    self.y = self.user.y + self.offy
  end
  self.autoCollision.global = false
end

function splash:update()
  self.anim:update(1/60)
  if self.user then
    self.x = self.user.x + self.offx
    self.y = self.user.y + self.offy
  end
  if not self.user or self.user.isRemoved or self.anim:looped() then
    megautils.removeq(self)
  end
end

function splash:draw()
  self.tex:draw(self.anim, math.floor(self.x), math.floor(self.y), self.rot, 1, 1, 16, 16)
end

water = basicEntity:extend()

water.autoClean = false

mapEntity.register("water", function(v)
  megautils.add(water, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function water:new(x, y, w, h, grav)
  water.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.grav = grav or 0.4
end

function water:added()
  water.super.added(self)
  
  self:addToGroup("handledBySections")
  self:addToGroup("water")
end

function water:begin()
  if megautils.groups().submergable then
    for _, v in ipairs(self:collisionTable(megautils.groups().submergable)) do
      v:setGravityMultiplier("water", self.grav)
      v.inWater = self
    end
  end
end

function water:removed()
  if megautils.groups().submergable then
    self:removeFromAllGroups()
    for _, v in ipairs(megautils.groups().submergable) do
      if v.gravityMultipliers.water and v:collisionNumber(megautils.groups().water) == 0 then
        v:setGravityMultiplier("water", nil)
        v.inWater = false
      end
    end
  end
end

function water:update()
  if megautils.groups().submergable then
    for _, v in ipairs(megautils.groups().submergable) do
      if v:collision(self) then
        if not v.inWater and not v.justAddedIn then
          local cx, cy = megautils.center(self)
          local vcx, vcy = megautils.center(v)
          local dir = 1
          
          if cx == vcx then
            dir = 2
          elseif cy ~= vcy then
            local slope = (vcy - cy) / (vcx - cx)
            local hw = self.collisionShape.w / 2
            local hh = self.collisionShape.h / 2
            local hsw = slope * hw
            local hsh = hh / slope
            
            if -hh <= hsw and hsw <= hh then
              if cx < vcx then
                dir = 4
              elseif cx > vcx then
                dir = 3
              end
            elseif -hw <= hsh and hsh <= hw then
              if cy < vcy then
                dir = 2
              elseif cy > vcy then
                dir = 1
              end
            end
          end
          
          if dir == 1 then
            megautils.add(splash, (v.x-self.x)+(v.collisionShape.w/2), 0, self, 0)
            megautils.playSound("splash")
          elseif dir == 2 then
            megautils.add(splash, (v.x-self.x)+(v.collisionShape.w/2), self.collisionShape.h, self, 180)
            megautils.playSound("splash")
          elseif dir == 3 then
            megautils.add(splash, 0, (v.y-self.y)+(v.collisionShape.h/2), self, 270)
            megautils.playSound("splash")
          elseif dir == 4 then
            megautils.add(splash, self.collisionShape.w, (v.y-self.y)+(v.collisionShape.h/2), self, 90)
            megautils.playSound("splash")
          end
        end
        
        v.inWater = self
        v:setGravityMultiplier("water", self.grav)
      elseif v.inWater == self and v:collisionNumber(megautils.groups().water) == 0 then
        local cx, cy = megautils.center(self)
        local vcx, vcy = megautils.center(v)
        local dir = 1
        
        if cx == vcx then
          dir = 2
        elseif cy ~= vcy then
          local slope = (vcy - cy) / (vcx - cx)
          local hw = self.collisionShape.w / 2
          local hh = self.collisionShape.h / 2
          local hsw = slope * hw
          local hsh = hh / slope
          
          if -hh <= hsw and hsw <= hh then
            if cx < vcx then
              dir = 4
            elseif cx > vcx then
              dir = 3
            end
          elseif -hw <= hsh and hsh <= hw then
            if cy < vcy then
              dir = 2
            elseif cy > vcy then
              dir = 1
            end
          end
        end
        
        if dir == 1 then
          megautils.add(splash, (v.x-self.x)+(v.collisionShape.w/2), 0, self, 0)
          megautils.playSound("splash")
        elseif dir == 2 then
          megautils.add(splash, (v.x-self.x)+(v.collisionShape.w/2), self.collisionShape.h, self, 180)
          megautils.playSound("splash")
        elseif dir == 3 then
          megautils.add(splash, 0, (v.y-self.y)+(v.collisionShape.h/2), self, 270)
          megautils.playSound("splash")
        elseif dir == 4 then
          megautils.add(splash, self.collisionShape.w, (v.y-self.y)+(v.collisionShape.h/2), self, 90)
          megautils.playSound("splash")
        end
        
        v.inWater = false
        v:setGravityMultiplier("water", nil)
      end
    end
  end
end

space = basicEntity:extend()

space.autoClean = false

mapEntity.register("space", function(v)
  megautils.add(space, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function space:new(x, y, w, h, grav)
  space.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.grav = grav or 0.4
end

function space:added()
  space.super.added(self)
  
  self:addToGroup("handledBySections")
  self:addToGroup("space")
end

function space:removed()
  if megautils.groups().submergable then
    self:removeFromAllGroups()
    for _, v in ipairs(megautils.groups().submergable) do
      if v.gravityMultipliers.space and v:collisionNumber(megautils.groups().space) == 0 then
        v:setGravityMultiplier("space", nil)
      end
    end
  end
end

function space:update()
  if megautils.groups().submergable then
    for _, v in ipairs(megautils.groups().submergable) do
      if v:collision(self) then
        v:setGravityMultiplier("space", self.grav)
      elseif v:collisionNumber(megautils.groups().space) == 0 then
        v:setGravityMultiplier("space", nil)
      end
    end
  end
end