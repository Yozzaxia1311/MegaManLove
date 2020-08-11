mmWeaponsMenu = basicEntity:extend()

mmWeaponsMenu.autoClean = false

function mmWeaponsMenu.resources()
  megautils.loadResource("assets/misc/weaponSelect.png", "weaponSelectBG")
  megautils.loadResource("assets/sfx/pause.ogg", "pause")
  megautils.loadResource("assets/sfx/selected.ogg", "selected")
  megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
end
  
function mmWeaponsMenu.pause(self)
  megautils.freeze(nil, "pause")
  megautils.add(fade, true, nil, nil, function(s)
      megautils.add(mmWeaponsMenu, megaMan.weaponHandler[self.player], self.healthHandler, self)
      local ff = megautils.add(fade, false, nil, nil, fade.remove)
      megautils.removeq(s)
    end)
  megautils.playSound("pause")
end

function mmWeaponsMenu:new(w, h, p)
  mmWeaponsMenu.super.new(self)
  self.bg = megautils.getResource("weaponSelectBG")
  self.tex = megautils.getResource("particles")
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.quadE = quad(72, 12, 16, 16)
  self.quadW = quad(88, 12, 16, 16)
  self.headQuad = quad(203, 398, 63, 62)
  self.w = w
  self.h = h
  self.player = p
  self.section = 0
  self.fills = {{}}
  self.list = {{0, -1},
			{1, 6},
			{2, 7},
			{3, 8},
			{4, 9},
			{5, 10}}
  for y=1, #self.list do
    for x=1, #self.list[y] do
      if self.w.currentSlot == self.list[y][x] then
        self.x = x
        self.y = y
        break
      end
    end
  end
  for y=1, #self.list do
    for x=1, #self.list[y] do
      if self.w.weapons[self.list[y][x]] then
        local h = healthHandler({124, 124, 124}, {188, 188, 188}, {0, 0, 0}, nil, "x", 8)
        if y == 1 and x == 1 then
          h.segments = self.h.segments
          h.health = self.h.health
        else
          h.segments = weapon.segments[self.w.weapons[self.list[y][x]]] or 7
          h.health = self.w.energy[self.list[y][x]]
        end
        h.side = -1
        h.transform.x = view.x+((x*80)-16)
        h.transform.y = view.y+(40+(y*16))
        h.icoX = (x*80)-32
        h.icoY = 32+(y*16)
        h.gridX = x
        h.gridY = y
        h.id = self.list[y][x]
        h:setLayer(10)
        if not self.fills[y] then
          self.fills[y] = {}
        end
        self.fills[y][x] = h
      end
    end
  end
  self.cur = self.w.currentSlot
  self.last = {self.w.currentSlot, megaMan.colorOutline[self.player.player], megaMan.colorOne[self.player.player], megaMan.colorTwo[self.player.player]}
  self.inactiveTankColor = {{0, 0, 0}, {188, 188, 188}, {255, 255, 255}}
  local trig = megautils.add(trigger, function(s, dt)
    for k, v in pairs(s.fills) do
      for i, j in pairs(v) do
        j:update(dt)
      end
    end
  end)
  trig.fills = self.fills
  trig:removeFromGroup("freezable")
  megaMan.colorOutline[self.player.player] = weapon.colors[self.w.weapons[self.list[self.y][self.x]]].outline
  megaMan.colorOne[self.player.player] = weapon.colors[self.w.weapons[self.list[self.y][self.x]]].one
  megaMan.colorTwo[self.player.player] = weapon.colors[self.w.weapons[self.list[self.y][self.x]]].two
  self:setLayer(10)
  if mmWeaponsMenu.main then
    megautils.removeq(mmWeaponsMenu.main)
  end
  mmWeaponsMenu.main = self
end

function mmWeaponsMenu:added()
  self:addToGroup("freezable")
end

