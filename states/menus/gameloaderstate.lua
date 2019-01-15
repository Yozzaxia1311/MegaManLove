local gameloaderstate = states.state:extend()

function gameloaderstate:begin()
  megautils.loadStage(self, "assets/maps/game_loader.lua", nil, true)
  megautils.add(menuSelect())
  megautils.add(fade(false):setAfter(fade.remove))
  view.x, view.y = 0, 0
  mmMusic.stopMusic()
end

function gameloaderstate:update(dt)
  megautils.update(self, dt)
end

function gameloaderstate:stop()
  self.system:clear()
  if globals.stopMusicMenu == nil then
    megautils.unload(self)
  end
end

function gameloaderstate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_gameloader"] = function()
  menuSelect = nil
  megautils.cleanFuncs["unload_gameloader"] = nil
end

menuSelect = entity:extend()

function menuSelect:new()
  menuSelect.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.tex = loader.get("menu_select")
  self.pick = 1
  self.offY = self.transform.y
  self.picked = false
  self.section = 0
  self.timer = 20
  self.heldTimer = 0
  self.doHold = 0
  self.games = {}
  for k, v in pairs(love.filesystem.getDirectoryItems("/")) do
    local info = love.filesystem.getInfo(v)
    if info and info.type == "directory" and love.filesystem.getInfo(v .. "/init.lua") then
      self.games[#self.games+1] = love.filesystem.load(v .. "/init.lua")()
      self.games[#self.games].path = v
    end
  end
end

function menuSelect:update(dt)
  if not self.picked then
    if #self.games ~= 0 then
      local old = self.pick
      if control.upPressed[1] or (self.heldTimer == 15 and control.upDown[1] and self.doHold == 1) then
        self.pick = math.wrap(self.pick-1, 1, #self.games)
      elseif control.downPressed[1] or (self.heldTimer == 15 and control.downDown[1] and self.doHold == 1) then
        self.pick = math.wrap(self.pick+1, 1, #self.games)
      end
      if control.upDown[1] or control.downDown[1] then
        self.heldTimer = math.min(self.heldTimer+1, 15)
        self.doHold = math.wrap(self.doHold+1, 0, 5)
      else
        self.heldTimer = 0
        self.doHold = 0
      end
      if old ~= self.pick then
        mmSfx.play("cursor_move")
      end
    end
    if control.startPressed[1] and self.games[self.pick].run then
      gamePath = self.games[self.pick].path
      megautils.add(fade(true):setAfter(function()
        self.games[self.pick].run()
        states.set(self.games[self.pick].initState)
      end))
      self.picked = true
    elseif control.shootPressed[1] then
      megautils.gotoState("states/menus/menustate.lua")
      self.picked = true
    elseif control.selectPressed[1] then
      love.system.openURL(love.filesystem.getSaveDirectory())
    end
  end
end

function menuSelect:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, 32, 64)
  love.graphics.setFont(mmFont)
  if #self.games ~= 0 then
    for i=1, #self.games do
      love.graphics.print(self.games[i].name, 48, 72-(self.pick*8))
    end
  else
    love.graphics.print("(no games)", 48, 64)
  end
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", 32, 0, 20*8, 32)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("start:load game\nshoot:back\nselect:map directory", 32, 8)
end

return gameloaderstate