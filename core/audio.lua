mmSfx = {}

function mmSfx.play(p, l, v)
  loader.get(p):stop()
  loader.get(p):setLooping(l or false)
  loader.get(p):setVolume(v or 1)
  loader.get(p):play()
end

function mmSfx.stop(s)
  loader.get(s):stop()
end

mmMusic = class:extend()

mmMusic.cur = nil
mmMusic.lock = false

function mmMusic.playFromFile(loop, intro, vol)
  if mmMusic.lock or (mmMusic.cur ~= nil and mmMusic.cur.id == tostring(loop) .. tostring(intro)) then return end
  mmMusic.stopMusic()
  if intro ~= nil then
    if loop ~= nil then
      mmMusic.cur = mmMusic(love.audio.newSource(loop, "stream"), love.audio.newSource(intro, "stream"), true)
    else
      mmMusic.cur = mmMusic(nil, love.audio.newSource(intro, "stream"))
    end
  else
    mmMusic.cur = mmMusic(love.audio.newSource(loop, "stream"), nil, true)
  end
  mmMusic.cur.id = tostring(loop) .. tostring(intro)
  mmMusic.cur.introFile = intro
  mmMusic.cur.loopFile = loop
  mmMusic.cur.playedVol = vol
  mmMusic.cur:play(nil, vol)
end

function mmMusic.stopMusic()
  if not mmMusic.lock and mmMusic.cur ~= nil then
    mmMusic.cur:pause()
    mmMusic.cur = nil
  end
end

function mmMusic:new(path, pathIntro, preload)
  self.musicLoop = path
  self.musicIntro = pathIntro
  self.playingLoop = false
  self.current = nil
  if (preload == nil or preload) then
    if self.musicIntro ~= nil then
      self.musicIntro:play()
      self.current = self.musicIntro
      self.musicIntro:pause()
    end
    if self.musicLoop ~= nil then
      self.musicLoop:play()
      self.current = self.musicLoop
      self.musicLoop:pause()
    end
  end
end

function mmMusic:pause()
  if self.musicLoop ~= nil then
    self.musicLoop:pause()
  end
  if self.musicIntro ~= nil then
    self.musicIntro:pause()
  end
end

function mmMusic:setVolume(v)
  if self.musicLoop ~= nil then
    self.musicLoop:setVolume(v)
  end
  if self.musicIntro ~= nil then
    self.musicIntro:setVolume(v)
  end
end

function mmMusic:getVolume()
  return self.musicLoop:getVolume()
end

function mmMusic:stopped()
  return self.current:isStopped()
end

function mmMusic:unpause()
  if self.musicLoop ~= nil and self.musicIntro == nil then
    self.musicLoop:resume()
  elseif self.musicLoop ~= nil and self.musicIntro ~= nil then
    if not self.musicIntro:isPlaying() then
      self.musicIntro:resume()
    elseif not self.musicLoop:isPlaying() then
      self.musicLoop:resume()
    end
  end
end

function mmMusic:play(l, v)
  if self.musicLoop ~= nil and v ~= nil then
    self.musicLoop:setVolume(v)
  end
  if self.musicIntro ~= nil and v ~= nil then
    self.musicIntro:setVolume(v)
  end
  if self.musicIntro == nil then
    self.musicLoop:seek(0)
    self.musicLoop:play()
    self.musicLoop:setLooping(ternary(l == nil, true, l))
    self.current = self.musicLoop
  else
    self.musicIntro:setLooping(false)
    if self.musicLoop ~= nil then
      self.musicLoop:setLooping(true)
      self.musicLoop:seek(0)
    end
    self.musicIntro:seek(0)
    self.musicIntro:play()
    self.playingLoop = false
    self.current = self.musicIntro
  end
end

function mmMusic:update()
  if not self.playingLoop and self.musicIntro ~= nil and not self.musicIntro:isPlaying() and self.musicLoop ~= nil and
      not self.musicLoop:isPlaying() then
    self.musicLoop:play()
    self.playingLoop = true
  end
end