collision = {}

function collision.ser()
  return {
      noSlope=collision.noSlope,
      maxSlope=collision.maxSlope
    }
end

function collision.deser(t)
  collision.noSlope = t.noSlope
  collision.maxSlope = t.maxSlope
end

collision.NONE = 0
collision.SOLID = 1
collision.ONEWAY = 2
collision.STANDIN = 3

collision.noSlope = false
collision.maxSlope = 1

function collision.doGrav(self, noSlope) 
  collision.checkGround(self, false, noSlope or collision.noSlope)
  if not self.ground and self.grav then self:grav() end
end

function collision.doCollision(self, noSlope)
  local lvx, lvy, lx, ly, lg =
    self.velX, self.velY, self.x, self.y, self.ground
  local nslp = noSlope or collision.noSlope
  
  collision.checkGround(self, false, nslp)
  
  if checkFalse(self.blockCollision) then
    collision.generalCollision(self, nslp)
  else
    self.x = self.x + self.velX
    self.y = self.y + self.velY
  end
  
  collision.checkGround(self, false, nslp)
  collision.entityPlatform(self)
  collision.checkGround(self, false, nslp)
  
  collision.checkDeath(self, lvx - (self.x - lx), (lvy - (self.y - ly)) + (self.ground and math.sign(self.gravity) or 0), lg)
end

