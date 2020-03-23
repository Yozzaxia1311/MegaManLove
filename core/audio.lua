mmMusic = class:extend()

function mmMusic:new(path)
  self.musicLoop = path
  self.paused = true
end

function mmMusic:pause()
  self.musicLoop:pause()
  self.paused = true
end

function mmMusic:setVolume(v)
  if v then
    self.musicLoop:setVolume(math.clamp(v, 0, 1))
  end
end

function mmMusic:getVolume()
  return self.musicLoop:getVolume()
end

function mmMusic:stopped()
  return self.musicLoop:isStopped()
end

function mmMusic:unpause()
  self.musicLoop:resume()
  self.paused = false
end

function mmMusic:play(loop, loopPoint, loopEndPoint, vol)
  self.loopPoint = loopPoint
  self.loopEndPoint = loopEndPoint == nil and self.musicLoop:getDuration("samples") or
    math.clamp(loopEndPoint, self.loopPoint, self.musicLoop:getDuration("samples"))
  if loopPoint or loopEndPoint then
    if self.loopEndPoint == self.musicLoop:getDuration("samples") then
      print("It's recommended to add a portion of music from the loop point to the loop end point; this makes the looping seamless.")
    end
    self.musicLoop:setLooping(false)
  else
    self.musicLoop:setLooping(loop ~= nil and loop)
  end
  self:setVolume(1)
  self:setVolume(vol)
  self.musicLoop:play()
  self.paused = false
end

function mmMusic:update()
  if self.loopPoint and self.loopEndPoint then
    if not self.musicLoop:isPlaying() and not self.paused and self.musicLoop:tell("samples") == 0 then
      self.musicLoop:seek(self.musicLoop:getDuration("samples") - (self.loopEndPoint - self.loopPoint), "samples")
      self.musicLoop:play()
    elseif self.musicLoop:isPlaying() and self.musicLoop:tell("samples") > self.loopEndPoint then
      self.musicLoop:seek(self.musicLoop:tell("samples") - (self.loopEndPoint - self.loopPoint), "samples")
    end
  end
end
