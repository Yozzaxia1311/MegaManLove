sfx = {}

sfx._cachedMutes = {}
sfx.curS = {}

function sfx.updateGMEVoiceMutes()
  for voice, s in safepairs(sfx._cachedMutes) do
    if not s:isPlaying() then
      sfx._cachedMutes[voice] = nil
    else
      music.GMEPushMuteVoice(voice)
    end
  end
end

function sfx.play(p, l, v, stack, muteGMEVoices)
  if loader.get(p) then
    if not stack then
      loader.get(p):stop()
    end
    local resTable = loader.getTable(p)
    if resTable.conf and resTable.conf.muteGMEVoices then
      if type(resTable.conf.muteGMEVoices) == "number" then
        sfx._cachedMutes[resTable.conf.muteGMEVoices] = resTable.data
        music.GMEPushMuteVoice(resTable.conf.muteGMEVoices)
      else
        for _, voice in pairs(resTable.conf.muteGMEVoices) do
          sfx._cachedMutes[voice] = resTable.data
          music.GMEPushMuteVoice(voice)
        end
      end
    end
    resTable.data:setLooping(l or false)
    resTable.data:setVolume(v or 1)
    resTable.data:play()
    
    return resTable.data
  else
    error("Sound \"" .. p .. "\" doesn't exist.")
  end
end

function sfx.playFromFile(p, l, v, stack)
  local s = sfx.curS.data
  if s and not stack then
    s:stop()
  end
  if not s or sfx.curS.id ~= p then
    if s then
      s:release()
    end
    s = love.audio.newSource(p, "static")
    
    sfx.curS.conf = love.filesystem.getInfo(p .. ".txt") and parseConf(p .. ".txt")
    if sfx.curS.conf and sfx.curS.conf.muteGMEVoices then
      if type(sfx.curS.conf.muteGMEVoices) == "number" then
        sfx._cachedMutes[sfx.curS.conf.muteGMEVoices] = s
        music.GMEPushMuteVoice(sfx.curS.conf.muteGMEVoices)
      else
        for _, voice in pairs(sfx.curS.conf.muteGMEVoices) do
          sfx._cachedMutes[voice] = s
          music.GMEPushMuteVoice(voice)
        end
      end
    end
  end
  s:setLooping(not not l)
  s:setVolume(v or 1)
  s:play()
  sfx.curS.id = p
  sfx.curS.data = s
  
  return s
end

function sfx.stop(s)
  if loader.get(s) then
    loader.get(s):stop()
  end
  if s == sfx.curS.id and sfx.curS.data then
    sfx.curS.data:stop()
  end
end

function sfx.stopAll()
  for _, v in pairs(loader.resources) do
    if v.type == "sound" then
      v.data:stop()
    end
  end
  for _, v in pairs(loader.locked) do
    if v.type == "sound" then
      v.data:stop()
    end
  end
  if sfx.curS.data then
    sfx.curS.data:stop()
  end
end

music = {}

function music.ser()
  return {
      paused=music.paused,
      curID=music.curID,
      playing=not music.stopped(),
      volume=music.getVolume(),
      queue=music.queue,
      locked=music.locked,
      track=music.track,
      mutes=music._mutes,
      pushMute=music._pushMute,
      tell=music.tell()
    }
end

function music.deser(t)
  music.locked = false
  music.stop()
  music.curID = t.curID
  music._queue = t.queue
  if t.mutes then
    music._mutes = t.mutes
    for v, b in safepairs(music._mutes) do
      music.muteGMEVoice(v, b)
    end
  end
  if t.pushMute then
    music._pushMute = t.pushMute
  end
  if t.curID and t.playing then
    music.play(t.curID, t.volume, t.track, t.tell)
  end
  if t.paused then
    music.pause()
  end
  music.locked = t.locked
end

music.music = nil
music.curID = nil
music.locked = false
music.loop = true
music.paused = true
music.stopping = true
music.vol = 1
music.type = 1
music._queue = nil

if canUseGME then
  music.gme = loveGME()
  music.track = nil
  music._mutes = {}
  music._pushMute = {}
end

function music.setVolume(v)
  if music.locked then return end
  
  if compatMusicMode or music.type ~= 1 then
    if music.music then
      music.music:setVolume(v or music.vol)
    end
  elseif music.thread:isRunning() then
    music.threadChannel:push("vol")
    music.threadChannel:push(v or music.vol)
  end
  
  music.vol = v or music.vol
end

function music.getVolume()
  return music.vol
end

