mmMusic = class:extend()

function mmMusic:new(path, pathIntro)
  self.musicLoop = path
  self.musicIntro = pathIntro
  self.playingLoop = false
  self.current = self.musicIntro or self.musicLoop
  self.paused = false
end

function mmMusic:pause()
  if self.musicLoop then
    self.musicLoop:pause()
  end
  if self.musicIntro then
    self.musicIntro:pause()
  end
  self.paused = true
end

function mmMusic:setVolume(v)
  if self.musicLoop then
    self.musicLoop:setVolume(v)
  end
  if self.musicIntro then
    self.musicIntro:setVolume(v)
  end
end

function mmMusic:getVolume()
  return self.current:getVolume()
end

function mmMusic:stopped()
  return self.current:isStopped()
end

function mmMusic:unpause()
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

function mmMusic:play(l, v)
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

function mmMusic:update()
  if not self.paused and not self.playingLoop and self.musicIntro and self.musicLoop and
      not self.musicLoop:isPlaying() and not self.musicIntro:isPlaying() then
    self.musicLoop:play()
    self.current = self.musicLoop
    self.playingLoop = true
  end
end
