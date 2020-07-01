healthHandler = basicEntity:extend()

healthHandler.playerTimers = {}
for i=1, maxPlayerCount do
  healthHandler.playerTimers[i] = -2
end

function healthHandler:new(colorOne, colorTwo, colorOutline, side, r, segments, player)
  healthHandler.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.barOne = megautils.getResource("barOne")
  self.barTwo = megautils.getResource("barTwo")
  self.barOutline = megautils.getResource("barOutline")
  self.colorOne = colorOne
  self.colorTwo = colorTwo
  self.colorOutline = colorOutline
  self.quads = {}
  self.quads[0] = love.graphics.newQuad(0, 48, 8, 8, 232, 56)
  self.quads[1] = love.graphics.newQuad(8, 48, 8, 8, 232, 56)
  self.quads[2] = love.graphics.newQuad(8*2, 48, 8, 8, 232, 56)
  self.quads[3] = love.graphics.newQuad(8*3, 48, 8, 8, 232, 56)
  self.quads[4] = love.graphics.newQuad(8*4, 48, 8, 8, 232, 56)
  self.segments = segments or 1
  self.side = side or 1
  self.health = self.segments*4
  self.renderedHealth = self.health
  self.riseTimer = 4
  self.rot = r or "y"
  self.player = player
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
  self.health = math.clamp(self.health, 0, 4*self.segments)
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
  if self.player and self.player == globals.mainPlayer and checkFalse(self.player.canControl) and self.player.updated then
    for i=1, globals.playerCount do
      if healthHandler.playerTimers[i] > -1 then
        healthHandler.playerTimers[i] = math.max(healthHandler.playerTimers[i]-1, 0)
        if healthHandler.playerTimers[i] == 0 then
          healthHandler.playerTimers[i] = -1
        end
      elseif healthHandler.playerTimers[i] == -1 and control.startPressed[i] then
        if globals.lives > 0 then
          healthHandler.playerTimers[i] = -2
          local p = megautils.add(megaMan, self.player.transform.x, self.player.transform.y, self.player.side, true, i)
          self.player:transferState(p)
          megautils.revivePlayer(i)
          if camera.main then
            camera.main:updateFuncs()
          end
          if not globals.infiniteLives then
            globals.lives = globals.lives - 1
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
  if globals.mainPlayer then
    self.mp = globals.mainPlayer
  end
  if self.player and self.player == self.mp then
    if not globals.infiniteLives then
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", self.transform.x, self.transform.y, 8, 8)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.setFont(mmFont)
      love.graphics.print(tostring(globals.lives), self.transform.x, self.transform.y)
    end
    if self.mp == self.player then
      for i=1, globals.playerCount do
        if healthHandler.playerTimers[i] == -1 then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.rectangle("fill", self.transform.x, self.transform.y+(i*8), 32, 8)
          love.graphics.setColor(1, 1, 1, 1)
          if globals.lives <= 0 then
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
    love.graphics.draw(self.barOutline, self.quads[bit], tx, ty, tr)
    love.graphics.setColor(self.colorOne[1]/255, 
      self.colorOne[2]/255,
      self.colorOne[3]/255, 1)
    love.graphics.draw(self.barOne, self.quads[bit], tx, ty, tr)
    love.graphics.setColor(self.colorTwo[1]/255, 
      self.colorTwo[2]/255,
      self.colorTwo[3]/255, 1)
    love.graphics.draw(self.barTwo, self.quads[bit], tx, ty, tr)
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

weaponHandler.id = 0

function weaponHandler:new(side, r, slots)
  weaponHandler.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.current = "megaBuster"
  self.slotSize = slots
  self.currentSlot = 0
  self.weapons = {}
  self.energy = {}
  self.slots = {}
  self.barOne = megautils.getResource("barOne")
  self.barTwo = megautils.getResource("barTwo")
  self.barOutline = megautils.getResource("barOutline")
  self.quads = {}
  self.quads[0] = love.graphics.newQuad(0, 48, 8, 8, 232, 56)
  self.quads[1] = love.graphics.newQuad(8, 48, 8, 8, 232, 56)
  self.quads[2] = love.graphics.newQuad(8*2, 48, 8, 8, 232, 56)
  self.quads[3] = love.graphics.newQuad(8*3, 48, 8, 8, 232, 56)
  self.quads[4] = love.graphics.newQuad(8*4, 48, 8, 8, 232, 56)
  self.segments = {}
  self.renderedWE = {}
  self.colorOne = {}
  self.colorTwo = {}
  self.colorOutline = {}
  self.currentColorOne = {}
  self.currentColorTwo = {}
  self.pauseConf = {}
  self.riseTimer = 4
  self.side = side or 1
  self.rot = r or "y"
  self.id = tostring(weaponHandler.id)
  weaponHandler.id = weaponHandler.id + 1
