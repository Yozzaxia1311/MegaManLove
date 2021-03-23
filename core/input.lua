input = {}

function input.ser()
  return {
      deactivateTouch = input.deactivateTouch,
      usingTouch = input.usingTouch
    }
end

function input.deser(t)
  input.deactivateTouch = t.deactivateTouch
  input.usingTouch = t.usingTouch
end

function input.pairs(t)
  local function iter(tbl, k)
    local v
    
    if tbl == input.down then
      k, v = next(input._downSV, k)
    elseif tbl == input.pressed then
      k, v = next(input._pressedSV, k)
    elseif tbl == input.touchDown then
      k, v = next(input._touchDownSV, k)
    elseif tbl == input.touchPressed then
      k, v = next(input._touchPressedSV, k)
    end
    
    return k, v
  end
  
  return iter, t, nil
end

function input.length(t)
  if t == input.down then
    return table.length(input._downSV)
  elseif t == input.pressed then
    return table.length(input._pressedSV)
  elseif t == input.touchDown then
    return #input._touchDownSV
  elseif t == input.touchPressed then
    return #input._touchPressedSV
  end
end

input._downMT = {__newindex = function(self, k, v)
    input._downSV[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].down then
        return record.loadedRec.data[record.loadedRecPos].down[k]
      end
      
      return
    end
    
    return input._downSV[k]
  end}

input._pressedMT = {__newindex = function(self, k, v)
    input._pressedSV[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].pressed then
        return record.loadedRec.data[record.loadedRecPos].pressed[k]
      end
      
      return
    end
    
    return input._pressedSV[k]
  end}

input._touchDownMT = {__newindex = function(self, k, v)
    input._touchDownSV[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].touchDown then
        return record.loadedRec.data[record.loadedRecPos].touchDown[k]
      end
      
      return
    end
    
    return input._touchDownSV[k]
  end}

input._touchPressedMT = {__newindex = function(self, k, v)
    input._touchPressedSV[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].touchPressed then
        return record.loadedRec.data[record.loadedRecPos].touchPressed[k]
      end
      
      return
    end
    
    return input._touchPressedSV[k]
  end}

function input.init()
  input.keys = {}
  input._pressedTable = {}
  input.gamepads = love.joystick and love.joystick.getJoysticks()
  input.down = {}
  input._downSV = {}
  setmetatable(input.down, input._downMT)
  input.pressed = {}
  input._pressedSV = {}
  setmetatable(input.pressed, input._pressedMT)
  input.touchDown = {}
  input._touchDownSV = {}
  setmetatable(input.touchDown, input._touchDownMT)
  input.touchPressed = {}
  input._touchPressedSV = {}
  setmetatable(input.touchPressed, input._touchPressedMT)
  input.deactivateTouch = {}
  input.usingTouch = isMobile or (not love.keyboard and (love.mouse or love.touch))
end

function input.refreshGamepads()
  input.gamepads = love.joystick.getJoysticks()
end

function input.bind(v, k, deactivateTouch)
  input.keys[k] = v
  input.down[k] = false
  input.pressed[k] = false
  input._pressedTable[k] = nil
  if deactivateTouch then
    input.deactivateTouch[k] = true
  end
end

function input.unbind(k)
  if not k then
    input.keys = {}
    input._pressedTable = {}
    input.down = {}
    input._downSV = {}
    setmetatable(input.down, input._downMT)
    input.pressed = {}
    input._pressedSV = {}
    setmetatable(input.pressed, input._pressedMT)
    input.deactivateTouch = {}
  else
    input.keys[k] = nil
    input._pressedTable[k] = nil
    input.down[k] = nil
    input.pressed[k] = nil
    input.deactivateTouch[k] = nil
  end
end

function input._down(k)
  if not input.keys[k] then
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

function input.touchDownOverlaps(x, y, w, h, realCoords)
  for _, v in input.pairs(input.touchDown) do
    if pointOverlapsRect(realCoords and v.realX or v.x, realCoords and v.realY or v.y, x, y, w, h) then
      return true
    end
  end
  
  return false
end

function input.touchPressedOverlaps(x, y, w, h, realCoords)
  for _, v in input.pairs(input.touchPressed) do
    if pointOverlapsRect(realCoords and v.realX or v.x, realCoords and v.realY or v.y, x, y, w, h) then
      return true
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
  return input.length(input.touchDown) ~= 0
end

