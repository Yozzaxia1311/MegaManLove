inputHandler = {}

function inputHandler.init()
  inputHandler.keys = {}
  inputHandler.pressedTable = {}
  inputHandler.gamepads = love.joystick.getJoysticks()
  inputHandler.custom = {}
end

function inputHandler.refreshGamepads()
  inputHandler.gamepads = love.joystick.getJoysticks()
end

function inputHandler.bind(v, k)
  inputHandler.keys[k] = v
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
  local result = false
  for i=1, #inputHandler.keys[k] do
    if inputHandler.keys[k][i][1] == "keyboard" then
      result = love.keyboard.isDown(inputHandler.keys[k][i][2])
    elseif inputHandler.keys[k][i][1] == "gamepad" then
      for _, v in ipairs(inputHandler.gamepads) do
        if inputHandler.keys[k][i][3] == v:getName() and v:isGamepadDown(inputHandler.keys[k][i][2]) then
          result = true
          break
        end
      end
    elseif inputHandler.keys[k][i][1] == "axis" then
      for _, v in ipairs(inputHandler.gamepads) do
        if inputHandler.keys[k][i][3] == v:getName() then
          if inputHandler.keys[k][i][2] == "leftx+" and v:getGamepadAxis("leftx") > deadZone then
            result = v:getGamepadAxis("leftx")
            break
          elseif inputHandler.keys[k][i][2] == "leftx-" and v:getGamepadAxis("leftx") < -deadZone then
            result = v:getGamepadAxis("leftx")
            break
          end
          if inputHandler.keys[k][i][2] == "lefty+" and v:getGamepadAxis("lefty") > deadZone then
            result = v:getGamepadAxis("lefty")
            break
          elseif inputHandler.keys[k][i][2] == "lefty-" and v:getGamepadAxis("lefty") < -deadZone then
            result = v:getGamepadAxis("lefty")
            break
          end
          if inputHandler.keys[k][i][2] == "rightx+" and v:getGamepadAxis("rightx") > deadZone then
            result = v:getGamepadAxis("rightx")
            break
          elseif inputHandler.keys[k][i][2] == "rightx-" and v:getGamepadAxis("rightx") < -deadZone then
            result = v:getGamepadAxis("rightx")
            break
          end
          if inputHandler.keys[k][i][2] == "righty+" and v:getGamepadAxis("righty") > deadZone then
            result = v:getGamepadAxis("righty")
            break
          elseif inputHandler.keys[k][i][2] == "righty-" and v:getGamepadAxis("righty") < -deadZone then
            result = v:getGamepadAxis("righty")
            break
          end
          if inputHandler.keys[k][i][2] == "triggerleft+" and v:getGamepadAxis("triggerleft") > deadZone then
            result = v:getGamepadAxis("triggerleft")
            break
          elseif inputHandler.keys[k][i][2] == "triggerleft-" and v:getGamepadAxis("triggerleft") < -deadZone then
            result = v:getGamepadAxis("triggerleft")
            break
          end
          if inputHandler.keys[k][i][2] == "triggerright+" and v:getGamepadAxis("triggerright") > deadZone then
            result = v:getGamepadAxis("triggerright")
            break
          elseif inputHandler.keys[k][i][2] == "triggerright-" and v:getGamepadAxis("triggerright") < -deadZone then
            result = v:getGamepadAxis("triggerright")
            break
          end
        end
      end
    elseif inputHandler.keys[k][i][1] == "custom" then
      if inputHandler.custom[k] then
        result = inputHandler.custom[k]()
      end
    end
    if result then break end
  end
  return result
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