function mmWeaponsMenu:removed()
  mmWeaponsMenu.main = nil
  megautils.unfreeze(nil, "pause")
  for k, v in pairs(self.fills) do
    for i, j in pairs(v) do
      if j.id ~= 0 then
        self.w:instantUpdate(j.health, j.id)
      else
        self.h:instantUpdate(j.health)
      end
    end 
  end
  self.player:switchWeaponSlot(self.cur)
  if self.cur == self.last[1] then
    megaMan.colorOutline[self.player.player] = self.last[2]
    megaMan.colorOne[self.player.player] = self.last[3]
    megaMan.colorTwo[self.player.player] = self.last[4]
  end
end

function mmWeaponsMenu:update(dt)
  if self.changing then
    if self.changing == "health" and self.fills[1][1].health == self.h.segments * 4 then
      self.changing = nil
    elseif self.changing == "weapons" then
      local res = true
      for k, v in pairs(self.fills) do
        for i, j in pairs(v) do
          if j.id ~= 0 and j.health ~= self.w.segments[j.id] * 4 then
            res = false
          end
        end
      end
      if res then self.changing = nil end
    end
    return
  end
  if self.section == 0 then
    local olx, oly = self.x, self.y
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j.colorOne = {124, 124, 124}
        j.colorTwo = {188, 188, 188}
      end
    end
    self.fills[self.y][self.x].colorOne = weapon.colors[self.w.weapons[self.list[self.y][self.x]]].one
    self.fills[self.y][self.x].colorTwo = weapon.colors[self.w.weapons[self.list[self.y][self.x]]].two
    if control.startPressed[self.player.player] then
      local ff = megautils.add(fade, true, nil, nil, function(s)
          megautils.removeq(self)
          megautils.removeq(s)
          megautils.add(fade, false, nil, nil, fade.remove)
        end)
      megautils.playSound("selected")
      return
    elseif control.rightPressed[self.player.player] then
      self.x = math.clamp(self.x+1, 1, 2)
      local ly = self.y
      while true do
        local highSteps = 0
        while not self.fills[self.y+highSteps] or not self.fills[self.y+highSteps][self.x] do
          highSteps = highSteps - 1
          if self.y+highSteps <= 0 then
            highSteps = -42
            break --Check failed
          end
        end
        local steps = 0
        while not self.fills[self.y+steps] or not self.fills[self.y+steps][self.x] do
          steps = steps + 1
          if self.y+steps >= 7 then
            steps = 42
            break -- Check failed
          end
        end
        if steps == 42 and highSteps == -42 then
          self.y = ly
          self.x = 1
          break --Both checks failed. Revert.
        else
          if steps ~= 42 then
            --Weapon selection below is closer
            self.y = self.y + steps
          else
            --Either weapon selection above is closer, or selection is directly next to us
            self.y = self.y + highSteps
          end
          break
        end
      end
      self.cur = self.fills[self.y][self.x].id
    elseif control.leftPressed[self.player.player] then
      self.x = math.clamp(self.x-1, 1, 2)
      local ly = self.y
      while true do
        local highSteps = 0
        while not self.fills[self.y+highSteps] or not self.fills[self.y+highSteps][self.x] do
          highSteps = highSteps - 1
          if self.y+highSteps <= 0 then
            highSteps = -42
            break --Check failed
          end
        end
        local steps = 0
        while not self.fills[self.y+steps] or not self.fills[self.y+steps][self.x] do
          steps = steps + 1
          if self.y+steps >= 7 then
            steps = 42
            break -- Check failed
          end
        end
        if steps == 42 and highSteps == -42 then
          self.y = ly
          self.x = 1
          break --Both checks failed. Revert.
        else
          if steps ~= 42 then
            --Weapon selection below is closer
            self.y = self.y + steps
          else
            --Either weapon selection above is closer, or selection is directly next to us
            self.y = self.y + highSteps
          end
          break
        end
      end
      self.cur = self.fills[self.y][self.x].id
    elseif control.upPressed[self.player.player] then
      while true do
        if (not self.fills[self.y] or not self.fills[self.y][self.x]) and self.y == 1 and self.x == 2 then
          self.x = 1
          break
        end
        self.y = math.clamp(self.y-1, 1, 6)
        if self.fills[self.y] and self.fills[self.y] and self.fills[self.y][self.x] then
          break
        end
      end
      self.cur = self.fills[self.y][self.x].id
    elseif control.downPressed[self.player.player] then
      while true do
        if self.y >= 6 then
          self.section = 1
          self.x = 1
          self.y = 1
          self.cur = self.last[1]
          megautils.playSound("cursorMove")
         return
        end
        self.y = math.clamp(self.y+1, 1, 6)
        if self.fills[self.y] and self.fills[self.y][self.x] then
          break
        end
      end
    end
    if olx ~= self.x or oly ~= self.y then
      self.cur = self.list[self.y][self.x]
      megautils.playSound("cursorMove")
    end
  elseif self.section == 1 then
    local olx, oly = self.x, self.y
    if control.startPressed[self.player.player] then
      if self.x == 1 and megautils.getETanks() > 0 then
        self.fills[1][1]:updateThis(self.h.segments * 4)
        self.changing = "health"
        megautils.setETanks(math.max(megautils.getETanks()-1, 0))
      elseif self.x == 2 and megautils.getWTanks() > 0 then
        local frz = false
        for k, v in pairs(self.fills) do
          for i, j in pairs(v) do
            if j.id ~= 0 then
              j:updateThis(self.w.segments[j.id] * 4)
            end
          end
        end
        self.changing = "weapons"
        megautils.setWTanks(math.max(megautils.getWTanks()-1, 0))
      end
    elseif control.upPressed[self.player.player] then
      self.section = 0
      self.x = 1
      self.y = #self.list
      while true do
        if self.fills[self.y] and self.fills[self.y][self.x] then
          break
        end
        self.y = self.y-1
      end
      self.cur = self.list[self.y][self.x]
      olx = -69
    end
    if self.x == 1 and control.rightPressed[self.player.player] then
      self.x = 2
    elseif self.x == 2 and control.leftPressed[self.player.player] then
      self.x = 1
    end
    if olx ~= self.x or oly ~= self.y then
      megautils.playSound("cursorMove")
    end
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j.colorOne = {124, 124, 124}
        j.colorTwo = {188, 188, 188}
      end
    end
  end
