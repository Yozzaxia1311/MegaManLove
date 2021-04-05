spriteBatch = class:extend()

binser.register(spriteBatch, "spriteBatch", function(o)
    return {path = o.image.path, ids = o.ids}
  end, function(o)
    local result = spriteBatch(o.path)
    
    for _, v in pairs(o.ids) do
      result:set(unpack(v))
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
  love.graphics.draw(self.batch, x, y, r, sx, sy, ox, oy, kx, ky)
end