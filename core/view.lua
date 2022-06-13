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
  local lastScale = view._canvasScale
  local nw, nh = math.floor(w / view.w), math.floor(h / view.h)
  
  if nw == w / view.w and nh == h / view.h then
    if view.canvas then
      view.canvas:release()
      view.canvas = nil
    end
    view._canvasScale = nw
    cscreen.resizeGame(view.w, view.h)
  else
    view._canvasScale = math.min((nw >= nh) and nh or nw, isMobile and 2 or 3)
    
    if not view.canvas or lastScale ~= view._canvasScale then
      if view.canvas then view.canvas:release() end
      view.canvas = love.graphics.newCanvas(view.w * view._canvasScale, view.h * view._canvasScale)
      cscreen.resizeGame(view.w * view._canvasScale, view.h * view._canvasScale)
    end
  end
  
  cscreen.update(w, h)
end

function view.project(x, y)
  if view.canvas then
    local nx, ny = cscreen.project(x, y)
    return nx / view._canvasScale, ny / view._canvasScale
  else
    return x / view._canvasScale, y / view._canvasScale
  end
end

function view.draw()
  if not view.canvas then
    love.graphics.clear(love.graphics.getBackgroundColor())
    cscreen.apply()
    megautils.updateShake()
    love.graphics.translate(-view.x, -view.y)
    if states.currentStateObject then
      love.graphics.setColor(1, 1, 1, 1)
      states.currentStateObject:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
    entities.draw()
    love.graphics.translate(view.x, view.y)
    record.drawDemo()
    if megautils.isShowingEntityCount() then
      local count = #entities.all
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
    cscreen.cease()
  else
    love.graphics.setCanvas(view.canvas)
    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.push()
    love.graphics.scale(view._canvasScale)
    love.graphics.translate(-view.x, -view.y)
    megautils.updateShake()
    if states.currentStateObject then
      love.graphics.setColor(1, 1, 1, 1)
      states.currentStateObject:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
    entities.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.translate(view.x, view.y)
    record.drawDemo()
    if megautils.isShowingEntityCount() then
      local count = #entities.all
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
    cscreen.apply()
    love.graphics.draw(view.canvas)
    cscreen.cease()
  end
end

local lgss = love.graphics.setScissor
local lggs = love.graphics.getScissor

function view.setScissor(x, y, w, h)
  if x == nil and y == nil and w == nil and h == nil then
    return lgss()
  end
  
  lgss(x * view._canvasScale, y * view._canvasScale, w * view._canvasScale, h * view._canvasScale)
end

function view.getScissor()
  local x, y, w, h = lggs()
  return x / view._canvasScale, y / view._canvasScale, w / view._canvasScale, h / view._canvasScale
end