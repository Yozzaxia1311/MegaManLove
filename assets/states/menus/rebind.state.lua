local rebindState = state:extend()

function rebindState:begin()
  doCheckDelay = true
  entities.add(rebinder)
  entities.add(fade, false, nil, nil, fade.remove)
end

function rebindState:switching()
  doCheckDelay = false
end

rebinder = basicEntity:extend()

rebinder.invisibleToHash = true

function rebinder:new()
  lastPressed.type = nil
  lastPressed.input = nil
  lastPressed.name = nil
  
  rebinder.super.new(self)
  self.x = 32
  self.y = 112
  self.keys = {"left", "right", "up", "down", "jump", "shoot", "dash", "prev", "next", "start", "select"}
  self.keyNames = {"left", "right", "up", "down", "jump", "shoot", "dash", "previous weapon", "next weapon", "start", "select"}
  self.currentKey = 1
  self.player = globals.rPlayer or 1
  globals.rPlayer = nil
  self.done = false
  self.data = save.load("main.sav") or {}
  if not self.data.inputBinds then
    self.data.inputBinds = {}
  end
  self.dt = {}
end

function rebinder:update()
  if (lastPressed.input == "escape" or lastPressed.input == "guide") and not self.done then
    entities.add(fade, true, nil, nil, function(s)
      if not globals.sendBackToDisclaimer and not globals.sendBackToPlayers then
        globals.fromOther = 5
      end
      states.setq(globals.sendBackToDisclaimer and globals.disclaimerState or
        (globals.sendBackToPlayers and globals.playerSelectState or globals.lastStateName))
      globals.sendBackToDisclaimer = nil
      globals.sendBackToPlayers = nil
    end)
    return
  end
  if lastPressed.input and not self.done then
    self.data.inputBinds[self.keys[self.currentKey] .. tostring(self.player)] = {table.clone(lastPressed)}
    if self.player == 1 then
      self.dt[#self.dt + 1] = self.keys[self.currentKey] .. tostring(self.player)
    end
    
    if self.currentKey == table.length(self.keys) then
      self.done = true
      for k, _ in safepairs(input.keys) do
        if k:sub(-1) == tostring(self.player) then
          input.unbind(k)
        end
      end
      for k, v in pairs(self.data.inputBinds) do
        input.bind(v, k, table.contains(self.dt, k))
      end
      save.save("main.sav", self.data)
      entities.add(fade, true, nil, nil, function(s)
          if not globals.sendBackToDisclaimer and not globals.sendBackToPlayers then
            globals.fromOther = 5
          end
          states.setq(globals.sendBackToDisclaimer and globals.disclaimerState or
            (globals.sendBackToPlayers and globals.playerSelectState or globals.lastStateName))
          globals.sendBackToDisclaimer = nil
          globals.sendBackToPlayers = nil
        end)
    else
      self.currentKey = math.min(self.currentKey + 1, table.length(self.keys))
    end
  end
end

function rebinder:draw()
  love.graphics.setFont(mmFont)
  love.graphics.printf("Press the player " .. tostring(self.player) .. " \n\""
    .. self.keyNames[self.currentKey] .. "\"!" ..
    "\n\n(press " .. (input.gamepads ~= 0 and "Escape or Guide" or "Escape") .. " to leave)", self.x, self.y, 200, "center")
end

return rebindState