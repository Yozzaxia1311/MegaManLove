local quad = class:extend()

binser.register(quad, "quad", function(o)
    return {
        quad={o.quad:getViewport()},
        flipX=o.flipX,
        flipY=o.flipY
      }
  end, function(o)
    local result = quad(unpack(o.quad))
    
    result.flipX = o.flipX
    result.flipY = o.flipY
    
    return result
  end)

function quad:new(x, y, w, h)
  self.quad = love.graphics.newQuad(x, y, w, h, 1, 1)
  self.flipX = false
  self.flipY = false
end

function quad:getViewport()
  return self.quad:getViewport()
end

function quad:setViewport(x, y, w, h)
  self.quad:setViewport(x, y, w, h, 1, 1)
end

function quad:draw(image, x, y, r, sx, sy, ox, oy, kx, ky)
  x,y,r,sx,sy,ox,oy,kx,ky = x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0, kx or 0, ky or 0
  local vx, vy, vw, vh = self.quad:getViewport()
  
  self.quad:setViewport(vx, vy, vw, vh, image:getDimensions())
  
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
  
  love.graphics.draw(image, self.quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

return quad