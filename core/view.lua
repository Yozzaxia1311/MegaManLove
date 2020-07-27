view = {}

function view.init(sw, sh, s)
  view.x = 0
  view.y = 0
  view.w = sw or 1
  view.h = sh or 1
  view.scale = s or 1
  view.canvas = love.graphics.newCanvas(view.w*view.scale, view.h*view.scale)
end

function view.draw(sys)
  love.graphics.setCanvas(view.canvas)
  love.graphics.clear(love.graphics.getBackgroundColor())
  love.graphics.push()
  love.graphics.scale(view.scale)
  love.graphics.translate(-view.x, -view.y)
  sys:draw()
  love.graphics.pop()
  sys:drawQuality()
  megautils.updateShake()
  love.graphics.setColor(1, 1, 1, 1)
  control.drawDemo()
  if megautils.isShowingEntityCount() then
    local count = #megautils.state().system.all
    love.graphics.setFont(mmFont)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print(count, view.w - 24, 24)
  end
  if megautils.isShowingFPS() then
    local fps = love.timer.getFPS()
    love.graphics.setFont(mmFont)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print(fps, view.w - 24, 8)
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setCanvas()
  cscreen.apply()
  love.graphics.draw(view.canvas)
end
