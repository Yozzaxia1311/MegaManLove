imageData = class:extend()

binser.register(imageData, "imageData", function(o)
    return o.path
  end, function(o)
    return imageData(o)
  end)

function imageData:new(path)
  self.path = path
  self.imageData = love.image.newImageData(self.path)
end

function imageData:toImage()
  local img = image(self.imageData)
  img.path = self.path
  return img
end

function imageData:getWidth()
  return self.imageData:getWidth()
end

function imageData:getHeight()
  return self.imageData:getHeight()
end

function imageData:getDimensions()
  return self.imageData:getDimensions()
end

function imageData:getPixel(x, y)
  return self.imageData:getPixel(x, y)
end

function imageData:setPixel(x, y, r, g, b, a)
  return self.imageData:setPixel(x, y, r, g, b, a)
end

function imageData:release()
  self.imageData:release()
  self.imageData = nil
end

image = class:extend()

binser.register(image, "image", function(o)
    return o.path
  end, function(o)
    return image(o)
  end)

function image:new(path)
  self.path = path
  self.image = love.graphics.newImage(self.path)
end

function image:getWidth()
  return self.image:getWidth()
end

function image:getHeight()
  return self.image:getHeight()
end

function image:getDimensions()
  return self.image:getDimensions()
end

function image:release()
  self.image:release()
  self.image = nil
end

function image:draw(x, y, r, sx, sy, ox, oy, kx, ky, flipx, flipy, what)
  if type(x) == "table" then
    local draw = x
    x,y,r,sx,sy,ox,oy,kx,ky,flipx,flipy = y or 0, r or 0, sx or 0, sy or 1, ox or 1, oy or 0, kx or 0, ky or 0, flipx or 0, flipy == true, what == true
    
    draw:draw(self.image, x, y, r, sx, sy, ox, oy, kx, ky, flipx, flipy)
  else
    x,y,r,sx,sy,ox,oy,kx,ky,flipx,flipy = x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0, kx or 0, ky or 0, flipx == true, flipy == true
    
    local vw, vh = self.image:getDimensions()
    
    if flipx then
      sx = sx * -1
      ox = vw - ox
      kx = kx * -1
      ky = ky * -1
    end

    if flipy then
      sy = sy * -1
      oy = vh - oy
      kx = kx * -1
      ky = ky * -1
    end
    
    love.graphics.draw(self.image, x, y, r, sx, sy, ox, oy, kx, ky)
  end
end