function music.stop()
  if music.locked then return end
  
  if not compatMusicMode and music.thread:isRunning() then
    music.threadChannel:push("stop")
    music.thread:wait()
  end
  
  music.curID = nil
  music._queue = nil
  
  if compatMusicMode or music.type ~= 1 then
    music.loopPoint = 0
    music._time = 0
    music._tell = nil
    music.stopping = true
    music.vol = 1
    music.loopEndPoint = nil
    music.loopEndOffset = nil
    music.track = nil
    if music.music then
      music.music:stop()
      if music.music ~= music.gme then music.music:release() end
      music.music = nil
    end
    if music._ml then
      music._ml:release()
      music._ml = nil
    end
  end
end

function music.stopped()
  if compatMusicMode or music.type ~= 1 then
    return music.stopping
  else
    return not music.thread:isRunning()
  end
end

function music.pause()
  if music.locked then return end
  
  if (compatMusicMode or music.type ~= 1) then
    if not music.paused and music.music then
      music.music:pause()
      music.paused = true
    end
  elseif music.thread:isRunning() and not music.paused then
    music.threadChannel:push("pause")
    music.paused = true
  end
end

function music.unpause()
  if music.locked then return end
  
  if (compatMusicMode or music.type ~= 1) then
    if music.paused and music.music then
      music.music:play()
      music.paused = false
    end
  elseif music.thread:isRunning() and music.paused then
    music.threadChannel:push("unpause")
    music.paused = false
  end
end

function music.seek(s)
  if music.locked then return end
  
  if compatMusicMode or music.type == 2 or music.type == 3 then
    if music.music then
      music.music:seek(s)
    end
  elseif music.thread:isRunning() then
    music.threadChannel:push("seek")
    music.threadChannel:push(s)
  end
end

function music.tell()
  if compatMusicMode or music.type == 2 or music.type == 3 then
    return music.music and music.music:tell()
  else
    return music._tell
  end
end

function music.muteGMEVoice(v, b)
  if music.locked then return end
  
  if music.gme and music._mutes then
    music._mutes[v] = not not b
    if music.type == 3 and music.gme.voice_count > 0 then
      music.gme:muteVoice(v, not not b)
    end
  end
end

function music.isGMEVoiceMute(v)
  return music._mutes and music._mutes[v]
end

function music.GMEPushMuteVoice(v)
  if music.locked then return end
  
  if music._pushMute then
    if not music._pushMute[v] then
      music._pushMute[v] = {1}
    else
      music._pushMute[v][1] = 1
    end
  end
end

function music.setLock(w)
  music.locked = not not w
  if not compatMusicMode and music.thread:isRunning() then
    music.threadChannel:push("lock")
    music.threadChannel:push(music.locked)
  end
end

function music.isLocked()
  return music.locked
end

function music.checkQueue()
  if music._queue then
    music.play(music._queue[1], music._queue[2], music._queue[3])
    music._queue = nil
  end
end

function music.playq(path, vol, track, from)
  music._queue = {path, vol, track, from}
end

