local menuState = states.state:extend()

function menuState:begin()
  megautils.loadMap(self, "assets/maps/menu.tmx")
  megautils.add(menuSelect)
  megautils.add(fade, false, nil, nil, fade.remove)
  view.x, view.y = 0, 0
  megautils.playMusic("assets/sfx/music/menu.ogg", true)
end

megautils.cleanFuncs.menu = function()
  menuSelect = nil
  megautils.cleanFuncs.menu = nil
end

menuSelect = entity:extend()

megautils.loadResource("assets/misc/menuSelect.png", "menuSelect")
megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")

function menuSelect:new()
  menuSelect.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.transform.y = 9*8
  self.transform.x = 88
  self.tex = megautils.getResource("menuSelect")
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
      self.pick = math.wrap(self.pick-1, 0, 6)
    elseif control.downPressed[1] then
      self.pick = math.wrap(self.pick+1, 0, 6)
    end
    if old ~= self.pick then
      megautils.playSound("cursorMove")
    end
    if (control.jumpPressed[1] or control.startPressed[1]) and not self.picked then
      if self.pick == 0 then
        self.picked = true
        self.section = -1
        megautils.stopMusic()
        megautils.transitionToState("states/stageselect.state.lua")
      elseif self.pick == 1 then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      elseif self.pick == 2 then
        self.picked = true
        self.section = -1
        globals.lastStateName = states.current
        megautils.transitionToState("states/rebind.state.lua")
      elseif self.pick == 3 then
        megautils.playSound("selected")
        local data = save.load("save.sav")
        if data then
          globals.defeats = data.defeats
          megautils.infiniteLives(data.infiniteLives)
          globals.lives = data.lives
          globals.lifeSegments = data.lifeSegments
          globals.eTanks = data.eTanks
          globals.wTanks = data.wTanks
          for k, v in ipairs(data.player) do
            megautils.setPlayer(k, v)
          end
        end
      elseif self.pick == 4 then
        local data = save.load("save.sav") or {}
        data.defeats = globals.defeats
        data.infiniteLives = megautils.hasInfiniteLives()
        data.lives = globals.lives
        data.lifeSegments = globals.lifeSegments
        data.eTanks = globals.eTanks
        data.wTanks = globals.wTanks
        data.player = megautils.getAllPlayers()
        save.save("save.sav", data)
        megautils.playSound("selected")
      elseif self.pick == 5 then
        self.section = 1
        self.timer = 0
        megautils.playSound("selected")
      elseif self.pick == 6 then
        self.picked = true
        self.section = -1
        megautils.stopMusic()
        megautils.transitionToState("states/title.state.lua")
      end
    end
    self.transform.y = self.offY + self.pick*16
  elseif self.section == 1 then
    self.timer = math.wrap(self.timer+1, 0, 20)
    local old = globals.playerCount
    if control.leftPressed[1] then
      globals.playerCount = math.wrap(globals.playerCount-1, 1, maxPlayerCount)
    elseif control.rightPressed[1] then
      globals.playerCount = math.wrap(globals.playerCount+1, 1, maxPlayerCount)
    end
    if old ~= globals.playerCount then
      megautils.playSound("cursorMove")
    end
    if control.jumpPressed[1] or control.startPressed[1] then
      self.section = 0
      self.timer = 20
      megautils.playSound("selected")
    end
  end
end

function menuSelect:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.section == 0 then
    love.graphics.draw(self.tex, self.transform.x, self.transform.y)
  end
  if self.timer > 10 then
    love.graphics.setFont(mmFont)
    love.graphics.print(tostring(globals.playerCount), 12*8, 19*8)
  end
  if globals.playerCount > 1 then
    love.graphics.print("s", 20*8, 19*8)
  end
end

return menuState