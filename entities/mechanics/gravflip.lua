gravFlip = basicEntity:extend()

addobject.register("gravFlip", function(v)
    megautils.add(gravFlip, v.x, v.y, v.width, v.height)
  end)


megautils.cleanFuncs.gravFlip = function()
  gravFlip = nil
  megautils.cleanFuncs.gravFlip = nil
end