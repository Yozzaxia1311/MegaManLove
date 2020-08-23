local rebindState = state:extend()

function rebindState:begin()
  megautils.add(rebinder)
  megautils.add(fade, false, nil, nil, fade.remove)
end

rebinder = basicEntity:extend()

binser.register(rebinder, "rebinder", function(o)
    local result = {}
    
    rebinder.super.transfer(o, result)
    
    result.currentKey = o.currentKey
    result.step = o.step
    result.done = o.done
    result.data = o.data
    
    return result
  end, function(o)
    local result = rebinder()
    
    rebinder.super.transfer(o, result)
    
    result.currentKey = o.currentKey
    result.step = o.step
    result.done = o.done
    result.data = o.data
    
    return result
  end)

function rebinder:new()
  lastPressed = nil
  rebinder.super.new(self)
  self.transform.x = 32
  self.transform.y = 112
  self.keysToSet = {3, 4, 1, 2, 7, 8, 11, 9, 10, 5, 6}
  self.keyNames = {"left", "right", "up", "down", "jump", "shoot", "dash", "previous weapon", "next weapon", "start", "select"}
  self.currentKey = 1
  self.step = 0
  self.done = false
  self.data = save.load("main.sav") or {}
  self.data.controls = {}
  inputHandler.refreshGamepads()
end

function rebinder:added()
  self:addToGroup("freezable")
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
    self.data.controls[self.keysToSet[self.currentKey]+self.step] = {lastPressed}
    lastPressed = nil
    
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
    "\n\n(press escape to leave)", self.transform.x, self.transform.y, 200, "center")
end

return rebindState