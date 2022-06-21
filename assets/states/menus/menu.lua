local menuState = state:extend()

function menuState:begin()
  entities.add(menuSelect)
  entities.add(parallax, 0, 0, view.w, view.h, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, 0.4, 0.4, true, true)
  entities.add(parallax, 0, -32, view.w, view.h+32, "assets/states/menus/menuParallax.png", nil, nil, nil, nil, 1, 1, -0.4, 0.4, true, true)
  if globals.wgsToMenu then
    globals.wgsToMenu = nil
    music._queue = nil
  end
end

loader.load("assets/misc/menuSelect.png")
loader.load("assets/sfx/cursorMove.ogg")
loader.load("assets/sfx/selected.ogg")

menuSelect = basicEntity:extend()

menuSelect.invisibleToHash = true

function menuSelect:new()
  menuSelect.super.new(self)
  self.x = 88
  self.tex = loader.get("assets/misc/menuSelect.png")
  self.pick = globals.fromOther or 0
  self.offY = 10 * 8
  self.y = self.offY + self.pick*16
  globals.fromOther = nil
  self.picked = false
  self.section = 0
  self.timer = 20
end

function menuSelect:update()
  if self.section == 0 then
    local old = self.pick
    if input.pressed.up1 then
      self.pick = math.wrap(self.pick-1, 0, 7)
    elseif input.pressed.down1 then
      self.pick = math.wrap(self.pick+1, 0, 7)
    end
    local touched = false
    if input.length(input.touchPressed) ~= 0 then
      for i = 0, 7 do
        local x, y, w, h = 80, 80 + (i * 16), 96, 8
        y = y - 4
        h = h + 8
        if input.touchPressedOverlaps(x, y, w, h) then
          self.pick = i
          touched = true
        end
      end
    end
    if old ~= self.pick and not input.usingTouch then
      sfx.play("assets/sfx/cursorMove.ogg")
    end
    if (input.pressed.start1 or input.pressed.jump1 or touched) and not self.picked then
      if self.pick == 0 then
        self.picked = true
        self.section = -1
        music.stop()
        states.fadeToState(globals.stageSelectState)
      elseif self.pick == 1 then
        local data = save.load("save.sav")
        if data then
          globals.defeats = data.defeats
          megautils.setInfiniteLives(data.infiniteLives)
          megautils.setLives(data.lives)
          globals.lifeSegments = data.lifeSegments
          megautils.setETanks(data.eTanks)
          megautils.setWTanks(data.wTanks)
          for k, v in ipairs(data.players) do
            megaMan.setSkin(k, v)
          end
        end
        sfx.play("assets/sfx/selected.ogg")
      elseif self.pick == 2 then
        local data = save.load("save.sav") or {}
        data.defeats = globals.defeats
        data.infiniteLives = megautils.hasInfiniteLives()
        data.lives = megautils.getLives()
        data.lifeSegments = globals.lifeSegments
        data.eTanks = megautils.getETanks()
        data.wTanks = megautils.getWTanks()
        data.players = {}
        for i = 1, megaMan.playerCount do
          if megaMan.getSkin(i) then
            data.players[i] = megaMan.getSkin(i).path
          end
        end
        save.save("save.sav", data)
        sfx.play("assets/sfx/selected.ogg")
      elseif self.pick == 3 and not isMobile and not isWeb then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      elseif self.pick == 4 and not isMobile and not isWeb then
        if input.usingTouch then
          megautils.setScale(math.wrap(megautils.getScale()+1, 1, 4))
        else
          self.section = 1
          self.timer = 0
        end
        sfx.play("assets/sfx/selected.ogg")
      elseif self.pick == 5 then
        self.picked = true
        self.section = -1
        globals.lastStateName = states.currentStatePath
        states.fadeToState(globals.rebindState)
      elseif self.pick == 6 then
        self.picked = true
        self.section = -1
        states.fadeToState(globals.playerSelectState)
      elseif self.pick == 7 then
        self.picked = true
        self.section = -1
        music.stop()
        states.fadeToState(globals.titleState)
      end
    end
    self.y = self.offY + self.pick*16
  elseif self.section == 1 then
    self.timer = math.wrap(self.timer+1, 0, 20)
    local old = megautils.getScale()
    if input.pressed.left1 then
      sfx.play("assets/sfx/selected.ogg")
      megautils.setScale(math.wrap(megautils.getScale()-1, 1, 8))
    elseif input.pressed.right1 then
      sfx.play("assets/sfx/selected.ogg")
      megautils.setScale(math.wrap(megautils.getScale()+1, 1, 8))
    end
    if input.pressed.start1 or input.pressed.jump1 then
      self.section = 0
      self.timer = 20
      sfx.play("assets/sfx/selected.ogg")
    end
  end
end

function menuSelect:draw()
  if self.section == 0 and not input.usingTouch then
    self.tex:draw(self.x, self.y)
  end
  if self.section ~= 1 or self.timer > 10 then
    love.graphics.print(megautils.getScale(), 96, (18*8)-1)
  end
  if isMobile or isWeb then
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", (12 * 8) - 1, (16 * 8) - 1, 58 + 2, (8 * 3) + 2)
  end
end

return menuState
