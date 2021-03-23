view = {}

function view.ser()
  return {
      x=view.x,
      y=view.y,
      w=view.w,
      h=view.h,
      scale=view.scale
    }
end

function view.deser(t)
  view.init(t.w, t.h, t.scale)
  view.x = t.x
  view.y = t.y
end

function view.init(sw, sh, s)
  view.x = 0
  view.y = 0
  view.w = sw or 1
  view.h = sh or 1
  view.scale = s or 1
  view.canvas = love.graphics.newCanvas(view.w*view.scale, view.h*view.scale)
  if isMobile then
    view.canvas:setFilter("linear", "linear")
  end
  view.wrapper = {view.canvas, stencil=true}
end

function view.draw()
  love.graphics.setCanvas(view.wrapper)
  love.graphics.clear(love.graphics.getBackgroundColor())
  love.graphics.push()
  love.graphics.scale(view.scale)
  love.graphics.translate(-view.x, -view.y)
  if states.currentState then
    love.graphics.setColor(1, 1, 1, 1)
    states.currentState:draw()
  end
  love.graphics.pop()
  megautils.updateShake()
  love.graphics.setColor(1, 1, 1, 1)
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
  love.graphics.setCanvas()
  cscreen.apply()
  love.graphics.draw(view.canvas)
  cscreen.cease()
end
