collision = {}

collision.NONE = 0
collision.SOLID = 1
collision.ONEWAY = 2
collision.STANDIN = 3

collision.noSlope = false
collision.maxSlope = 1

function collision.doGrav(self, noSlope)
  noSlope = noSlope or collision.noSlope
  collision.checkGround(self, false, noSlope)
  if self.grav then self:grav() end
end

function collision.doCollision(self, noSlope)
  noSlope = noSlope or collision.noSlope
  if self.blockCollision then
    collision.generalCollision(self, noSlope)
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  collision.entityPlatform(self)
  collision.checkGround(self, false, noSlope)
end

function collision.getTable(self, dx, dy, noSlope)
  if self.collisionShape and megautils.groups().collision then
    noSlope = noSlope or collision.noSlope
    
    local xs = dx or 0
    local ys = dy or 0
    local solid = {}
    
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
        (not v.ladder or v:collisionNumber(megautils.groups().ladder, 0, -cgrav, true) == 0)) then
        solid[#solid+1] = v
      end
    end
    
    local ret = {}
    for i=1, #solid do
      if self:collision(solid[i], xs, ys) then
        ret[#ret+1] = solid[i]
      elseif not noSlope and xs ~= 0 and ys == 0 then
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
    noSlope = noSlope or collision.noSlope
    
    local xs = dx or 0
    local ys = dy or 0
    local solid = {}
    
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
        (not v.ladder or v:collisionNumber(megautils.groups().ladder, 0, -cgrav, true) == 0)) then
        solid[#solid+1] = v
      end
    end
    
    local ret = true
    if self:collisionNumber(solid, xs, ys) == 0 then
      ret = false
    elseif not noSlope and xs ~= 0 and ys == 0 then
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
    local possible = resolid ~= 0 and self.collisionShape and all ~= nil
    
    self.solidType = collision.NONE
    self.transform.x = self.epX
    self.transform.y = self.epY
    
    if possible and myyspeed ~= 0 then
      for i=1, #all do
        local v = all[i]
        if v ~= self and v.blockCollision and v.collisionShape and
          (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
          (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
          local epDir = math.sign(self.transform.y + (self.collisionShape.h/2) -
            (v.transform.y + (v.collisionShape.h/2)))
          
          if not v:collision(self) then
            local epIsPassenger = v:collision(self, 0, (v.gravity >= 0 and 1 or -1)*(v.ground and 1 or 0))
            local epWillCollide = self:collision(v, 0, myyspeed)
            
            if epIsPassenger or epWillCollide then
              self.transform.y = self.transform.y + myyspeed
              
              xypre = v.transform.y
              if epIsPassenger then
                v.transform.y = v.transform.y + myyspeed
              end
              
              if resolid == collision.SOLID or (resolid == collision.ONEWAY and (epDir*(v.gravity >= 0 and 1 or -1))>0 and
                (not self.ladder or self:collisionNumber(megautils.groups().ladder, 0, v.gravity < 0 and 1 or -1, true) == 0)) then
                if v:collision(self) then
                  v.transform.y = math.round(v.transform.y)
                  v.transform.y = v.transform.y - epDir
                end
                local rpts = math.max(32, math.abs(self.collisionShape.h)*2)
                for i=0, rpts do
                  if v:collision(self) then
                    v.transform.y = v.transform.y - epDir
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
                  if self.crushing then
                    self:crushing(v)
                  end
                  if v.crushed then
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
        if v ~= self and v.blockCollision and v.collisionShape and
          (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
          (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
          if not v:collision(self) then
            local epIsOnPlat = false
            local epDir = math.sign((self.transform.x + (self.collisionShape.w/2)) -
              (v.transform.x + (v.collisionShape.w/2)))
            
            if v:collision(self, 0, (v.gravity >= 0 and 1 or -1)*(v.ground and 1 or 0)) then
              collision.shiftObject(v, myxspeed, 0, true)
              epIsOnPlat = true
              v.onMovingFloor = self
            end
            
            if resolid == 1 then
              self.transform.x = self.transform.x + myxspeed
              
              if not epIsOnPlat and v:collision(self) then
                xypre = v.transform.x
                v.transform.x = math.round(v.transform.x)
                v.transform.x = v.transform.x + myxspeed + math.sign(epDir)
                local rpts = math.max(32, math.abs(self.collisionShape.w)*2)
                for i=0, rpts do
                  if v:collision(self) then
                    v.transform.x = v.transform.x - epDir
                  else
                    break
                  end
                end
                
                xypre = xypre - v.transform.x
                v.transform.x = v.transform.x + xypre
                
                collision.shiftObject(v, -xypre, 0, true)
                
                if epCanCrush and v:collision(self) then
                  if self.crushing then
                    self:crushing(v)
                  end
                  if v.crushed then
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
  noSlope = noSlope or collision.noSlope
  
  local xsub = self.velocity.velx
  local ysub = self.velocity.vely
  
  self.velocity.velx = dx
  self.velocity.vely = dy
  
  self.epX = self.transform.x
  self.epY = self.transform.y
  
  if checkforcol then
    self.canStandSolid.global = false
    collision.generalCollision(self, noSlope)
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
  if not self.blockCollision or not self.collisionShape or not megautils.groups().collision then
    self.ground = false
  end
  
  if not self.ground then
    self.onMovingFloor = nil
    self.inStandSolid = nil
    if not checkAnyway then
      return
    end
  end
  
  noSlope = noSlope or collision.noSlope
  
  local solid = {}
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  local slp = math.ceil(math.abs(self.velocity.velx)) + 1
  local all = megautils.groups().collision
  
  for i=1, #all do
    local v = all[i]
    if v ~= self and v.collisionShape and
      (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
      (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) then
      if (v.solidType == collision.SOLID or v.solidType == collision.ONEWAY) and
        not v:collision(self, 0, cgrav) and (v.solidType ~= collision.ONEWAY or (v:collision(self, 0, -cgrav * slp) and
        (not v.ladder or v:collisionNumber(megautils.groups().ladder, 0, -cgrav, true) == 0))) then
        solid[#solid+1] = v
      elseif v.solidType == collision.STANDIN then
        solid[#solid+1] = v
      end
    end
  end
  
  if self:collisionNumber(solid) == 0 then
    local i = cgrav
    while math.abs(i) <= slp do
      if self:collisionNumber(solid, 0, i + cgrav) == 0 then
        self.ground = false
        self.onMovingFloor = nil
        self.inStandSolid = nil
      elseif self.velocity.vely * cgrav >= 0 then
        self.ground = true
        self.transform.y = math.round(self.transform.y+cgrav) + (i - cgrav)
        local dec = 0
        while self:collisionNumber(solid) ~= 0 do
          self.transform.y = self.transform.y - cgrav
        end
        break
      end
      if noSlope then
        break
      end
      i = i + cgrav
    end
  end
end

function collision.generalCollision(self, noSlope)
  noSlope = noSlope or collision.noSlope
  
  self.xColl = 0
  self.yColl = 0
  
  local xprev = self.transform.x
  local solid = {}
  local stand = {}
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  local all = megautils.groups().collision
  local possible = self.collisionShape and self.blockCollision and all ~= nil
    
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
    if possible then
      local slp = math.ceil(math.abs(self.velocity.velx)) * collision.maxSlope * cgrav
      if not noSlope and slp ~= 0 then
        for i=1, #all do
          local v = all[i]
          if v ~= self and v.collisionShape and
            (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
            (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and
            not table.contains(solid, v) and v.solidType == collision.ONEWAY and
            v:collision(self, -self.velocity.velx, 0) and
            not v:collision(self, -self.velocity.velx, slp) and not v:collision(self) and
            (not v.ladder or v:collisionNumber(megautils.groups().ladder, 0, -cgrav) == 0) then
            solid[#solid+1] = v
          end
        end
      end
    end
      
    self.transform.x = self.transform.x + self.velocity.velx
    
    if possible and self:collisionNumber(solid) ~= 0 then
      self.xColl = -math.sign(self.velocity.velx)
      self.transform.x = math.round(self.transform.x-self.xColl)
      
      for ii=0, math.max(32, math.abs(self.velocity.velx) * 4) do
        if self:collisionNumber(solid) ~= 0 then
          self.transform.x = self.transform.x + self.xColl
        else
          break
        end
      end
      
      self.xColl = self.velocity.velx
      self.velocity.velx = 0
      
      if not noSlope and self.xColl ~= 0 and slp ~= 0 then
        local xsl = self.xColl - (self.transform.x - xprev)
        if math.sign(self.xColl) == math.sign(xsl) then
          local iii=1
          while iii <= math.ceil(math.abs(xsl)) * collision.maxSlope do
            if self:collisionNumber(solid, xsl, -iii) == 0 then
              self.transform.x = self.transform.x + xsl
              self.transform.y = self.transform.y - iii
              self.velocity.velx = self.xColl
              self.xColl = 0
              break
            elseif self:collisionNumber(solid, xsl, iii) == 0 then
              self.transform.x = self.transform.x + xsl
              self.transform.y = self.transform.y + iii
              self.velocity.velx = self.xColl
              self.xColl = 0
              break
            end
            iii = iii + 1
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
          (not v.ladder or v:collisionNumber(megautils.groups().ladder, 0, -cgrav, true) == 0) then
            table.removevaluearray(solid, v)
            if not v:collision(self) then
              solid[#solid+1] = v
            end
          end
        end
      end
    end
    
    self.transform.y = self.transform.y + self.velocity.vely
    
    if possible and self:collisionNumber(solid) ~= 0 then
      self.yColl = -math.sign(self.velocity.vely)
      self.transform.y = math.round(self.transform.y-self.yColl)
      
      for i=0, math.max(32, math.abs(self.velocity.vely) * 4) do
        if self:collisionNumber(solid) ~= 0 then
          self.transform.y = self.transform.y + self.yColl
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
  
  if possible and checkFalse(self.canStandSolid) then
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