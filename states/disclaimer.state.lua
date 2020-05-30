local disclaimerState = states.state:extend()

function disclaimerState:begin()
  megautils.stopMusic()
  megautils.loadResource("assets/misc/disclaimerFace.png", "face")
  megautils.add(disclaimer)
  megautils.add(fade, false, nil, nil, fade.remove)
end

megautils.cleanFuncs.disclaimer = function()
  disclaimer = nil
  megautils.cleanFuncs.disclaimer = nil
end

disclaimer = entity:extend()

function disclaimer:new()
  disclaimer.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.transform.x = 0
  self.transform.y = 0
  self.t = megautils.getResource("face")
  self.timer = 0
  self.alpha = 0
  self.otherTimer = 5
  self.check = false
  self.cycler = 1
  self.colors = {{0, 70, 90}, {0, 120, 248}, {60, 188, 252}, {255, 255, 255}}
  self.disclaimerText = "Mega Man and all related content (c) Capcom 2020." .. 
    "\n\n\n\nthe Mega Man Love engine is a non-profit fanmade engine created by " .. 
    "various contributors.\n\nit is not for sale.\n\n" .. 
    "have fun!"
  self.bottomText = "Press start to continue" .. (isWeb and "" or "\nPress Alt+Enter for fullscreen") .. "\nPress " .. 
    (isWeb and "1" or "Escape") .. " to rebind controls"
end

function disclaimer:update()
  if control.startPressed[1] and self.check then
    megautils.transitionToState("states/title.state.lua")
    self.updated = false
  elseif globals.lastKeyPressed and globals.lastKeyPressed[2] == (isWeb and "1" or "escape") and self.check then
    globals.lastKeyPressed = nil
    globals.sendBackToDisclaimer = true
    megautils.transitionToState("states/rebind.state.lua")
  end
  self.timer = self.timer + 1
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
  love.graphics.draw(self.t, 40, 160)
  love.graphics.draw(self.t, 120, 160)
  love.graphics.draw(self.t, 200, 160)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.printf(self.disclaimerText, 4, 16, 248, "center")
  love.graphics.setColor(1, 1, 1, self.alpha/255)
  love.graphics.printf(self.bottomText, -21, 192, 300, "center")
end

return disclaimerState