function music.play(path, vol, track, from)
  if music.locked or (music.curID == path and music.track == track and not music.stopped()) then return end
  
  music.stop()
  
  music.type = 1
  if checkExt(path, {"699", "amf", "ams", "dbm", "dmf", "dsm", "far", "it", "j2b",
    "mdl", "med", "mod", "mt2", "mtm", "okt", "psm", ".3m", "stm", "ult", "umx", "xm",
    "abc", "mid", "pat"}) then
    music.type = 2
  elseif checkExt(path, {"ay", "gbs", "gym", "hes", "kss", "nsf", "nsfe", "sap", "spc",
    "vgm", "vgz"}) then
    music.type = 3
    music.track = track or 0
  end
  
  local t = {}
  
  if love.filesystem.getInfo(path .. ".txt") then
    t = parseConf(path .. ".txt")
  end
  
  music.curID = path
  music._time = from or 0
  music._tell = music._time
  music.loopPoint = t.loopPoint or 0
  music.loop = t.loop == nil or t.loop
  music.vol = vol or music.vol
  music.stopping = false
  music.paused = false
  music._ml = nil
  music.music = nil
  music.track = track or 0
  
  if music.type == 1 then
    if compatMusicMode then
      if music.loop and music.loopPoint > 0 then
        local tmp = love.sound.newSoundData(music.curID)
        local lpSamples = music.loopPoint * tmp:getSampleRate()
        music.loopEndPoint = tmp:getDuration()
        music.loopEndOffset = music.loopEndPoint - music.loopPoint
        local nm = love.sound.newSoundData(tmp:getSampleCount() + tmp:getSampleRate(),
          tmp:getSampleRate(), tmp:getBitDepth(), tmp:getChannelCount())
        
        if ffi then
          ffi.copy(nm:getFFIPointer(), tmp:getFFIPointer(), tmp:getSize() - 1)
        else
          for ch = 1, tmp:getChannelCount() do
            for i = 0, tmp:getSampleCount() - 1 do
              nm:setSample(i, ch, tmp:getSample(i, ch))
            end
          end
        end
        
        local tmp2 = tmp:getSampleCount() - 1
        for ch = 1, tmp:getChannelCount() do
          for i = tmp:getSampleCount(), nm:getSampleCount() - 1 do
            nm:setSample(i, ch, tmp:getSample(math.wrap(i, lpSamples, tmp2), ch))
          end
        end
        
        music.music = love.audio.newSource(nm)
        tmp:release()
        tmp = nil
      else
        music.music = love.audio.newSource(music.curID, "static")
      end
      if music.loop then
        music.music:setLooping(music.loopPoint == 0)
      else
        music.music:setLooping(false)
      end
      music.setVolume(music.vol)
      music.seek(music._time)
      music.music:play()
    else
      music.thread:start(music.curID, music.loop, music.loopPoint, music._time, music.vol, music.type)
      music.setLock(music.locked)
    end
  elseif music.type == 2 then
    music.music = love.audio.newSource(music.curID, "stream")
    music.setVolume(music.vol)
    music.setLock(music.locked)
    music.music:play()
  elseif music.type == 3 then
    if not canUseGME then
      local exists = love.filesystem.getInfo(music.curID .. ".txt")
      if love.system.getOS() == "Linux" then
        assert(love.filesystem.getInfo(music.curID .. ".txt"), "No backup music or libgme. " ..
          "(Install 'libgme-dev' with your package manager)")
      else
        assert(love.filesystem.getInfo(music.curID .. ".txt"), "Backup music conf does not exist")
      end
      local bConf = parseConf(music.curID .. ".txt")
      assert(bConf["backup" .. music.track], "Backup music not listed in conf")
      music.play(bConf["backup" .. music.track], music.vol)
      return
    else
      assert(loveGME, "LoveGME could not be loaded.")
      music.music = music.gme
      music.music:loadFile(music.curID)
      for voice, bool in safepairs(music._mutes) do
        music.muteGMEVoice(voice, bool)
      end
      music.music:setTrack(music.track)
      music.music:seek(music._time)
      music.music:play()
      music.setLock(music.locked)
    end
  end
  
  collectgarbage()
  collectgarbage()
end

function music.update()
  if music.type == 1 then
    if compatMusicMode then
      if music.music and music.loop and not music.stopping and not music.paused and music.music:isPlaying() and
        music.loopPoint > 0 and music.music:tell() > music.loopEndPoint then
        music.music:seek(music.music:tell() - music.loopEndOffset)
      end
    else
      while not music.stopping do
        local value = music.mainChannel:pop()
        if value ~= nil then
          if value == "time" then
            music._time = music.mainChannel:pop()
          elseif value == "tell" then
            music._tell = music.mainChannel:pop()
          elseif value == "vol" then
            music.vol = music.mainChannel:pop()
          elseif value == "stop" then
            music.loopPoint = 0
            music._time = 0
            music._tell = nil
            music.stopping = true
            music.vol = 1
          end
        else
          break
        end
      end
    end
  elseif music.type == 3 then
    for voice, data in safepairs(music._pushMute) do
      if data[1] == 1 then
        music._pushMute[voice][1] = 0
        if not music._pushMute[voice][3] then
          music._pushMute[voice][2] = music._mutes[voice]
          music.muteGMEVoice(voice, true)
          music._pushMute[voice][3] = true
        end
      elseif data[1] == 0 then
        if music._pushMute[voice][2] == nil then
          music.muteGMEVoice(voice, false)
        else
          music.muteGMEVoice(voice, music._pushMute[voice][2])
        end
        music._pushMute[voice] = nil
      end
    end
    music.gme:update()
  end
end

function music.clean()
  music.stop()
  if music.gme then music.gme:release() end
end

-- Sample streaming

if compatMusicMode then
  music.loopEndPoint = nil
  music.loopEndOffset = nil
