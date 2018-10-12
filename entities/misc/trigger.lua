trigger = entity:extend()

function trigger:new(call, drawCall)
  trigger.super.new(self, tran)
  self.call = call
  self.drawCall = drawCall
end

function trigger:update(dt)
  if self.call ~= nil then self.call(self, dt) end
end

function trigger:draw()
  if self.drawCall ~= nil then self.drawCall(self) end
end