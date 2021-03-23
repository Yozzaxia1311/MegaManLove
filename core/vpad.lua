vPad = {}

function vPad.init()
  vPad.active = true
  vPad.down = {}
  vPad.pressed = {}
end

function vPad.update()
  local w, h = love.graphics.getDimensions()
  
  vPad.down.down = input.touchDownOverlaps(0, h - 81, 64, 64, true)
  vPad.pressed.down = input.touchPressedOverlaps(0, h - 81, 64, 64, true)
end

function vPad.draw()
  if vPad.active then
    local w, h = love.graphics.getDimensions()
    local r, g, b, a = love.graphics.getColor()
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, h - 81, 64, 64)
    love.graphics.setColor(1, vPad.down.down and 0 or 1, vPad.down.down and 0 or 1, 1)
    love.graphics.rectangle("line", 0, h - 81, 64, 64)
    
    love.graphics.setColor(r, g, b, a)
  end
end