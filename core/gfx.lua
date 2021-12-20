gfx = class:extend()

function gfx:new(x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  self.name = "GFX"
  
  self.x = x or 0
  self.y = y or 0
  self.r = r or 0
  self.sx = sx or 1
  self.sy = sy or 1
  self.ox = ox or 0
  self.oy = oy or 0
  self.offX = offX or 0
  self.offY = offY or 0
  self.flipX = not not flipX
  self.flipY = not not flipY
  self.color = color
  
  self.gfx = {}
  self.canDraw = {global = true}
  self.canUpdate = {global = true}
  self.syncPos = syncPos
  
  return self
end

function gfx:sync(syncPos)
  self.syncPos = syncPos
  
  return self
end

function gfx:visibility(t)
  self.canDraw.global = not not t
  
  return self
end

function gfx:addGFX(name, gfx, noSync)
  if not table.icontains(self.gfx, gfx) then
    gfx.name = name or "GFX"
    gfx.syncPos = not noSync and self
    self.gfx[#self.gfx + 1] = gfx
  end
  
  return self
end

function gfx:removeGFX(gfx)
  table.removevaluearray(self.gfx, gfx)
end

function gfx:removeGFXByName(n)
  for i = 1, #self.gfx do
    if self.gfx[i].name == n then
      table.remove(self.gfx, i)
      return
    end
  end
end

function gfx:getGFXByName(n)
  for i = 1, #self.gfx do
    if self.gfx[i].name == n then
      return self.gfx[i]
    end
  end
end

function gfx:pos(x, y)
  self.x = x or self.x or 0
  self.y = y or self.y or 0
  
  return self
end

function gfx:rot(r)
  self.r = r or self.r or 0
  
  return self
end

function gfx:scale(sx, sy)
  self.sx = sx or self.sx or 1
  self.sy = sy or self.sy or 1
  
  return self
end

function gfx:origin(ox, oy)
  self.ox = ox or self.ox or 0
  self.oy = oy or self.oy or 0
  
  return self
end

function gfx:off(offX, offY)
  self.offX = offX or self.offX or 0
  self.offY = offY or self.offY or 0
  
  return self
end

function gfx:flip(flipX, flipY)
  if flipX ~= nil then
    self.flipX = not not flipX
  end
  if flipY ~= nil then
    self.flipY = not not flipY
  end
  
  return self
end

function gfx:doFlipX()
  self.flipX = not self.flipX
  
  return self
end

function gfx:doFlipY()
  self.flipY = not self.flipY
  
  return self
end

function gfx:col(r, g, b, a)
  self.color = {r, g, b, a}
  
  return self
end

function gfx:draw() end

function gfx:_draw()
  for i = 1, #self.gfx do
    self.gfx[i]:_draw()
  end
  
  local r, g, b, a = love.graphics.getColor()
  
  if self.syncPos then
    self.x = self.syncPos.x
    self.y = self.syncPos.y
  end
  
  love.graphics.setColor(self.color and self.color[1] or r, self.color and self.color[2] or g,
    self.color and self.color[3] or b, self.color and self.color[4] or a)
  if checkFalse(self.canDraw) then self:draw() end
end

function gfx:update(dt) end

function gfx:_update(dt)
  for i = 1, #self.gfx do
    self.gfx[i]:_update(dt)
  end
  
  if checkFalse(self.canUpdate) then self:update(dt) end
end

image = gfx:extend()

function image:new(res, quad, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  image.super.new(self, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  
  self.image = type(res) == "string" and loader.get(res) or res
  self.path = self.image.path
  self.quad = quad
end

function image:setQuad(q)
  self.quad = q
  
  return self
end

function image:getQuad()
  return quad
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

function image:draw(x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  local fx, fy = self.flipX, self.flipY
  if flipX ~= nil then
    fx = flipX
  end
  if flipY ~= nil then
    fy = flipY
  end
  if self.quad then
    self.image:draw(self.quad, x or self.x, y or self.y,
      r or self.r, sx or self.sx, sy or self.sy,
      ox or self.ox, oy or self.oy, offX or self.offX, offY or self.offY, fx, fy)
  else
    self.image:draw(x or self.x, y or self.y,
      r or self.r, sx or self.sx, sy or self.sy,
      ox or self.ox, oy or self.oy, offX or self.offX, offY or self.offY, fx, fy)
  end
end

animation = gfx:extend()

function animation:new(res, useDelta, framerate,
    x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  animation.super.new(self, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  
  local rt = type(res) == "string" and loader.getTable(res) or res
  
  self.anim = anim8.newAnimation(rt.data(unpack(rt.frames)), rt.durations or 1, rt.onLoop)
  self.image = rt.img
  self.useDelta = not not useDelta
  self.framerate = framerate or 1/60
end

function animation:looped()
  return self.anim:looped()
end

function animation:pause()
  self.anim:pause()
end

function animation:resume()
  self.anim:resume()
end

function animation:isPaused()
  return self.anim.status == "paused"
end

function animation:time()
  return self.anim.timer
end

function animation:setTime(t)
  self.anim.timer = t
end

function animation:frame()
  return self.anim.position
end

function animation:getFramePosition(f)
  return self.anim:getFramePosition(f)
end

function animation:gotoFrame(f, t)
  self.anim:gotoFrame(f)
  if t then
    self:setTime(t)
  end
end

function animation:length()
  return table.length(self.anim.frames)
end

function animation:update(dt)
  self.anim:update(self.useDelta and dt or self.framerate)
end

function animation:draw(image, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  if self.image or image then
    local fx, fy = self.flipX, self.flipY
    if flipX ~= nil then
      fx = flipX
    end
    if flipY ~= nil then
      fy = flipY
    end
    self.anim:draw(image or self.image, x or self.x, y or self.y, r or self.r,
      sx or self.sx, sy or self.sy, ox or self.ox, oy or self.oy, offX or self.offX, offY or self.offY, fx, fy)
  end
end

animationSet = gfx:extend()

function animationSet:new(res, useDelta, framerate,
    x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  animationSet.super.new(self, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  
  local rt = type(res) == "string" and loader.getTable(res) or res
  
  self.anims = {}
  self.current = nil
  self.image = rt.img
  self.useDelta = not not useDelta
  self.framerate = framerate or 1/60
  
  for k, v in pairs(rt.sets) do
    self:add(k, animation(v))
  end
  
  if rt.default then
    self:set(rt.default)
  end
end

function animationSet:add(name, anim)
  if not self.current then
    self.current = name
  end
  
  self.anims[name] = anim
end

function animationSet:remove(name)
  self.anims[name] = nil
end

function animationSet:set(name, f, t)
  if self.current ~= name then
    self.current = name
    self:gotoFrame(f or 1, t)
    self:resume()
  end
  
  return self
end

function animationSet:looped()
  return self.anims[self.current]:looped()
end

function animationSet:pause()
  self.anims[self.current]:pause()
  
  return self
end

function animationSet:resume()
  self.anims[self.current]:resume()
end

function animationSet:isPaused()
  return self.anims[self.current]:isPaused()
end

function animationSet:time(a)
  return self.anims[a or self.current]:time()
end

function animationSet:setTime(t, a)
  self.anims[a or self.current]:setTime(t)
  
  return self
end

function animationSet:frame(a)
  return self.anims[a or self.current]:frame()
end

function animationSet:getFramePosition(f, a)
  return self.anims[a or self.current]:getFramePosition(f)
end

function animationSet:gotoFrame(f, t)
  self.anims[self.current]:gotoFrame(f)
  if t then
    self:setTime(t)
  end
  
  return self
end

function animationSet:length(a)
  return self.anims[a or self.current]:length()
end

function animationSet:update(dt, a)
  if self.anims[a or self.current] then
    self.anims[a or self.current].useDelta = self.useDelta
    self.anims[a or self.current].framerate = self.framerate
    self.anims[a or self.current]:update(dt)
  end
end

function animationSet:draw(image, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  if self.anims[self.current] and (self.image or image) then
    local fx, fy = self.flipX, self.flipY
    if flipX ~= nil then
      fx = flipX
    end
    if flipY ~= nil then
      fy = flipY
    end
    self.anims[self.current]:draw(image or self.image, x or self.x, y or self.y, r or self.r,
      sx or self.sx, sy or self.sy, ox or self.ox, oy or self.oy, offX or self.offX, offY or self.offY, fx, fy)
  end
end

text = gfx:extend()

function text:new(_text, align, limit, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  text.super.new(self, x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY, color, syncPos)
  
  self.text = _text or ""
  self.align = align or "left"
  self.limit = limit or math.huge
end

function text:draw(x, y, r, sx, sy, ox, oy, offX, offY, flipX, flipY)
  love.graphics.setShader(drawShader)
  love.graphics.printf(tostring(self.text),
    (x or self.x) + (offX or self.offX), y or self.y + (offY or self.offY), self.limit, self.align,
    r or self.r, sx or self.sx, sy or self.sy, nil, nil, ox or self.ox, oy or self.oy)
  love.graphics.setShader()
end