local playersState = state:extend()

function playersState:begin()
  megautils.add(smash)
  megautils.add(parallax, 0, 0, view.w, view.h, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, 0.4, 0.4, true, true)
  megautils.add(parallax, 0, -32, view.w, view.h+32, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, -0.4, 0.4, true, true)
  megautils.add(fade, false, nil, nil, fade.remove)
  
  love.graphics.setBackgroundColor(0, 0.5, 136/255, 1)
  music.play("assets/sfx/mm5.nsf", nil, 19)
end

function playersState:switching()
  love.graphics.setBackgroundColor(0, 0, 0, 1)
end

loader.load("assets/players/mug.animset", "mugAnims")
loader.load("assets/players/player.animset", "playerAnims")
loader.load("assets/misc/playerSelect.png", "playerSelect")
loader.load("assets/misc/playerSelectOutline.png", "playerSelectOutline")
loader.load("assets/sfx/cursorMove.ogg", "cursorMove")

smash = basicEntity:extend()

smash.invisibleToHash = true

function smash:new()
  smash.super.new(self)
  
  self.selectionOffset = 0
  
  self.psTex = loader.get("playerSelect")
  self.psoTex = loader.get("playerSelectOutline")
  
  self.players = {}
  self.colors = {}
  self.names = {}
  self.protoIdle = {}
  
  self.roles = {}
  self.cursors = {}
  
  for i = megaMan.playerCount, maxPlayerCount do
    if self:isValidSkin("assets/players/megaMan") then
      self:registerSkin("assets/players/megaMan")
    end
    if self:isValidSkin("assets/players/protoMan") then
      self:registerSkin("assets/players/protoMan")
    end
    if self:isValidSkin("assets/players/bass") then
      self:registerSkin("assets/players/bass")
    end
    if self:isValidSkin("assets/players/roll") then
      self:registerSkin("assets/players/roll")
    end
  end
  
  for _, path in ipairs(iterateDirs()) do
    if self:isValidSkin(path) then
      self:registerSkin(path)
    end
  end
  
  for i = 1, megaMan.playerCount do
    local skinI
    
    for k, v in ipairs(self.players) do
      if megaMan.getSkin(i).path == v then
        skinI = k
      end
    end
    
    self.roles[i] = megaMan.getSkin(i).path
    self.cursors[i] = {x = (i * 64) - 38, y = view.h - 63,
      input = megaMan.playerToInput[i], color = self.colors[skinI].one, name = self.names[skinI]}
  end
  
  self.hasMoreSkins = #self.players > 4
  
  self.anims = animationSet("mugAnims")
  self.playerAnims = animationSet("playerAnims")
end

function smash:isValidSkin(path)
  local dirCheck = love.filesystem.getInfo(path)
  
  if not dirCheck then
    return false
  end
  
  if dirCheck and not (dirCheck.type == "directory" or dirCheck.type == "symlink") then
    return false
  end
  
  if not (love.filesystem.getInfo(path .. "/conf.txt") or
    love.filesystem.getInfo(path .. "/one.png") or love.filesystem.getInfo(path .. "/two.png") or
    love.filesystem.getInfo(path .. "/outline.png") or love.filesystem.getInfo(path .. "/player.png")) then
    return false
  end
  
  return true
end

function smash:registerSkin(_path)
  local path = (type(_path) == "table") and _path.path or _path
  
  if not table.contains(self.players, path) then
    local i = #self.players + 1
    
    local t = (type(_path) == "table") and _path.traits or parseConf(_path .. "/conf.txt")
    if t.name and t.slot0 then
      self.protoIdle[i] = t.protoIdleAnim
      self.names[i] = t.name
      self.colors[i] = {
          outline = {
            weapon.colors[t.slot0].outline[1] / 255,
            weapon.colors[t.slot0].outline[2] / 255,
            weapon.colors[t.slot0].outline[3] / 255
          },
          one = {
            weapon.colors[t.slot0].one[1] / 255,
            weapon.colors[t.slot0].one[2] / 255,
            weapon.colors[t.slot0].one[3] / 255
          },
          two = {
            weapon.colors[t.slot0].two[1] / 255,
            weapon.colors[t.slot0].two[2] / 255,
            weapon.colors[t.slot0].two[3] / 255
          }
        }
      
      loader.load(path .. "/player.png", path)
      loader.load(path .. "/one.png", path .. "one")
      loader.load(path .. "/two.png", path .. "two")
      loader.load(path .. "/outline.png", path .. "outline")
      
      self.players[i] = path
    else
      return false
    end
  end
  
  return true