else
  music.loopPoint = 0
  music._time = 0
  music._tell = nil
  music._dec = nil
  music._rate = 0
  music._queueLengths = {}
  music.buffers = 3
  music.threadChannel = love.thread.getChannel("musicThread")
  music.mainChannel = love.thread.getChannel("musicMain")

  music.thread = love.thread.newThread([[
      require("love.timer")
      require("love.sound")
      require("love.audio")
      require("core/utils")
      require("core/audio")
      
      local curID, loop, loopPoint, time, vol, typ = ...
      
      local timer = love.timer
      local threadChannel = music.threadChannel
      local mainChannel = music.mainChannel
      local run = true
      
      music._threadPlay(curID, loop, loopPoint, time, vol, typ)
      
      while run do
        music._threadUpdate()
        
        while true do
          local value = threadChannel:pop()
          if value ~= nil then
            if value == "stop" then
              run = false
            elseif value == "pause" then
              music._threadPause()
            elseif value == "unpause" then
              music._threadUnpause()
            elseif value == "seek" then
              music._threadSeek(threadChannel:pop())
            elseif value == "lock" then
              music.locked = threadChannel:pop()
            elseif value == "vol" then
              music._threadSetVolume(threadChannel:pop())
            end
          else
            break
          end
        end
        
        mainChannel:push("time")
        mainChannel:push(music._time)
        if music.music then
          mainChannel:push("tell")
          mainChannel:push(music._threadTell())
        end
        
        if music._threadStopped() then
          run = false
        end
        
        timer.sleep(0.03)
      end
      
      music._threadStop()
      mainChannel:push("stop")
    ]])
end

function music._threadUpdate()
  if music.music then
    local stop = false
    
    while music.music:getFreeBufferCount() >= music.buffers do
      local sd = music._threadDecode()
      if sd then
        music._queueLengths[#music._queueLengths + 1] = sd:getDuration()
        if #music._queueLengths > music.buffers then
          table.remove(music._queueLengths, 1)
        end
      else
        if not music.loop and music.music:getFreeBufferCount() == music.buffers + 3 then
          stop = true
        end
        
        break
      end
    end
    
    if stop then
      music._threadStop()
    end
  end
end

function music._threadPlay(curID, loop, loopPoint, time, vol)
  if music.locked or (music.music and music.curID == curID and not music._threadStopped()) then return end
  
  music._threadStop()
  
  music.curID = curID
  music.type = typ
  music._time = time or 0
  music._dec = love.sound.newDecoder(curID, 1024*24)
  music._rate = ((1024*24) / ((music._dec:getBitDepth() / 8) * music._dec:getChannelCount())) / music._dec:getSampleRate()
  music._queueLengths = {}
  music.buffers = 4
  while music._dec:getDuration() * music.buffers < music._rate do -- incase of unbelievably short "music".
    music.buffers = music.buffers + 1
  end
  music.music = love.audio.newQueueableSource(
    music._dec:getSampleRate(), music._dec:getBitDepth(), music._dec:getChannelCount(), music.buffers + 3)
  music.loopPoint = loopPoint
  music.loop = loop
  music._threadSetVolume(music.vol)
  music._threadUpdate()
  music.music:play()
end

function music._threadDecode()
  music._dec:seek(music._time)
  local sd = music._dec:decode()
  if sd then
    music.music:queue(sd)
    music._time = math.min(music._time + music._rate, music._dec:getDuration())
  elseif music.loop then
    music._dec:seek(music.loopPoint)
    music.music:queue(music._dec:decode())
    music._time = music.loopPoint + music._rate
  end
  
  return sd
end

function music._threadTell()
  if music.music then
    local queueLength = 0
    for i = 1, #music._queueLengths do
      queueLength = queueLength + music._queueLengths[i]
    end
    return math.max((music._time - queueLength) + music.music:tell(), 0)
  end
  
  return 0
end

function music._threadSeek(s)
  if s and music._time ~= s and music.music and music._dec then
    music.music:seek(music.music:getDuration()+1)
    music._queueLengths = {}
    music._time = s
    music._threadUpdate()
    music.music:play()
  end
end

function music._threadUnpause()
  if music.music and music.paused then
    music.music:play()
    music.paused = false
  end
end

function music._threadPause()
  if music.music and not music.paused then
    music.music:pause()
    music.paused = true
  end
end

function music._threadStopped()
  return music.music and not music.music:isPlaying()
end

function music._threadStop()
  if music.music then
    music.curID = nil
    music.loopPoint = 0
    music._time = 0
    music._tell = nil
    music._queue = nil
    music._queueLengths = {}
    music.music:stop()
    music.music:release()
    music.music = nil
    music._dec:release()
    music._dec = nil
  end
end

function music._threadSetVolume(v)
  if music.music and v then
    music.vol = math.clamp(v, 0, 1)
    music.music:setVolume(music.vol)
  end
end

function music._threadGetVolume()
  return music.vol
end