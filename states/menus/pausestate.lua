local pausestate = states.state:extend()

function pausestate:begin()
  megautils.loadStage(self, "assets/maps/weapon_select.lua", nil, true)
  megautils.add(globals.pauseWeaponSelect)
  megautils.add(fade(false):setAfter(fade.remove))
  view.x, view.y = 0, 0
end

function pausestate:update(dt)
  if globals.pauseUpdateFunc ~= nil then
    globals.pauseUpdateFunc(dt)
  end
  megautils.update(self, dt)
end

function pausestate:draw()
  megautils.draw(self)
end

weaponSelect = entity:extend()

function weaponSelect:new(w, h, p)
  weaponSelect.super.new(self)
  self.t = loader.get("weapon_select")
  self.w = w
  self.h = h
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
      if self.w.weapons[self.list[y][x]] ~= nil then
        local h = healthhandler({124, 124, 124}, {188, 188, 188}, {0, 0, 0}, nil, "x", 8)
        if y == 1 and x == 1 then
          h.segments = self.h.segments
          h.health = self.h.health
        else
          h.segments = self.w.segments[self.list[y][x]]
          h.health = self.w.energy[self.list[y][x]]
        end
        h.side = -1
        --h:removeFromGroup("freezable")
        h.transform.x = (x*80)-16
        h.transform.y = 40+(y*16)
        h.icoX = (x*80)-32
        h.icoY = 32+(y*16)
        h.gridX = x
        h.gridY = y
        h.id = self.list[y][x]
        if self.fills[y] == nil then
          self.fills[y] = {}
        end
        self.fills[y][x] = h
        self:addIcon(self.list[y][x])
      end
    end
  end
  self.active["eTank"] = love.graphics.newQuad(80, 32, 16, 16, 176, 48)
  self.inactive["eTank"] = love.graphics.newQuad(48, 32, 16, 16, 176, 48)
  self.active["wTank"] = love.graphics.newQuad(96, 32, 16, 16, 176, 48)
  self.inactive["wTank"] = love.graphics.newQuad(64, 32, 16, 16, 176, 48)
  self.player = p
  globals.pauseUpdateFunc = function(dt)
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:update(dt)
      end
    end
  end
  self.added = function(self)
    self:addToGroup("freezable")
  end
end

function weaponSelect:addIcon(id)
  if id == 0 then
    self.active[id] = love.graphics.newQuad(16, 32, 16, 16, 176, 48)
    self.inactive[id] = love.graphics.newQuad(32, 32, 16, 16, 176, 48)
    self.text[id] = "m.buster"
  elseif id == 9 then
    self.active[id] = love.graphics.newQuad(144, 0, 16, 16, 176, 48)
    self.inactive[id] = love.graphics.newQuad(160, 0, 16, 16, 176, 48)
    self.text[id] = "rush c."
  elseif id == 10 then
    self.active[id] = love.graphics.newQuad(112, 32, 16, 16, 176, 48)
    self.inactive[id] = love.graphics.newQuad(128, 32, 16, 16, 176, 48)
    self.text[id] = "rush jet"
  elseif id == 1 then
    self.active[id] = love.graphics.newQuad(16, 0, 16, 16, 176, 48)
    self.inactive[id] = love.graphics.newQuad(32, 0, 16, 16, 176, 48)
    self.text[id] = "stick w."
  end
end