end

function smash:drawMug(i, x, y)
  loader.get(self.roles[i]):draw(self.anims, x, y)
end

function smash:drawPlayer(i, x, y)
  if self.protoIdle[i] then
    self.playerAnims.current = "protoIdle"
  else
    self.playerAnims.current = "idle"
  end
  love.graphics.setColor(1, 1, 1, 1)
  loader.get(self.players[i]):draw(self.playerAnims, x, y)
  love.graphics.setColor(unpack(self.colors[i].outline))
  loader.get(self.players[i] .. "outline"):draw(self.playerAnims, x, y)
  love.graphics.setColor(unpack(self.colors[i].one))
  loader.get(self.players[i] .. "one"):draw(self.playerAnims, x, y)
  love.graphics.setColor(unpack(self.colors[i].two))
  loader.get(self.players[i] .. "two"):draw(self.playerAnims, x, y)
  love.graphics.setColor(1, 1, 1, 1)
end

function smash:inputHasRole(inp)
  for i = 1, #self.cursors do
    if self.cursors[i].input == inp then
      return true
    end
  end
  
  return false
end

function smash:nextUnusedSkin()
  for i = 1, #self.players do
    if not table.contains(self.roles, self.players[i]) then
      return self.players[i], i
    end
  end
  
  return self.players[1], 1
end

