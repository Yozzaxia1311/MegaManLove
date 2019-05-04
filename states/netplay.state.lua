local netplaystate = states.state:extend()

function netplaystate:begin()
end

function netplaystate:update(dt)
  megautils.update(self, dt)
end

function netplaystate:stop()
  megautils.unload(self)
end

function netplaystate:draw()
  megautils.draw(self)
end

return netplaystate