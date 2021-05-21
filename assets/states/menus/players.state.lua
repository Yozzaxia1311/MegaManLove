local playersState = state:extend()

function playersState:begin()
  megautils.add(smash)
  megautils.add(fade, false, nil, nil, fade.remove)
  
  love.graphics.setBackgroundColor(0, 0.5, 136/255, 1)
end

function playersState:switching()
  love.graphics.setBackgroundColor(0, 0, 0, 1)
end

megautils.loadResource("assets/players/mug.animset", "mugAnims")

smash = basicEntity:extend()

smash.invisibleToHash = true

function smash:new()
  smash.super.new(self)
  
  self.players = {"assets/players/megaMan", "assets/players/protoMan", "assets/players/bass", "assets/players/roll"}
  self.roles = {}
  self.cursors = {}
  for i = 1, #self.players do
    megautils.loadResource(self.players[i] .. "/player.png", self.players[i])
  end
  for i = 1, megaMan.playerCount do
    for j = 1, #self.players do
      if self.players[j] == megaMan.getSkin(i).path then
        self.roles[#self.roles + 1] = megaMan.getSkin(i).path
        megaMan.playerToInput[#self.roles] = i
        self.cursors[#self.roles] = {x = (i * 64) - 64, y = view.h - 64, input = megaMan.playerToInput[i]}
      end
    end
  end
  self.anims = animationSet("mugAnims")
end

function smash:pfi(i)
  return tonumber(i:sub(0, -1))
end

function smash:dm(i, x, y)
  megautils.getResource(self.roles[i]):draw(self.anims, x, y)
end

function smash:roleHasInput(inp)
  for i = 1, #self.cursors do
    if self.cursors[i].input == inp then
      return true
    end
  end
  
  return false
end

function smash:update()
  for i = 2, maxPlayerCount do
    if not self:roleHasInput(i) and input.pressed["jump" .. tostring(i)] then
      self.roles[#self.roles + 1] = megaMan.getSkin(i).path
      megaMan.playerToInput[#self.roles] = i
      self.cursors[#self.roles] = {x = (i * 64) - 64, y = view.h - 64, input = megaMan.playerToInput[#self.roles]}
    end
  end
  
  for i = 2, #self.roles do
    if input.pressed["shoot" .. tostring(self.cursors[i].input)] then
      table.remove(self.roles, i)
      table.remove(self.cursors, i)
      table.remove(megaMan.playerToInput, i)
      break
    end
  end
end

function smash:draw()
  love.graphics.print("CHOOSE YOUR CHARACTER!", 40, 16)
  
  for i = 1, megaMan.playerCount do
    if self.roles[i] then
      local x, y = (i * 64) - 64, view.h - 64
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", x, y, 64, 64)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("P." .. tostring(i), x, y)
      self:dm(i, x, y)
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.circle("line", self.cursors[i].x, self.cursors[i].y, 8)
    end
  end
end

return playersState