local rebindstate = states.state:extend()

function rebindstate:begin()
  loader.load("assets/sfx/cursor_move.ogg", "cursor_move", "sound")
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
  self.done = false
  self.data = save.load("main.set") or {}
  self.data.controls = {}
  control.input:refreshGamepads()
end

function rebinder:update(dt)
  if globals.lastKeyPressed ~= nil and globals.lastKeyPressed[1] == "escape" and not self.done then
    globals.lastKeyPressed = nil
    megautils.add(fade(true, nil, nil, function(s)
      states.set(ternary(globals.sendBackToDisclaimer, "states/menus/disclaimerstate.lua", "states/menus/menustate.lua"))
      if not globals.sendBackToDisclaimer then
        megautils.add(fade(false, nil, nil, fade.remove))
      end
      globals.sendBackToDisclaimer = nil
    end))
    self.updated = false
    return
  end
  if globals.lastKeyPressed ~= nil and not self.done then
    self.data.controls[self.keysToSet[self.currentKey]] = globals.lastKeyPressed
    if self.currentKey == table.length(self.keysToSet) then
      self.currentKey = table.length(self.keysToSet)
      self.done = true
      control.input:unbind()
      for k, v in pairs(self.data.controls) do
        control.input:bind(v[1], k, v[2])
      end
      save.save("main.set", self.data)
      if globals.sendBackToDisclaimer then
        megautils.add(fade(true, nil, nil, function(s)
          states.set("states/menus/disclaimerstate.lua")
          globals.sendBackToDisclaimer = nil
        end))
      else
        megautils.gotoState("states/menus/menustate.lua")
      end
    end
    self.currentKey = math.min(self.currentKey + 1, table.length(self.keysToSet))
    globals.lastKeyPressed = nil
  end
end

function rebinder:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(mmFont)
  love.graphics.printf("press the '"
    .. self.keyNames[self.currentKey] .. "' key!" ..
    "\n\n(press escape to leave)", self.transform.x, self.transform.y, 200, "center")
end

return rebindstate