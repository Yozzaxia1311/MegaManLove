weaponhandler = basicEntity:extend()

weaponhandler.removeGroups = {}
weaponhandler.id = 0

function weaponhandler:new(side, r, slots)
  weaponhandler.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.current = "megaBuster"
  self.slotSize = slots
  self.currentSlot = 0
  self.weapons = {}
  self.energy = {}
  self.slots = {}
  self.barOne = loader.get("bar_one")
  self.barTwo = loader.get("bar_two")
  self.barOutline = loader.get("bar_outline")
  self.quads = {}
  self.quads[0] = love.graphics.newQuad(0, 48, 8, 8, 232, 56)
  self.quads[1] = love.graphics.newQuad(8, 48, 8, 8, 232, 56)
  self.quads[2] = love.graphics.newQuad(8*2, 48, 8, 8, 232, 56)
  self.quads[3] = love.graphics.newQuad(8*3, 48, 8, 8, 232, 56)
  self.quads[4] = love.graphics.newQuad(8*4, 48, 8, 8, 232, 56)
  self.segments = {}
  self.colorOne = {}
  self.colorTwo = {}
  self.colorOutline = {}
  self.currentColorOne = {}
  self.currentColorTwo = {}
  self.pauseConf = {}
  self.riseTimer = 4
  self.rise = 0
  self.change = 0
  self.side = side or 1
  self.rot = r or "y"
  self.onceA = false
  self.me = {self}
  self.id = tostring(weaponhandler.id)
  weaponhandler.id = weaponhandler.id + 1
end

function weaponhandler:reinit()
  self.current = self.weapons[0]
  self.curSegment = 0
  self.riseTimer = 4
  self.rise = 0
  self.change = 0
  self.currentSlot = 0
end

function weaponhandler:register(slot, name, pn, colorone, colortwo, coloroutline, segments)
  self.weapons[slot] = name
  self.segments[slot] = segments or 7
  self.energy[slot] = self.segments[slot]*4
  self.slots[name] = slot
  self.colorOne[slot] = colorone
  self.colorTwo[slot] = colortwo
  self.colorOutline[slot] = coloroutline
  self.pauseConf[slot] = pn
end

function weaponhandler:removeWeaponShots()
  if weaponhandler.removeGroups[self.current] then
    for _, i in ipairs(weaponhandler.removeGroups[self.current]) do
      if megautils.groups()[i .. self.id] then
        for _, v in ipairs(megautils.groups()[i .. self.id]) do
          megautils.remove(v, true)
        end
      end
    end
  end
end

function weaponhandler:switch(slot)
  if self.currentSlot ~= slot then
    self:removeWeaponShots()
  end
  self.current = self.weapons[slot]
  self.currentSlot = self.slots[self.current]
  self.currentColorOne = self.colorOne[self.currentSlot]
  self.currentColorTwo = self.colorTwo[self.currentSlot]
end

function weaponhandler:switchName(name)
  if self.current ~= name then
    self:removeWeaponShots()
  end
  self.current = name
  self.currentSlot = self.slots[self.current]
  self.currentColorOne = self.colorOne[self.currentSlot]
  self.currentColorTwo = self.colorTwo[self.currentSlot]
end

function weaponhandler:updateThis()
  if self.change > 0 then
    if self.energy[self.currentSlot] ~= self.segments[self.currentSlot]*4 then
      megautils.freeze(self.me)
      self.rise = self.change
      self.riseTimer = 0
    end
  elseif self.change < 0 then
    self.energy[self.currentSlot] = self.energy[self.currentSlot] + self.change
  end
  self.change = 0
end

function weaponhandler:update(dt)
  self.riseTimer = math.min(self.riseTimer+1, 4)
  if self.rise > 0 and self.riseTimer == 4 then
    megautils.freeze(self.me)
    self.change = 0
    self.energy[self.currentSlot] = self.energy[self.currentSlot] + 1
    self.riseTimer = 0
    self.rise = self.rise - 1
    mmSfx.play("heal")
    if self.rise == 0 or self.energy[self.currentSlot] == self.segments[self.currentSlot]*4 
      or self.energy[self.currentSlot] == 0 then
      megautils.unfreeze({self})
      self.rise = 0
      mmSfx.stop("heal")
    end
  end
  if self.energy[self.currentSlot] and self.segments[self.currentSlot] then
    self.energy[self.currentSlot] = math.clamp(self.energy[self.currentSlot], 0, self.segments[self.currentSlot]*4)
  end
end

function weaponhandler:draw(x, y)
  love.graphics.setColor(1, 1, 1, 1)
  if self.currentSlot == 0 and self.energy[self.currentSlot] then return end
  local curSeg = math.ceil(self.energy[self.currentSlot]/4)
  for i=1, self.segments[self.currentSlot] do
    local bit = 0
    if i == curSeg then
      bit = 4 + (math.round(self.energy[self.currentSlot])-(i*4))
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