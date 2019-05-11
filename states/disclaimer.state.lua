local disclaimerstate = states.state:extend()

function disclaimerstate:begin()
  mmMusic.stopMusic()
  loader.load("assets/misc/disclaimer_face.png", "face", "texture")
  megautils.add(disclaimer)
  megautils.add(fade, false, nil, nil, fade.remove)
end

function disclaimerstate:update(dt)
  megautils.update(self)
end

function disclaimerstate:stop()
  megautils.unload()
end

function disclaimerstate:draw()
  megautils.draw(self, dt)
end

megautils.cleanFuncs["unload_disclaimer"] = function()
  disclaimer = nil
  megautils.cleanFuncs["unload_disclaimer"] = nil
end

disclaimer = entity:extend()

function disclaimer:new()
  disclaimer.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.transform.x = 0
  self.transform.y = 0
  self.t = loader.get("face")
  self.timer = 0
  self.timer2 = 2
  self.alpha = 0
  self.otherTimer = 6
  self.check = false
  self.cycler = 1
  self.colors = {{0, 70, 90}, {0, 120, 248}, {60, 188, 252}, {255, 255, 255}}
  self.disclaimerText = "mega man and all related content (c) capcom 2019." .. 
    "\n\n\n\nthe mega man love engine is a non-profit fanmade engine created by " .. 
    "various contributors.\n\nit is not for sale.\n\n" .. 
    "have fun!"
end

function disclaimer:update()
  if control.startPressed[1] and self.check then
    megautils.gotoState("states/title.state.lua")
    self.updated = false
  elseif globals.lastKeyPressed and globals.lastKeyPressed[1] == "escape" and self.check then
    globals.lastKeyPressed = nil
    globals.sendBackToDisclaimer = true
    megautils.gotoState("states/rebind.state.lua")
  end
  globals.lastKeyPressed = nil
  self.timer = math.min(self.timer+1, 80)
  if self.timer == 80 then
    self.check = true
  end
  self.otherTimer = math.min(self.otherTimer+1, 6)
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
  love.graphics.printf(self.disclaimerText, 4, 24, 248, "center")
  love.graphics.setColor(1, 1, 1, self.alpha/255)
  love.graphics.printf("press start to continue\npress atl+enter for fullscreen\npress escape to rebind controls", -21, 200, 300, "center")
end

return disclaimerstate