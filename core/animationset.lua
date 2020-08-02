animationSet = class:extend()

function animationSet:new()
  self.flipX = false
  self.flipY = false
  self.anims = {}
  self.current = nil
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
end

function animationSet:looped()
  return self.anims[self.current]:looped()
end

function animationSet:pause()
  self.anims[self.current]:pause()
end

function animationSet:resume()
  self.anims[self.current]:resume()
end

function animationSet:isPaused()
  return self.anims[self.current].status == "paused"
end

function animationSet:time(a)
  return self.anims[a or self.current].timer
end

function animationSet:setTime(t, a)
  self.anims[a or self.current].timer = t
end

function animationSet:frame(a)
  return self.anims[a or self.current].position
end

function animationSet:gotoFrame(f, t)
  self.anims[self.current]:gotoFrame(f)
  if t then
    self:setTime(t)
  end
end

function animationSet:length(a)
  return table.legnth(self.anims[a or self.current].frames)
end

function animationSet:update(dt)
  if self.anims[self.current] then
    self.anims[self.current]:update(dt)
  end
end

function animationSet:draw(texture, x, y, r, sx, sy, ox, oy, kx, ky)
  if self.anims[self.current] then
    self.anims[self.current].flipX = self.flipX
    self.anims[self.current].flipY = self.flipY
    self.anims[self.current]:draw(texture, x, y, r, sx, sy, ox, oy, kx, ky)
  end
end