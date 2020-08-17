megautils.loadResource("assets/misc/barOne.png", "barOne", false, true)
megautils.loadResource("assets/misc/barTwo.png", "barTwo", false, true)
megautils.loadResource("assets/misc/barOutline.png", "barOutline", false, true)
megautils.loadResource("assets/sfx/error.ogg", "error", true)

healthHandler = basicEntity:extend()

healthHandler.autoClean = false

healthHandler.playerTimers = {}
for i=1, maxPlayerCount do
  healthHandler.playerTimers[i] = -2
end

megautils.resetGameObjectsFuncs.barHandler = {func=function()
    healthHandler.playerTimers = {}
    for i=1, maxPlayerCount do
      healthHandler.playerTimers[i] = -2
    end
    
    weaponHandler.id = 0
  end, autoClean=false}

function healthHandler:new(colorOne, colorTwo, colorOutline, side, r, segments, player)
  healthHandler.super.new(self)
  self.barOne = megautils.getResource("barOne")
  self.barTwo = megautils.getResource("barTwo")
  self.barOutline = megautils.getResource("barOutline")
  self.colorOne = colorOne
  self.colorTwo = colorTwo
  self.colorOutline = colorOutline
  self.quads = {}
  self.quads[0] = quad(0, 48, 8, 8)
  self.quads[1] = quad(8, 48, 8, 8)
  self.quads[2] = quad(8*2, 48, 8, 8)
  self.quads[3] = quad(8*3, 48, 8, 8)
  self.quads[4] = quad(8*4, 48, 8, 8)
  self.segments = segments or 1
  self.side = side or 1
  self.health = self.segments*4
  self.renderedHealth = self.health
  self.riseTimer = 4
  self.rot = r or "y"
  self.player = player
end

function healthHandler:added()
  self:addToGroup("freezable")
end

function healthHandler:updateThis(newHealth)
  if newHealth > self.health and self.health < 4*self.segments then
    megautils.freeze({self}, "hb")
    self.health = math.min(newHealth, 4*self.segments)
    self.riseTimer = 0
  elseif newHealth < self.health then
    self.health = math.max(newHealth, 0)
    self.renderedHealth = self.health
  end
end

function healthHandler:instantUpdate(newHealth)
  self.health = math.clamp(newHealth, 0, 4*self.segments)
  self.renderedHealth = self.health
end

function healthHandler:update(dt)
  if self.renderedHealth < self.health then
    self.riseTimer = math.min(self.riseTimer+1, 4)
    if self.riseTimer == 4 then
      self.riseTimer = 0
      self.renderedHealth = math.approach(self.renderedHealth, self.health, 1)
      megautils.playSound("heal")
      if self.renderedHealth == self.health then
        megautils.unfreeze({self}, "hb")
        self.rise = 0
        megautils.stopSound("heal")
      end
    end
  end
  if self.player and self.player == megaMan.mainPlayer and
    checkFalse(self.player.canControl) and checkFalse(self.player.canUpdate) then
    for i=1, globals.playerCount do
      if healthHandler.playerTimers[i] > -1 then
        healthHandler.playerTimers[i] = math.max(healthHandler.playerTimers[i]-1, 0)
        if healthHandler.playerTimers[i] == 0 then
          healthHandler.playerTimers[i] = -1
        end
      elseif healthHandler.playerTimers[i] == -1 and control.startPressed[i] then
        if megautils.getLives() > 0 then
          healthHandler.playerTimers[i] = -2
          local p = megautils.add(megaMan, self.player.transform.x, self.player.transform.y, self.player.side, true, i)
          self.player:transferState(p)
          megautils.revivePlayer(i)
          if camera.main then
            camera.main:updateFuncs()
          end
          if not megautils.hasInfiniteLives() then
            megautils.setLives(math.max(megautils.getLives()-1, -1))
          end
          self.t2 = nil
          self.tween = nil
          megautils.playSoundFromFile("assets/sfx/selected.ogg")
        else
          megautils.playSound("error")
        end
      end
    end
  end
end

function healthHandler:removed()
  megautils.unfreeze(nil, "hb")
end

