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
  cscreen.deser(t.cscr)
  view.resize(love.graphics.getDimensions())
end

function view.init(sw, sh, s)
  view.x = 0
  view.y = 0
  view.w = sw or 1
  view.h = sh or 1
  cscreen.init(view.w, view.h, borderLeft, borderRight)
  view.resize(love.graphics.getDimensions())
end

function view.resize(w, h)
  local lastScale = view.canvasScale
  local nw, nh = math.floor(w / view.w), math.floor(h / view.h)
  view.canvasScale = math.min((nw >= nh) and nh or nw, 3)
  
  if lastScale ~= view.canvasScale then
    if view.canvas then view.canvas:release() end
    view.canvas = love.graphics.newCanvas(view.w * view.canvasScale, view.h * view.canvasScale)
    cscreen.resizeGame(view.w * view.canvasScale, view.h * view.canvasScale)
  end
  
  cscreen.update(w, h)
end

function view.draw()
  love.graphics.setCanvas(view.canvas)
  love.graphics.clear(love.graphics.getBackgroundColor())
  love.graphics.push()
  love.graphics.scale(view.canvasScale)
  love.graphics.translate(-view.x, -view.y)
  if states.currentState then
    love.graphics.setColor(1, 1, 1, 1)
    states.currentState:draw()
  end
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
  love.graphics.pop()
  
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1, 1)
  megautils.updateShake()
  cscreen.apply()
  love.graphics.draw(view.canvas)
  cscreen.cease()
end
