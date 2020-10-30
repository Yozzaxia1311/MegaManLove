mmWeaponsMenu = basicEntity:extend()

mmWeaponsMenu.autoClean = false

function mmWeaponsMenu.resources()
  megautils.loadResource("assets/misc/weaponSelect.png", "weaponSelectBG")
  megautils.loadResource("assets/sfx/pause.ogg", "pause")
  megautils.loadResource("assets/sfx/selected.ogg", "selected")
  megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
end
  
function mmWeaponsMenu.pause(self)
  megautils.freeze("pause")
  
  megautils.add(fade, true, nil, nil, function(s)
      for _, v in pairs(megautils.playerPauseFuncs) do
        if type(v) == "function" then
          v(self)
        else
          v.func(self)
        end
      end
      
      megautils.add(mmWeaponsMenu, self)
      local ff = megautils.add(fade, false, nil, nil, fade.remove)
      megautils.removeq(s)
    end)
  
  if camera.main then
    camera.main:doView()
  end
  
  megautils.playSound("pause")
end

function mmWeaponsMenu:new(p)
  mmWeaponsMenu.super.new(self)
  self.bg = megautils.getResource("weaponSelectBG")
  self.tex = megautils.getResource("particles")
  self.texOutline = megautils.getResource("particlesOutline")
  self.texOne = megautils.getResource("particlesOne")
  self.texTwo = megautils.getResource("particlesTwo")
  self.quadE = quad(72, 12, 16, 16)
  self.quadW = quad(88, 12, 16, 16)
  self.headQuad = quad(203, 398, 63, 62)
  self.playerQuad = quad(2, 2, 63, 62)
  self.player = p
  self.noFreeze = {"pause", "hb"}
  w = megaMan.weaponHandler[self.player.player]
  self.section = 0
  self.dOutline, self.dOne, self.dTwo = {0, 0, 0}, {124, 124, 124}, {188, 188, 188}
  self.fills = {{}}
  self.list = {{0, -1},
			{1, 6},
			{2, 7},
			{3, 8},
			{4, 9},
			{5, 10}}
  
  local w = megaMan.weaponHandler[self.player.player]
  for y=1, #self.list do
    for x=1, #self.list[y] do
      if w.currentSlot == self.list[y][x] then
        self.x = x
        self.y = y
        break
      end
    end
  end
  for y=1, #self.list do
    for x=1, #self.list[y] do
      if w.weapons[self.list[y][x]] then
        local h = healthHandler({124, 124, 124}, {188, 188, 188}, {0, 0, 0}, nil, "x", 8)
        if x == 1 and y == 1 then
          h.segments = self.player.healthHandler.segments
          h:instantUpdate(self.player.healthHandler.health)
          h.colorOutline = self.player.healthHandler.colorOutline
          h.colorOne = self.player.healthHandler.colorOne
          h.colorTwo = self.player.healthHandler.colorTwo
        else
          h.segments = weapon.segments[w.weapons[self.list[y][x]]] or 7
          h:instantUpdate(w.energy[self.list[y][x]])
        end
        h.side = -1
        h.transform.x = view.x+(64+(x*112)-112)
        h.transform.y = view.y+(32+(y*16)-16)
        h.icoX = 32+(x*112)-112
        h.icoY = 24+(y*16)-16
        h.gridX = x
        h.gridY = y
        h.wid = self.list[y][x]
        h:setLayer(10)
        if not self.fills[y] then
          self.fills[y] = {}
        end
        self.fills[y][x] = h
      end
    end
  end
  self.cur = w.currentSlot
  self.last = {w.currentSlot, megaMan.colorOutline[self.player.player], megaMan.colorOne[self.player.player], megaMan.colorTwo[self.player.player]}
  self.inactiveTankColor = {{0, 0, 0}, {188, 188, 188}, {255, 255, 255}}
  self.trig = megautils.add(trigger, function(s, dt)
    for _, v in pairs(s.fills) do
      for _, j in pairs(v) do
        j:update(dt)
      end
    end
  end)
  self.trig.fills = self.fills
  self.trig.noFreeze = {"pause", "hb"}
  megaMan.colorOutline[self.player.player] = weapon.colors[w.weapons[self.list[self.y][self.x]]].outline
  megaMan.colorOne[self.player.player] = weapon.colors[w.weapons[self.list[self.y][self.x]]].one
  megaMan.colorTwo[self.player.player] = weapon.colors[w.weapons[self.list[self.y][self.x]]].two
  self:setLayer(10)
  if mmWeaponsMenu.main then
    megautils.removeq(mmWeaponsMenu.main)
  end
  mmWeaponsMenu.main = self
end