function healthHandler:draw()
  self.health = math.clamp(self.health, 0, 4*self.segments)
  self.renderedHealth = math.clamp(self.renderedHealth, 0, 4*self.segments)
  if megaMan.mainPlayer then
    self.mp = megaMan.mainPlayer
  end
  if self.player and self.player == self.mp then
    if not megautils.hasInfiniteLives() then
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", self.transform.x, self.transform.y, 8, 8)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.setFont(mmFont)
      love.graphics.print(tostring(megautils.getLives()), self.transform.x, self.transform.y)
    end
    if self.mp == self.player then
      for i=1, globals.playerCount do
        if healthHandler.playerTimers[i] == -1 then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.rectangle("fill", self.transform.x, self.transform.y+(i*8), 32, 8)
          love.graphics.setColor(1, 1, 1, 1)
          if megautils.getLives() <= 0 then
            love.graphics.print("p" .. tostring(i) .. " x", self.transform.x, self.transform.y+(i*8))
          else
            love.graphics.print("p" .. tostring(i) .. " `", self.transform.x, self.transform.y+(i*8))
          end
        elseif healthHandler.playerTimers[i] > -1 then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.rectangle("fill", self.transform.x, self.transform.y+(i*8), 32, 8)
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.print("p" .. tostring(i) .. " " ..
            tostring(math.abs(math.ceil(healthHandler.playerTimers[i]/20))), self.transform.x, self.transform.y+(i*8))
        end
      end
    end
  else
    love.graphics.setColor(1, 1, 1, 1)
  end
  local curSeg = math.ceil(self.renderedHealth/4)
  for i=1, self.segments do
    local bit = 0
    if i == curSeg then
      bit = 4 + (math.round(self.renderedHealth)-(i*4))
    elseif i > curSeg then
      bit = 0
    elseif i < curSeg then
      bit = 4
    end
    local tx, ty, tr = self.transform.x-(self.rot=="x" and (8*i)*self.side or 0), 
      self.transform.y-(self.rot=="y" and (8*i)*self.side or 0), math.rad(self.rot=="x" and 90 or 0)
    love.graphics.setColor(self.colorOutline[1]/255, 
      self.colorOutline[2]/255,
      self.colorOutline[3]/255, 1)
    self.quads[bit]:draw(self.barOutline, tx, ty, tr)
    love.graphics.setColor(self.colorOne[1]/255, 
      self.colorOne[2]/255,
      self.colorOne[3]/255, 1)
    self.quads[bit]:draw(self.barOne, tx, ty, tr)
    love.graphics.setColor(self.colorTwo[1]/255, 
      self.colorTwo[2]/255,
      self.colorTwo[3]/255, 1)
    self.quads[bit]:draw(self.barTwo, tx, ty, tr)
  end
  if self.player and globals.playerCount > 1 then
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.transform.x, self.transform.y-(self.segments*8)-8, 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(mmFont)
    love.graphics.print(tostring(self.player.player), self.transform.x, self.transform.y-(self.segments*8)-8)
  end
end

weaponHandler = basicEntity:extend()

weaponHandler.autoClean = false

function weaponHandler.ser()
  return weaponHandler.id
end

function weaponHandler.deser(t)
  weaponHandler.id = t
end

binser.register(weaponHandler, "weaponHandler", function(o)
    local result = basicEntity.transfer(o, result)
    
    result.slotSize = o.slotSize
    result.currentSlot = o.currentSlot
    result.weapons = table.clone(o.weapons)
    result.energy = table.clone(o.energy)
    result.slots = table.clone(o.slots)
    result.renderedWE = table.clone(o.renderedWE)
    result.riseTimer = o.riseTimer
    result.side = o.side
    result.rot = o.rot
    
    return result
  end, function(o)
    local result = weaponHandler()
    
    basicEntity.transfer(o, result)
    
    result.slotSize = o.slotSize
    result.currentSlot = o.currentSlot
    result.weapons = o.weapons
    result.energy = o.energy
    result.slots = o.slots
    result.renderedWE = o.renderedWE
    result.riseTimer = o.riseTimer
    result.side = o.side
    result.rot = o.rot
    
    return result
  end)

weaponHandler.id = 0

function weaponHandler:new(side, r, slots)
  weaponHandler.super.new(self)
  self.slotSize = slots
  self.currentSlot = 0
  self.weapons = {}
  self.energy = {}
  self.slots = {}
  self.iconTex = megautils.getResource("weaponSelect")
  self.barOne = megautils.getResource("barOne")
  self.barTwo = megautils.getResource("barTwo")
  self.barOutline = megautils.getResource("barOutline")
  self.quads = {}
  self.quads[0] = quad(0, 48, 8, 8)
  self.quads[1] = quad(8, 48, 8, 8)
  self.quads[2] = quad(8*2, 48, 8, 8)
  self.quads[3] = quad(8*3, 48, 8, 8)
  self.quads[4] = quad(8*4, 48, 8, 8)
  self.renderedWE = {}
  self.riseTimer = 4
  self.side = side or 1
  self.rot = r or "y"
  self.id = tostring(weaponHandler.id)
  weaponHandler.id = weaponHandler.id + 1
end

function weaponHandler:added()
  self:addToGroup("freezable")
end

function weaponHandler:reinit()
  self.riseTimer = 4
  self:switch(0)
end

function weaponHandler:register(slot, name, noRefill)
  self.weapons[slot] = name
  if not noRefill or not self.energy[slot] then
    self.energy[slot] = 4*(weapon.segments[slot] or 7)
  end
  self.energy[slot] = math.clamp(self.energy[slot], 0, 4*(weapon.segments[slot] or 7))
  self.renderedWE[slot] = self.energy[slot]
  self.slots[name] = slot
  
  if not self.current then
    self.current = name
  end
  
  if weapon.resources[name] then
    weapon.resources[name]()
  end
