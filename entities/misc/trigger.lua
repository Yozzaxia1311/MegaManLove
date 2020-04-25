trigger = basicEntity:extend()

function trigger:new(call, drawCall)
  trigger.super.new(self, tran)
  self.call = call
  self.drawCall = drawCall
  self.added = function(self)
    self:addToGroup("freezable")
  end
end

function trigger:update(dt)
  if self.call then self.call(self, dt) end
end

function trigger:draw()
  if self.drawCall then self.drawCall(self) end
end