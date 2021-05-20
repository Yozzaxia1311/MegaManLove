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
  self.player = 1
  self.done = false
  self.data = save.load("main.sav") or {}
  self.data.inputBinds = {}
  self.dt = {}
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
    self.data.inputBinds[self.keys[self.currentKey] .. tostring(self.player)] = {table.clone(lastPressed)}
    if self.player == 1 then
      self.dt[#self.dt + 1] = self.keys[self.currentKey] .. tostring(self.player)
    end
    
    if self.currentKey == table.length(self.keys) then
      if self.player == megaMan.playerCount then
        self.done = true
        input.unbind()
        for k, v in pairs(self.data.inputBinds) do
          input.bind(v, k, table.contains(self.dt, k))
        end
        save.save("main.sav", self.data)
        megautils.add(fade, true, nil, nil, function(s)
            megautils.gotoState(globals.sendBackToDisclaimer and globals.disclaimerState or globals.lastStateName)
            globals.sendBackToDisclaimer = nil
          end)
      else
        self.currentKey = 1
        self.player = self.player + 1
      end
    else
      self.currentKey = math.min(self.currentKey + 1, table.length(self.keys))
    end
  end
end

function rebinder:draw()
  love.graphics.setFont(mmFont)
  love.graphics.printf("press the player " .. tostring(self.player) .. " \n\""
    .. self.keyNames[self.currentKey] .. "\"!" ..
    "\n\n(press escape to leave)", self.x, self.y, 200, "center")
end

return rebindState