function mmWeaponsMenu:removed()
  mmWeaponsMenu.main = nil
  megautils.unfreeze("pause")
  for _, v in pairs(self.fills) do
    for _, j in pairs(v) do
      if j.wid ~= 0 then
        megaMan.weaponHandler[self.player.player]:instantUpdate(j.health, j.wid)
      else
        self.player.healthHandler:instantUpdate(j.health)
      end
    end 
  end
  self.player:switchWeaponSlot(self.cur)
  if self.cur == self.last[1] then
    megaMan.colorOutline[self.player.player] = self.last[2]
    megaMan.colorOne[self.player.player] = self.last[3]
    megaMan.colorTwo[self.player.player] = self.last[4]
  end
  
  if not self.ff or self.ff.isRemoved then
    for _, v in ipairs(megautils.state().system.all) do
      v.canDraw.pause = nil
    end
  end
  
  if self.trig then
    megautils.remove(self.trig)
  end
end

function mmWeaponsMenu:update(dt)
  local w = megaMan.weaponHandler[self.player.player]
  if self.changing then
    if self.changing == "health" and self.fills[1][1].renderedHealth == self.player.healthHandler.segments * 4 then
      self.x = 1
      self.y = 1
      self.section = 0
      self.changing = nil
    elseif self.changing == "weapons" then
      local res = true
      for _, v in pairs(self.fills) do
        for _, j in pairs(v) do
          if j.wid ~= 0 and j.renderedHealth ~= (weapon.segments[w.weapons[j.wid]] or 7) * 4 then
            res = false
          end
        end
      end
      if res then
        self.x = 1
        self.y = 1
        self.section = 0
        self.changing = nil
      end
    end
    return
  end
  
  if self.section == 0 then
    local olx, oly = self.x, self.y
    for _, v in pairs(self.fills) do
      for _, j in pairs(v) do
        j.colorOne = {124, 124, 124}
        j.colorTwo = {188, 188, 188}
      end
    end
    local h = self.fills[self.y][self.x]
    if self.x == 1 and self.y == 1 then
      h.colorOutline = self.player.healthHandler.colorOutline
      h.colorOne = self.player.healthHandler.colorOne
      h.colorTwo = self.player.healthHandler.colorTwo
    else
      h.colorOne = weapon.colors[w.weapons[self.list[self.y][self.x]]].one
      h.colorTwo = weapon.colors[w.weapons[self.list[self.y][self.x]]].two
    end
    if control.startPressed[self.player.player] then
      megautils.add(fade, true, nil, nil, function(s)
          megautils.removeq(self)
          megautils.removeq(s)
          
          for _, v in ipairs(megautils.state().system.all) do
            if not v.visibleDuringPause then
              v.canDraw.pause = false
            end
          end
          
          self.ff = megautils.add(fade, false, nil, nil, function(ss)
              for _, v in ipairs(megautils.state().system.all) do
                v.canDraw.pause = nil
              end
              
              megautils.removeq(ss)
            end)
        end)
      self.changing = "leaving"
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
      self.cur = self.fills[self.y][self.x].wid
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
      self.cur = self.fills[self.y][self.x].wid
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
      self.cur = self.fills[self.y][self.x].wid
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
        self.fills[1][1]:updateThis(self.player.healthHandler.segments * 4)
        self.changing = "health"
        megautils.setETanks(math.max(megautils.getETanks()-1, 0))
      elseif self.x == 2 and megautils.getWTanks() > 0 then
        local frz = false
        for _, v in pairs(self.fills) do
          for _, j in pairs(v) do
            if j.wid ~= 0 then
              j:updateThis((weapon.segments[w.weapons[j.wid]] or 7) * 4)
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
    for _, v in pairs(self.fills) do
      for _, j in pairs(v) do
        j.colorOne = {124, 124, 124}
        j.colorTwo = {188, 188, 188}
      end
    end
  end
end