function smash:update()
  if input.pressed.select1 then
    globals.fromOther = 6
    states.fadeToState(globals.menuState)
    return
  end
  
  self.playerAnims:update(1/60)
  self.playerAnims:update(1/60, "protoIdle")
  
  for i = 2, maxPlayerCount do
    if not self:inputHasRole(i) and (input.pressed["jump" .. tostring(i)] or input.pressed["start" .. tostring(i)]) then
      local nextP = #self.roles + 1
      local ns, nsi = self:nextUnusedSkin()
      megaMan.setSkin(nextP, ns)
      self.roles[nextP] = ns
      megaMan.playerToInput[nextP] = i
      self.cursors[nextP] = {x = (i * 64) - 38, y = view.h - 64, input = megaMan.playerToInput[nextP],
        color = self.colors[nsi].one, name = self.names[nsi]}
      megaMan.playerCount = nextP
      sfx.playFromFile("assets/sfx/selected.ogg")
    end
  end
  
  for i = 1, #self.roles do
    local l, r, u, d = input.down["left" .. tostring(self.cursors[i].input)],
      input.down["right" .. tostring(self.cursors[i].input)],
      input.down["up" .. tostring(self.cursors[i].input)],
      input.down["down" .. tostring(self.cursors[i].input)]
    if (l and not r) or (r and not l) then
      if l then
        self.cursors[i].x = self.cursors[i].x + (((type(l) == "number") and l or -1) * 2.5)
      else
        self.cursors[i].x = self.cursors[i].x + (((type(r) == "number") and r or 1) * 2.5)
      end
    end
    
    if (u and not d) or (d and not u) then
      if u then
        self.cursors[i].y = self.cursors[i].y + (((type(u) == "number") and u or -1) * 2.5)
      else
        self.cursors[i].y = self.cursors[i].y + (((type(d) == "number") and d or 1) * 2.5)
      end
    end
    
    self.cursors[i].x = math.clamp(self.cursors[i].x, view.x, view.w)
    self.cursors[i].y = math.clamp(self.cursors[i].y, view.y, view.h)
    
    if input.pressed["start" .. tostring(self.cursors[i].input)] or
      input.pressed["jump" .. tostring(self.cursors[i].input)] then
      for j = 1, maxPlayerCount do
        if (self.cursors[i].input == 1 or self.cursors[i].input == j) and
          rectOverlapsRect(128 + (j * 16) - 16, 144, 8, 8, self.cursors[i].x, self.cursors[i].y, 2, 2) then
          globals.rPlayer = j
          globals.sendBackToPlayers = true
          states.fadeToState(globals.rebindState)
          return
        end
        
        if self.hasMoreSkins then
          if rectOverlapsRect(40, 56, 40, 8, self.cursors[i].x, self.cursors[i].y, 2, 2) then
            self.selectionOffset = math.wrap(self.selectionOffset - 1, 0, math.ceil(#self.players / 4) - 1)
            sfx.play("cursorMove")
            return
          elseif rectOverlapsRect(176, 56, 40, 8, self.cursors[i].x, self.cursors[i].y, 2, 2) then
            self.selectionOffset = math.wrap(self.selectionOffset + 1, 0, math.ceil(#self.players / 4) - 1)
            sfx.play("cursorMove")
            return
          end
        end
      end
      for j = 1, 4 do
        if not self.players[j + self.selectionOffset] then
          break
        end
        
        if self.roles[i] ~= self.players[j + (self.selectionOffset * 4)] and
          rectOverlapsRect((j * 64) - 64, 64, 64, 64, self.cursors[i].x, self.cursors[i].y, 8, 8) then
          local realOffset = j + (self.selectionOffset * 4)
          self.roles[i] = self.players[realOffset]
          self.cursors[i].color = self.colors[realOffset].one
          self.cursors[i].name = self.names[realOffset]
          megaMan.setSkin(i, self.players[realOffset])
          sfx.playFromFile("assets/sfx/selected.ogg")
          break
        end
      end
    end
    
    if i ~= 1 and input.pressed["shoot" .. tostring(self.cursors[i].input)] then
      table.remove(self.roles, i)
      table.remove(self.cursors, i)
      table.remove(megaMan.playerToInput, i)
      if self.roles[i] then
        megaMan.setSkin(i, self.roles[i])
      end
      megaMan.playerCount = #self.roles
      break
    end
  end
end

function smash:draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", 40 - 8, 16 - 8, 192, 40)
  love.graphics.rectangle("fill", 64 - 8, 144 - 8, 134, 24)
  if self.hasMoreSkins then
    love.graphics.rectangle("fill", 40 - 8, 56, 56, 8)
    love.graphics.rectangle("fill", 176 - 8, 56, 56, 8)
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("fill", 40, 56, 40, 8)
    love.graphics.rectangle("fill", 176, 56, 40, 8)
  end
  for i = 1, maxPlayerCount do
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("fill", 128 + (i * 16) - 16, 144, 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(i, 128 + (i * 16) - 16, 144)
  end
  love.graphics.print("CHOOSE A CUSTOM SKIN!", 48, 16)
  love.graphics.print("(Select to go back)", 48, 32)
  love.graphics.print("Rebind:", 64, 144)
  if self.hasMoreSkins then
    love.graphics.print("<Prev", 40, 56)
    love.graphics.print("Next>", 176, 56)
  end
  
  for i = 1, 4 do
    if not self.players[i + (self.selectionOffset * 4)] then
      break
    end
    
    local x, y = (i * 64) - 64, 64
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", x, y, 64, 64)
    self:drawPlayer(i + (self.selectionOffset * 4), x, y)
  end
  
  for i = 1, megaMan.playerCount do
    if self.roles[i] then
      local x, y = (i * 64) - 64, view.h - 64
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", x, y, 64, 64)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("P." .. tostring(i), x, y)
      love.graphics.printf(self.cursors[i].name, x, y + 46, 64, "center")
      self:drawMug(i, x, y)
    end
  end
  
  for i = 1, megaMan.playerCount do
    if self.roles[i] then
      love.graphics.setColor(1, 1, 1, 1)
      self.psoTex:draw(math.floor(self.cursors[i].x - 2), math.floor(self.cursors[i].y - 2))
      love.graphics.setColor(unpack(self.cursors[i].color))
      self.psTex:draw(math.floor(self.cursors[i].x - 2), math.floor(self.cursors[i].y - 2))
    end
  end
end

return playersState