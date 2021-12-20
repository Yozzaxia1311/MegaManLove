solid = basicEntity:extend()

solid.autoClean = false

mapEntity.register("solid", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height)
end, 0, true)

function solid:new(x, y, w, h)
  solid.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setRectangleCollision(w or 16, h or 16)
  self.solidType = collision.SOLID
end

function solid:added()
  self:addToGroup("handledBySections")
  self:makeStatic()
end

loader.load("assets/misc/slopes/slopeLeft.png", "slopeLeft", true, true)
loader.load("assets/misc/slopes/slopeRight.png", "slopeRight", true, true)
loader.load("assets/misc/slopes/slopeLeftLong.png", "slopeLeftLong", true, true)
loader.load("assets/misc/slopes/slopeRightLong.png", "slopeRightLong", true, true)
loader.load("assets/misc/slopes/slopeLeftInvert.png", "slopeLeftInvert", true, true)
loader.load("assets/misc/slopes/slopeRightInvert.png", "slopeRightInvert", true, true)
loader.load("assets/misc/slopes/slopeLeftLongInvert.png", "slopeLeftLongInvert", true, true)
loader.load("assets/misc/slopes/slopeRightLongInvert.png", "slopeRightLongInvert", true, true)
loader.load("assets/misc/slopes/slopeLeftHalf.png", "slopeLeftHalf", true, true)
loader.load("assets/misc/slopes/slopeRightHalf.png", "slopeRightHalf", true, true)
loader.load("assets/misc/slopes/slopeLeftHalfInvert.png", "slopeLeftHalfInvert", true, true)
loader.load("assets/misc/slopes/slopeRightHalfInvert.png", "slopeRightHalfInvert", true, true)
loader.load("assets/misc/slopes/slopeLeftHalfUpper.png", "slopeLeftHalfUpper", true, true)
loader.load("assets/misc/slopes/slopeRightHalfUpper.png", "slopeRightHalfUpper", true, true)
loader.load("assets/misc/slopes/slopeLeftHalfUpperInvert.png", "slopeLeftHalfUpperInvert", true, true)
loader.load("assets/misc/slopes/slopeRightHalfUpperInvert.png", "slopeRightHalfUpperInvert", true, true)

slope = basicEntity:extend()

slope.autoClean = false

mapEntity.register("slope", function(v)
  megautils.add(slope, v.x, v.y, v.properties.mask)
end, 0, true)

function slope:new(x, y, mask)
  slope.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self:setImageCollision(mask or "slopeLeft")
  self.solidType = collision.SOLID
end

function slope:added()
  self:addToGroup("handledBySections")
  self:makeStatic()
end

mapEntity.register("oneway", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height).solidType = collision.ONEWAY
end, 0, true)