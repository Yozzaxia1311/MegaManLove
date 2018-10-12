touchInput = {}

function touchInput.init(w, h)
  touchInput.w = w
  touchInput.h = h
  touchInput.buttons = {}
  touchInput.pressed = {}
end

function touchInput.resize(w, h)
  touchInput.w = w
  touchInput.h = h
end

function touchInput.add(name, align, offx, offy, w, h)
  touchInput.buttons[name] = {align, offx, offy, w, h}
end

function touchInput.down(n)
  if touchInput.buttons[n] == nil then return end
  local touches = {}
  if love.touch then
    for k, v in ipairs(love.touch.getTouches()) do
      local x, y = love.touch.getPosition(v)
      touches[#touches+1] = {["x"]=x, ["y"]=y}
    end
  elseif love.mouse and love.mouse.isDown(1) then
    touches[1] = {}
    touches[1].x = love.mouse.getX()
    touches[1].y = love.mouse.getY()
  end
  local x, y = touchInput.buttons[n][2], touchInput.h+touchInput.buttons[n][3]
  if touchInput.buttons[n][1] == "right-down" then
    x = touchInput.w+touchInput.buttons[n][2]
    y = touchInput.h+touchInput.buttons[n][3]
  elseif touchInput.buttons[n][1] == "right-up" then
    x = touchInput.w+touchInput.buttons[n][2]
    y = touchInput.buttons[n][3]
  elseif touchInput.buttons[n][1] == "left-up" then
    x = touchInput.buttons[n][2]
    y = touchInput.buttons[n][3]
  end
  for k, v in ipairs(touches) do
    if pointRectOverlaps(v.x, v.y, x, y, touchInput.buttons[n][4], touchInput.buttons[n][5]) then
      return true
    end
  end
  return false
end

function touchInput.touchPressed(button) end

function touchInput.update()
  for k, v in pairs(touchInput.buttons) do
    if not touchInput.pressed[k] and touchInput.down(k) then
      touchInput.pressed[k] = true
      touchInput.touchPressed(k)
    end
  end
end

function touchInput.flush()
  for k, v in pairs(touchInput.pressed) do
    if not touchInput.down(k) then
      touchInput.pressed[k] = nil
    end
  end
end

function touchInput.draw()
  for k, v in pairs(touchInput.buttons) do
    if not touchInput.down(k) then
      love.graphics.setColor(1, 1, 1, 0.7)
    else
      love.graphics.setColor(1, 0, 0, 0.7)
    end
    if v[1] == "left-down" then
      love.graphics.rectangle("line", v[2], touchInput.h+v[3], v[4], v[5])
    elseif v[1] == "right-down" then
      love.graphics.rectangle("line", touchInput.w+v[2], touchInput.h+v[3], v[4], v[5])
    elseif v[1] == "right-up" then
      love.graphics.rectangle("line", touchInput.w+v[2], v[3], v[4], v[5])
    elseif v[1] == "left-up" then
      love.graphics.rectangle("line", v[2], v[3], v[4], v[5])
    end
  end
end

inputHandler = class:extend()

function inputHandler:new()
  self.keys = {}
  self.pressedTable = {}
  self.gamepads = love.joystick.getJoysticks()
end

function inputHandler:refreshGamepads()
  self.gamepads = love.joystick.getJoysticks()
end

function inputHandler:bind(v, k, t)
  self.keys[k] = {t, v}
end

function inputHandler:unbind(k)
  if k == nil then
    self.keys = {}
    self.pressedTable = {}
  else
    self.keys[k] = nil
    self.pressedTable[k] = nil
  end
end

function inputHandler:down(k)
  if self.keys[k][1] == "keyboard" then
    return love.keyboard.isDown(self.keys[k][2])
  elseif self.keys[k][1] == "touch" then
    return touchInput.down(self.keys[k][2])
  elseif self.keys[k][1] == "gamepad" then
    for i, v in ipairs(self.gamepads) do
      if v:isGamepadDown(self.keys[k][2]) then
        return true
      end
    end
  elseif self.keys[k][1] == "axis" then
    for i, v in ipairs(self.gamepads) do
      if math.abs(v:getGamepadAxis("leftx")) > math.abs(v:getGamepadAxis("lefty")) then
        if self.keys[k][2] == "leftx+" and v:getGamepadAxis("leftx") > deadZone then
          return true
        elseif self.keys[k][2] == "leftx-" and v:getGamepadAxis("leftx") < -deadZone then
          return true
        end
      else
        if self.keys[k][2] == "lefty+" and v:getGamepadAxis("lefty") > deadZone then
          return true
        elseif self.keys[k][2] == "lefty-" and v:getGamepadAxis("lefty") < -deadZone then
          return true
        end
      end
      if math.abs(v:getGamepadAxis("rightx")) > math.abs(v:getGamepadAxis("righty")) then
        if self.keys[k][2] == "rightx+" and v:getGamepadAxis("rightx") > deadZone then
          return true
        elseif self.keys[k][2] == "rightx-" and v:getGamepadAxis("rightx") < -deadZone then
          return true
        end
      else
        if self.keys[k][2] == "righty+" and v:getGamepadAxis("righty") > deadZone then
          return true
        elseif self.keys[k][2] == "righty-" and v:getGamepadAxis("righty") < -deadZone then
          return true
        end
      end
      if self.keys[k][2] == "triggerleft+" and v:getGamepadAxis("triggerleft") > deadZone then
        return true
      elseif self.keys[k][2] == "triggerleft-" and v:getGamepadAxis("triggerleft") < -deadZone then
        return true
      end
      if self.keys[k][2] == "triggerright+" and v:getGamepadAxis("triggerright") > deadZone then
        return true
      elseif self.keys[k][2] == "triggerright-" and v:getGamepadAxis("triggerright") < -deadZone then
        return true
      end
    end
  end
  return false
end

function inputHandler:pressed(k)
  if not self.pressedTable[k] and self:down(k) then
    self.pressedTable[k] = true
    return true
  end
  return false
end

function inputHandler:anyDown()
  for k, v in pairs(self.keys) do
    if self:down(k) then
      return true
    end
  end
  return false
end

function inputHandler:flush()
  for k, v in pairs(self.pressedTable) do
    if not self:down(k) then
      self.pressedTable[k] = nil
    end
  end
end