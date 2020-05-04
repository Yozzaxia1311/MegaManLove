ice = basicEntity:extend()

addobjects.register("ice", function(v)
  megautils.add(ice, v.x, v.y, v.width, v.height)
end)

function ice:new(x, y, w, h)
  ice.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.isSolid = 1
  self.elseFunc = function(s)
      if s.nonIceLeftDecel then
        s.leftDecel = s.nonIceLeftDecel
        s.nonIceLeftDecel = nil
      end
      if s.nonIceRightDecel then
        s.rightDecel = s.nonIceRightDecel
        s.nonIceRightDecel = nil
      end
    end
  self.gFunc = function(s)
      local doIce = megautils.groups().ice and #s:collisionTable(megautils.groups().ice, 0, s.gravity >= 0 and 1 or -1) ~= 0
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
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("ice")
    for k, v in ipairs(globals.allPlayers) do
      if not v.groundUpdateFuncs.ice then
        v.groundUpdateFuncs.ice = self.gFunc
      end
      if not v.airUpdateFuncs.ice then
        v.airUpdateFuncs.ice = self.elseFunc
      end
      if not v.climbUpdateFuncs.ice then
        v.climbUpdateFuncs.ice = self.elseFunc
      end
    end
  end
end