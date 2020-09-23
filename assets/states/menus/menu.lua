local menuState = state:extend()

function menuState:begin()
  megautils.add(menuSelect)
  megautils.add(parallax, 0, 0, view.w, view.h, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, 0.4, 0.4, true, true)
  megautils.add(parallax, 0, -32, view.w, view.h+32, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, -0.4, 0.4, true, true)
  if globals.wgsToMenu then
    globals.wgsToMenu = nil
    mmMusic._queue = nil
  end
end

megautils.loadResource("assets/misc/menuSelect.png", "menuSelect")
megautils.loadResource("assets/sfx/cursorMove.ogg", "cursorMove")
megautils.loadResource("assets/sfx/selected.ogg", "selected")

menuSelect = basicEntity:extend()

function menuSelect:new()
  menuSelect.super.new(self)
  self.transform.x = 88
  self.transform.y = 10*8
  self.tex = megautils.getResource("menuSelect")
  self.pick = 0
  self.offY = self.transform.y
  self.picked = false
  self.section = 0
  self.timer = 20
end

function menuSelect:update()
  if self.section == 0 then
    local old = self.pick
    if control.upPressed[1] then
      self.pick = math.wrap(self.pick-1, 0, 7)
    elseif control.downPressed[1] then
      self.pick = math.wrap(self.pick+1, 0, 7)
    end
    if old ~= self.pick then
      megautils.playSound("cursorMove")
    end
    if (control.jumpPressed[1] or control.startPressed[1]) and not self.picked then
      if self.pick == 0 then
        self.picked = true
        self.section = -1
        megautils.stopMusic()
        megautils.transitionToState(globals.stageSelectState)
      elseif self.pick == 1 then
        local data = save.load("save.sav")
        if data then
          globals.defeats = data.defeats
          megautils.infiniteLives(data.infiniteLives)
          megautils.setLives(data.lives)
          globals.lifeSegments = data.lifeSegments
          megautils.setETanks(data.eTanks)
          megautils.setWTanks(data.wTanks)
          for k, v in ipairs(data.player) do
            megaMan.setSkin(k, v)
          end
        end
        megautils.playSound("selected")
      elseif self.pick == 2 then
        local data = save.load("save.sav") or {}
        data.defeats = globals.defeats
        data.infiniteLives = megautils.hasInfiniteLives()
        data.lives = megautils.getLives()
        data.lifeSegments = globals.lifeSegments
        data.eTanks = megautils.getETanks()
        data.wTanks = megautils.getWTanks()
        data.player = megaMan.skins
        save.save("save.sav", data)
        megautils.playSound("selected")
      elseif self.pick == 3 then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      elseif self.pick == 4 then
        self.section = 1
        self.timer = 0
        megautils.playSound("selected")
      elseif self.pick == 5 then
        self.picked = true
        self.section = -1
        globals.lastStateName = megautils.getCurrentState()
        megautils.transitionToState(globals.rebindState)
      elseif self.pick == 6 then
        self.section = 2
        self.timer = 0
        megautils.playSound("selected")
      elseif self.pick == 7 then
        self.picked = true
        self.section = -1
        megautils.stopMusic()
        megautils.transitionToState(globals.titleState)
      end
    end
    self.transform.y = self.offY + self.pick*16
  elseif self.section == 1 then
    self.timer = math.wrap(self.timer+1, 0, 20)
    local old = megautils.getScale()
    if control.leftPressed[1] then
      megautils.playSound("selected")
      megautils.setScale(math.wrap(megautils.getScale()-1, 1, 8))
    elseif control.rightPressed[1] then
      megautils.playSound("selected")
      megautils.setScale(math.wrap(megautils.getScale()+1, 1, 8))
    end
    if control.jumpPressed[1] or control.startPressed[1] then
      self.section = 0
      self.timer = 20
      megautils.playSound("selected")
    end
  elseif self.section == 2 then
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
  if self.section == 0 then
    self.tex:draw(self.transform.x, self.transform.y)
  end
  if self.section ~= 1 or self.timer > 10 then
    love.graphics.print(megautils.getScale(), 96, (18*8)-1)
  end
  if self.section ~= 2 or self.timer > 10 then
    love.graphics.print(tostring(globals.playerCount), 96, (22*8)-1)
  end
  if globals.playerCount > 1 then
    love.graphics.print("S", 20*8, (22*8)-1)
  end
end

return menuState