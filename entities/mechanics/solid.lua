solid = entity:extend()

addobjects.register("solid", function(v)
  megautils.add(solid(v.x, v.y, v.width, v.height))
end)

function solid:new(x, y, w, h)
  solid.super.new(self, true)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self:setLayer(9)
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("solid")
    self:addStatic()
  end
end

function solid.blockFromGroup(self, group, x, y)
  if group ~= nil and #group ~= 0 then
    local tmp = self:collisionTable(group, 0, y)
    if #tmp ~= 0 then
      if y > 0 then
        self.transform.y = math.round(self.transform.y + y)
        while #self:collisionTable(tmp) ~= 0 do
          self.transform.y = self.transform.y - 1
        end
        self.collisionChecks.ground = true
        self.collisionChecks.touching = true
      elseif y < 0 then
        self.transform.y = math.round(self.transform.y + y)
        while #self:collisionTable(tmp) ~= 0 do
          self.transform.y = self.transform.y + 1
        end
        self.collisionChecks.ceiling = true
        self.collisionChecks.touching = true
      end
    end
    tmp = self:collisionTable(group, x)
    if #tmp ~= 0 then
      if x > 0 then
        self.transform.x = math.round(self.transform.x + x)
        while #self:collisionTable(tmp) ~= 0 do
          self.transform.x = self.transform.x - 1
        end
        self.transform.x = tmp[1].transform.x - self.collisionShape.w
        self.collisionChecks.rightWall = true
        self.collisionChecks.touching = true
      elseif x < 0 then
        self.transform.x = math.round(self.transform.x + x)
        while #self:collisionTable(tmp) ~= 0 do
          self.transform.x = self.transform.x + 1
        end
        self.transform.x = tmp[1].transform.x + tmp[1].collisionShape.w
        self.collisionChecks.leftWall = true
        self.collisionChecks.touching = true
      end
    end
  end
end

slope = entity:extend()

addobjects.register("slope", function(v)
  megautils.add(slope(v.x, v.y, loader.get(v.properties["mask"]), v.properties["invert"], v.properties["left"]))
end)

function slope:new(x, y, mask, invert, left)
  slope.super.new(self, true)
  self.transform.x = x
  self.transform.y = y
  self.left = left
  self.invert = invert
  self:setImageCollision(mask)
  self.added = function(self)
    self:addToGroup("slope")
    self:addToGroup("despawnable")
    self:addStatic()
  end
end

function slope.blockFromGroup(self, group, x, y)
  if group ~= nil and #group ~= 0 then
    if not self.onSlope and not self.slopeCeiling then
      self.slope = self:collisionTable(group, 0, y)
      if self.slope ~= nil and self.slope[1] ~= nil and not self.slope[1].invert then
        self.slope = self:collisionTable(group, 0, y>=0 and y+1 or -8)
      end
      if self.slope ~= nil and self.slope[1] ~= nil then
        if self.slope[1].invert then
          self.transform.y = self.slope[1].transform.y
          while #self:collisionTable(self.slope) == 0 do
            self:moveBy(0, -1)
          end
          while #self:collisionTable(self.slope) ~= 0 do
            self:moveBy(0, 1)
          end
          if (self.slope[1].left and self.transform.x+x < self.slope[1].transform.x) or
            (not self.slope[1].left and self.transform.x+x >
            self.slope[1].transform.x+self.slope[1].collisionShape.w-self.collisionShape.w) then
            self.transform.x = self.transform.x+x
            while #self:collisionTable(megautils.groups()["solid"]) ~= 0 do
              self:moveBy(0, 1)
            end
            self.transform.x = self.transform.x-x
          else
            self.slopeCeiling = true
          end
          self.collisionChecks.ceiling = true
        else
          self.transform.y = self.slope[1].transform.y - self.collisionShape.h
          while #self:collisionTable(self.slope) == 0 do
            self:moveBy(0, 1)
          end
          while #self:collisionTable(self.slope) ~= 0 do
            self:moveBy(0, -1)
          end
          self.onSlope = true
          self.collisionChecks.ground = true
        end
      end
    elseif self.onSlope and self.slope ~= nil and self.slope[1] ~= nil then
      self.slope = self:collisionTable(group, 0, y>=0 and y+math.abs(x)+4 or y)
      if self.slope ~= nil and self.slope[1] ~= nil and y >= 0 then
        self.transform.y = self.slope[1].transform.y - self.collisionShape.h
        while #self:collisionTable(self.slope, 0, 1) == 0 do
          self:moveBy(0, 1)
        end
        while #self:collisionTable(self.slope) ~= 0 do
          self:moveBy(0, -1)
        end
        local tmp2 = self:collisionTable(table.merge({megautils.groups()["solid"], 
          megautils.groups()["oneway"]}), x)
        if #tmp2 ~= 0 and self.transform.y+(self.collisionShape.h-1)-math.abs(x) < tmp2[1].transform.y then
          self.transform.y = self.slope[1].transform.y - self.collisionShape.h
        end
      elseif self.slope == nil or #self.slope == 0 then
        local tmp = self:collisionTable(table.merge({megautils.groups()["solid"],
          oneway.collisionTable(self, megautils.groups()["oneway"], 0, y+math.abs(x)+4)}), 0, y+math.abs(x)+4)
        if #tmp ~= 0 then
          self.transform.y = tmp[1].transform.y - self.collisionShape.h
          while not self:collision(tmp[1], 0, 1) do
            self:moveBy(0, 1)
          end
          while self:collision(tmp[1]) do
            self:moveBy(0, -1)
          end
        end
        self.onSlope = false
      end
    elseif self.slope ~= nil and self.slope[1] ~= nil and self.slopeCeiling then
        self.transform.y = self.slope[1].transform.y
        while not self:collision(self.slope[1], 0, -1) do
          self:moveBy(0, -1)
        end
        while self:collision(self.slope[1]) do
          self:moveBy(0, 1)
        end
        if (self.slope[1].left and self.transform.x+x < self.slope[1].transform.x) or
          (not self.slope[1].left and self.transform.x+x >
          self.slope[1].transform.x+self.slope[1].collisionShape.w-self.collisionShape.w) then
          self.transform.x = self.transform.x+x
          while not self:collision(self.slope[1], 0, -1) do
            self:moveBy(0, -1)
          end
          while self:collision(self.slope[1]) do
            self:moveBy(0, 1)
          end
          self.transform.x = self.transform.x-x
        end
        if not self:collision(self.slope[1], x, y) then
          self.slopeCeiling = false
        end
      end
  end