end

function weaponHandler:reinit()
  self.current = self.weapons[0]
  self.curSegment = 0
  self.riseTimer = 4
  self.currentSlot = 0
end

function weaponHandler:register(slot, name, pn, colorone, colortwo, coloroutline, segments)
  self.weapons[slot] = name
  self.segments[slot] = segments or 7
  self.energy[slot] = self.segments[slot]*4
  self.renderedWE[slot] = self.energy[slot]
  self.slots[name] = slot
  self.colorOne[slot] = colorone
  self.colorTwo[slot] = colortwo
  self.colorOutline[slot] = coloroutline
  self.pauseConf[slot] = pn
  
  if weapons.resources[name] then
    weapons.resources[name]()
  end
end

function weaponHandler:removeWeaponShots()
  if weapons.removeGroups[self.current] then
    for _, i in ipairs(weapons.removeGroups[self.current]) do
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
  self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
  self.current = self.weapons[slot]
  self.currentSlot = self.slots[self.current]
  self.currentColorOne = self.colorOne[self.currentSlot]
  self.currentColorTwo = self.colorTwo[self.currentSlot]
  self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
end

function weaponHandler:switchName(name)
  if self.current ~= name then
    self:removeWeaponShots()
  end
  self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
  self.current = name
  self.currentSlot = self.slots[self.current]
  self.currentColorOne = self.colorOne[self.currentSlot]
  self.currentColorTwo = self.colorTwo[self.currentSlot]
  self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
end

function weaponHandler:currentWE()
  return self.energy[self.currentSlot]
end

function weaponHandler:updateCurrent(newWE)
  if newWE > self.energy[self.currentSlot] and self.energy[self.currentSlot] < 4*self.segments[self.currentSlot] then
    megautils.freeze({self}, "wb")
    self.energy[self.currentSlot] = math.min(newWE, 4*self.segments[self.currentSlot])
    self.riseTimer = 0
  elseif newWE < self.energy[self.currentSlot] then
    self.energy[self.currentSlot] = math.max(newWE, 0)
    self.renderedWE[self.currentSlot] = self.energy[self.currentSlot]
  end
end

function weaponHandler:instantUpdate(newWE, slot)
  self.energy[slot or self.currentSlot] = math.clamp(newWE, 0, 4*self.segments[slot or self.currentSlot])
  self.renderedWE[slot or self.currentSlot] = self.energy[slot or self.currentSlot]
end

function weaponHandler:update(dt)
  if self.energy[self.currentSlot] and self.segments[self.currentSlot] then
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

function weaponHandler:draw(x, y)
  love.graphics.setColor(1, 1, 1, 1)
  if (self.currentSlot == 0 and self.energy[self.currentSlot]) or not self.energy[self.currentSlot] or
    not self.segments[self.currentSlot] then return end
  local curSeg = math.ceil(self.renderedWE[self.currentSlot]/4)
  for i=1, self.segments[self.currentSlot] do
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
    love.graphics.draw(self.barOutline, self.quads[bit], tx, ty, tr)
    love.graphics.setColor(self.currentColorOne[1]/255, self.currentColorOne[2]/255, self.currentColorOne[3]/255, 1)
    love.graphics.draw(self.barOne, self.quads[bit], tx, ty, tr)
    love.graphics.setColor(self.currentColorTwo[1]/255, self.currentColorTwo[2]/255, self.currentColorTwo[3]/255, 1)
    love.graphics.draw(self.barTwo, self.quads[bit], tx, ty, tr)
  end
end

megautils.resetGameObjectsFuncs.barHandler = function()
    healthHandler.playerTimers = {}
    for i=1, maxPlayerCount do
      healthHandler.playerTimers[i] = -2
    end
    
    weaponHandler.id = 0
    
    megautils.loadResource("assets/players/bar/barOne.png", "barOne")
    megautils.loadResource("assets/players/bar/barTwo.png", "barTwo")
    megautils.loadResource("assets/players/bar/barOutline.png", "barOutline")
    megautils.loadResource("assets/sfx/error.ogg", "error")
  end