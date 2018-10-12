local disclaimerstate = states.state:extend()

function disclaimerstate:begin()
  loader.load("assets/misc/disclaimer_face.png", "face", "texture")
  megautils.add(disclaimer())
  megautils.add(fade(false):setAfter(fade.remove))
end

function disclaimerstate:update(dt)
  megautils.update(self)
end

function disclaimerstate:stop()
  megautils.unload(self)
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
  self.transform.x = 0
  self.transform.y = 0
  self.t = loader.get("face")
  self:addToGroup("freezable")
  self.timer = 0
  self.timer2 = 2
  self.alpha = 0
  self.otherTimer = 6
  self.check = false
  self.cycler = 1
  self.colors = {{0, 70, 90}, {0, 120, 248}, {60, 188, 252}, {255, 255, 255}}
end

function disclaimer:update()
  if control.startPressed and self.check then
    megautils.gotoState("states/menus/titlestate.lua")
    self.updated = false
  elseif globals.lastKeyPressed ~= nil and globals.lastKeyPressed[1] == "escape" and self.check then
    globals.lastKeyPressed = nil
    globals.sendBackToDisclaimer = true
    megautils.gotoState("states/menus/rebindstate.lua")
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
  love.graphics.draw(self.t, 42, 155)
  love.graphics.draw(self.t, 122, 155)
  love.graphics.draw(self.t, 202, 155)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.printf("mega man is a registered trademark of capcom" .. 
    "\n\n\n\nthe mega man love engine is a non-profit fanmade engine created by " .. 
    "yozzaxia1311.\n\nremember to give credit. don't claim this engine as your own.\n\n" .. 
    "have fun!", 0, 35, 256, "center")
  love.graphics.setColor(1, 1, 1, self.alpha/255)
  love.graphics.printf("press start to continue\npress escape to rebind controls", -21, 200, 300, "center")
end

return disclaimerstate