end

function weaponHandler:unregister(slot)
  self.weapons[slot] = nil
  self.energy[slot] = nil
  self.renderedWE[slot] = nil
  if self.weapons[slot] then
    self.slots[self.weapons[slot]] = nil
  end
  
  if slot == self.currentSlot then
    self:switch(0)
  end
end

function weaponHandler:removeWeaponShots()
  if weapon.removeGroups[self.current] then
    for _, i in ipairs(weapon.removeGroups[self.current]) do
      if megautils.groups()[i .. self.id] then
        for _, v in ipairs(megautils.groups()[i .. self.id]) do
          megautils.removeq(v)
        end
      end
    end
  end
end

function weaponHandler:switch(slot)
  if self.currentSlot ~= slot then
    self:removeWeaponShots()
  end
  self.current = self.weapons[slot]
  if self.current then
    self.currentSlot = self.slots[self.current]
    self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
  end
end

function weaponHandler:switchName(name)
  self:switch(self.slots[name])
end

function weaponHandler:currentWE()
  return self.energy[self.currentSlot]
end

function weaponHandler:updateCurrent(newWE)
  if self.current then
    if newWE > self.energy[self.currentSlot] and self.energy[self.currentSlot] < 4*self.segments[self.currentSlot] then
      megautils.freeze({self}, "wb")
      self.energy[self.currentSlot] = math.min(newWE, 4*(weapon.segments[self.current] or 7))
      self.riseTimer = 0
    elseif newWE < self.energy[self.currentSlot] then
      self.energy[self.currentSlot] = math.max(newWE, 0)
      self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
    end
  end
end

function weaponHandler:instantUpdate(newWE, slot)
  if self.current then
    self.energy[slot or self.currentSlot] = math.clamp(newWE, 0, 4*(weapon.segments[self.weapons[slot] or self.current] or 7))
    self.renderedWE[slot or self.currentSlot] = self.energy[slot or self.currentSlot]
  end
end

function weaponHandler:update(dt)
  if self.current and self.energy[self.currentSlot] and weapon.segments[self.current] then
    self.energy[self.currentSlot] = math.clamp(self.energy[self.currentSlot], 0, self.segments[self.currentSlot]*4)
    if self.renderedWE[self.currentSlot] < self.energy[self.currentSlot] then
      self.riseTimer = math.min(self.riseTimer+1, 4)
      if self.riseTimer == 4 then
        self.renderedWE[self.currentSlot] = math.approach(self.renderedWE[self.currentSlot], self.energy[self.currentSlot], 1)
        self.riseTimer = 0
        megautils.playSound("heal")
        if self.renderedWE[self.currentSlot] == self.energy[self.currentSlot] then
          megautils.unfreeze({self}, "wb")
          megautils.stopSound("heal")
        end
      end
    end
  end
end

function weaponHandler:removed()
  megautils.unfreeze(nil, "wb")
end

function weaponHandler:draw()
  if not self.current or (self.currentSlot == 0 and self.energy[self.currentSlot]) or not self.energy[self.currentSlot] then return end
  local curSeg = math.ceil(self.renderedWE[self.currentSlot]/4)
  self.energy[self.currentSlot] = math.clamp(self.energy[self.currentSlot], 0, 4*(weapon.segments[self.current] or 7))
  self.renderedWE[self.currentSlot] = math.clamp(self.renderedWE[self.currentSlot], 0, 4*(weapon.segments[self.current] or 7))
  for i=1, weapon.segments[self.current] or 7 do
    local bit = 0
    if i == curSeg then
      bit = 4 + (math.round(self.renderedWE[self.currentSlot])-(i*4))
    elseif i > curSeg then
      bit = 0
    elseif i < curSeg then
      bit = 4
    end
    love.graphics.setColor(0, 0, 0, 1)
    local tx, ty, tr = self.transform.x-(self.rot=="x" and (8*i)*self.side or 0), 
      self.transform.y-(self.rot=="y" and (8*i)*self.side or 0), math.rad(self.rot=="x" and 90 or 0)
    self.quads[bit]:draw(self.barOutline, tx, ty, tr)
    love.graphics.setColor(weapon.colors[self.current].one[1]/255, weapon.colors[self.current].one[2]/255,
      weapon.colors[self.current].one[3]/255, 1)
    self.quads[bit]:draw(self.barOne, tx, ty, tr)
    love.graphics.setColor(weapon.colors[self.current].two[1]/255, weapon.colors[self.current].two[2]/255,
      weapon.colors[self.current].two[3]/255, 1)
    self.quads[bit]:draw(self.barTwo, tx, ty, tr)
  end
end