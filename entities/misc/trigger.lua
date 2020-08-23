trigger = basicEntity:extend()

trigger.autoClean = false

binser.register(trigger, "trigger", function(o)
    local result = {}
    
    trigger.super.transfer(o, result)
    
    result.call = o.call
    result.drawCall = o.drawCall
    
    return result
  end, function(o)
    local result = trigger()
    
    trigger.super.transfer(o, result)
    
    result.call = o.call
    result.drawCall = o.drawCall
    
    return result
  end)

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