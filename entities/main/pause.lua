weaponSelect = basicEntity:extend()

function weaponSelect:new(w, h, p)
  weaponSelect.super.new(self)
  self.t = megautils.getResource("weaponSelect")
  self.bg = megautils.getResource("weaponSelectImg")
  self.tex = megautils.getResource("particles")
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.quadE = love.graphics.newQuad(72, 12, 16, 16, 128, 98)
  self.quadW = love.graphics.newQuad(88, 12, 16, 16, 128, 98)
  self.heads = {}
  self.heads.mega = love.graphics.newQuad(104, 12, 16, 16, 128, 98)
  self.heads.proto = love.graphics.newQuad(56, 31, 16, 15, 128, 98)
  self.heads.bass = love.graphics.newQuad(54, 16, 18, 15, 128, 98)
  self.heads.roll = love.graphics.newQuad(38, 16, 16, 16, 128, 98)
  self.w = w
  self.h = h
  self.player = p
  self.section = 0
  self.active = {}
  self.inactive = {}
  self.text = {}
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
          h.segments = self.w.segments[self.list[y][x]]
          h.health = self.w.energy[self.list[y][x]]
        end
        h.side = -1
        --h:removeFromGroup("freezable")
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
        self:addIcon(self.list[y][x])
      end
    end
  end
  self.cur = self.w.currentSlot
  self.activeTankColor = {self.w.colorOne[0], self.w.colorTwo[0], self.w.colorOutline[0]}
  self.inactiveTankColor = {{188, 188, 188}, {255, 255, 255}, {0, 0, 0}}
  local trig = megautils.add(trigger, function(s, dt)
    for k, v in pairs(s.fills) do
      for i, j in pairs(v) do
        j:update(dt)
      end
    end
  end)
  trig.fills = self.fills
  trig:removeFromGroup("freezable")
  megaman.colorOutline[self.player] = self.w.colorOutline[self.list[self.y][self.x]]
  megaman.colorOne[self.player] = self.w.colorOne[self.list[self.y][self.x]]
  megaman.colorTwo[self.player] = self.w.colorTwo[self.list[self.y][self.x]]
  self:setLayer(10)
  self.added = function(self)
    self:addToGroup("freezable")
  end
end

function weaponSelect:addIcon(id)
  self.active[id] = love.graphics.newQuad(self.w.pauseConf[id][2][1], self.w.pauseConf[id][2][2],
    self.w.pauseConf[id][2][3], self.w.pauseConf[id][2][4], 240, 48)
  self.inactive[id] = love.graphics.newQuad(self.w.pauseConf[id][3][1], self.w.pauseConf[id][3][2],
    self.w.pauseConf[id][3][3], self.w.pauseConf[id][3][4], 240, 48)
  self.text[id] = self.w.pauseConf[id][1]
end

function weaponSelect:update(dt)
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
    self.fills[self.y][self.x].colorOne = self.w.colorOne[self.list[self.y][self.x]]
    self.fills[self.y][self.x].colorTwo = self.w.colorTwo[self.list[self.y][self.x]]
    if control.startPressed[self.player] then
      self.updated = false
      self.w:switch(self.list[self.y][self.x])
      megaman.colorOutline[self.player] = self.w.colorOutline[self.list[self.y][self.x]]
      megaman.colorOne[self.player] = self.w.colorOne[self.list[self.y][self.x]]
      megaman.colorTwo[self.player] = self.w.colorTwo[self.list[self.y][self.x]]
      for k, v in pairs(self.fills) do
        for i, j in pairs(v) do
          if j.id ~= 0 then
            self.w.energy[j.id] = j.health
          else
            self.h.health = j.health
          end
        end 
      end
      local ff = megautils.add(fade, true, nil, nil, function(s)
            megautils.removeq(self)
            megautils.removeq(s)
            megautils.add(fade, false, nil, nil, fade.remove)
            megautils.unfreeze(nil, "pause")
          end)
      megautils.playSound("selected")
      return
    elseif control.rightPressed[self.player] then
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
    elseif control.leftPressed[self.player] then
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
    elseif control.upPressed[self.player] then
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
    elseif control.downPressed[self.player] then
      while true do
        if self.y >= 6 then
          self.section = 1
          self.x = 1
          self.y = 1
          megaman.colorOutline[self.player] = self.w.colorOutline[self.cur]
          megaman.colorOne[self.player] = self.w.colorOne[self.cur]
          megaman.colorTwo[self.player] = self.w.colorTwo[self.cur]
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
      megaman.colorOutline[self.player] = self.w.colorOutline[self.list[self.y][self.x]]
      megaman.colorOne[self.player] = self.w.colorOne[self.list[self.y][self.x]]
      megaman.colorTwo[self.player] = self.w.colorTwo[self.list[self.y][self.x]]
      megautils.playSound("cursorMove")
    end
  elseif self.section == 1 then
    local olx, oly = self.x, self.y
    if control.startPressed[self.player] then
      if self.x == 1 and globals.eTanks > 0 then
        self.fills[1][1].change = self.h.segments * 4
        self.fills[1][1]:updateThis()
        self.changing = "health"
        globals.eTanks = math.clamp(globals.eTanks-1, 0, 9)
      elseif self.x == 2 and globals.wTanks > 0 then
        local frz = false
        for k, v in pairs(self.fills) do
          for i, j in pairs(v) do
            if j.id ~= 0 then
              j.change = self.w.segments[j.id] * 4
              j:updateThis()
            end
          end
        end
        self.changing = "weapons"
        globals.wTanks = math.clamp(globals.wTanks-1, 0, 9)
      end
    elseif control.upPressed[self.player] then
      self.section = 0
      self.x = 1
      self.y = #self.list
      while true do
        if self.fills[self.y] and self.fills[self.y][self.x] then
          break
        end
        self.y = self.y-1
      end
      megaman.colorOutline[self.player] = self.w.colorOutline[self.list[self.y][self.x]]
      megaman.colorOne[self.player] = self.w.colorOne[self.list[self.y][self.x]]
      megaman.colorTwo[self.player] = self.w.colorTwo[self.list[self.y][self.x]]
      olx = -69
    end
    if self.x == 1 and control.rightPressed[self.player] then
      self.x = 2
    elseif self.x == 2 and control.leftPressed[self.player] then
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

