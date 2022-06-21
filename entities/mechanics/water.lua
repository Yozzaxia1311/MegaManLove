loader.load("assets/sfx/splash.ogg")
loader.load("assets/misc/splash.anim")

splash = particle:extend()

splash.autoClean = false

function splash:new(offx, offy, p, rot)
  splash.super.new(self, p)
  self.offx = offx or 0
  self.offy = offy or 0
  self:setRectangleCollision(32, 28)
  self.rot = rot or 0
  if self.user then
    self.x = self.user.x + self.offx
    self.y = self.user.y + self.offy
  end
  self.autoCollision.global = false
  
  self:addGFX("anim", animation("assets/misc/splash.anim"):origin(16, 16):rot(self.rot))
end

function splash:update()
  if self.user then
    self.x = self.user.x + self.offx
    self.y = self.user.y + self.offy
  end
  if not self.user or self.user.isRemoved or self:getGFXByName("anim"):looped() then
    entities.remove(self)
  end
  self:getGFXByName("anim"):rot(self.rot)
end

water = basicEntity:extend()

water.autoClean = false

mapEntity.register("water", function(v)
  entities.add(water, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function water:new(x, y, w, h, grav)
  water.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.grav = grav or 0.4
end

function water:added()
  self:addToGroup("handledBySections")
  self:addToGroup("water")
end

function water:begin()
  if entities.groups.submergable then
    for _, v in ipairs(self:collisionTable(entities.groups.submergable)) do
      v:setGravityMultiplier("water", self.grav)
      v.inWater = self
    end
  end
end

function water:removed()
  if entities.groups.submergable then
    self:removeFromAllGroups()
    for _, v in ipairs(entities.groups.submergable) do
      if v.gravityMultipliers.water and v:collisionNumber(entities.groups.water) == 0 then
        v:setGravityMultiplier("water", nil)
        v.inWater = false
      end
    end
  end
end

function water:update()
  if entities.groups.submergable then
    for _, v in ipairs(entities.groups.submergable) do
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
            entities.add(splash, (v.x-self.x)+(v.collisionShape.w/2), 0, self, 0)
            sfx.play("assets/sfx/splash.ogg")
          elseif dir == 2 then
            entities.add(splash, (v.x-self.x)+(v.collisionShape.w/2), self.collisionShape.h, self, 180)
            sfx.play("assets/sfx/splash.ogg")
          elseif dir == 3 then
            entities.add(splash, 0, (v.y-self.y)+(v.collisionShape.h/2), self, 270)
            sfx.play("assets/sfx/splash.ogg")
          elseif dir == 4 then
            entities.add(splash, self.collisionShape.w, (v.y-self.y)+(v.collisionShape.h/2), self, 90)
            sfx.play("assets/sfx/splash.ogg")
          end
        end
        
        v.inWater = self
        v:setGravityMultiplier("water", self.grav)
      elseif v.inWater == self and v:collisionNumber(entities.groups.water) == 0 then
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
          entities.add(splash, (v.x-self.x)+(v.collisionShape.w/2), 0, self, 0)
          sfx.play("assets/sfx/splash.ogg")
        elseif dir == 2 then
          entities.add(splash, (v.x-self.x)+(v.collisionShape.w/2), self.collisionShape.h, self, 180)
          sfx.play("assets/sfx/splash.ogg")
        elseif dir == 3 then
          entities.add(splash, 0, (v.y-self.y)+(v.collisionShape.h/2), self, 270)
          sfx.play("assets/sfx/splash.ogg")
        elseif dir == 4 then
          entities.add(splash, self.collisionShape.w, (v.y-self.y)+(v.collisionShape.h/2), self, 90)
          sfx.play("assets/sfx/splash.ogg")
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
  entities.add(space, v.x, v.y, v.width, v.height, v.properties.grav)
end)

function space:new(x, y, w, h, grav)
  space.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.grav = grav or 0.4
end

function space:added()
  self:addToGroup("handledBySections")
  self:addToGroup("space")
end

function space:removed()
  if entities.groups.submergable then
    self:removeFromAllGroups()
    for _, v in ipairs(entities.groups.submergable) do
      if v.gravityMultipliers.space and v:collisionNumber(entities.groups.space) == 0 then
        v:setGravityMultiplier("space", nil)
      end
    end
  end
end

function space:update()
  if entities.groups.submergable then
    for _, v in ipairs(entities.groups.submergable) do
      if v:collision(self) then
        v:setGravityMultiplier("space", self.grav)
      elseif v:collisionNumber(entities.groups.space) == 0 then
        v:setGravityMultiplier("space", nil)
      end
    end
  end
end