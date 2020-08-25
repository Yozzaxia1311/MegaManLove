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
end

function image:draw(x, y, r, sx, sy, ox, oy, kx, ky, flipx, flipy, what)
  if type(x) == "table" then
    local draw = x
    local lfx, lfy = draw.flipX, draw.flipY
    x,y,r,sx,sy,ox,oy,kx,ky,flipx,flipy = y or 0, r or 0, sx or 0, sy or 1, ox or 1, oy or 0, kx or 0, ky or 0, flipx or 0, flipy == true, what == true
    
    if self.flipX then
      draw.flipX = not draw.flipX
    end
    if self.flipY then
      draw.flipY = not draw.flipY
    end
    
    draw:draw(self.image, x, y, r, sx, sy, ox, oy, kx, ky)
    
    draw.flipX = lfx
    draw.flipY = lfy
  else
    x,y,r,sx,sy,ox,oy,kx,ky,flipx,flipy = x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0, kx or 0, ky or 0, flipx == true, flipy == true
    
    local vw, vh = self.image:getDimensions()
    
    if self.flipX then
      sx = sx * -1
      ox = vw - ox
      kx = kx * -1
      ky = ky * -1
    end

    if self.flipY then
      sy = sy * -1
      oy = vh - oy
      kx = kx * -1
      ky = ky * -1
    end
    
    love.graphics.draw(self.image, x, y, r, sx, sy, ox, oy, kx, ky)
  end
end