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
  local lvx, lvy = self.velocity.velx, self.velocity.vely
  local nslp = noSlope or collision.noSlope
  if checkFalse(self.blockCollision) then
    collision.generalCollision(self, nslp)
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  collision.checkGround(self, false, nslp)
  collision.entityPlatform(self)
  collision.checkGround(self, false, nslp)
  collision.checkDeath(self, lvx, lvy + (self.ground and math.sign(self.gravity) or 0))
end

function collision.getTable(self, dx, dy, noSlope)
  if self.collisionShape and megautils.groups().collision then
    local nslp = noSlope or collision.noSlope
    
    local xs = dx or 0
    local ys = dy or 0
    local solid = {}
    local ladders = collision.getLadders()
    local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
    local all = megautils.groups().collision
    
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and
        (v.solidType == collision.SOLID or v.solidType == collision.ONEWAY) and
        (v.solidType ~= collision.ONEWAY or ((ys == 0 and 1 or math.sign(ys)) == cgrav and
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
  if self.collisionShape and megautils.groups().collision then
    local nslp = noSlope or collision.noSlope
    
    local xs = dx or 0
    local ys = dy or 0
    local solid = {}
    local ladders = collision.getLadders()
    local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
    local all = megautils.groups().collision
    
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and
        (v.solidType == collision.SOLID or v.solidType == collision.ONEWAY) and
        (v.solidType ~= collision.ONEWAY or ((ys == 0 and 1 or math.sign(ys)) == cgrav and
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
  if self.transform.x ~= self.epX or self.transform.y ~= self.epY then
    local resolid = self.solidType
    local xypre
    local epCanCrush = true
    local myyspeed = self.transform.y - self.epY
    local myxspeed = self.transform.x - self.epX
    local all = megautils.groups().collision
    local ladders = collision.getLadders()
    local possible = resolid ~= 0 and self.collisionShape and all
    
    self.solidType = collision.NONE
    self.transform.x = self.epX
    self.transform.y = self.epY
    
    if possible and myyspeed ~= 0 then
      for i=1, #all do
        local v = all[i]
        if v ~= self and checkFalse(v.blockCollision) and v.collisionShape and
          (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
          (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
          local epDir = math.sign(self.transform.y + (self.collisionShape.h/2) -
            (v.transform.y + (v.collisionShape.h/2)))
          
          if v:collision(self, 0, -myyspeed) then
            collision.performDeath(v, self)
          end
          
          if not v:collision(self) then
            local epIsPassenger = v:collision(self, 0, (v.gravity >= 0 and 1 or -1) * ((v.ground and v.snapToMovingFloor) and 1 or 0))
            local epWillCollide = self:collision(v, 0, myyspeed)
            
            if epIsPassenger or epWillCollide then
              self.transform.y = self.transform.y + myyspeed
              
              xypre = v.transform.y
              
              if epIsPassenger then
                v.transform.y = v.transform.y + myyspeed
                collision.checkDeath(v, 0, math.sign(v.gravity))
              end
              
              if (resolid == collision.SOLID or (resolid == collision.ONEWAY and (epDir * (v.gravity >= 0 and 1 or -1))>0 and
                (not self.ladder or self:collisionNumber(ladders, 0, v.gravity < 0 and 1 or -1, true) == 0))) and
                v:collision(self) then
                local step = epDir * 0.5
                v.transform.y = math.round(v.transform.y) - step
                
                for _=1, 256 do
                  if v:collision(self) then
                    v.transform.y = v.transform.y - step
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
                  local crushing = self.crushing and self:crushing(v)
                  if v.crushed and (crushing == nil or crushing) then
                    v:crushed(self)
                  end
                end
              end
              
              if v.velocity.vely == 0 and epDir == (v.gravity >= 0 and 1 or -1) then
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
      
    if possible and myxspeed ~= 0 then
      for i=1, #all do
        local v = all[i]
        local continue = false
        if v ~= self and checkFalse(v.blockCollision) and v.collisionShape and
          (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
          (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
          
          if v:collision(self, -myxspeed, 0) then
            collision.performDeath(v, self)
          end
          
          if not v:collision(self) then
            local epIsOnPlat = false
            local epDir = math.sign((self.transform.x + (self.collisionShape.w / 2)) -
              (v.transform.x + (v.collisionShape.w / 2)))
            
            if v:collision(self, 0, (v.gravity >= 0 and 1 or -1) * (v.ground and 1 or 0)) and
              (not self.ladder or self:collisionNumber(ladders, 0, v.gravity < 0 and 1 or -1, true) == 0) then
              collision.shiftObject(v, myxspeed, 0, true)
              collision.checkDeath(v, 0, math.sign(v.gravity))
              epIsOnPlat = true
              v.onMovingFloor = self
            end
            
            if resolid == 1 then
              self.transform.x = self.transform.x + myxspeed
              
              if not epIsOnPlat and v:collision(self) then
                xypre = v.transform.x
                
                v.transform.x = math.round(v.transform.x + myxspeed + epDir)
                local step = epDir * 0.5
                
                for _=1, 256 do
                  if v:collision(self) then
                    v.transform.x = v.transform.x - step
                  else
                    break
                  end
                end
                
                xypre = xypre - v.transform.x
                v.transform.x = v.transform.x + xypre
                
                collision.shiftObject(v, -xypre, 0, true)
                
                if epCanCrush and v:collision(self) then
                  local crushing = self.crushing and self:crushing(v)
                  if v.crushed and (crushing == nil or crushing) then
                    v:crushed(self)
                  end
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
    
    self.solidType = resolid
    
    self.epX = self.transform.x
    self.epY = self.transform.y
  end
end

function collision.shiftObject(self, dx, dy, checkforcol, ep, noSlope)
  local xsub = self.velocity.velx
  local ysub = self.velocity.vely
  
  self.velocity.velx = dx
  self.velocity.vely = dy
  
  self.epX = self.transform.x
  self.epY = self.transform.y
  
  if checkforcol then
    self.canStandSolid.global = false
    collision.generalCollision(self, noSlope or collision.noSlope)
    self.canStandSolid.global = true
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  
  if ep == nil or ep then
    collision.entityPlatform(self)
  end
  
  self.velocity.velx = xsub
  self.velocity.vely = ysub
end

function collision.checkGround(self, checkAnyway, noSlope)
  local possible = self.collisionShape and checkFalse(self.blockCollision) and megautils.groups().collision
  
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
  local ladders = collision.getLadders()
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  local slp = (noSlope or collision.noSlope) and 1 or ((math.ceil(math.abs(self.velocity.velx)) * collision.maxSlope) + 2)
  local all = megautils.groups().collision
  
  if possible then
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) then
        if (v.solidType == collision.SOLID or v.solidType == collision.ONEWAY) and
          not v:collision(self, 0, cgrav) and (v.solidType ~= collision.ONEWAY or (v:collision(self, 0, -cgrav * slp) and
          (not v.ladder or v:collisionNumber(ladders, 0, -cgrav, true) == 0))) then
          solid[#solid + 1] = v
        elseif v.solidType == collision.STANDIN then
          solid[#solid + 1] = v
        end
      end
    end
  end
  
  if self:collisionNumber(solid) == 0 then
    if self.velocity.vely * cgrav < 0 then
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
            if v.solidType == collision.STANDIN then
              table.quickremovevaluearray(solid, v)
            end
          end
          
          if self:collisionNumber(solid, 0, yStep * cgrav) ~= 0 then
            self.transform.y = math.round(self.transform.y) + (yStep * cgrav)
            
            while self:collisionNumber(solid) ~= 0 do
              self.transform.y = self.transform.y - cgrav
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
  
  local xprev = self.transform.x
  local solid = {}
  local stand = {}
  local ladders = collision.getLadders()
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  local all = megautils.groups().collision
  local possible = self.collisionShape and checkFalse(self.blockCollision) and all
    
  if possible then
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and
        (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
        (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) then
        if v.solidType == collision.SOLID then
          if not v:collision(self) and not table.contains(solid, v) then
            solid[#solid+1] = v
          end
        elseif v.solidType == collision.STANDIN then
          stand[#stand+1] = v
        end
      end
    end
  end
  
  if self.velocity.velx ~= 0 then
    local slp = 0
    
    if possible then
      slp = math.ceil(math.abs(self.velocity.velx)) * collision.maxSlope
      if not nslp and slp ~= 0 then
        for i=1, #all do
          local v = all[i]
          if v ~= self and v.collisionShape and
            (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
            (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and
            not table.contains(solid, v) and v.solidType == collision.ONEWAY and
            v:collision(self, -self.velocity.velx, 0) and
            not v:collision(self, -self.velocity.velx, -cgrav * slp) and not v:collision(self) and
            (not v.ladder or v:collisionNumber(ladders, 0, -cgrav) == 0) then
            solid[#solid+1] = v
          end
        end
      end
    end
    
    self.transform.x = self.transform.x + self.velocity.velx
    
    if possible and self:collisionNumber(solid) ~= 0 then
      local s = -math.sign(self.velocity.velx)
      self.transform.x = math.round(self.transform.x - s)
      
      for _=1, 128 do
        if self:collisionNumber(solid) ~= 0 then
          self.transform.x = self.transform.x + s
        else
          break
        end
      end
      
      self.xColl = self.velocity.velx
      self.velocity.velx = 0
      
      if not nslp and self.xColl ~= 0 and slp ~= 0 then
        local xsl = self.xColl - (self.transform.x - xprev)
        if math.sign(self.xColl) == math.sign(xsl) then
          local yStep = 1
          local xStep = 0
          local dst = math.abs(xsl)
          local yTolerance = math.ceil(dst) * collision.maxSlope
          
          while xStep ~= dst do
            if self:collisionNumber(solid, xsl - xStep, -yStep) == 0 then
              self.transform.x = self.transform.x + xsl - xStep
              self.transform.y = self.transform.y - yStep
              if xStep == 0 then
                self.velocity.velx = self.xColl
                self.xColl = 0
              end
              break
            elseif self:collisionNumber(solid, xsl - xStep, yStep) == 0 then
              self.transform.x = self.transform.x + xsl - xStep
              self.transform.y = self.transform.y + yStep
              if xStep == 0 then
                self.velocity.velx = self.xColl
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
  
  if self.velocity.vely ~= 0 then
    if possible then
      if self.velocity.vely * cgrav > 0 then
        for i=1, #all do
          local v = all[i]
          if v ~= self and v.collisionShape and
          (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
          (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and v.solidType == collision.ONEWAY and
          (not v.ladder or v:collisionNumber(ladders, 0, -cgrav, true) == 0) then
            if not v:collision(self) then
              solid[#solid+1] = v
            else
              table.removevaluearray(solid, v)
            end
          end
        end
      end
    end
    
    self.transform.y = self.transform.y + self.velocity.vely
    
    if possible and self:collisionNumber(solid) ~= 0 then
      local s = -math.sign(self.velocity.vely)
      self.transform.y = math.round(self.transform.y - s)
      
      for _=1, 128 do
        if self:collisionNumber(solid) ~= 0 then
          self.transform.y = self.transform.y + s
        else
          break
        end
      end
      
      self.yColl = self.velocity.vely
      
      if self.velocity.vely * cgrav > 0 then
        self.ground = true
      end
      
      self.velocity.vely = 0
    end
  end
  
  if possible then
    if checkFalse(self.canStandSolid) then
      local ss = self:collisionTable(stand, 0, cgrav)
      if #ss ~= 0 then
        if self.velocity.vely * cgrav > 0 then
          self.ground = true
          self.yColl = self.velocity.vely
          self.velocity.vely = 0
        end
        self.inStandSolid = ss[1]
      end
    end
  end
end

function collision.checkDeath(self, x, y)
  local all = megautils.groups().collision
  local possible = self.iFrames == 0 and self.collisionShape and checkFalse(self.blockCollision) and all
  
  if possible then
    local death = {}
    
    for i=1, #all do
      local v = all[i]
      if v ~= self and v.collisionShape and v.death then
        death[#death+1] = v
      end
    end
    
    local lx, ly, lg, lxc, lyc, lsd, lmf = 
      self.transform.x, self.transform.y, self.ground, self.xColl, self.yColl, self.inStandSolid, self.onMovingFloor
    
    for i=1, #death do
      local v = death[i]
      v._LST = v.solidType
      v.solidType = collision.NONE
    end
    
    collision.shiftObject(self, x, y, true, false)
    
    for i=1, #death do
      local v = death[i]
      v.solidType = v._LST
      v._LST = nil
      if self:collision(v) then
        collision.performDeath(self, v)
      end
    end
    
    self.transform.x, self.transform.y, self.ground, self.xColl, self.yColl, self.inStandSolid, self.onMovingFloor =
      lx, ly, lg, lxc, lyc, lsd, lmf
  end
end

function collision.performDeath(self, death)
  if death.death then
    death:interact(self, death.damage or -99999, true)
  end
end

function collision.getLadders()
  local result = {}
  local all = megautils.groups().collision
  
  if all then
    for i=1, #all do
      local v = all[i]
      if v.ladder then
        result[#result+1] = v
      end
    end
  end
  
  return result
end