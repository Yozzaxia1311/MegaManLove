touchInput = {}

function touchInput.init(w, h)
  touchInput.w = w
  touchInput.h = h
  touchInput.touchX = 0
  touchInput.touchY = 0
  touchInput.buttons = {}
  touchInput.pressed = {}
  touchInput.screenPressed = false
end

function touchInput.resize(w, h)
  touchInput.w = w
  touchInput.h = h
end

function touchInput.add(name, align, offx, offy, w, h)
  touchInput.buttons[name] = {align, offx, offy, w, h}
end

function touchInput.updateTouchPos()
  if love.mouse and love.mouse.isDown(1) then
    touchInput.touchX, touchInput.touchY = love.mouse.getX(), love.mouse.getY()
  elseif love.touch then
    for k, v in ipairs(touchInput.touches) do
      touchInput.touchX, touchInput.touchY = love.touch.getPosition(v)
    end
  end
end

function touchInput.down(n)
  local touches = {}
  if love.mouse and love.mouse.isDown(1) then
    touches[1] = {}
    touches[1].x = love.mouse.getX()
    touches[1].y = love.mouse.getY()
  elseif love.touch then
    for k, v in ipairs(touchInput.touches) do
      local x, y = love.touch.getPosition(v)
      touches[#touches+1] = {["x"]=x, ["y"]=y}
    end
  end
  if n then
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
      if pointOverlapsRect(v.x, v.y, x, y, touchInput.buttons[n][4], touchInput.buttons[n][5]) then
        return true
      end
    end
  else
    return #touches ~= 0
  end
  return false
end

function touchInput.touchPressed(button) end

function touchInput.update()
  touchInput.touches = love.touch.getTouches()
  if not touchInput.screenPressed and touchInput.down() then
    touchInput.screenPressed = true
    touchInput.updateTouchPos()
  end
  for k, v in pairs(touchInput.buttons) do
    if not touchInput.pressed[k] and touchInput.down(k) then
      touchInput.pressed[k] = true
      touchInput.touchPressed(k)
    end
  end
end

function touchInput.flush()
  touchInput.screenPressed = false
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

inputHandler = {}

function inputHandler.init()
  inputHandler.keys = {}
  inputHandler.pressedTable = {}
  inputHandler.gamepads = love.joystick.getJoysticks()
  touchInput.init(love.graphics.getWidth(), love.graphics.getHeight())
end

function inputHandler.refreshGamepads()
  inputHandler.gamepads = love.joystick.getJoysticks()
end

function inputHandler.bind(v, k, t, n)
  inputHandler.keys[k] = {t, v, n}
end

function inputHandler.unbind(k)
  if not k then
    inputHandler.keys = {}
    inputHandler.pressedTable = {}
  else
    inputHandler.keys[k] = nil
    inputHandler.pressedTable[k] = nil
  end
end

function inputHandler.down(k)
  if (console and console.state == 1) or not inputHandler.keys[k] then
    return false
  end
  if inputHandler.keys[k][1] == "keyboard" then
    return love.keyboard.isDown(inputHandler.keys[k][2])
  elseif inputHandler.keys[k][1] == "touch" then
    return touchInput.down(inputHandler.keys[k][2])
  elseif inputHandler.keys[k][1] == "gamepad" then
    for i, v in ipairs(inputHandler.gamepads) do
      if inputHandler.keys[k][3] == v:getName() and v:isGamepadDown(inputHandler.keys[k][2]) then
        return true
      end
    end
  elseif inputHandler.keys[k][1] == "axis" then
    for i, v in ipairs(inputHandler.gamepads) do
      if inputHandler.keys[k][3] == v:getName() then
        if inputHandler.keys[k][2] == "leftx+" and v:getGamepadAxis("leftx") > deadZone then
          return v:getGamepadAxis("leftx")
        elseif inputHandler.keys[k][2] == "leftx-" and v:getGamepadAxis("leftx") < -deadZone then
          return v:getGamepadAxis("leftx")
        end
        if inputHandler.keys[k][2] == "lefty+" and v:getGamepadAxis("lefty") > deadZone then
          return v:getGamepadAxis("lefty")
        elseif inputHandler.keys[k][2] == "lefty-" and v:getGamepadAxis("lefty") < -deadZone then
          return v:getGamepadAxis("lefty")
        end
        if inputHandler.keys[k][2] == "rightx+" and v:getGamepadAxis("rightx") > deadZone then
          return v:getGamepadAxis("rightx")
        elseif inputHandler.keys[k][2] == "rightx-" and v:getGamepadAxis("rightx") < -deadZone then
          return v:getGamepadAxis("rightx")
        end
        if inputHandler.keys[k][2] == "righty+" and v:getGamepadAxis("righty") > deadZone then
          return v:getGamepadAxis("righty")
        elseif inputHandler.keys[k][2] == "righty-" and v:getGamepadAxis("righty") < -deadZone then
          return v:getGamepadAxis("righty")
        end
        if inputHandler.keys[k][2] == "triggerleft+" and v:getGamepadAxis("triggerleft") > deadZone then
          return v:getGamepadAxis("triggerleft")
        elseif inputHandler.keys[k][2] == "triggerleft-" and v:getGamepadAxis("triggerleft") < -deadZone then
          return v:getGamepadAxis("triggerleft")
        end
        if inputHandler.keys[k][2] == "triggerright+" and v:getGamepadAxis("triggerright") > deadZone then
          return v:getGamepadAxis("triggerright")
        elseif inputHandler.keys[k][2] == "triggerright-" and v:getGamepadAxis("triggerright") < -deadZone then
          return v:getGamepadAxis("triggerright")
        end
      end
    end
  end
  return false
end

function inputHandler.pressed(k)
  if console and console.state == 1 then
    return false
  end
  if not inputHandler.pressedTable[k] then
    local res = inputHandler.down(k)
    if res then
      inputHandler.pressedTable[k] = true
      return res
    end
  end
  return false
end

function inputHandler.anyDown()
  if console and console.state == 1 then
    return false
  end
  for k, v in pairs(inputHandler.keys) do
    if inputHandler.down(k) then
      return true
    end
  end
  return false
end

function inputHandler.flush()
  for k, v in pairs(inputHandler.pressedTable) do
    if not inputHandler.down(k) then
      inputHandler.pressedTable[k] = nil
    end
  end
end