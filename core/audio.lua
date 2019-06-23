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
  if mmMusic.lock or (mmMusic.cur and mmMusic.cur.id == tostring(loop) .. tostring(intro)) then return end
  mmMusic.stopMusic()
  if intro then
    if loop then
      mmMusic.cur = mmMusic(love.audio.newSource(loop, "stream"), love.audio.newSource(intro, "stream"))
    else
      mmMusic.cur = mmMusic(nil, love.audio.newSource(intro, "stream"))
    end
  else
    mmMusic.cur = mmMusic(love.audio.newSource(loop, "stream"), nil)
  end
  mmMusic.cur.id = tostring(loop) .. tostring(intro)
  mmMusic.cur.introFile = intro
  mmMusic.cur.loopFile = loop
  mmMusic.cur.playedVol = vol
  mmMusic.cur:play(nil, vol)
end

function mmMusic.stopMusic()
  if not mmMusic.lock and mmMusic.cur then
    mmMusic.cur:pause()
    mmMusic.cur = nil
  end
end

function mmMusic:new(path, pathIntro)
  self.musicLoop = path
  self.musicIntro = pathIntro
  self.playingLoop = false
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
  return self.musicLoop:getVolume()
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
    self.playingLoop = true
  end
end