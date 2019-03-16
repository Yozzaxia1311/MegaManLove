local rebindstate = states.state:extend()

function rebindstate:begin()
  megautils.add(rebinder())
  megautils.add(fade(false):setAfter(fade.remove))
end

function rebindstate:update(dt)
  megautils.update(self, dt)
end

function rebindstate:stop()
  megautils.unload(self)
end

function rebindstate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_rebind"] = function()
  rebinder = nil
  megautils.cleanFuncs["unload_rebind"] = nil
end

rebinder = entity:extend()

function rebinder:new()
  rebinder.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
  end
  self.transform.x = 32
  self.transform.y = 112
  self.keysToSet = {3, 4, 1, 2, 7, 8, 11, 9, 10, 5, 6}
  self.keyNames = {"left", "right", "up", "down", "jump", "shoot", "dash", "previous weapon", "next weapon", "start", "select"}
  self.currentKey = 1
  globals.lastKeyPressed = nil
  self.step = 0
  self.done = false
  self.data = save.load("main.set", true) or {}
  self.data.controls = {}
  inputHandler.refreshGamepads()
end

function rebinder:update(dt)
  if globals.lastKeyPressed ~= nil and globals.lastKeyPressed[1] == "escape" and not self.done then
    globals.lastKeyPressed = nil
    megautils.add(fade(true, nil, nil, function(s)
      states.set(globals.sendBackToDisclaimer and "states/menus/disclaimerstate.lua" or globals.lastStateName, nil,
        globals.sendBackToDisclaimer)
      if not globals.sendBackToDisclaimer then
        megautils.add(fade(false, nil, nil, fade.remove))
      end
      globals.sendBackToDisclaimer = nil
    end))
    self.updated = false
    return
  end
  if globals.lastKeyPressed ~= nil and not self.done then
    self.data.controls[self.keysToSet[self.currentKey]+self.step] = globals.lastKeyPressed
    globals.lastKeyPressed = nil
    
    if self.currentKey == table.length(self.keysToSet) then
      if (self.step/11)+1 == playerCount then
        self.done = true
        inputHandler.unbind()
        for k, v in pairs(self.data.controls) do
          inputHandler.bind(v[1], k, v[2], v[3])
        end
        save.save("main.set", self.data, true)
        states.set(globals.sendBackToDisclaimer and "states/menus/disclaimerstate.lua" or globals.lastStateName, nil,
          globals.sendBackToDisclaimer)
        globals.sendBackToDisclaimer = nil
      else
        self.currentKey = 1
        self.step = self.step + 11
      end
    else
      self.currentKey = math.min(self.currentKey + 1, table.length(self.keysToSet))
    end
  end
end

function rebinder:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.printf("press the player " .. tostring((self.step/11)+1) .. " \n'"
    .. self.keyNames[self.currentKey] .. "'!" ..
    "\n\n(press escape to leave)", self.transform.x, self.transform.y, 200, "center")
end

return rebindstate