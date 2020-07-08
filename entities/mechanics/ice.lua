ice = basicEntity:extend()

addobjects.register("ice", function(v)
  megautils.add(ice, v.x, v.y, v.width, v.height)
end)

function ice:new(x, y, w, h)
  ice.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.solidType = collision.SOLID
end

function ice:added()
  self:addToGroup("despawnable")
  self:addToGroup("ice")
  self:addToGroup("solid")
end

function ice.elseFunc(s)
  if s.nonIceLeftDecel then
    s.leftDecel = s.nonIceLeftDecel
    s.nonIceLeftDecel = nil
  end
  if s.nonIceRightDecel then
    s.rightDecel = s.nonIceRightDecel
    s.nonIceRightDecel = nil
  end
end
  
function ice.gFunc(s)
  local doIce = megautils.groups().ice and s:collisionNumber(megautils.groups().ice, 0, s.gravity >= 0 and 1 or -1) ~= 0
  if doIce then
    if not s.nonIceLeftDecel then
      s.nonIceLeftDecel = s.leftDecel
    end
    if not s.nonIceRightDecel then
      s.nonIceRightDecel = s.rightDecel
    end
    if s.runCheck then
      s.leftDecel = 0.05
      s.rightDecel = 0.05
    else
      s.leftDecel = 0.025
      s.rightDecel = 0.025
    end
  else
    if s.nonIceLeftDecel then
      s.leftDecel = s.nonIceLeftDecel
      s.nonIceLeftDecel = nil
    end
    if s.nonIceRightDecel then
      s.rightDecel = s.nonIceRightDecel
      s.nonIceRightDecel = nil
    end
  end
end

megautils.resetGameObjectsFuncs.ice = function()
    megautils.playerGroundFuncs.ice = ice.gFunc
    megautils.playerKnockbackFuncs.ice = ice.gFunc
    megautils.playerAirFuncs.ice = ice.elseFunc
    megautils.playerClimbFuncs.ice = ice.elseFunc
    megautils.playerTrebleFuncs.ice = ice.elseFunc
  end

megautils.cleanFuncs.ice = function()
    ice = nil
    addobjects.unregister("ice")
    megautils.playerGroundFuncs.ice = nil
    megautils.playerKnockbackFuncs.ice = nil
    megautils.playerAirFuncs.ice = nil
    megautils.playerClimbFuncs.ice = nil
    megautils.playerTrebleFuncs.ice = nil
    megautils.cleanFuncs.ice = nil
  end