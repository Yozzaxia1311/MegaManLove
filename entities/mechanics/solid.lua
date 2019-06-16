collision = {}

collision.maxSlope = 1

function collision.doCollision(self)
  collision.checkGround(self)
  if not self.ground and self.grav then self:grav() end
  if self.blockCollision then
    collision.generalCollision(self)
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  collision.entityPlatform(self)
  collision.checkGround(self)
end

function collision.getTable(self, dx, dy)
  local xs = dx or 0
  local ys = dy or 0
  local solid = {}
  
  local cgrav = math.sign(self.gravity)
  cgrav = cgrav == 0 and 1 or cgrav
  
  for i=1, #megautils.state().system.all do
    local v = megautils.state().system.all[i]
    if (not v.exclusiveCollision or table.contains(v.exclusiveCollision, self)) and (v.isSolid == 1 or v.isSolid == 2) then
      if v.isSolid ~= 2 or (not v:collision(self) and v:collision(self, -xs, -(cgrav * math.abs(ys)))) then
        solid[#solid+1] = v
      end
    end
  end
  
  local ret = {}
  for i=1, #solid do
    if self:collision(solid[i], xs, ys) then
      ret[#ret+1] = solid[i]
    elseif not noSlope and xs ~= 0 and ys == 0 then
      if #self:collisionTable(solid, xs, math.min(4, math.ceil(math.abs(xs)) * collision.maxSlope)) ~= 0 or
        #self:collisionTable(solid, xs, -math.max(-4, math.ceil(math.abs(xs)) * collision.maxSlope)) ~= 0 then
        ret[#ret+1] = solid[i]
      end
    end
  end
  return ret
end

function collision.checkSolid(self, dx, dy, noSlope)
  local xs = dx or 0
  local ys = dy or 0
  local solid = {}
  
  local cgrav = math.sign(self.gravity)
  cgrav = cgrav == 0 and 1 or cgrav
  
  for i=1, #megautils.state().system.all do
    local v = megautils.state().system.all[i]
    if (not v.exclusiveCollision or table.contains(v.exclusiveCollision, self)) and (v.isSolid == 1 or v.isSolid == 2) then
      if v.isSolid ~= 2 or (not v:collision(self) and v:collision(self, -xs, -(cgrav * math.abs(ys)))) then
        solid[#solid+1] = v
      end
    end
  end
  
  local ret = true
  if #self:collisionTable(solid, xs, ys) == 0 then
    ret = false
  elseif not noSlope and xs ~= 0 and ys == 0 then
    if #self:collisionTable(solid, xs, math.min(4, math.ceil(math.abs(xs)) * collision.maxSlope)) == 0 or
      #self:collisionTable(solid, xs, -math.max(-4, math.ceil(math.abs(xs)) * collision.maxSlope)) == 0 then
      ret = false
    end
  end
  return ret
end

function collision.entityPlatform(self)
  if self.isSolid ~= 0 and self.collisionShape then
    if self.transform.x ~= self.previousX or self.transform.y ~= self.previousY then
      local all = megautils.state().system.all
      if self.exclusiveCollision then
        all = self.exclusiveCollision
      end
      
      local resolid = self.isSolid
      self.isSolid = 0
      local xypre
      
      local epCanCrush = true
      
      local myyspeed = self.transform.y - self.previousY
      local myxspeed = self.transform.x - self.previousX
      self.transform.x = self.previousX
      self.transform.y = self.previousY
      
      local savedgrav
      if globals.mainPlayer then
        savedgrav = globals.mainPlayer.gravity
        globals.mainPlayer.gravity = math.sign(globals.mainPlayer.gravity)
      end
      
      if myyspeed ~= 0 then
        for i=1, #all do
          local v = all[i]
          if v ~= self and v.blockCollision and v.collisionShape and v.crushed ~= self and
            (not self.exclusiveCollision or table.contains(self.exclusiveCollision, v)) then
            local epDir = math.sign(self.transform.y + (self.collisionShape.h/2) -
              (v.transform.y + (v.collisionShape.h/2)))
            
            if not v:collision(self) then
              local epIsPassenger = v:collision(self, 0, math.sign(v.gravity) + v.gravity +
                (0.5*math.sign(v.gravity)*(v.ground and 1 or 0)))
              local epWillCollide = self:collision(v, 0, myyspeed)
              
              if epIsPassenger or epWillCollide then
                self.transform.y = self.transform.y + myyspeed
                
                xypre = v.transform.y
                if epIsPassenger then
                  v.transform.y = v.transform.y + myyspeed
                end
                
                if resolid == 1 or (resolid == 2 and (epDir*math.sign(v.gravity))>0) then
                  if v:collision(self) then
                    v.transform.y = math.round(v.transform.y)
                    v.transform.y = v.transform.y + (epDir*-0.5)
                  end
                  local rpts = math.max(32, math.abs(self.collisionShape.h)*2)
                  for i=0, rpts do
                    if v:collision(self) then
                      v.transform.y = v.transform.y + (epDir*-0.5)
                    else
                      break
                    end
                  end
                end
                xypre = xypre - v.transform.y
                v.transform.y = v.transform.y + xypre
                
                collision.shiftObject(v, 0, -xypre, true)
                
                if resolid == 1 then
                  if epCanCrush and v:collision(self) then
                    v.crushed = self
                    for k2, _ in pairs(v.canBeInvincible) do
                      v.canBeInvincible[k2] = false
                    end
                    v.iFrame = v.maxIFrame
                    v:hurt({v}, -999)
                  end
                end
                
                if v.velocity.vely == 0 and epDir == math.sign(v.gravity) then
                  v.ground = true
                  v.onMovingFloor = self
                end
                
                self.transform.y = self.transform.y - myyspeed
              end
            end
          end
        end
      end
      
      self.transform.y = self.transform.y + myyspeed
        
      if myxspeed ~= 0 then
        for i=1, #all do
          local v = all[i]
          local continue = false
          if v ~= self and v.blockCollision and v.collisionShape and v.crushed ~= self and
            (not self.exclusiveCollision or table.contains(self.exclusiveCollision, v)) then
            if not v:collision(self) then
              local epIsOnPlat = false
              local epDir = math.sign((self.transform.x + (self.collisionShape.w/2)) -
                (v.transform.x + (v.collisionShape.w/2)))
              
              if v:collision(self, 0, math.sign(v.gravity)+v.gravity+
                ((v.ground and 1 or 0)*0.5*math.sign(v.gravity))) then
                collision.shiftObject(v, myxspeed, 0, true)
                epIsOnPlat = true
                v.onMovingFloor = self
              end
              
              if resolid == 1 then
                self.transform.x = self.transform.x + myxspeed
                
                if not epIsOnPlat and v:collision(self) then
                  xypre = v.transform.x
                  v.transform.x = v.transform.x + (myxspeed + (2 * math.sign(epDir)))
                  local rpts = math.max(32, math.abs(self.collisionShape.w)*2)
                  for i=0, rpts do
                    if v:collision(self) then
                      v.transform.x = v.transform.x + (epDir * -0.5)
                    else
                      break
                    end
                  end
                  
                  xypre = xypre - v.transform.x
                  v.transform.x = v.transform.x + xypre
                  
                  collision.shiftObject(v, -xypre, 0, true)
                  
                  if epCanCrush and v:collision(self) then
                    v.crushed = self
                    v.iFrame = v.maxIFrame
                    v:hurt({v}, -999)
                  end
                end
                
                self.transform.x = self.transform.x - myxspeed
              end
            else
              continue = true
            end
          end
          if not continue then
            epIsOnPlat = false
          end
        end
      end
      
      self.transform.x = self.transform.x + myxspeed
      
      self.isSolid = resolid
      
      self.previousX = self.transform.x
      self.previousY = self.transform.y
      if savedgrav and globals.mainPlayer then globals.mainPlayer.gravity = savedgrav end
    end
  end
end

function collision.shiftObject(self, dx, dy, checkforcol)
  local xsub = self.velocity.velx
  local ysub = self.velocity.vely
  
  self.velocity.velx = dx
  self.velocity.vely = dy
  
  self.previousX = self.transform.x
  self.previousY = self.transform.y
  
  if checkforcol then
    self.canStandSolid["global"] = false
    collision.generalCollision(self)
    self.canStandSolid["global"] = true
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  
  collision.entityPlatform(self)
  
  self.velocity.velx = xsub
  self.velocity.vely = ysub
end

function collision.checkGround(self, noSlopeEffect)
  if not self.ground then return end
  local solid = {}
  local cgrav = math.sign(self.gravity)
  cgrav = cgrav == 0 and 1 or cgrav
  
  local slp = math.ceil(math.abs(self.velocity.velx) + 1)
  
  for i=1, #megautils.state().system.all do
    local v = megautils.state().system.all[i]
    if v ~= self and v.collisionShape and (not v.exclusiveCollision or table.contains(v.exclusiveCollision, self)) then
      if v.isSolid == 1 or v.isSolid == 2 then
        if not v:collision(self, 0, cgrav) and (v.isSolid ~= 2 or v:collision(self, 0, -cgrav * slp)) then
          solid[#solid+1] = v
        end
      elseif v.isSolid == 3 then
        solid[#solid+1] = v
      end
    end
  end
  
  if #self:collisionTable(solid) == 0 then
    local i = 1
    while i <= slp do
      if #self:collisionTable(solid, 0, cgrav * i) == 0 then
        self.ground = false
        self.onMovingFloor = nil
        self.inStandSolid = nil
      elseif self.velocity.vely * cgrav >= 0 then
        self.ground = true
        self.transform.y = math.round(self.transform.y+cgrav) + (i - 1) * cgrav
        while #self:collisionTable(solid) ~= 0 do
          self.transform.y = self.transform.y - cgrav
        end
        break
      end
      if noSlopeEffect then
        break
      end
      i = i + 1
    end
  end
end

function collision.generalCollision(self, noSlopeEffect)
  self.xcoll = 0
  self.ycoll = 0
  
  local xprev = self.transform.x
  local solid = {}
  local stand = {}
  local cgrav = math.sign(self.gravity)
  cgrav = cgrav == 0 and 1 or cgrav
  
  for i=1, #megautils.state().system.all do
    local v = megautils.state().system.all[i]
    if v ~= self and v.collisionShape and (not v.exclusiveCollision or table.contains(v.exclusiveCollision, self)) then
      if v.isSolid == 1 then
        if not v:collision(self) and not table.contains(solid, v) then
          solid[#solid+1] = v
        end
      elseif v.isSolid == 3 then
        stand[#stand+1] = v
      end
    end
  end
  
  if self.velocity.velx ~= 0 then
    local slp = (math.ceil(math.abs(self.velocity.velx)) * collision.maxSlope * cgrav) *
      ((self.velocity.vely * cgrav) <= 0 and 1 or 0)
    if slp ~= 0 then
      for i=1, #megautils.state().system.all do
        local v = megautils.state().system.all[i]
        if v ~= self and v.collisionShape and not table.contains(solid, v) and
          (not v.exclusiveCollision or table.contains(v.exclusiveCollision, self)) then
          if v.isSolid == 2 and v:collision(self, -self.velocity.velx, 0) and
            not v:collision(self, -self.velocity.velx, slp) and not v:collision(self) then
            solid[#solid+1] = v
          end
        end
      end
    end
      
    self.transform.x = self.transform.x + self.velocity.velx
    
    if #self:collisionTable(solid) ~= 0 then
      self.transform.x = math.round(self.transform.x)
      self.xcoll = -math.sign(self.velocity.velx)
      
      for ii=0, math.max(32, math.abs(self.velocity.velx) * 4) do
        if #self:collisionTable(solid) ~= 0 then
          self.transform.x = self.transform.x + self.xcoll
        else
          break
        end
      end
      
      self.xcoll = self.velocity.velx
      self.velocity.velx = 0
      
      if not noSlopeEffect then
        if self.xcoll ~= 0 then
          if slp ~= 0 then
            local xsl = self.xcoll - (self.transform.x - xprev)
            if math.sign(self.xcoll) == math.sign(xsl) then
              local iii=1
              while iii <= math.ceil(math.abs(xsl)) * collision.maxSlope do
                if #self:collisionTable(solid, xsl, -iii) == 0 then
                  self.transform.x = self.transform.x + xsl
                  self.transform.y = self.transform.y - iii
                  self.velocity.velx = self.xcoll
                  self.xcoll = 0
                  break
                elseif #self:collisionTable(solid, xsl, iii) == 0 then
                  self.transform.x = self.transform.x + xsl
                  self.transform.y = self.transform.y + iii
                  self.velocity.velx = self.xcoll
                  self.xcoll = 0
                  break
                end
                iii = iii + 1
              end
            end
          end
        end
      end
    end
  end
  
  if self.velocity.vely ~= 0 then
    if self.velocity.vely * cgrav > 0 then
      for i=1, #megautils.state().system.all do
        local v = megautils.state().system.all[i]
        if v ~= self and v.collisionShape and v.isSolid == 2 and
          (not v.exclusiveCollision or table.contains(v.exclusiveCollision, self)) then
          table.removevaluearray(solid, v)
          if not v:collision(self) then
            solid[#solid+1] = v
          end
        end
      end
    end
    
    self.transform.y = self.transform.y + self.velocity.vely
    
    if #self:collisionTable(solid) ~= 0 then
      self.transform.y = math.round(self.transform.y)
      
      self.ycoll = math.sign(self.velocity.vely) * -1
      
      for i=0, math.max(32, math.abs(self.velocity.vely) * 4) do
        if #self:collisionTable(solid) ~= 0 then
          self.transform.y = self.transform.y + self.ycoll
        else
          break
        end
      end
      
      self.ycoll = self.velocity.vely
      if self.velocity.vely * cgrav > 0 then
        self.ground = true
      end
      
      self.velocity.vely = 0
    end
  end
  
  if self:checkTrue(self.canStandSolid) then
    local ss = self:collisionTable(stand, 0, cgrav)
    if #ss ~= 0 then
      if self.velocity.vely * cgrav > 0 then
        self.ground = true
        self.ycoll = self.velocity.vely
        self.velocity.vely = 0
      end
      self.inStandSolid = ss[1]
    end
  end
end

solid = basicEntity:extend()

addobjects.register("solid", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height)
end)

function solid:new(x, y, w, h)
  solid.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self:setLayer(9)
  self.isSolid = 1
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addStatic()
  end
end

sinkIn = basicEntity:extend()

addobjects.register("sink_in", function(v)
  megautils.add(sinkIn, v.x, v.y, v.width, v.height, v.properties["speed"])
end)

function sinkIn:new(x, y, w, h, s)
  sinkIn.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self:setLayer(9)
  self.sink = s or 0.125
  self.isSolid = 3
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("freezable")
  end
end

function sinkIn:update(dt)
  for i=1, #globals.allPlayers do
    local p = globals.allPlayers[i]
    if p:collision(self, 0, 1) or p:collision(self) then
      collision.shiftObject(p, 0, self.sink, true)
    end
  end
end

slope = basicEntity:extend()

addobjects.register("slope", function(v)
  megautils.add(slope, v.x, v.y, loader.get(v.properties["mask"]))
end)

function slope:new(x, y, mask)
  slope.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setImageCollision(mask)
  self.isSolid = 1
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addStatic()
  end
end

oneway = basicEntity:extend()

addobjects.register("oneway", function(v)
  megautils.add(oneway, v.x, v.y, v.width, v.height)
end)

function oneway:new(x, y, w, h)
  oneway.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.isSolid = 2
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addStatic()
  end
end
