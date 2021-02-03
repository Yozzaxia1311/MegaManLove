local disclaimerState = state:extend()

function disclaimerState:begin()
  megautils.loadResource("assets/misc/disclaimerFace.png", "face")
  megautils.add(disclaimer)
  megautils.add(fade, false, nil, nil, fade.remove)
  megautils.stopMusic()
end

disclaimer = basicEntity:extend()

disclaimer.invisibleToHash = true

function disclaimer:new()
  disclaimer.super.new(self)
  self.x = 0
  self.y = 0
  self.t = megautils.getResource("face")
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
    "\nPress Alt+Enter for fullscreen" ..
    "\nPress 1-9 to set the scale" ..
    "\nPress Escape here to rebind"
  self.bottomTextGP = "Press Start to continue" ..
    "\nPress Select here for fullscreen" ..
    "\nPress 1-9 to set the scale" ..
    "\nPress RStickBtn here to rebind"
  self.gpTimer = 0
end

function disclaimer:update()
  if self.check then
    if #inputHandler.gamepads ~= 0 then
      self.gpTimer = (self.gpTimer + 1) % 160
      if lastPressed.input == "back" then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      elseif lastPressed.input == "rightstick" then
        globals.sendBackToDisclaimer = true
        megautils.transitionToState(globals.rebindState)
        self.check = false
        return
      end
    else
      self.gpTimer = 0
    end
    if control.startPressed[1] then
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
  love.graphics.printf((self.gpTimer < 80) and self.bottomText or self.bottomTextGP, -21, 181, 300, "center")
end

return disclaimerState