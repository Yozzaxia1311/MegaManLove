local menustate = states.state:extend()

function menustate:begin()
  megautils.loadStage(self, "assets/maps/menu.lua", nil, true)
  megautils.add(menuSelect())
  megautils.add(fade(false):setAfter(fade.remove))
  view.x, view.y = 0, 0
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
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.tex = loader.get("menu_select")
  self.pick = 0
  self.offY = self.transform.y
  self.picked = false
  self.section = 0
  self.timer = 20
end

function menuSelect:update(dt)
  if self.section == 0 then
    local old = self.pick
    if control.upPressed[1] then
      self.pick = math.wrap(self.pick-1, 0, 4)
    elseif control.downPressed[1] then
      self.pick = math.wrap(self.pick+1, 0, 4)
    end
    if old ~= self.pick then
      mmSfx.play("cursor_move")
    end
    if (control.jumpPressed[1] or control.startPressed[1]) and not self.picked then
      if self.pick == 0 then
        self.picked = true
        self.section = -1
        megautils.gotoState("states/menus/gameloaderstate.lua")
      elseif self.pick == 1 then
        if convar.getNumber("r_fullscreen") == 1 then
          convar.setValue("r_fullscreen", 0, true)
        else
          convar.setValue("r_fullscreen", 1, true)
        end
        local data = save.load("main.set") or {}
        data.fullscreen = convar.getNumber("r_fullscreen")
        save.save("main.set", data)
      elseif self.pick == 2 then
        self.picked = true
        self.section = -1
        globals.lastStateName = states.current
        megautils.gotoState("states/menus/rebindstate.lua")
      elseif self.pick == 3 then
        self.section = 1
        self.timer = 0
        mmSfx.play("selected")
      elseif self.pick == 4 then
        self.picked = true
        self.section = -1
        megautils.gotoState("states/menus/titlestate.lua")
      end
    end
  elseif self.section == 1 then
    self.timer = math.wrap(self.timer+1, 0, 20)
    local old = playerCount
    if control.leftPressed[1] then
      playerCount = math.wrap(playerCount-1, 1, maxPlayerCount)
    elseif control.rightPressed[1] then
      playerCount = math.wrap(playerCount+1, 1, maxPlayerCount)
    end
    if old ~= playerCount then
      mmSfx.play("cursor_move")
    end
    if control.jumpPressed[1] or control.startPressed[1] then
      self.section = 0
      self.timer = 20
      mmSfx.play("selected")
    end
  end
end

function menuSelect:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.section == 0 then
    love.graphics.draw(self.tex, 88, (9*8)+self.offY+self.pick*16)
  end
  if self.timer > 10 then
    love.graphics.setFont(mmFont)
    love.graphics.print(tostring(playerCount), 12*8, 15*8)
  end
  if playerCount > 1 then
    love.graphics.print("s", 20*8, 15*8)
  end
end

return menustate