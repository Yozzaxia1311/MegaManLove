local rebindState = state:extend()

function rebindState:begin()
  doCheckDelay = true
  megautils.add(rebinder)
  megautils.add(fade, false, nil, nil, fade.remove)
end

function rebindState:switching()
  doCheckDelay = false
end

rebinder = basicEntity:extend()

function rebinder:new()
  lastPressed.type = nil
  lastPressed.input = nil
  lastPressed.name = nil
  
  rebinder.super.new(self)
  self.x = 32
  self.y = 112
  self.keysToSet = {3, 4, 1, 2, 7, 8, 11, 9, 10, 5, 6}
  self.keyNames = {"left", "right", "up", "down", "jump", "shoot", "dash", "previous weapon", "next weapon", "start", "select"}
  self.currentKey = 1
  self.step = 0
  self.done = false
  self.data = save.load("main.sav") or {}
  self.data.controls = {}
  inputHandler.refreshGamepads()
end

function rebinder:update()
  if lastPressed.input == "escape" and not self.done then
    megautils.add(fade, true, nil, nil, function(s)
      megautils.gotoState(globals.sendBackToDisclaimer and globals.disclaimerState or globals.lastStateName)
      globals.sendBackToDisclaimer = nil
    end)
    return
  end
  if lastPressed.input and not self.done then
    self.data.controls[self.keysToSet[self.currentKey]+self.step] = {table.clone(lastPressed)}
    
    if self.currentKey == table.length(self.keysToSet) then
      if (self.step/11)+1 == globals.playerCount then
        self.done = true
        inputHandler.unbind()
        for k, v in pairs(self.data.controls) do
          inputHandler.bind(v, k)
        end
        control.usesDefaultBinds = false
        save.save("main.sav", self.data)
        megautils.add(fade, true, nil, nil, function(s)
            megautils.gotoState(globals.sendBackToDisclaimer and globals.disclaimerState or globals.lastStateName)
            globals.sendBackToDisclaimer = nil
          end)
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
  love.graphics.setFont(mmFont)
  love.graphics.printf("press the player " .. tostring((self.step/11)+1) .. " \n\""
    .. self.keyNames[self.currentKey] .. "\"!" ..
    "\n\n(press escape to leave)", self.x, self.y, 200, "center")
end

return rebindState