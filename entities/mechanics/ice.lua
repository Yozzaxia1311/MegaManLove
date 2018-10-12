ice = entity:extend()

addobjects.register("ice", function(v)
  megautils.add(ice(v.x, v.y, v.width, v.height))
end)

megautils.resetStateFuncs["ice"] = function()
  ice.active = nil
  ice.leftDecel = nil
  ice.rightDecel = nil
  ice.leftSpeed = nil
  ice.rightSpeed = nil
  ice.stepVelocity = nil
  ice.stepLeftSpeed = nil
  ice.stepRightSpeed = nil
  ice.current = nil
end

function ice.init()
  ice.active = false
end

function ice:new(x, y, w, h)
  ice.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("solid")
  end
end

function ice:update(dt)
  if megautils.outside(self) then return end
  if globals.mainPlayer ~= nil and globals.mainPlayer:collision(self, 0, 1) then
    if not ice.active then
      if ice.active == nil then
        ice.init()
      end
      ice.leftDecel = globals.mainPlayer.leftDecel
      ice.rightDecel = globals.mainPlayer.rightDecel
      ice.leftSpeed = globals.mainPlayer.leftSpeed
      ice.rightSpeed = globals.mainPlayer.rightSpeed
      ice.stepVelocity = globals.mainPlayer.stepVelocity
      ice.stepLeftSpeed = globals.mainPlayer.stepLeftSpeed
      ice.stepRightSpeed = globals.mainPlayer.stepRightSpeed
      
      globals.mainPlayer.leftDecel = 0.02
      globals.mainPlayer.rightDecel = 0.02
      globals.mainPlayer.leftSpeed = -0.1
      globals.mainPlayer.rightSpeed = 0.1
      globals.mainPlayer.stepVelocity = true
      globals.mainPlayer.stepLeftSpeed = 0
      globals.mainPlayer.stepRightSpeed = 0
    end
    ice.active = true
    ice.current = self
  elseif ice.active and self == ice.current then
    ice.active = false
    globals.mainPlayer.leftDecel = ice.leftDecel
    globals.mainPlayer.rightDecel = ice.rightDecel
    globals.mainPlayer.leftSpeed = ice.leftSpeed
    globals.mainPlayer.rightSpeed = ice.rightSpeed
    globals.mainPlayer.stepVelocity = ice.stepVelocity
    globals.mainPlayer.stepLeftSpeed = ice.stepLeftSpeed
    globals.mainPlayer.stepRightSpeed = ice.stepRightSpeed
  end
end