local playersState = state:extend()

function playersState:begin()
  megautils.add(smash)
  megautils.add(parallax, 0, 0, view.w, view.h, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, 0.4, 0.4, true, true)
  megautils.add(parallax, 0, -32, view.w, view.h+32, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, -0.4, 0.4, true, true)
  megautils.add(fade, false, nil, nil, fade.remove)
  
  love.graphics.setBackgroundColor(0, 0.5, 136/255, 1)
  megautils.playMusic("assets/sfx/music/menu.ogg")
end

function playersState:switching()
  love.graphics.setBackgroundColor(0, 0, 0, 1)
end

megautils.loadResource("assets/players/mug.animset", "mugAnims")
megautils.loadResource("assets/players/player.animset", "playerAnims")
megautils.loadResource("assets/misc/playerSelect.png", "playerSelect")
megautils.loadResource("assets/misc/playerSelectOutline.png", "playerSelectOutline")

smash = basicEntity:extend()

smash.invisibleToHash = true

function smash:new()
  smash.super.new(self)
  
  self.psTex = megautils.getResource("playerSelect")
  self.psoTex = megautils.getResource("playerSelectOutline")
  self.players = {"assets/players/megaMan", "assets/players/protoMan", "assets/players/bass", "assets/players/roll"}
  self.colors = {}
  self.names = {}
  self.protoIdle = {}
  self.roles = {}
  self.cursors = {}
  for i = 1, #self.players do
    if not love.filesystem.getInfo(self.players[i]) then
      table.remove(self.players, i)
    end
  end
  for i = 1, #self.players do
    local t = parseConf(self.players[i] .. "/conf.txt")
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
      
      megautils.loadResource(self.players[i] .. "/player.png", self.players[i])
      megautils.loadResource(self.players[i] .. "/one.png", self.players[i] .. "one")
      megautils.loadResource(self.players[i] .. "/two.png", self.players[i] .. "two")
      megautils.loadResource(self.players[i] .. "/outline.png", self.players[i] .. "outline")
    else
      table.remove(self.players, i)
    end
  end
  for i = 1, megaMan.playerCount do
    for j = 1, #self.players do
      if self.players[j] == megaMan.getSkin(i).path then
        self.roles[#self.roles + 1] = megaMan.getSkin(#self.roles + 1).path
        self.cursors[#self.roles] = {x = (i * 64) - 38, y = view.h - 63,
          input = megaMan.playerToInput[#self.roles], color = self.colors[j].one, name = self.names[j]}
      end
    end
  end
  self.anims = animationSet("mugAnims")
  self.playerAnims = animationSet("playerAnims")
end

function smash:dm(i, x, y)
  megautils.getResource(self.roles[i]):draw(self.anims, x, y)
end

function smash:dp(i, x, y)
  if self.protoIdle[i] then
    self.playerAnims.current = "protoIdle"
  else
    self.playerAnims.current = "idle"
  end
  love.graphics.setColor(1, 1, 1, 1)
  megautils.getResource(self.players[i]):draw(self.playerAnims, x, y)
  love.graphics.setColor(unpack(self.colors[i].outline))
  megautils.getResource(self.players[i] .. "outline"):draw(self.playerAnims, x, y)
  love.graphics.setColor(unpack(self.colors[i].one))
  megautils.getResource(self.players[i] .. "one"):draw(self.playerAnims, x, y)
  love.graphics.setColor(unpack(self.colors[i].two))
  megautils.getResource(self.players[i] .. "two"):draw(self.playerAnims, x, y)
  love.graphics.setColor(1, 1, 1, 1)
end

function smash:roleHasInput(inp)
  for i = 1, #self.cursors do
    if self.cursors[i].input == inp then
      return true
    end
  end
  
  return false
end

function smash:nextFree()
  for i = 1, #self.players do
    if not table.contains(self.roles, self.players[i]) then
      return self.players[i], i
    end
  end
end

function smash:update()
  if input.pressed.select1 then
    globals.fromOther = 6
    megautils.transitionToState(globals.menuState)
    return
  end
  
  self.playerAnims:update(1/60)
  self.playerAnims:update(1/60, "protoIdle")
  
  for i = 2, maxPlayerCount do
    if not self:roleHasInput(i) and (input.pressed["jump" .. tostring(i)] or input.pressed["start" .. tostring(i)]) then
      local nextP = #self.roles + 1
      local ns, nsi = self:nextFree()
      megaMan.setSkin(nextP, ns)
      self.roles[nextP] = ns
      megaMan.playerToInput[nextP] = i
      self.cursors[nextP] = {x = (i * 64) - 38, y = view.h - 64, input = megaMan.playerToInput[nextP],
        color = self.colors[nsi].one, name = self.names[nsi]}
      megaMan.playerCount = nextP
      megautils.playSoundFromFile("assets/sfx/selected.ogg")
    end
  end
  
  for i = 1, #self.roles do
    local l, r, u, d = input.down["left" .. tostring(self.cursors[i].input)], input.down["right" .. tostring(self.cursors[i].input)],
      input.down["up" .. tostring(self.cursors[i].input)], input.down["down" .. tostring(self.cursors[i].input)]
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
    
    if input.pressed["start" .. tostring(self.cursors[i].input)] or input.pressed["jump" .. tostring(self.cursors[i].input)] then
      for j = 1, 4 do
        if (self.cursors[i].input == 1 or self.cursors[i].input == j) and
          rectOverlapsRect(128 + (j * 16) - 16, 144, 8, 8, self.cursors[i].x, self.cursors[i].y, 2, 2) then
          globals.rPlayer = j
          globals.sendBackToPlayers = true
          megautils.transitionToState(globals.rebindState)
          return
        end
      end
      for j = 1, #self.players do
        if self.roles[i] ~= self.players[j] and rectOverlapsRect((j * 64) - 64, 64, 64, 64, self.cursors[i].x, self.cursors[i].y, 8, 8) then
          self.roles[i] = self.players[j]
          self.cursors[i].color = self.colors[j].one
          self.cursors[i].name = self.names[j]
          megaMan.setSkin(i, self.players[j])
          megautils.playSoundFromFile("assets/sfx/selected.ogg")
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
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("CHOOSE YOUR CHARACTER!", 40, 16)
  love.graphics.print("(Select to go back)", 48, 32)
  love.graphics.print("Rebind: 1 2 3 4", 64, 144)
  
  for i = 1, #self.players do
    local x, y = (i * 64) - 64, 64
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", x, y, 64, 64)
    self:dp(i, x, y)
  end
  
  for i = 1, megaMan.playerCount do
    if self.roles[i] then
      local x, y = (i * 64) - 64, view.h - 64
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", x, y, 64, 64)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("P." .. tostring(i), x, y)
      love.graphics.printf(self.cursors[i].name, x, y + 46, 64, "center")
      self:dm(i, x, y)
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