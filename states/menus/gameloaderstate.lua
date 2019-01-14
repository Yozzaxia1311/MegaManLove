local gameloaderstate = states.state:extend()

function gameloaderstate:begin()
  loader.load("assets/misc/select.png", "select", "texture")
  loader.load("assets/sfx/cursor_move.ogg", "cursor_move", "sound")
  megautils.loadStage(self, "assets/maps/game_loader.lua")
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
  self.tex = loader.get("select")
  self.pick = 1
  self.offY = self.transform.y
  self.picked = false
  self.quad = love.graphics.newQuad(81, 288, 5, 8, 96, 303)
  self.section = 0
  self.timer = 20
  self.heldTimer = 0
  self.doHold = 0
  self.games = {"placeholder"}
end

function menuSelect:update(dt)
  if not self.picked then
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
    if control.selectPressed[1] then
      mmMusic.stopMusic()
      megautils.gotoState("states/menus/menustate.lua")
    end
  end
end

function menuSelect:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, 32, 64)
  love.graphics.setFont(mmFont)
  for i=1, #self.games do
    love.graphics.print(self.games[i], 48, 72-(self.pick*8))
  end
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", 32, 0, 20*8, 16)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("load a game\nselect to go back", 64, 0)
end

return gameloaderstate