function collision.getTable(self, dx, dy, noSlope)
  if self.collisionShape then
    local nslp = noSlope or collision.noSlope
    
    local xs = dx or 0
    local ys = dy or 0
    local solid = {}
    local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
    local all = self:getSurroundingEntities(xs, ys)
    local ladders = collision.getLadders(all)
    
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.icontains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.icontains(v.excludeSolidFor, self)) and
        (v.solidType == 1 or v.solidType == 2) and
        (v.solidType ~= 2 or ((ys == 0 and 1 or math.sign(ys)) == cgrav and
        not v:collision(self, 0, cgrav) and v:collision(self, 0, -ys)) and
        (not v.ladder or v:collisionNumber(ladders, 0, -cgrav, true) == 0)) then
        solid[#solid+1] = v
      end
    end
    
    local ret = {}
    for i=1, #solid do
      if self:collision(solid[i], xs, ys) then
        ret[#ret+1] = solid[i]
      elseif not nslp and xs ~= 0 and ys == 0 then
        if self:collisionNumber(solid, xs, math.min(4, math.ceil(math.abs(xs)) * collision.maxSlope)) ~= 0 or
          self:collisionNumber(solid, xs, -math.max(-4, math.ceil(math.abs(xs)) * collision.maxSlope)) ~= 0 then
          ret[#ret+1] = solid[i]
        end
      end
    end
    return ret
  end
  return {}
end

function collision.checkSolid(self, dx, dy, noSlope)
  if self.collisionShape then
    local nslp = noSlope or collision.noSlope
    
    local xs = dx or 0
    local ys = dy or 0
    local solid = {}
    local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
    local all = self:getSurroundingEntities(xs, ys)
    local ladders = collision.getLadders(all)
    
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.icontains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.icontains(v.excludeSolidFor, self)) and
        (v.solidType == 1 or v.solidType == 2) and
        (v.solidType ~= 2 or ((ys == 0 and 1 or math.sign(ys)) == cgrav and
        not v:collision(self, 0, cgrav) and v:collision(self, 0, -ys)) and
        (not v.ladder or v:collisionNumber(ladders, 0, -cgrav, true) == 0)) then
        solid[#solid+1] = v
      end
    end
    
    local ret = true
    if self:collisionNumber(solid, xs, ys) == 0 then
      ret = false
    elseif not nslp and xs ~= 0 and ys == 0 then
      if self:collisionNumber(solid, xs, math.min(4, math.ceil(math.abs(xs)) * collision.maxSlope)) == 0 or
        self:collisionNumber(solid, xs, -math.max(-4, math.ceil(math.abs(xs)) * collision.maxSlope)) == 0 then
        ret = false
      end
    end
    return ret
  end
  return false
end

function collision.entityPlatform(self)
  if self.x ~= self._epX or self.y ~= self._epY then
    local resolid = self.solidType
    local xypre
    local epCanCrush = true
    local myyspeed = self.y - self._epY
    local myxspeed = self.x - self._epX
    
    local ladders = collision.getLadders(all)
    
    self.solidType = 0
    self.x = self._epX
    self.y = self._epY
    
    local all = self:getSurroundingEntities(myxspeed, myyspeed)
    local possible = resolid ~= 0 and self.collisionShape and #all > 1
    
    if possible and myyspeed ~= 0 then
      for i=1, #all do
        local v = all[i]
        if v ~= self and checkFalse(v.blockCollision) and v.collisionShape and
          (not self.exclusivelySolidFor or table.icontains(self.exclusivelySolidFor, v)) and
          (not self.excludeSolidFor or not table.icontains(self.excludeSolidFor, v)) then
          local epDir = math.sign(self.y + (self.collisionShape.h/2) -
            (v.y + (v.collisionShape.h/2)))
          
          if v:collision(self, 0, -myyspeed) then
            collision.performDeath(v, self)
          end
          
          if not v:collision(self) then
            local epIsPassenger = v:collision(self, 0, (v.gravity >= 0 and 1 or -1) * ((v.ground and v.snapToMovingFloor) and 1 or 0))
            local epWillCollide = self:collision(v, 0, myyspeed)
            
            if epIsPassenger or epWillCollide then
              self.y = self.y + myyspeed
              
              xypre = v.y
              
              if epIsPassenger then
                v.y = v.y + myyspeed
                collision.checkDeath(v, 0, math.sign(v.gravity))
              end
              
              if (resolid == 1 or (resolid == 2 and (epDir * (v.gravity >= 0 and 1 or -1))>0 and
                (not self.ladder or self:collisionNumber(ladders, 0, v.gravity < 0 and 1 or -1, true) == 0))) and
                v:collision(self) then
                local step = epDir * 0.5
                v.y = math.round(v.y) - step
                
                while v:collision(self) do
                  v.y = v.y - step
                end
              end
              
              xypre = xypre - v.y
              v.y = v.y + xypre
              
              collision.shiftObject(v, 0, -xypre, true)
              
              if resolid == 1 then
                if epCanCrush and v:collision(self) then
                  local crushing = self.crushing and self:crushing(v)
                  if v.crushed and (crushing == nil or crushing) then
                    if not self.invisibleToHash then self:updateHash() end
                    v:crushed(self)
                    if not v.invisibleToHash then v:updateHash() end
                  end
                end
              end
              
              if v.velY == 0 and epDir == (v.gravity >= 0 and 1 or -1) then
                v.ground = true
                v.onMovingFloor = self
              end
              
              self.y = self.y - myyspeed
            end
          end
        end
      end
    end
    
    self.y = self.y + myyspeed
      
    if possible and myxspeed ~= 0 then
      for i=1, #all do
        local v = all[i]
        local continue = false
        if v ~= self and checkFalse(v.blockCollision) and v.collisionShape and
          (not self.exclusivelySolidFor or table.icontains(self.exclusivelySolidFor, v)) and
          (not self.excludeSolidFor or not table.icontains(self.excludeSolidFor, v)) then
          
          if v:collision(self, -myxspeed, 0) then
            collision.performDeath(v, self)
          end
          
          if not v:collision(self) then
            local epIsOnPlat = false
            local epDir = math.sign((self.x + (self.collisionShape.w / 2)) -
              (v.x + (v.collisionShape.w / 2)))
            
            if v:collision(self, 0, (v.gravity >= 0 and 1 or -1) * (v.ground and 1 or 0)) and
              (not self.ladder or self:collisionNumber(ladders, 0, v.gravity < 0 and 1 or -1, true) == 0) then
              collision.shiftObject(v, myxspeed, 0, true)
              collision.checkDeath(v, 0, math.sign(v.gravity))
              epIsOnPlat = true
              v.onMovingFloor = self
            end
            
            if resolid == 1 then
              self.x = self.x + myxspeed
              
              if not epIsOnPlat and v:collision(self) then
                xypre = v.x
                
                v.x = math.round(v.x + myxspeed + epDir)
                local step = epDir * 0.5
                
                while v:collision(self) do
                  v.x = v.x - step
                end
                
                xypre = xypre - v.x
                v.x = v.x + xypre
                
                collision.shiftObject(v, -xypre, 0, true)
                
                if epCanCrush and v:collision(self) then
                  local crushing = self.crushing and self:crushing(v)
                  if v.crushed and (crushing == nil or crushing) then
                    if not self.invisibleToHash then self:updateHash() end
                    v:crushed(self)
                    if not v.invisibleToHash then v:updateHash() end
                  end
                end
              end
              
              self.x = self.x - myxspeed
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
    
    self.x = self.x + myxspeed
    
    self.solidType = resolid
    
    self._epX = self.x
    self._epY = self.y
  end
end

function collision.shiftObject(self, dx, dy, checkforcol, ep, noSlope)
  local xsub = self.velX
  local ysub = self.velY
  
  self.velX = dx
  self.velY = dy
  
  self._epX = self.x
  self._epY = self.y
  
  if checkforcol then
    self.canStandSolid.global = false
    collision.generalCollision(self, noSlope or collision.noSlope)
    self.canStandSolid.global = true
  else
    self.x = self.x + self.velX
    self.y = self.y + self.velY
  end
  
  if ep == nil or ep then
    collision.entityPlatform(self)
  end
  
  self.velX = xsub
  self.velY = ysub
end

function collision.checkGround(self, checkAnyway, noSlope)
  local possible = self.collisionShape and checkFalse(self.blockCollision)
  
  if not possible then
    self.ground = false
  end
  
  if not self.ground then
    self.onMovingFloor = nil
    self.inStandSolid = nil
    if not checkAnyway then
      return
    end
  end
  
  local solid = {}
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  local slp = (noSlope or collision.noSlope) and 1 or ((math.ceil(math.abs(self.velX)) * collision.maxSlope) + 2)
  local all = self:getSurroundingEntities(0, cgrav * slp)
  local ladders = collision.getLadders(all)
  
  if possible then
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.icontains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.icontains(v.excludeSolidFor, self)) then
        if (v.solidType == 1 or v.solidType == 2) and
          not v:collision(self, 0, cgrav) and ((v.solidType ~= 2) or (v:collision(self, 0, -cgrav * slp) and
          (not v.ladder or v:collisionNumber(ladders, 0, -cgrav, true) == 0))) then
          solid[#solid + 1] = v
        elseif v.solidType == 3 then
          solid[#solid + 1] = v
        end
      end
    end
  end
  
  if self:collisionNumber(solid) == 0 then
    if self.velY * cgrav < 0 then
      if self:collisionNumber(solid, 0, -cgrav) == 0 then
        self.ground = false
        self.onMovingFloor = nil
        self.inStandSolid = nil
      end
    else
      self.ground = false
      
      for yStep = 1, slp do
        if self:collisionNumber(solid, 0, yStep * cgrav) ~= 0 then
          for _, v in ipairs(solid) do
            if v.solidType == 3 then
              table.quickremovevaluearray(solid, v)
            end
          end
          
          if self:collisionNumber(solid, 0, yStep * cgrav) ~= 0 then
            self.y = math.round(self.y) + (yStep * cgrav)
            
            while self:collisionNumber(solid) ~= 0 do
              self.y = self.y - cgrav
            end
          end
          
          self.ground = true
          break
        end
      end
      
      if not self.ground then
        self.onMovingFloor = nil
        self.inStandSolid = nil
      end
    end
  end
end

function collision.generalCollision(self, noSlope)
  local nslp = noSlope or collision.noSlope
  
  self.xColl = 0
  self.yColl = 0
  
  local xprev = self.x
  local solid = {}
  local stand = {}
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  local slp = math.ceil(math.abs(self.velX)) * collision.maxSlope
  local all = (self.velX ~= 0 or self.velY ~= 0) and table.imerge({self:getSurroundingEntities(self.velX, self.velY),
    self:getSurroundingEntities(self.velX, -cgrav * slp)}, true, true) or {}
  local ladders = collision.getLadders(all)
  local possible = self.collisionShape and #all > 1 and (self.velX ~= 0 or self.velY ~= 0) and checkFalse(self.blockCollision)
    
  if possible then
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.icontains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.icontains(v.excludeSolidFor, self)) then
        if v.solidType == 1 then
          if not v:collision(self) and not table.icontains(solid, v) then
            solid[#solid+1] = v
          end
        elseif v.solidType == 3 then
          stand[#stand+1] = v
        end
      end
    end
  end
  
  if self.velY ~= 0 then
    if possible then
      if self.velY * cgrav > 0 then
        for i = 1, #all do
          local v = all[i]
          if v ~= self and v.collisionShape and
            (not v.exclusivelySolidFor or table.icontains(v.exclusivelySolidFor, self)) and
            (not v.excludeSolidFor or not table.icontains(v.excludeSolidFor, self)) and
            v.solidType == 2 and
            (not v:collision(self) or not v:collision(self, 0, cgrav * 0.01)) and -- Oneway safe-margin, for floating-point errors.
            (not v.ladder or v:collisionNumber(ladders, 0, -cgrav, true) == 0) then
            solid[#solid+1] = v
          end
        end
      end
    end
    
    self.y = self.y + self.velY
    
    if possible and self:collisionNumber(solid) ~= 0 then
      local s = math.sign(self.velY)
      self.y = math.round(self.y + s)
      
      while self:collisionNumber(solid) ~= 0 do
        self.y = self.y - s
      end
      
      self.yColl = self.velY
      
      if self.velY * cgrav > 0 then
        self.ground = true
      end
      
      self.velY = 0
    end
  end
  
  if self.velX ~= 0 then
    if possible then
      if not nslp and slp ~= 0 then
        for i=1, #all do
          local v = all[i]
          if v.solidType == 2 then
            if v ~= self and v.collisionShape and
              (not v.exclusivelySolidFor or table.icontains(v.exclusivelySolidFor, self)) and
              (not v.excludeSolidFor or not table.icontains(v.excludeSolidFor, self)) and
              v:collision(self, -self.velX, 0) and
              not v:collision(self, -self.velX, -cgrav * slp) and
              (not v:collision(self) or not v:collision(self, 0, cgrav * 0.01)) and -- Oneway safe-margin, for floating-point errors.
              (not v.ladder or v:collisionNumber(ladders, 0, -cgrav) == 0) then
              solid[#solid+1] = v
            else
              table.quickremovevaluearray(solid, v)
            end
          end
        end
      end
    end
    
    self.x = self.x + self.velX
    
    if possible and self:collisionNumber(solid) ~= 0 then
      local s = math.sign(self.velX)
      self.x = math.round(self.x + s)
      
      while self:collisionNumber(solid) ~= 0 do
        self.x = self.x - s
      end
      
      self.xColl = self.velX
      self.velX = 0
      
      if not nslp and self.xColl ~= 0 and slp ~= 0 then
        local xsl = self.xColl - (self.x - xprev)
        if math.sign(self.xColl) == math.sign(xsl) then
          local yStep = 1
          local xStep = 0
          local dst = math.abs(xsl)
          local yTolerance = math.ceil(dst) * collision.maxSlope
          
          while xStep ~= dst do
            if self:collisionNumber(solid, xsl - xStep, -yStep) == 0 then
              self.x = self.x + xsl - xStep
              self.y = self.y - yStep
              if xStep == 0 then
                self.velX = self.xColl
                self.xColl = 0
              end
              break
            elseif self:collisionNumber(solid, xsl - xStep, yStep) == 0 then
              self.x = self.x + xsl - xStep
              self.y = self.y + yStep
              if xStep == 0 then
                self.velX = self.xColl
                self.xColl = 0
              end
              break
            end
            if yStep > yTolerance then
              yStep = 1
              xStep = math.min(xStep + 1, dst)
              yTolerance = math.ceil(dst - xStep) * collision.maxSlope
            else
              yStep = yStep + 1
            end
          end
        end
      end
    end
  end
  
  if possible then
    if checkFalse(self.canStandSolid) then
      local ss = self:collisionTable(stand, 0, cgrav)
      if #ss ~= 0 then
        if self.velY * cgrav > 0 then
          self.ground = true
          self.yColl = self.velY
          self.velY = 0
        end
        self.inStandSolid = ss[1]
      end
    end
  end
end

function collision.checkDeath(self, x, y, dg)
  local all = self:getSurroundingEntities(x, y)
  local possible = self.collisionShape and checkFalse(self.blockCollision) and #all > 1
  
  if possible then
    local death = {}
    
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and v.death then
        death[#death+1] = v
      end
    end
    
    local deathSolid
    local lx, ly, lg, lxc, lyc, lss, lmf = 
      self.x, self.y, self.ground, self.xColl, self.yColl, self.inStandSolid, self.onMovingFloor
    
    for i=1, #death do
      local v = death[i]
      v._LSTDeathCheck = v.solidType
      v.solidType = 0
    end
    
    collision.shiftObject(self, x, y, true, false)
    
    for i=1, #death do
      local v = death[i]
      v.solidType = v._LSTDeathCheck
      v._LSTDeathCheck = nil
      
      if not deathSolid and self:collision(v) then
        deathSolid = v
      end
    end
    
    if deathSolid then
      self.x, self.y, self.ground, self.xColl, self.yColl, self.inStandSolid, self.onMovingFloor =
        lx, ly, lg, lxc, lyc, lss, lmf
      
      local ld = self.dead
      
      collision.performDeath(self, deathSolid)
      
      if not ld and self.dead and dg ~= nil then
        self.ground = dg
      end
    else
      self.x, self.y, self.ground, self.xColl, self.yColl, self.inStandSolid, self.onMovingFloor =
        lx, ly, lg, lxc, lyc, lss, lmf
    end
  end
end

function collision.performDeath(self, death)
  if death.death then
    death:interact(self, death.damage or -99999, true)
  end
end

function collision.getLadders(t)
  local result = {}
  local all = t or megautils.getAllEntities()
  
  for i=1, #all do
    local v = all[i]
    if v.ladder then
      result[#result+1] = v
    end
  end
  
  return result
end