end

oneway = entity:extend()

addobjects.register("oneway", function(v)
  megautils.add(oneway(v.x, v.y, v.width, v.height))
end)

function oneway:new(x, y, w, h)
  oneway.super.new(self, true)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.added = function(self)
    self:addToGroup("oneway")
    self:addToGroup("despawnable")
    self:addStatic()
  end
end

function oneway.blockFromGroup(self, group, y)
  if group ~= nil and #group ~= 0 then
    local tmp = self:collisionTable(group, 0, y)
    if #tmp ~= 0 then
      for k, v in pairs(tmp) do
        if y >= 0 and self.transform.y < v.transform.y - (self.collisionShape.h - 1) then
          self.transform.y = v.transform.y - self.collisionShape.h
          self.collisionChecks.ground = true
          self.collisionChecks.touching = true
          break
        end
      end
    end
  end
end

function oneway.collision(self, e, x, y)
  if e == nil or self.collisionShape == nil or e.collisionShape == nil then return false end
  if self.collisionShape.type == 0 then
    if e.collisionShape.type == 0 then
      return self.transform.y < e.transform.y - (self.collisionShape.h - 1) and self:collision(e, x, y)
    elseif e.collisionShape.type == 1 then
      return false --Actually implement rect/image collision
    end
  elseif self.collisionShape.type == 1 then
    if e.collisionShape.type == 0 then
      return false --image/rect collision
    elseif e.collisionShape.type == 1 then
      return false --image/image collision
    end
  end
  return false
end

function oneway.collisionTable(self, t, x, y)
  local result = {}
  if t == nil then return result end
  for k, v in pairs(t) do
    if oneway.collision(self, v, x, y) then
      result[#result+1] = v
    end
  end
  return result
end

movingOneway = {}

function movingOneway.shift(self, group)
  if self.shifted == nil then self.shifted = {} end
  if group ~= nil and #group ~= 0 then
    for k, v in pairs(group) do
      if v.velocity ~= nil then
        if (v.velocity.vely >= math.min(0, self.velocity.vely) and not v:collision(self, 0, self.velocity.vely-1) and
          v:collision(self, 0, self.velocity.vely+v.velocity.vely+1)) then
          v.transform.y = self.transform.y - v.collisionShape.h
          if v:solid(0, 0) then
            if self.velocity.vely >= 0 then
              v:snapToFloor()
              v.onMovingFloor = nil
              table.removevalue(self.shifted, v)
            else
              v:snapToCeiling()
              v.onMovingFloor = nil
              table.removevalue(self.shifted, v)
            end
          else
            self.shifted[k] = v
            local lx, ly = v.velocity.velx, v.velocity.vely
            v.velocity.velx = self.velocity.velx
            v.velocity.vely = self.velocity.vely
            v:phys()
            v.velocity.velx = lx
            v.velocity.vely = ly
            v.onMovingFloor = self
            v.transform.y = self.transform.y - v.collisionShape.h
            v.velocity.vely = 0
          end
        elseif table.contains(self.shifted, v) then
          v.onMovingFloor = nil
          table.removevalue(self.shifted, v)
        end
      end
    end
  end
  if self.isRemoved and self.shifted ~= nil and #self.shifted ~= 0 then
    movingOneway.clean(self)
  end
end

function movingOneway.clean(self)
  if self.shifted ~= nil then
    for k, v in pairs(self.shifted) do
      v.onMovingFloor = false
    end
  end
end