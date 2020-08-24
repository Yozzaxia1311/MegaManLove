trigger = basicEntity:extend()

trigger.autoClean = false

function trigger:new(call, drawCall)
  trigger.super.new(self)
  self.call = call
  self.drawCall = drawCall
end

function trigger:added()
  self:addToGroup("freezable")
end

function trigger:update(dt)
  if self.call then self.call(self, dt) end
end

function trigger:draw()
  if self.drawCall then self.drawCall(self) end
end