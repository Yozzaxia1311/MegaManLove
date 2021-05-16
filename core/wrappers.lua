imageWrapper = class:extend()

binser.register(imageWrapper, "imageWrapper", function(o)
    return o.path
  end, function(o)
    return imageWrapper(o)
  end)

function imageWrapper:new(path)
  self.path = path
  self.image = love.graphics.newImage(self.path)
end

function imageWrapper:getWidth()
  return self.image:getWidth()
end

function imageWrapper:getHeight()
  return self.image:getHeight()
end

function imageWrapper:getDimensions()
  return self.image:getDimensions()
end

function imageWrapper:release()
  if self.image then
    self.image:release()
    self.image = nil
  end
end

function imageWrapper:draw(x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, what)
  if type(x) == "table" then
    local draw = x
    x,y,r,sx,sy,ox,oy,offX,offY,flipX,flipY =
      y or 0, r or 0, sx or 0, sy or 1, ox or 1, oy or 0, offX or 0, offY or 0, flipX or 0, flipY == true, what == true
    
    draw:draw(self, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  else
    x,y,r,sx,sy,ox,oy,offX,offY,flipX,flipY =
      x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0, offX or 0, offY or 0, flipX == true, flipY == true
    
    local vw, vh = self.image:getDimensions()
    
    if flipX then
      sx = sx * -1
      ox = vw - ox
    end

    if flipY then
      sy = sy * -1
      oy = vh - oy
    end
    
    love.graphics.draw(self.image, x + offX, y + offY, math.rad(r), sx, sy, ox, oy)
  end
end

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

function imageData:toImageWrapper()
  local img = imageWrapper(self.imageData)
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
  if self.imageData then
    self.imageData:release()
    self.imageData = nil
  end
end

quad = class:extend()

binser.register(quad, "quad", function(o)
    return {
        quad={o.quad:getViewport()},
        fx=o.fx,
        fy=o.fy
      }
  end, function(o)
    local result = quad(unpack(o.quad))
    
    result.fx = o.fx
    result.fy = o.fy
    
    return result
  end)

function quad:new(x, y, w, h)
  self.quad = love.graphics.newQuad(x, y, w, h, 1, 1)
end

function quad:getViewport()
  return self.quad:getViewport()
end

function quad:setViewport(x, y, w, h)
  self.quad:setViewport(x, y, w, h, 1, 1)
end

function quad:release()
  if self.quad then
    self.quad:release()
    self.quad = nil
  end
end

function quad:fillFromImage(image)
  local vx, vy, vw, vh = self.quad:getViewport()
  self.quad:setViewport(vx, vy, vw, vh, image:getDimensions())
end

function quad:draw(image, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  x,y,r,sx,sy,ox,oy,offX,offY = x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0, offX or 0, offY or 0
  local vx, vy, vw, vh = self.quad:getViewport()
    
  self:fillFromImage(image)
  
  if flipX then
    sx = sx * -1
    ox = vw - ox
  end

  if flipY then
    sy = sy * -1
    oy = vh - oy
  end
  
  love.graphics.draw(image.image, self.quad, x + offX, y + offY, math.rad(r), sx, sy, ox, oy)
end

spriteBatch = class:extend()

binser.register(spriteBatch, "spriteBatch", function(o)
    return {image = o.image, ids = o.ids}
  end, function(o)
    local result = spriteBatch(o.image)
    
    for _, v in ipairs(o.ids) do
      result:add(unpack(v))
    end
    
    return result
  end)

function spriteBatch:new(img)
  self.image = img
  self.batch = love.graphics.newSpriteBatch(self.image.image)
  self.ids = {}
end

function spriteBatch:add(quad, x, y, r, sx, sy, ox, oy, kx, ky)
  if type(quad) == "table" then
    quad:fillFromImage(self.image)
    local id = self.batch:add(quad.quad, x, y, r, sx, sy, ox, oy, kx, ky)
    self.ids[id] = {quad, x, y, r, sx, sy, ox, oy, kx, ky}
    return id
  else
    local id = self.batch:add(quad, x, y, r, sx, sy, ox, oy, kx)
    self.ids[id] = {quad, x, y, r, sx, sy, ox, oy, kx}
    return id
  end
end

function spriteBatch:set(spriteindex, quad, x, y, r, sx, sy, ox, oy, kx, ky)
  assert(self.ids[spriteindex])
  
  if type(quad) == "table" then
    self.batch:set(spriteindex, quad.quad, x, y, r, sx, sy, ox, oy, kx, ky)
  else
    self.batch:set(spriteindex, quad, x, y, r, sx, sy, ox, oy, kx)
  end
  
  self.ids[spriteindex] = {quad, x, y, r, sx, sy, ox, oy, kx, ky}
end

function spriteBatch:clear()
  self.batch:clear()
end

function spriteBatch:flush()
  self.batch:flush()
end

function spriteBatch:setColor(r, g, b, a)
  self.batch:setColor(r, g, b, a)
end

function spriteBatch:getColor()
  return self.batch:getColor()
end

function spriteBatch:draw(x, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.draw(self.batch, x, y, math.rad(r), sx, sy, ox, oy, kx, ky)
end