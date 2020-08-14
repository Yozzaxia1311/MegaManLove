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
  return not self.musicLoop:isPlaying()
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
    self.musicLoop:setLooping(loop == nil or loop)
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

mmMusicOld = class:extend()

function mmMusicOld:new(path, pathIntro)
  self.musicLoop = path
  self.musicIntro = pathIntro
  self.playingLoop = false
  self.current = self.musicIntro or self.musicLoop
  self.paused = false
end

function mmMusicOld:pause()
  if self.musicLoop then
    self.musicLoop:pause()
  end
  if self.musicIntro then
    self.musicIntro:pause()
  end
  self.paused = true
end

function mmMusicOld:setVolume(v)
  if self.musicLoop then
    self.musicLoop:setVolume(v)
  end
  if self.musicIntro then
    self.musicIntro:setVolume(v)
  end
end

function mmMusicOld:getVolume()
  return self.current:getVolume()
end

function mmMusicOld:stopped()
  return self.current:isStopped()
end

function mmMusicOld:unpause()
  if self.musicLoop and not self.musicIntro then
    self.musicLoop:resume()
  elseif self.musicLoop and self.musicIntro then
    if not self.musicIntro:isPlaying() then
      self.musicIntro:resume()
    elseif not self.musicLoop:isPlaying() then
      self.musicLoop:resume()
    end
  end
  self.paused = false
end

function mmMusicOld:play(l, v)
  if self.musicLoop and v then
    self.musicLoop:setVolume(v)
  end
  if self.musicIntro and v then
    self.musicIntro:setVolume(v)
  end
  if not self.musicIntro then
    self.musicLoop:play()
    self.musicLoop:setLooping(l == nil and true or l)
    self.current = self.musicLoop
  else
    self.musicIntro:setLooping(false)
    if self.musicLoop then
      self.musicLoop:setLooping(true)
    end
    self.musicIntro:play()
    self.playingLoop = false
    self.current = self.musicIntro
  end
  self.paused = false
end

function mmMusicOld:update()
  if not self.paused and not self.playingLoop and self.musicIntro and self.musicLoop and
      not self.musicLoop:isPlaying() and not self.musicIntro:isPlaying() then
    self.musicLoop:play()
    self.current = self.musicLoop
    self.playingLoop = true
  end
end