function input.poll()
  if console and console.state == 1 then return end
  
  for k, _ in pairs(input.keys) do
    input.down[k] = input._down(k)
    input.pressed[k] = input._pressed(k)
    
    if input.down[k] and input.deactivateTouch[k] then
      input.usingTouch = false
    end
  end
  
  if love.touch or love.mouse then
    local newTouches = love.touch and love.touch.getTouches() or {}
    local ids = {}
    
    if love.mouse and love.mouse.isDown(1, 2, 3) then
      newTouches[#newTouches + 1] = "mousetouch"
    end
    
    for k, v in input.pairs(input.touchDown) do
      if not table.icontains(newTouches, v.id) then
        local len = input.length(input.touchDown)
        if input.touchDown[len] == v then input.touchDown[len] = nil return end
        for i=1, len do
          if input.touchDown[i] == v then
            input.touchDown[i] = input.touchDown[len]
            input.touchDown[len] = nil
            break
          end
        end
      end
    end
    
    for _, v in input.pairs(input.touchDown) do
      ids[#ids + 1] = v.id
    end
    
    for _, v in pairs(newTouches) do
      if not table.icontains(ids, v) then
        if love.mouse and v == "mousetouch" then
          local realX, realY = love.mouse.getPosition()
          local x, y = cscreen.project(realX, realY)
          input.touchDown[input.length(input.touchDown) + 1] = {id = v, x = x, y = y, pressure = 1, realX = realX, realY = realY}
          input.touchPressed[input.length(input.touchPressed) + 1] = {id = v, x = x, y = y, pressure = 1, realX = realX, realY = realY}
        elseif love.touch then
          local realX, realY = love.touch.getPosition(v)
          local x, y = cscreen.project(realX, realY)
          local p = love.touch.getPressure(v)
          input.touchDown[input.length(input.touchDown) + 1] = {id = v, x = x, y = y, pressure = p, realX = realX, realY = realY}
          input.touchPressed[input.length(input.touchPressed) + 1] = {id = v, x = x, y = y, pressure = p, realX = realX, realY = realY}
        end
      end
    end
    
    for _, v in input.pairs(input.touchDown) do
      if love.mouse and v.id == "mousetouch" then
        v.realX, v.realY = love.mouse.getPosition()
        v.x, v.y = cscreen.project(v.realX, v.realY)
      elseif love.touch and table.icontains(newTouches, v.id) then
        v.realX, v.realY = love.touch.getPosition(v.id)
        v.x, v.y = cscreen.project(v.realX, v.realY)
        v.pressure = love.touch.getPressure(v.id)
      end
    end
    
    for _, v in input.pairs(input.touchPressed) do
      if love.mouse and v.id == "mousetouch" then
        v.realX, v.realY = love.mouse.getPosition()
        v.x, v.y = cscreen.project(v.realX, v.realY)
      elseif love.touch and table.icontains(newTouches, v.id) then
        v.realX, v.realY = love.touch.getPosition(v.id)
        v.x, v.y = cscreen.project(v.realX, v.realY)
        v.pressure = love.touch.getPressure(v.id)
      end
    end
  end
end

function input.flush()
  for k, _ in pairs(input._pressedTable) do
    if not input._down(k) then
      input._pressedTable[k] = nil
    end
  end
  
  input.touchPressed = {}
  input._touchPressedSV = {}
  setmetatable(input.touchPressed, input._touchPressedMT)
end

input._dTimer = 0

function input.draw()
  if input._checkD == nil then
    input._checkD = input.usingTouch
  end
  if input._checkD ~= input.usingTouch then
    input._dTimer = 100
    input._checkD = input.usingTouch
  end
  if input._dTimer > 0 then
    input._dTimer = math.max(input._dTimer - 1, 0)
    local na = input._dTimer % 12 < 6
    local r, g, b, a = love.graphics.getColor()
    
    if input.usingTouch then
      love.graphics.setColor(0, 0, 0, na and 0.4 or 0)
      love.graphics.rectangle("fill", 0, 0, 8*22, 24)
    else
      love.graphics.setColor(0, 0, 0, na and 0.4 or 0)
      love.graphics.rectangle("fill", 0, 0, 8*24, 24)
    end
    love.graphics.setColor(1, 1, 1, na and 0.8 or 0)
    love.graphics.print(input.usingTouch and "TOUCH MODE ACTIVATED" or "TOUCH MODE DEACTIVATED", 8, 8)
    love.graphics.setColor(r, g, b, a)
  end
end
