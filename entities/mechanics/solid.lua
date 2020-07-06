solid = basicEntity:extend()

addobjects.register("solid", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height)
end)

function solid:new(x, y, w, h)
  solid.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.isSolid = 1
end

function solid:added()
  self:addToGroup("despawnable")
  self:makeStatic()
end

sinkIn = basicEntity:extend()

addobjects.register("sinkIn", function(v)
  megautils.add(sinkIn, v.x, v.y, v.width, v.height, v.properties.speed)
end)

function sinkIn:new(x, y, w, h, s)
  sinkIn.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.sink = s or 0.125
  self.isSolid = 3
end

function sinkIn:added()
  self:addToGroup("despawnable")
  self:addToGroup("freezable")
end

function sinkIn:update(dt)
  for i=1, #megaMan.allPlayers do
    local p = megaMan.allPlayers[i]
    if p:collision(self, 0, (p.gravity >= 0 and 1 or -1)) or p:collision(self) then
      collision.shiftObject(p, 0, self.sink * (p.gravity >= 0 and 1 or -1), true)
    end
  end
end

slope = basicEntity:extend()

addobjects.register("slope", function(v)
  megautils.add(slope, v.x, v.y, megautils.getResourceTable(v.properties.mask))
end)

function slope:new(x, y, mask)
  slope.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setImageCollision(mask)
  self.isSolid = 1
end

function slope:added()
  self:addToGroup("despawnable")
  self:makeStatic()
end

addobjects.register("oneway", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height).isSolid = 2
end)

megautils.cleanFuncs.solid = function()
    solid = nil
    sinkIn = nil
    slope = nil
    addobjects.unregister("solid")
    addobjects.unregister("sinkIn")
    addobjects.unregister("slope")
    addobjects.unregister("oneway")
    megautils.cleanFuncs.solid = nil
  end