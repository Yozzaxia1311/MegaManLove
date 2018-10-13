local menustate = states.state:extend()

function menustate:begin()
  loader.load("assets/misc/select.png", "select", "texture")
  loader.load("assets/sfx/cursor_move.ogg", "cursor_move", "sound")
  loader.load("assets/sfx/selected.ogg", "selected", "sound")
  megautils.loadStage(self, "assets/maps/menu.lua")
  megautils.add(menuSelect())
  megautils.add(fade(false):setAfter(fade.remove))
  view.x, view.y = 0, 0
  if globals.stopMusicMenu == nil then
    mmMusic.playFromFile("assets/sfx/music/menu.ogg")
  end
end

function menustate:update(dt)
  megautils.update(self, dt)
end

function menustate:stop()
  self.system:clear()
  if globals.stopMusicMenu == nil then
    megautils.unload(self)
  end
end

function menustate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_menu"] = function()
  menuSelect = nil
  megautils.cleanFuncs["unload_menu"] = nil
end

menuSelect = entity:extend()

function menuSelect:new()
  menuSelect.super.new(self)
  self.transform.y = 96
  self.transform.x = 88
  self.tex = loader.get("select")
  self:addToGroup("freezable")
  self.pick = 0
  self.offY = self.transform.y
  self.picked = false
  self.quad = love.graphics.newQuad(81, 288, 5, 8, 96, 303)
end

function menuSelect:update(dt)
  local old = self.pick
  if control.upPressed then
    self.pick = math.wrap(self.pick-1, 0, 5)
  elseif control.downPressed then
    self.pick = math.wrap(self.pick+1, 0, 5)
  end
  if old ~= self.pick then
    mmSfx.play("cursor_move")
  end
  if (control.jumpPressed or control.startPressed) and not self.picked then
    if self.pick == 0 then
      self.picked = true
      self.render = false
      mmMusic.stopMusic()
      megautils.gotoState("states/menus/stageselectstate.lua")
      globals.stopMusicMenu = nil
    elseif self.pick == 1 then
      if convar.getNumber("r_fullscreen") == 1 then
        convar.setValue("r_fullscreen", 0, true)
      else
        convar.setValue("r_fullscreen", 1, true)
      end
    elseif self.pick == 2 then
      self.picked = true
      self.render = false
      mmMusic.stopMusic()
      megautils.gotoState("states/menus/rebindstate.lua")
      globals.stopMusicMenu = nil
    elseif self.pick == 3 then
      mmSfx.play("selected")
      local data = save.load("save.txt")
      if data ~= nil then
        globals.defeats = data.defeats
        globals.infiniteLives = data.infiniteLives
        globals.lives = data.lives
        globals.lifeSegments = data.lifeSegments
        globals.eTanks = data.eTanks
        globals.wTanks = data.wTanks
      end
    elseif self.pick == 4 then
      local data = save.load("save.txt") or {}
      data.defeats = globals.defeats
      data.infiniteLives = globals.infiniteLives
      data.lives = globals.lives
      data.lifeSegments = globals.lifeSegments
      data.eTanks = globals.eTanks
      data.wTanks = globals.wTanks
      save.save("save.txt", data)
      mmSfx.play("selected")
    elseif self.pick == 5 then
      self.picked = true
      self.render = false
      mmMusic.stopMusic()
      megautils.gotoState("states/menus/titlestate.lua")
      globals.stopMusicMenu = nil
    end
  end
  self.transform.y = self.offY + self.pick*16
end

function menuSelect:draw()
  love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y)
end

return menustate