function weaponSelect:draw()
  love.graphics.setFont(mmFont)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.bg, view.x, view.y)
  love.graphics.print((globals.infiniteLives and "inf" or tostring(globals.lives)), view.x+(24*8), view.y+(23*8))
  love.graphics.print(tostring(globals.eTanks), view.x+(8*8), view.y+(23*8))
  love.graphics.print(tostring(globals.wTanks), view.x+(12*8), view.y+(23*8))
  
  local ox, oy = 0, 0
  local tx, ty = view.x+(8*21), view.y+(22*8)

  if globals.player[self.player] == "proto" then
    oy = 1
  elseif globals.player[self.player] == "bass" then
    ox = -1
    oy = 1
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.heads[globals.player[self.player]], tx+ox, ty+oy)
  love.graphics.setColor(megaman.colorTwo[self.player][1]/255, megaman.colorTwo[self.player][2]/255, megaman.colorTwo[self.player][3]/255, 1)
  love.graphics.draw(self.texTwo, self.heads[globals.player[self.player]], tx+ox, ty+oy)
  love.graphics.setColor(megaman.colorOutline[self.player][1]/255, megaman.colorOutline[self.player][2]/255, megaman.colorOutline[self.player][3]/255, 1)
  love.graphics.draw(self.texOutline, self.heads[globals.player[self.player]], tx+ox, ty+oy)
  love.graphics.setColor(megaman.colorOne[self.player][1]/255, megaman.colorOne[self.player][2]/255, megaman.colorOne[self.player][3]/255, 1)
  love.graphics.draw(self.texOne, self.heads[globals.player[self.player]], tx+ox, ty+oy)
  
  if self.section == 0 then
    local tx, ty, tx2 = view.x+(8*6), view.y+(22*8), view.x+(8*10)
    love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
    love.graphics.draw(self.texTwo, self.quadE, tx, ty)
    love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
    love.graphics.draw(self.texOutline, self.quadE, tx, ty)
    love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
    love.graphics.draw(self.texOne, self.quadE, tx, ty)
    
    love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
    love.graphics.draw(self.texTwo, self.quadW, tx2, ty)
    love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
    love.graphics.draw(self.texOutline, self.quadW, tx2, ty)
    love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
    love.graphics.draw(self.texOne, self.quadW, tx2, ty)
    
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        if self.x == j.gridX and self.y == j.gridY then
          love.graphics.draw(self.t, self.active[j.id], view.x+(j.icoX), view.y+(j.icoY))
        else
          love.graphics.draw(self.t, self.inactive[j.id], view.x+(j.icoX), view.y+(j.icoY))
        end
        love.graphics.print(self.text[j.id], view.x+(j.icoX+16), view.y+(j.icoY))
      end
    end
  else
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.t, self.inactive[j.id], view.x+(j.icoX), view.y+(j.icoY))
        love.graphics.print(self.text[j.id], view.x+(j.icoX+16), view.y+(j.icoY))
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    if self.x == 1 then
      local tx, ty, tx2 = view.x+(8*6), view.y+(22*8), view.x+(8*10)
      love.graphics.setColor(self.activeTankColor[2][1]/255, self.activeTankColor[2][2]/255, self.activeTankColor[2][3]/255, 1)
      love.graphics.draw(self.texTwo, self.quadE, tx, ty)
      love.graphics.setColor(self.activeTankColor[3][1]/255, self.activeTankColor[3][2]/255, self.activeTankColor[3][3]/255, 1)
      love.graphics.draw(self.texOutline, self.quadE, tx, ty)
      love.graphics.setColor(self.activeTankColor[1][1]/255, self.activeTankColor[1][2]/255, self.activeTankColor[1][3]/255, 1)
      love.graphics.draw(self.texOne, self.quadE, tx, ty)
      
      love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
      love.graphics.draw(self.texTwo, self.quadW, tx2, ty)
      love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
      love.graphics.draw(self.texOutline, self.quadW, tx2, ty)
      love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
      love.graphics.draw(self.texOne, self.quadW, tx2, ty)
    elseif self.x == 2 then
      local tx, ty, tx2 = view.x+(8*6), view.y+(22*8), view.x+(8*10)
      love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
      love.graphics.draw(self.texTwo, self.quadE, tx, ty)
      love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
      love.graphics.draw(self.texOutline, self.quadE, tx, ty)
      love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
      love.graphics.draw(self.texOne, self.quadE, tx, ty)
      
      love.graphics.setColor(self.activeTankColor[2][1]/255, self.activeTankColor[2][2]/255, self.activeTankColor[2][3]/255, 1)
      love.graphics.draw(self.texTwo, self.quadW, tx2, ty)
      love.graphics.setColor(self.activeTankColor[3][1]/255, self.activeTankColor[3][2]/255, self.activeTankColor[3][3]/255, 1)
      love.graphics.draw(self.texOutline, self.quadW, tx2, ty)
      love.graphics.setColor(self.activeTankColor[1][1]/255, self.activeTankColor[1][2]/255, self.activeTankColor[1][3]/255, 1)
      love.graphics.draw(self.texOne, self.quadW, tx2, ty)
    end
  end
end
