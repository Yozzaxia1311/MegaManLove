solid = basicEntity:extend()

solid.autoClean = false

binser.register(solid, "solid", function(o)
    local result = {}
    
    solid.super.transfer(o, result)
    
    return result
  end, function(o)
    local result = solid()
    
    solid.super.transfer(o, result)
    
    return result
  end)

mapEntity.register("solid", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height)
end, 0, true)

function solid:new(x, y, w, h)
  solid.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.solidType = collision.SOLID
end

function solid:added()
  self:addToGroup("handledBySections")
  self:addToGroup("collision")
  self:makeStatic()
end

megautils.loadResource("assets/misc/slopes/slopeLeft.png", "slopeLeft", true, true)
megautils.loadResource("assets/misc/slopes/slopeRight.png", "slopeRight", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftLong.png", "slopeLeftLong", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightLong.png", "slopeRightLong", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftInvert.png", "slopeLeftInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightInvert.png", "slopeRightInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftLongInvert.png", "slopeLeftLongInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightLongInvert.png", "slopeRightLongInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftHalf.png", "slopeLeftHalf", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightHalf.png", "slopeRightHalf", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftHalfInvert.png", "slopeLeftHalfInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightHalfInvert.png", "slopeRightHalfInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftHalfUpper.png", "slopeLeftHalfUpper", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightHalfUpper.png", "slopeRightHalfUpper", true, true)
megautils.loadResource("assets/misc/slopes/slopeLeftHalfUpperInvert.png", "slopeLeftHalfUpperInvert", true, true)
megautils.loadResource("assets/misc/slopes/slopeRightHalfUpperInvert.png", "slopeRightHalfUpperInvert", true, true)

slope = basicEntity:extend()

slope.autoClean = false

binser.register(slope, "slope", function(o)
    local result = {}
    
    slope.super.transfer(o, result)
    
    return result
  end, function(o)
    local result = slope()
    
    slope.super.transfer(o, result)
    
    return result
  end)

mapEntity.register("slope", function(v)
  megautils.add(slope, v.x, v.y, megautils.getResourceTable(v.properties.mask))
end, 0, true)

function slope:new(x, y, mask)
  slope.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setImageCollision(mask)
  self.solidType = collision.SOLID
end

function slope:added()
  self:addToGroup("handledBySections")
  self:addToGroup("collision")
  self:makeStatic()
end

mapEntity.register("oneway", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height).solidType = collision.ONEWAY
end, 0, true)