end

function mmWeaponsMenu:draw()
  love.graphics.setFont(mmFont)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.bg, view.x, view.y)
  love.graphics.print((megautils.hasInfiniteLives() and "inf" or tostring(megautils.getLives())), view.x+(24*8), view.y+(23*8))
  love.graphics.print(tostring(megautils.getETanks()), view.x+(8*8), view.y+(23*8))
  love.graphics.print(tostring(megautils.getWTanks()), view.x+(12*8), view.y+(23*8))
  
  local tx, ty = view.x+(8*21)+8, view.y+(22*8)+16
  local skin = megaMan.getSkin(self.player.player)

  love.graphics.setColor(1, 1, 1, 1)
  self.headQuad:draw(skin.texture, tx, ty, 0, 1, 1, 31, 37)
  love.graphics.setColor(megaMan.colorOutline[self.player.player][1]/255, megaMan.colorOutline[self.player.player][2]/255,
    megaMan.colorOutline[self.player.player][3]/255, 1)
  self.headQuad:draw(skin.outline, tx, ty, 0, 1, 1, 31, 37)
  love.graphics.setColor(megaMan.colorOne[self.player.player][1]/255, megaMan.colorOne[self.player.player][2]/255,
    megaMan.colorOne[self.player.player][3]/255, 1)
  self.headQuad:draw(skin.one, tx, ty, 0, 1, 1, 31, 37)
  love.graphics.setColor(megaMan.colorTwo[self.player.player][1]/255, megaMan.colorTwo[self.player.player][2]/255,
    megaMan.colorTwo[self.player.player][3]/255, 1)
  self.headQuad:draw(skin.two, tx, ty, 0, 1, 1, 31, 37)
  
  if self.section == 0 then
    local tx, ty, tx2 = view.x+(8*6), view.y+(22*8), view.x+(8*10)
    love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
    self.quadE:draw(self.texOutline, tx, ty)
    love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
    self.quadE:draw(self.texOne, tx, ty)
    love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
    self.quadE:draw(self.texTwo, tx, ty)
    
    love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
    self.quadW:draw(self.texOutline, tx2, ty)
    love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
    self.quadW:draw(self.texOne, tx2, ty)
    love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
    self.quadW:draw(self.texTwo, tx2, ty)
    
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        if self.x == j.gridX and self.y == j.gridY then
          weapon.drawIcon(self.w.weapons[j.id], true, view.x+(j.icoX), view.y+(j.icoY))
        else
          weapon.drawIcon(self.w.weapons[j.id], false, view.x+(j.icoX), view.y+(j.icoY))
        end
        love.graphics.print(self.w.weapons[j.id], view.x+(j.icoX+16), view.y+(j.icoY))
      end
    end
  else
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        weapon.drawIcon(self.w.weapons[j.id], false, view.x+(j.icoX), view.y+(j.icoY))
        love.graphics.print(self.w.weapons[j.id], view.x+(j.icoX+16), view.y+(j.icoY))
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    if self.x == 1 then
      local tx, ty, tx2 = view.x+(8*6), view.y+(22*8), view.x+(8*10)
      love.graphics.setColor(weapon.colors[self.w.weapons[self.cur]].outline[1]/255,
        weapon.colors[self.w.weapons[self.cur]].outline[2]/255, weapon.colors[self.w.weapons[self.cur]].outline[3]/255, 1)
      self.quadE:draw(self.texOutline, tx, ty)
      love.graphics.setColor(weapon.colors[self.w.weapons[self.cur]].one[1]/255,
        weapon.colors[self.w.weapons[self.cur]].one[2]/255, weapon.colors[self.w.weapons[self.cur]].one[3]/255, 1)
      self.quadE:draw(self.texOne, tx, ty)
      love.graphics.setColor(weapon.colors[self.w.weapons[self.cur]].two[1]/255,
        weapon.colors[self.w.weapons[self.cur]].two[2]/255, weapon.colors[self.w.weapons[self.cur]].two[3]/255, 1)
      self.quadE:draw(self.texTwo, tx, ty)
      
      love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
      self.quadW:draw(self.texOutline, tx2, ty)
      love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
      self.quadW:draw(self.texOne, tx2, ty)
      love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
      self.quadW:draw(self.texTwo, tx2, ty)
    elseif self.x == 2 then
      local tx, ty, tx2 = view.x+(8*6), view.y+(22*8), view.x+(8*10)
      love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
      self.quadE:draw(self.texOutline, tx, ty)
      love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
      self.quadE:draw(self.texOne, tx, ty)
      love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
      self.quadE:draw(self.texTwo, tx, ty)
      
      love.graphics.setColor(weapon.colors[self.w.weapons[self.cur]].outline[1]/255,
        weapon.colors[self.w.weapons[self.cur]].outline[2]/255, weapon.colors[self.w.weapons[self.cur]].outline[3]/255, 1)
      self.quadW:draw(self.texOutline, tx2, ty)
      love.graphics.setColor(weapon.colors[self.w.weapons[self.cur]].one[1]/255,
        weapon.colors[self.w.weapons[self.cur]].one[2]/255, weapon.colors[self.w.weapons[self.cur]].one[3]/255, 1)
      self.quadW:draw(self.texOne, tx2, ty)
      love.graphics.setColor(weapon.colors[self.w.weapons[self.cur]].two[1]/255,
        weapon.colors[self.w.weapons[self.cur]].two[2]/255, weapon.colors[self.w.weapons[self.cur]].two[3]/255, 1)
      self.quadW:draw(self.texTwo, tx2, ty)
    end
  end
end
