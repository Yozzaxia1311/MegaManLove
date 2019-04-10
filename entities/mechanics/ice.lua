ice = entity:extend()

addobjects.register("ice", function(v)
  megautils.add(ice(v.x, v.y, v.width, v.height))
end)

megautils.resetStateFuncs["ice"] = function()
  ice.active = {}
  ice.leftDecel = {}
  ice.rightDecel = {}
  ice.leftSpeed = {}
  ice.rightSpeed = {}
  ice.stepVelocity = {}
  ice.stepLeftSpeed = {}
  ice.stepRightSpeed = {}
  ice.current = {}
end

ice.active = {}
ice.leftDecel = {}
ice.rightDecel = {}
ice.leftSpeed = {}
ice.rightSpeed = {}
ice.stepVelocity = {}
ice.stepLeftSpeed = {}
ice.stepRightSpeed = {}
ice.current = {}

function ice:new(x, y, w, h)
  ice.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.isSolid = 1
  self.added = function(self)
    self:addToGroup("despawnable")
  end
end

function ice:update(dt)
  if megautils.outside(self) then return end
  for i=1, #globals.allPlayers do
    local p = globals.allPlayers[i]
    if p:collision(self, 0, 1) then
      if not ice.active[p] then
        ice.leftDecel[p] = p.leftDecel
        ice.rightDecel[p] = p.rightDecel
        ice.leftSpeed[p] = p.leftSpeed
        ice.rightSpeed[p] = p.rightSpeed
        ice.stepVelocity[p] = p.stepVelocity
        ice.stepLeftSpeed[p] = p.stepLeftSpeed
        ice.stepRightSpeed[p] = p.stepRightSpeed
        
        p.leftDecel = 0.02
        p.rightDecel = 0.02
        p.leftSpeed = -0.1
        p.rightSpeed = 0.1
        p.stepVelocity = true
        p.stepLeftSpeed = 0
        p.stepRightSpeed = 0
      end
      ice.active[p] = true
      ice.current[p] = self
    elseif ice.active[p] and self == ice.current[p] then
      ice.active[p] = false
      p.leftDecel = ice.leftDecel[p]
      p.rightDecel = ice.rightDecel[p]
      p.leftSpeed = ice.leftSpeed[p]
      p.rightSpeed = ice.rightSpeed[p]
      p.stepVelocity = ice.stepVelocity[p]
      p.stepLeftSpeed = ice.stepLeftSpeed[p]
      p.stepRightSpeed = ice.stepRightSpeed[p]
    end
  end
end