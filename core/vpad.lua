vPad = {}

function vPad.ser()
  return {
      active = vPad.active,
      down = vPad.down,
      pressed = vPad.pressed,
      extra = vPad.extra
    }
end

function vPad.deser(t)
  vPad.active = t.active
  vPad.down = t.down
  vPad.pressed = t.pressed
  vPad.extra = t.extra
end

megautils.initEngineFuncs.vPad = {func=function()
    vPad.init()
  end, autoClean=false}

function vPad.init()
  vPad.active = false
  vPad.down = {}
  vPad.pressed = {}
  vPad.extra = {}
end

function vPad.update()
  local w, h = love.graphics.getDimensions()
  
  vPad.down.down = vPad.active and input.touchDownOverlaps(32 + 16, h - 81, 64, 64, true)
  vPad.pressed.down = vPad.active and input.touchPressedOverlaps(32 + 16, h - 81, 64, 64, true)
  
  vPad.down.left = vPad.active and input.touchDownOverlaps(8, h - 81 - 64, 64 + 8, 64, true)
  vPad.pressed.left = input.touchPressedOverlaps(8, h - 81 - 64, 64 + 8, 64, true)
  
  vPad.down.right = vPad.active and input.touchDownOverlaps(16 + 64, h - 81 - 64, 64 + 8, 64, true)
  vPad.pressed.right = vPad.active and input.touchPressedOverlaps(16 + 64, h - 81 - 64, 64 + 8, 64, true)
  
  vPad.down.up = vPad.active and input.touchDownOverlaps(32 + 16, h - 81 - 128, 64, 64, true)
  vPad.pressed.up = vPad.active and input.touchPressedOverlaps(32 + 16, h - 81 - 128, 64, 64, true)
  
  local downRightDown = vPad.active and input.touchDownOverlaps(32 + 64 + 16, h - 81, 32, 32, true)
  local downRightPressed = vPad.active and input.touchPressedOverlaps(32 + 64 + 16, h - 81, 32, 32, true)
  vPad.extra.downRight = downRightDown
  if downRightDown then
    vPad.down.down = downRightDown
    vPad.down.right = downRightDown
  end
  if downRightPressed then
    vPad.pressed.down = downRightPressed
    vPad.pressed.right = downRightPressed
  end
  
  local downLeftDown = vPad.active and input.touchDownOverlaps(16, h - 81, 32, 32, true)
  local downLeftPressed = vPad.active and input.touchPressedOverlaps(16, h - 81, 32, 32, true)
  vPad.extra.downLeft = downLeftDown
  if downLeftDown then
    vPad.down.down = downLeftDown
    vPad.down.left = downLeftDown
  end
  if downLeftPressed then
    vPad.pressed.down = downLeftPressed
    vPad.pressed.left = downLeftPressed
  end
  
  local upRightDown = vPad.active and input.touchDownOverlaps(32 + 64 + 16, h - 81 - 128 + 32, 32, 32, true)
  local upRightPressed = vPad.active and input.touchPressedOverlaps(32 + 64 + 16, h - 81 - 128 + 32, 32, 32, true)
  vPad.extra.upRight = upRightDown
  if upRightDown then
    vPad.down.up = upRightDown
    vPad.down.right = upRightDown
  end
  if upRightPressed then
    vPad.pressed.up = upRightPressed
    vPad.pressed.right = upRightPressed
  end
  
  local upLeftDown = vPad.active and input.touchDownOverlaps(16, h - 81 - 128 + 32, 32, 32, true)
  local upLeftPressed = vPad.active and input.touchPressedOverlaps(16, h - 81 - 128 + 32, 32, 32, true)
  vPad.extra.upLeft = upLeftDown
  if upLeftDown then
    vPad.down.up = upLeftDown
    vPad.down.left = upLeftDown
  end
  if upLeftPressed then
    vPad.pressed.up = upLeftPressed
    vPad.pressed.left = upLeftPressed
  end
  
  vPad.down.jump = vPad.active and input.touchDownOverlaps(w - 64 - 48, h - 128 - 16, 64, 64, true)
  vPad.pressed.jump = vPad.active and input.touchPressedOverlaps(w - 64 - 48, h - 128 - 16, 64, 64, true)
  
  vPad.down.shoot = vPad.active and input.touchDownOverlaps(w - 96 - 48, h - 64 - 16, 64, 64, true)
  vPad.pressed.shoot = vPad.active and input.touchPressedOverlaps(w - 96 - 48, h - 64 - 16, 64, 64, true)
  
  vPad.down.dash = vPad.active and input.touchDownOverlaps(w - 64 - 16, h - 128 - 64 - 16, 64, 64, true)
  vPad.pressed.dash = vPad.active and input.touchPressedOverlaps(w - 64 - 16, h - 128 - 64 - 16, 64, 64, true)
  
  vPad.down.start = vPad.active and input.touchDownOverlaps(16 + 48, 16, 32, 32, true)
  vPad.pressed.start = vPad.active and input.touchPressedOverlaps(16 + 48, 16, 32, 32, true)
  
  vPad.down.select = vPad.active and input.touchDownOverlaps(16, 16, 32, 32, true)
  vPad.pressed.select = vPad.active and input.touchPressedOverlaps(16, 16, 32, 32, true)