function weaponSelect:update(dt)
  if self.section == 0 then
    local olx, oly = self.x, self.y
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j.colorOne = {124, 124, 124}
        j.colorTwo = {188, 188, 188}
      end
    end
    self.fills[self.y][self.x].colorOne = {0, 120, 248}
    self.fills[self.y][self.x].colorTwo = {0, 232, 216}
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
      megautils.gotoState(globals.pauseLastStateName, nil, function()
        view.x, view.y = globals.lastCamPosX, globals.lastCamPosY
        megautils.add(fade(false, nil, nil, fade.remove):setAfter(fade.remove))
        globals.resetState = true
        globals.pauseLastStateName = nil
        globals.pauseLastState = nil
        globals.pauseWeaponSelect = nil
        globals.pauseUpdateFunc = nil
        weaponSelect = nil
        collectgarbage()
      end, globals.pauseLastState)
      mmSfx.play("selected")
      return
    elseif control.rightPressed[self.player] then
      self.x = math.clamp(self.x+1, 1, 2)
      local ly = self.y
      while true do
        local highSteps = 0
        while self.fills[self.y+highSteps] == nil or self.fills[self.y+highSteps][self.x] == nil do
          highSteps = highSteps - 1
          if self.y+highSteps <= 0 then
            highSteps = -42
            break --Check failed
          end
        end
        local steps = 0
        while self.fills[self.y+steps] == nil or self.fills[self.y+steps][self.x] == nil do
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
        while self.fills[self.y+highSteps] == nil or self.fills[self.y+highSteps][self.x] == nil do
          highSteps = highSteps - 1
          if self.y+highSteps <= 0 then
            highSteps = -42
            break --Check failed
          end
        end
        local steps = 0
        while self.fills[self.y+steps] == nil or self.fills[self.y+steps][self.x] == nil do
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
        if (self.fills[self.y] == nil or self.fills[self.y][self.x] == nil) and self.y == 1 and self.x == 2 then
          self.x = 1
          break
        end
        self.y = math.clamp(self.y-1, 1, 6)
        if self.fills[self.y] ~= nil and self.fills[self.y] ~= nil and self.fills[self.y][self.x] ~= nil then
          break
        end
      end
    elseif control.downPressed[self.player] then
      while true do
        if self.y >= 6 then
          self.section = 1
          self.x = 1
          self.y = 1
          mmSfx.play("cursor_move")
         return
        end
        self.y = math.clamp(self.y+1, 1, 6)
        if self.fills[self.y] ~= nil and self.fills[self.y][self.x] ~= nil then
          break
        end
      end
    end
    if olx ~= self.x or oly ~= self.y then
      mmSfx.play("cursor_move")
    end
  elseif self.section == 1 then
    local olx, oly = self.x, self.y
    if control.startPressed[self.player] then
      if self.x == 1 and globals.eTanks > 0 then
        self.fills[1][1].change = self.h.segments * 4
        self.fills[1][1]:updateThis()
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
        globals.wTanks = math.clamp(globals.wTanks-1, 0, 9)
      end
    elseif control.upPressed[self.player] then
      self.section = 0
      self.x = 1
      self.y = #self.list
      while true do
        if self.fills[self.y] ~= nil and self.fills[self.y][self.x] ~= nil then
          break
        end
        self.y = self.y-1
      end
      olx = -69
    end
    if self.x == 1 and control.rightPressed[self.player] then
      self.x = 2
    elseif self.x == 2 and control.leftPressed[self.player] then
      self.x = 1
    end
    if olx ~= self.x or oly ~= self.y then
      mmSfx.play("cursor_move")
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
  love.graphics.print(tostring(ternary(globals.infiniteLives, "inf", globals.lives)), 24*8, 23*8)
  love.graphics.print(tostring(globals.eTanks), 8*8, 23*8)
  love.graphics.print(tostring(globals.wTanks), 12*8, 23*8)
  if self.section == 0 then
    love.graphics.draw(self.t, self.inactive["eTank"], 8*6, 22*8)
    love.graphics.draw(self.t, self.inactive["wTank"], 8*10, 22*8)
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        if self.x == j.gridX and self.y == j.gridY then
          love.graphics.draw(self.t, self.active[j.id], j.icoX, j.icoY)
        else
          love.graphics.draw(self.t, self.inactive[j.id], j.icoX, j.icoY)
        end
        love.graphics.print(self.text[j.id], j.icoX+16, j.icoY)
      end
    end
  else
    for k, v in pairs(self.fills) do
      for i, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.t, self.inactive[j.id], j.icoX, j.icoY)
        love.graphics.print(self.text[j.id], j.icoX+16, j.icoY)
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    if self.x == 1 then
      love.graphics.draw(self.t, self.active["eTank"], 8*6, 22*8)
      love.graphics.draw(self.t, self.inactive["wTank"], 8*10, 22*8)
    elseif self.x == 2 then
      love.graphics.draw(self.t, self.inactive["eTank"], 8*6, 22*8)
      love.graphics.draw(self.t, self.active["wTank"], 8*10, 22*8)
    end
  end
end

return pausestate