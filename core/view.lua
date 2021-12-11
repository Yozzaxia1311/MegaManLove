view = {}

function view.ser()
  return {
      x=view.x,
      y=view.y,
      w=view.w,
      h=view.h,
      cscr=cscreen.ser()
    }
end

function view.deser(t)
  view.x = t.x
  view.y = t.y
  view.w = t.w
  view.h = t.h
  csreen.deser(t.cscr)
end

function view.init(sw, sh, s)
  view.x = 0
  view.y = 0
  view.w = sw or 1
  view.h = sh or 1
  cscreen.init(view.w, view.h, borderLeft, borderRight)
end

function view.draw()
  cscreen.apply()
  love.graphics.setShader(drawShader)
  love.graphics.clear(love.graphics.getBackgroundColor())
  love.graphics.translate(-view.x, -view.y)
  if states.currentState then
    love.graphics.setColor(1, 1, 1, 1)
    states.currentState:draw()
  end
  megautils.updateShake()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.translate(view.x, view.y)
  record.drawDemo()
  if megautils.isShowingEntityCount() then
    local count = #megautils.state().system.all
    love.graphics.setFont(mmFont)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", view.w - 24 - 8, 23, 32, 10)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print(count, view.w - 24, 24)
  end
  if megautils.isShowingFPS() then
    local fps = love.timer.getFPS()
    love.graphics.setFont(mmFont)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", view.w - 24 - 8, 7, 32, 10)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print(fps, view.w - 24, 8)
  end
  input.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setShader()
  cscreen.cease()
end
