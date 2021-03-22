input = {}

input._downMT = {__newindex = function(self, k, v)
    rawget(self, "_sv")[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].down then
        return record.loadedRec.data[record.loadedRecPos].down[k]
      end
      
      return
    end
    
    return rawget(self, "_sv")[k]
  end}

input._pressedMT = {__newindex = function(self, k, v)
    rawget(self, "_sv")[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].pressed then
        return record.loadedRec.data[record.loadedRecPos].pressed[k]
      end
      
      return
    end
    
    return rawget(self, "_sv")[k]
  end}

function input.init()
  input.keys = {}
  input._pressedTable = {}
  input.gamepads = love.joystick and love.joystick.getJoysticks()
  input.down = {_sv = {}}
  setmetatable(input.down, input._downMT)
  input.pressed = {_sv = {}}
  setmetatable(input.pressed, input._pressedMT)
end

function input.refreshGamepads()
  input.gamepads = love.joystick.getJoysticks()
end

function input.bind(v, k)
  input.keys[k] = v
  input.down[k] = false
  input.pressed[k] = false
  input._pressedTable[k] = nil  
end

function input.unbind(k)
  if not k then
    input.keys = {}
    input._pressedTable = {}
    input.down = {_sv = {}}
    setmetatable(input.down, input._downMT)
    input.pressed = {_sv = {}}
    setmetatable(input.pressed, input._pressedMT)
  else
    input.keys[k] = nil
    input._pressedTable[k] = nil
    input.down[k] = nil
    input.pressed[k] = nil
  end
end

function input._down(k)
  if (console and console.state == 1) or not input.keys[k] then
    return false
  end
  local result = false
  for i=1, #input.keys[k] do
    if input.keys[k][i].type == "keyboard" then
      local v = input.keys[k][i].input
      result = love.keyboard.isDown(v) and not pressingHardInputs(v)
    elseif input.keys[k][i].type == "gamepad" then
      for _, v in ipairs(input.gamepads) do
        if input.keys[k][i].name == v:getName() and v:isGamepadDown(input.keys[k][i].input) then
          result = true
          break
        end
      end
    elseif input.keys[k][i].type == "axis" then
      for _, v in ipairs(input.gamepads) do
        if input.keys[k][i].name == v:getName() then
          local input = input.keys[k][i].input
          if input == "leftx+" and v:getGamepadAxis("leftx") > deadZone then
            result = v:getGamepadAxis("leftx")
            break
          elseif input == "leftx-" and v:getGamepadAxis("leftx") < -deadZone then
            result = v:getGamepadAxis("leftx")
            break
          end
          if input == "lefty+" and v:getGamepadAxis("lefty") > deadZone then
            result = v:getGamepadAxis("lefty")
            break
          elseif input == "lefty-" and v:getGamepadAxis("lefty") < -deadZone then
            result = v:getGamepadAxis("lefty")
            break
          end
          if input == "rightx+" and v:getGamepadAxis("rightx") > deadZone then
            result = v:getGamepadAxis("rightx")
            break
          elseif input == "rightx-" and v:getGamepadAxis("rightx") < -deadZone then
            result = v:getGamepadAxis("rightx")
            break
          end
          if input == "righty+" and v:getGamepadAxis("righty") > deadZone then
            result = v:getGamepadAxis("righty")
            break
          elseif input == "righty-" and v:getGamepadAxis("righty") < -deadZone then
            result = v:getGamepadAxis("righty")
            break
          end
          if input == "triggerleft+" and v:getGamepadAxis("triggerleft") > deadZone then
            result = v:getGamepadAxis("triggerleft")
            break
          elseif input == "triggerleft-" and v:getGamepadAxis("triggerleft") < -deadZone then
            result = v:getGamepadAxis("triggerleft")
            break
          end
          if input == "triggerright+" and v:getGamepadAxis("triggerright") > deadZone then
            result = v:getGamepadAxis("triggerright")
            break
          elseif input == "triggerright-" and v:getGamepadAxis("triggerright") < -deadZone then
            result = v:getGamepadAxis("triggerright")
            break
          end
        end
      end
    elseif input.keys[k][i].type == "custom" then
      if input.keys[k][i].func then
        result = input.keys[k][i].func()
      end
    end
    if result then break end
  end
  return result
end

function input._pressed(k)
  if console and console.state == 1 then
    return false
  end
  if not input._pressedTable[k] then
    local res = input._down(k)
    if res then
      input._pressedTable[k] = true
      return res
    end
  end
  return false
end

function input.anyDown()
  if console and console.state == 1 then
    return false
  end
  for k, _ in pairs(input.keys) do
    if input._down(k) then
      return true
    end
  end
  return false
end

function input.poll()
  for k, _ in pairs(input.keys) do
    input.down[k] = input._down(k)
    input.pressed[k] = input._pressed(k)
  end
end

function input.flush()
  for k, _ in pairs(input._pressedTable) do
    if not input._down(k) then
      input._pressedTable[k] = nil
    end
  end
end