end

function vPad.draw()
  if vPad.active then
    local w, h = love.graphics.getDimensions()
    local r, g, b, a = love.graphics.getColor()
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 32 + 16, h - 81, 64, 64)
    love.graphics.setColor(1, (vPad.down.down and not vPad.extra.downRight and not vPad.extra.downLeft) and 0 or 1,
      (vPad.down.down and not vPad.extra.downRight and not vPad.extra.downLeft) and 0 or 1, 1)
    love.graphics.rectangle("line", 32 + 16, h - 81, 64, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 8, h - 81 - 64, 64 + 8, 64)
    love.graphics.setColor(1, (vPad.down.left and not vPad.extra.downLeft and not vPad.extra.upLeft) and 0 or 1,
      (vPad.down.left and not vPad.extra.downLeft and not vPad.extra.upLeft) and 0 or 1, 1)
    love.graphics.rectangle("line", 8, h - 81 - 64, 64 + 8, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 16 + 64, h - 81 - 64, 64 + 8, 64)
    love.graphics.setColor(1, (vPad.down.right and not vPad.extra.downRight and not vPad.extra.upRight) and 0 or 1,
      (vPad.down.right and not vPad.extra.downRight and not vPad.extra.upRight) and 0 or 1, 1)
    love.graphics.rectangle("line", 16 + 64, h - 81 - 64, 64 + 8, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 32 + 16, h - 81 - 128, 64, 64)
    love.graphics.setColor(1, (vPad.down.up and not vPad.extra.upRight and not vPad.extra.upLeft) and 0 or 1,
      (vPad.down.up and not vPad.extra.upRight and not vPad.extra.upLeft) and 0 or 1, 1)
    love.graphics.rectangle("line", 32 + 16, h - 81 - 128, 64, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 32 + 64 + 16, h - 81, 32, 32)
    love.graphics.setColor(1, vPad.extra.downRight and 0 or 1, vPad.extra.downRight and 0 or 1, 1)
    love.graphics.rectangle("line", 32 + 64 + 16, h - 81, 32, 32)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 16, h - 81, 32, 32)
    love.graphics.setColor(1, vPad.extra.downLeft and 0 or 1, vPad.extra.downLeft and 0 or 1, 1)
    love.graphics.rectangle("line", 16, h - 81, 32, 32)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 32 + 64 + 16, h - 81 - 128 + 32, 32, 32)
    love.graphics.setColor(1, vPad.extra.upRight and 0 or 1, vPad.extra.upRight and 0 or 1, 1)
    love.graphics.rectangle("line", 32 + 64 + 16, h - 81 - 128 + 32, 32, 32)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 16, h - 81 - 128 + 32, 32, 32)
    love.graphics.setColor(1, vPad.extra.upLeft and 0 or 1, vPad.extra.upLeft and 0 or 1, 1)
    love.graphics.rectangle("line", 16, h - 81 - 128 + 32, 32, 32)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", w - 64 - 48, h - 128 - 16, 64, 64)
    love.graphics.setColor(1, vPad.down.jump and 0 or 1, vPad.down.jump and 0 or 1, 1)
    love.graphics.rectangle("line", w - 64 - 48, h - 128 - 16, 64, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", w - 96 - 48, h - 64 - 16, 64, 64)
    love.graphics.setColor(1, vPad.down.shoot and 0 or 1, vPad.down.shoot and 0 or 1, 1)
    love.graphics.rectangle("line", w - 96 - 48, h - 64 - 16, 64, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", w - 64 - 16, h - 128 - 64 - 16, 64, 64)
    love.graphics.setColor(1, vPad.down.dash and 0 or 1, vPad.down.dash and 0 or 1, 1)
    love.graphics.rectangle("line", w - 64 - 16, h - 128 - 64 - 16, 64, 64)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 16 + 48, 16, 32, 32)
    love.graphics.setColor(1, vPad.down.start and 0 or 1, vPad.down.start and 0 or 1, 1)
    love.graphics.rectangle("line", 16 + 48, 16, 32, 32)
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 16, 16, 32, 32)
    love.graphics.setColor(1, vPad.down.select and 0 or 1, vPad.down.select and 0 or 1, 1)
    love.graphics.rectangle("line", 16, 16, 32, 32)
    
    love.graphics.setColor(r, g, b, a)
  end
end
