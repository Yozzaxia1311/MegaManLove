view = {}

function view.init(sw, sh, s)
  view.x = 0
  view.y = 0
  view.w = sw or 1
  view.h = sh or 1
  view.scale = s or 1
  view.canvas = love.graphics.newCanvas(view.w*view.scale, view.h*view.scale)
  view.form = {view.canvas, stencil=true}
end

function view.draw(sys)
  love.graphics.setCanvas(view.form)
  love.graphics.clear()
  love.graphics.push()
  love.graphics.scale(view.scale)
  love.graphics.translate(-view.x, -view.y)
  sys:draw()
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
  megautils.updateShake()
  love.graphics.setCanvas()
  cscreen.apply()
  love.graphics.draw(view.canvas)
end