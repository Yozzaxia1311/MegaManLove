solid = basicEntity:extend()

solid.autoClean = false

mapEntity.register("solid", function(v)
  entities.add(solid, v.x, v.y, v.width, v.height)
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

loader.load("assets/misc/slopes/slopeLeft.data.png", true)
loader.load("assets/misc/slopes/slopeRight.data.png", true)
loader.load("assets/misc/slopes/slopeLeftLong.data.png", true)
loader.load("assets/misc/slopes/slopeRightLong.data.png", true)
loader.load("assets/misc/slopes/slopeLeftInvert.data.png", true)
loader.load("assets/misc/slopes/slopeRightInvert.data.png", true)
loader.load("assets/misc/slopes/slopeLeftLongInvert.data.png", true)
loader.load("assets/misc/slopes/slopeRightLongInvert.data.png", true)
loader.load("assets/misc/slopes/slopeLeftHalf.data.png", true)
loader.load("assets/misc/slopes/slopeRightHalf.data.png", true)
loader.load("assets/misc/slopes/slopeLeftHalfInvert.data.png", true)
loader.load("assets/misc/slopes/slopeRightHalfInvert.data.png", true)
loader.load("assets/misc/slopes/slopeLeftHalfUpper.data.png", true)
loader.load("assets/misc/slopes/slopeRightHalfUpper.data.png", true)
loader.load("assets/misc/slopes/slopeLeftHalfUpperInvert.data.png", true)
loader.load("assets/misc/slopes/slopeRightHalfUpperInvert.data.png", true)

slope = basicEntity:extend()

slope.autoClean = false

mapEntity.register("slope", function(v)
  entities.add(slope, v.x, v.y, v.properties.mask)
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
  entities.add(solid, v.x, v.y, v.width, v.height).solidType = collision.ONEWAY
end, 0, true)