local disclaimerState = state:extend()

function disclaimerState:begin()
  music.stop()
  loader.load("assets/misc/disclaimerFace.png", "face")
  megautils.add(disclaimer)
  megautils.add(fade, false, nil, nil, fade.remove)
end

disclaimer = basicEntity:extend()

disclaimer.invisibleToHash = true

function disclaimer:new()
  disclaimer.super.new(self)
  self.x = 0
  self.y = 0
  self.t = loader.get("face")
  self.timer = 0
  self.alpha = 0
  self.otherTimer = 5
  self.check = false
  self.cycler = 1
  self.colors = {{0, 70, 90}, {0, 120, 248}, {60, 188, 252}, {255, 255, 255}}
  self.disclaimerText = "Mega Man and all related content © Capcom 2021." .. 
    "\n\n\n\nThe Mega Man Love engine is a non-profit fan-made engine created by " .. 
    "various contributors.\n\nIt is not for sale.\n\n" .. 
    "Have fun!"
  self.bottomText = "Press Start to continue" ..
    (canDoFullscreenShortcut and "\nPress Alt+Enter for fullscreen" or "\n") ..
    (canDoScaleShortcuts and "\nPress 1-9 to set the scale" or "\n") ..
    "\nPress Escape here to rebind"
  self.bottomTextGP = "Press Start to continue" ..
    (canDoFullscreenShortcut and "\nPress Select here for fullscreen" or "\n") ..
    (canDoScaleShortcuts and "\nPress 1-9 to set the scale" or "\n") ..
    "\nPress Guide here to rebind"
  self.bottomTextT = "Touch or MouseBtn to continue" ..
    "\n" ..
    "\n" ..
    "\nPress Back here to rebind"
  self.tTimer = 0
  self.texts = {self.bottomText}
  self.text = 1
end

function disclaimer:update()
  if self.check then
    self.tTimer = math.min(self.tTimer + 1, 80)
    if self.tTimer == 80 then
      self.tTimer = 0
      self.text = math.wrap(self.text + 1, 1, #self.texts)
    end
    if input.usingTouch and not table.contains(self.texts, self.bottomTextT) then
      self.texts[#self.texts + 1] = self.bottomTextT
      self.tTimer = 40
    elseif not input.usingTouch and table.contains(self.texts, self.bottomTextT) then
      table.removevalue(self.texts, self.bottomTextT)
    end
    if #input.gamepads ~= 0 then
      if not table.contains(self.texts, self.bottomTextGP) then
        self.tTimer = 40
        self.texts[#self.texts + 1] = self.bottomTextGP
      end
      if lastPressed.input == "back" then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      elseif lastPressed.input == "guide" then
        globals.sendBackToDisclaimer = true
        megautils.transitionToState(globals.rebindState)
        self.check = false
        return
      end
    elseif table.contains(self.texts, self.bottomTextGP) then
      table.removevalue(self.texts, self.bottomTextGP)
    end
    if input.pressed.start1 or input.length(input.touchPressed) ~= 0 then
      megautils.transitionToState(globals.titleState)
      self.check = false
      return
    elseif lastPressed.input == "escape" then
      globals.sendBackToDisclaimer = true
      megautils.transitionToState(globals.rebindState)
      self.check = false
      return
    end
  end
  self.timer = math.min(self.timer + 1, 81)
  if self.timer == 80 then
    self.check = true
  end
  self.otherTimer = self.otherTimer + 1
  if self.otherTimer == 6 then
    self.otherTimer = 0
    if self.check then
      self.alpha = math.min(self.alpha + (255/3), 255)
    end
    self:cycle()
  end
end

function disclaimer:cycle()
  self.cycler = math.wrap(self.cycler+1, 1, 4)
end

function disclaimer:draw()
  love.graphics.setColor(self.colors[self.cycler][1]/255, self.colors[self.cycler][2]/255, self.colors[self.cycler][3]/255, 1)
  self.t:draw(40, 150)
  self.t:draw(120, 150)
  self.t:draw(200, 150)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.printf(self.disclaimerText, 4, 16, 248, "center")
  love.graphics.setColor(1, 1, 1, self.alpha/255)
  love.graphics.printf(self.texts[math.wrap(self.text, 1, #self.texts)], -21, 181, 300, "center")
end

return disclaimerState