function mmWeaponsMenu:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.bg:draw(view.x, view.y)
  
  local w = megaMan.weaponHandler[self.player.player]
  local skin = megaMan.getSkin(self.player.player)
  local tx, ty, tx2 = view.x+216, view.y+200, view.x+80
  
  local h = self.fills[1][1]
  local out, on, tw, x, y = h.colorOutline, h.colorOne, h.colorTwo,
    h.transform.x, h.transform.y
  h.colorOutline, h.colorOne, h.colorTwo = self.player.healthHandler.colorOutline, self.player.healthHandler.colorOne, self.player.healthHandler.colorTwo
  h.transform.x, h.transform.y = view.x+129, view.y+209
  h:draw()
  h.colorOutline, h.colorOne, h.colorTwo = out, on, tw
  h.transform.x, h.transform.y = x, y
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print((megautils.hasInfiniteLives() and "inf" or tostring(megautils.getLives())), view.x+224, view.y+200)
  
  local px, py = view.x+156, view.y+207
  
  skin.texture:draw(self.headQuad, tx, ty, 0, 1, 1, 31, 37)
  skin.texture:draw(self.playerQuad, px, py, 0, 1, 1, 32, 41)
  
  love.graphics.setColor(megaMan.colorOutline[self.player.player][1]/255, megaMan.colorOutline[self.player.player][2]/255,
    megaMan.colorOutline[self.player.player][3]/255, 1)
  
  skin.outline:draw(self.headQuad, tx, ty, 0, 1, 1, 31, 37)
  skin.outline:draw(self.playerQuad, px, py, 0, 1, 1, 32, 41)
  
  love.graphics.setColor(megaMan.colorOne[self.player.player][1]/255, megaMan.colorOne[self.player.player][2]/255,
    megaMan.colorOne[self.player.player][3]/255, 1)
  
  skin.one:draw(self.headQuad, tx, ty, 0, 1, 1, 31, 37)
  skin.one:draw(self.playerQuad, px, py, 0, 1, 1, 32, 41)
  
  love.graphics.setColor(megaMan.colorTwo[self.player.player][1]/255, megaMan.colorTwo[self.player.player][2]/255,
    megaMan.colorTwo[self.player.player][3]/255, 1)
  
  skin.two:draw(self.headQuad, tx, ty, 0, 1, 1, 31, 37)
  skin.two:draw(self.playerQuad, px, py, 0, 1, 1, 32, 41)
  
  tx, ty = view.x+24, view.y+184
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(tostring(megautils.getETanks()), tx+16, ty+16)
  love.graphics.print(tostring(megautils.getWTanks()), tx2+16, ty+16)
  
  if self.section == 0 then
    love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
    self.texOutline:draw(self.quadE, tx, ty)
    love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
    self.texOne:draw(self.quadE, tx, ty)
    love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
    self.texTwo:draw(self.quadE, tx, ty)
    
    love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
    self.texOutline:draw(self.quadW, tx2, ty)
    love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
    self.texOne:draw(self.quadW, tx2, ty)
    love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
    self.texTwo:draw(self.quadW, tx2, ty)
    
    for _, v in pairs(self.fills) do
      for _, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        if self.x == j.gridX and self.y == j.gridY then
          weapon.drawIcon(w.weapons[j.wid], true, view.x+(j.icoX), view.y+(j.icoY))
        else
          weapon.drawIcon(w.weapons[j.wid], false, view.x+(j.icoX), view.y+(j.icoY))
        end
        love.graphics.print(w.weapons[j.wid], view.x+(j.icoX+24), view.y+(j.icoY))
      end
    end
  else
    for _, v in pairs(self.fills) do
      for _, j in pairs(v) do
        j:draw()
        love.graphics.setColor(1, 1, 1, 1)
        weapon.drawIcon(w.weapons[j.wid], false, view.x+(j.icoX), view.y+(j.icoY))
        love.graphics.print(w.weapons[j.wid], view.x+(j.icoX+24), view.y+(j.icoY))
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    if self.x == 1 then
      love.graphics.setColor(weapon.colors[w.weapons[self.cur]].outline[1]/255,
        weapon.colors[w.weapons[self.cur]].outline[2]/255, weapon.colors[w.weapons[self.cur]].outline[3]/255, 1)
      self.texOutline:draw(self.quadE, tx, ty)
      love.graphics.setColor(weapon.colors[w.weapons[self.cur]].one[1]/255,
        weapon.colors[w.weapons[self.cur]].one[2]/255, weapon.colors[w.weapons[self.cur]].one[3]/255, 1)
      self.texOne:draw(self.quadE, tx, ty)
      love.graphics.setColor(weapon.colors[w.weapons[self.cur]].two[1]/255,
        weapon.colors[w.weapons[self.cur]].two[2]/255, weapon.colors[w.weapons[self.cur]].two[3]/255, 1)
      self.texTwo:draw(self.quadE, tx, ty)
      
      love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
      self.texOutline:draw(self.quadW, tx2, ty)
      love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
      self.texOne:draw(self.quadW, tx2, ty)
      love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
      self.texTwo:draw(self.quadW, tx2, ty)
    elseif self.x == 2 then
      love.graphics.setColor(self.inactiveTankColor[1][1]/255, self.inactiveTankColor[1][2]/255, self.inactiveTankColor[1][3]/255, 1)
      self.texOutline:draw(self.quadE, tx, ty)
      love.graphics.setColor(self.inactiveTankColor[2][1]/255, self.inactiveTankColor[2][2]/255, self.inactiveTankColor[2][3]/255, 1)
      self.texOne:draw(self.quadE, tx, ty)
      love.graphics.setColor(self.inactiveTankColor[3][1]/255, self.inactiveTankColor[3][2]/255, self.inactiveTankColor[3][3]/255, 1)
      self.texTwo:draw(self.quadE, tx, ty)
      
      love.graphics.setColor(weapon.colors[w.weapons[self.cur]].outline[1]/255,
        weapon.colors[w.weapons[self.cur]].outline[2]/255, weapon.colors[w.weapons[self.cur]].outline[3]/255, 1)
      self.texOutline:draw(self.quadW, tx2, ty)
      love.graphics.setColor(weapon.colors[w.weapons[self.cur]].one[1]/255,
        weapon.colors[w.weapons[self.cur]].one[2]/255, weapon.colors[w.weapons[self.cur]].one[3]/255, 1)
      self.texOne:draw(self.quadW, tx2, ty)
      love.graphics.setColor(weapon.colors[w.weapons[self.cur]].two[1]/255,
        weapon.colors[w.weapons[self.cur]].two[2]/255, weapon.colors[w.weapons[self.cur]].two[3]/255, 1)
      self.texTwo:draw(self.quadW, tx2, ty)
    end
  end
end