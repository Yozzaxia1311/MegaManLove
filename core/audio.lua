mmMusic = {}

function mmMusic.ser()
  return {
      paused=mmMusic.paused,
      curID=mmMusic.curID,
      playing=not mmMusic.stopped(),
      volume=mmMusic.getVolume(),
      queue=mmMusic.queue,
      locked=mmMusic.locked,
      track=mmMusic.track
    }
end

function mmMusic.deser(t)
  mmMusic.locked = false
  mmMusic.stop()
  mmMusic.curID = t.curID
  mmMusic._queue = t.queue
  if t.curID and t.playing then
    mmMusic.play(t.curID, t.volume, mmMusic.track)
  end
  if t.paused then
    mmMusic.pause()
  end
  mmMusic.locked = t.locked
end

mmMusic.music = nil
mmMusic.curID = nil
mmMusic.locked = false
mmMusic.loop = true
mmMusic.paused = true
mmMusic.stopping = true
mmMusic.vol = 1
mmMusic.type = 1
mmMusic._queue = nil

if ffi and not isWeb and not isMobile then
  mmMusic.gme = require("core/lovegme")()
  mmMusic.track = nil
end

function mmMusic.setVolume(v)
  if mmMusic.locked then return end
  
  if compatMusicMode or mmMusic.type ~= 1 then
    if mmMusic.music then
      mmMusic.music:setVolume(v or mmMusic.vol)
    end
  elseif mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("vol")
    mmMusic.threadChannel:push(v or mmMusic.vol)
  end
  
  mmMusic.vol = v or mmMusic.vol
end

function mmMusic.getVolume()
  return mmMusic.vol
end

function mmMusic.stop()
  if mmMusic.locked then return end
  
  if not compatMusicMode and mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("stop")
    mmMusic.thread:wait()
  end
  
  mmMusic.curID = nil
  mmMusic._queue = nil
  
  if compatMusicMode or mmMusic.type ~= 1 then
    mmMusic.loopPoint = 0
    mmMusic._time = 0
    mmMusic._tell = 0
    mmMusic.stopping = true
    mmMusic.vol = 1
    mmMusic.loopEndPoint = nil
    mmMusic.loopEndOffset = nil
    mmMusic.track = nil
    if mmMusic.music then
      mmMusic.music:stop()
      if mmMusic.music ~= mmMusic.gme then mmMusic.music:release() end
      mmMusic.music = nil
    end
    if mmMusic._ml then
      mmMusic._ml:release()
      mmMusic._ml = nil
    end
  end
end

function mmMusic.stopped()
  if compatMusicMode or mmMusic.type ~= 1 then
    return mmMusic.stopping
  else
    return not mmMusic.thread:isRunning()
  end
end

function mmMusic.pause()
  if mmMusic.locked then return end
  
  if (compatMusicMode or mmMusic.type ~= 1) then
    if not mmMusic.paused and mmMusic.music then
      mmMusic.music:pause()
      mmMusic.paused = true
    end
  elseif mmMusic.thread:isRunning() and not mmMusic.paused then
    mmMusic.threadChannel:push("pause")
    mmMusic.paused = true
  end
end

function mmMusic.unpause()
  if mmMusic.locked then return end
  
  if (compatMusicMode or mmMusic.type ~= 1) then
    if mmMusic.paused and mmMusic.music then
      mmMusic.music:play()
      mmMusic.paused = false
    end
  elseif mmMusic.thread:isRunning() and mmMusic.paused then
    mmMusic.threadChannel:push("unpause")
    mmMusic.paused = false
  end
end

function mmMusic.seek(s)
  if mmMusic.locked then return end
  
  if compatMusicMode == 1 or mmMusic.type == 2 then
    if mmMusic.music then
      mmMusic.music:seek(s)
    end
  elseif compatMusicMode == 2 then
    error("Compatibility music mode 2 cannot seek audio. (Too buggy for web!)")
  elseif mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("seek")
    mmMusic.threadChannel:push(s)
  end
end

function mmMusic.tell()
  if compatMusicMode == 1 or mmMusic.type == 2 then
    return mmMusic.music and mmMusic.music:tell()
  else
    return mmMusic._tell
  end
end

function mmMusic.setLock(w)
  mmMusic.locked = w == true
  if not compatMusicMode and mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("lock")
    mmMusic.threadChannel:push(mmMusic.locked)
  end
end

function mmMusic.isLocked()
  return mmMusic.locked
end

function mmMusic.checkQueue()
  if mmMusic._queue then
    mmMusic.play(mmMusic._queue[1], mmMusic._queue[2], mmMusic._queue[3])
    mmMusic._queue = nil
  end
end

function mmMusic.playq(path, vol, from)
  mmMusic._queue = {path, vol, from}
end

function mmMusic.play(path, vol, track)
  if mmMusic.locked or (mmMusic.curID == path and mmMusic.track == track and not mmMusic.stopped()) then return end
  
  mmMusic.stop()
  
  mmMusic.type = 1
  if checkExt(path, {"699", "amf", "ams", "dbm", "dmf", "dsm", "far", "it", "j2b",
    "mdl", "med", "mod", "mt2", "mtm", "okt", "psm", ".3m", "stm", "ult", "umx", "xm",
    "abc", "mid", "pat"}) then
    mmMusic.type = 2
  elseif checkExt(path, {"ay", "gbs", "gym", "hes", "kss", "nsf", "nsfe", "sap", "spc",
    "vgm", "vgz"}) then
    mmMusic.type = 3
    mmMusic.track = track or 0
  end
  
  local t = {}
  
  if love.filesystem.getInfo(path .. ".txt") then
    t = parseConf(path .. ".txt")
  end
  
  mmMusic.curID = path
  mmMusic._time = 0
  mmMusic._tell = mmMusic._time
  mmMusic.loopPoint = t.loopPoint or 0
  mmMusic.loop = t.loop == nil or t.loop
  mmMusic.vol = vol or mmMusic.vol
  mmMusic.stopping = false
  mmMusic.paused = false
  mmMusic._ml = nil
  mmMusic.music = nil
  
  if mmMusic.type == 1 then
    if compatMusicMode == 1 then
      if mmMusic.loop and mmMusic.loopPoint > 0 then
        local tmp = love.sound.newSoundData(mmMusic.curID)
        local lpSamples = mmMusic.loopPoint * tmp:getSampleRate()
        mmMusic.loopEndPoint = tmp:getDuration()
        mmMusic.loopEndOffset = mmMusic.loopEndPoint - mmMusic.loopPoint
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
        
        mmMusic.music = love.audio.newSource(nm)
        tmp:release()
        tmp = nil
      else
        mmMusic.music = love.audio.newSource(mmMusic.curID, "static")
      end
      if mmMusic.loop then
        mmMusic.music:setLooping(mmMusic.loopPoint == 0)
      else
        mmMusic.music:setLooping(false)
      end
      mmMusic.setVolume(mmMusic.vol)
      mmMusic.seek(mmMusic._time)
      mmMusic.music:play()
    elseif compatMusicMode == 2 then
      if mmMusic.loop and mmMusic.loopPoint > 0 then
        error("Compatibility music mode 2 cannot have audio with intros. (FRUSTRATING WEB BUG)")
        
        local tmp = love.sound.newSoundData(mmMusic.curID)
        local intro = love.sound.newSoundData(math.floor(mmMusic.loopPoint * tmp:getSampleRate()), tmp:getSampleRate(),
          tmp:getBitDepth(), tmp:getChannelCount())
        local music = love.sound.newSoundData(tmp:getSampleCount() - intro:getSampleCount(), tmp:getSampleRate(),
          tmp:getBitDepth(), tmp:getChannelCount())
        
        for ch = 1, tmp:getChannelCount() do
          for i = 0, intro:getSampleCount() - 1 do
            intro:setSample(i, ch, tmp:getSample(i, ch))
          end
        end
        local lps = intro:getSampleCount()
        for ch = 1, tmp:getChannelCount() do
          for i = 0, music:getSampleCount() - 1 do
            music:setSample(i, ch, tmp:getSample(lps + i, ch))
          end
        end
        
        mmMusic.music = love.audio.newQueueableSource(tmp:getSampleRate(), tmp:getBitDepth(), tmp:getChannelCount(), 3)
        mmMusic.setVolume(mmMusic.vol)
        mmMusic._ml = music
        mmMusic.music:queue(intro)
        mmMusic.music:queue(music)
        
        tmp:release()
        tmp = nil
        
        mmMusic.music:play()
      else
        mmMusic.music = love.audio.newSource(mmMusic.curID, "static")
        mmMusic.music:setLooping(mmMusic.loop)
        mmMusic.setVolume(mmMusic.vol)
        mmMusic.music:play()
      end
    else
      mmMusic.thread:start(mmMusic.curID, mmMusic.loop, mmMusic.loopPoint, mmMusic._time, mmMusic.vol, mmMusic.type)
      mmMusic.setLock(mmMusic.locked)
    end
  elseif mmMusic.type == 2 then
    mmMusic.music = love.audio.newSource(mmMusic.curID, "stream")
    mmMusic.setVolume(mmMusic.vol)
    mmMusic.setLock(mmMusic.locked)
    mmMusic.music:play()
  elseif mmMusic.type == 3 then
    assert(not isWeb and not isMobile, "libgme is desktop only")
    assert(ffi, "FFI is required for libgme")
    mmMusic.music = mmMusic.gme
    mmMusic.music:loadFile(mmMusic.curID)
    mmMusic.music:setTrack(mmMusic.track)
    mmMusic.music:play()
    mmMusic.setLock(mmMusic.locked)
  end
  
  collectgarbage()
  collectgarbage()
end

function mmMusic.update()
  if mmMusic.type == 1 then
    if compatMusicMode == 1 then
      if mmMusic.music and mmMusic.loop and not mmMusic.stopping and not mmMusic.paused and mmMusic.music:isPlaying() and
        mmMusic.loopPoint > 0 and mmMusic.music:tell() > mmMusic.loopEndPoint then
        mmMusic.music:seek(mmMusic.music:tell() - mmMusic.loopEndOffset)
      end
    elseif compatMusicMode == 2 then
      if mmMusic._ml and mmMusic.music and not mmMusic.stopping and not mmMusic.paused then
        while mmMusic.music:getFreeBufferCount() ~= 0 do
          mmMusic.music:queue(mmMusic._ml)
        end
      end
    else
      while not mmMusic.stopping do
        local value = mmMusic.mainChannel:pop()
        if value ~= nil then
          if value == "time" then
            mmMusic._time = mmMusic.mainChannel:pop()
          elseif value == "tell" then
            mmMusic._tell = mmMusic.mainChannel:pop()
          elseif value == "vol" then
            mmMusic.vol = mmMusic.mainChannel:pop()
          elseif value == "stop" then
            mmMusic.loopPoint = 0
            mmMusic._time = 0
            mmMusic._tell = 0
            mmMusic.stopping = true
            mmMusic.vol = 1
          end
        else
          break
        end
      end
    end
  elseif mmMusic.type == 3 then
    mmMusic.gme:update()
  end
end

-- Sample streaming

if not compatMusicMode then
  mmMusic.loopPoint = 0
  mmMusic._time = 0
  mmMusic._tell = 0
  mmMusic._dec = nil
  mmMusic._rate = 0
  mmMusic.buffers = 3
  mmMusic.threadChannel = love.thread.getChannel("mmMusicThread")
  mmMusic.mainChannel = love.thread.getChannel("mmMusicMain")

  mmMusic.thread = love.thread.newThread([[
      require("love.timer")
      require("love.sound")
      require("love.audio")
      require("core/utils")
      require("core/audio")
      
      local curID, loop, loopPoint, time, vol, typ = ...
      
      local timer = love.timer
      local threadChannel = mmMusic.threadChannel
      local mainChannel = mmMusic.mainChannel
      local run = true
      
      mmMusic._threadPlay(curID, loop, loopPoint, time, vol, typ)
      
      while run do
        mmMusic._threadUpdate()
        
        while true do
          local value = threadChannel:pop()
          if value ~= nil then
            if value == "stop" then
              run = false
            elseif value == "pause" then
              mmMusic._threadPause()
            elseif value == "unpause" then
              mmMusic._threadUnpause()
            elseif value == "seek" then
              mmMusic._threadSeek(threadChannel:pop())
            elseif value == "lock" then
              mmMusic.locked = threadChannel:pop()
            elseif value == "vol" then
              mmMusic._threadSetVolume(threadChannel:pop())
            end
          else
            break
          end
        end
        
        mainChannel:push("time")
        mainChannel:push(mmMusic._time)
        if mmMusic.music then
          mainChannel:push("tell")
          mainChannel:push(mmMusic._threadTell())
        end
        
        if mmMusic._threadStopped() then
          run = false
        end
        
        if timer then
          timer.sleep(0.05)
        end
      end
      
      mmMusic._threadStop()
      mainChannel:push("stop")
    ]])
elseif compatMusicMode == 1 then
  mmMusic.loopEndPoint = nil
  mmMusic.loopEndOffset = nil
elseif compatMusicMode == 2 then
  mmMusic._ml = nil
end

function mmMusic._threadUpdate()
  if mmMusic.music then
    local stop = false
    
    while mmMusic.music:getFreeBufferCount() > mmMusic.buffers do
      if mmMusic.music:getDuration() == 0 then
        mmMusic._threadDecode()
      end
      mmMusic._time = math.min(mmMusic._time + mmMusic._rate, mmMusic._dec:getDuration())
      local sd = mmMusic._threadDecode()
      if not sd and not mmMusic.loop and mmMusic.music:tell() == 0 and mmMusic._time ~= 0 then
        stop = true
        break
      end
    end
    
    if stop then
      mmMusic._threadStop()
    end
  end
end

function mmMusic._threadPlay(curID, loop, loopPoint, time, vol)
  if mmMusic.locked or (mmMusic.music and mmMusic.curID == curID and not mmMusic._threadStopped()) then return end
  
  mmMusic._threadStop()
  
  mmMusic.curID = curID
  mmMusic.type = typ
  mmMusic._time = time or 0
  mmMusic._dec = love.sound.newDecoder(curID, 1024*24)
  mmMusic._rate = ((1024*24) / ((mmMusic._dec:getBitDepth() / 8) * mmMusic._dec:getChannelCount())) / mmMusic._dec:getSampleRate()
  mmMusic.buffers = 4
  while mmMusic._dec:getDuration() * mmMusic.buffers < mmMusic._rate do -- incase of unbelievably short "music".
    mmMusic.buffers = mmMusic.buffers + 1
  end
  mmMusic.music = love.audio.newQueueableSource(
    mmMusic._dec:getSampleRate(), mmMusic._dec:getBitDepth(), mmMusic._dec:getChannelCount(), mmMusic.buffers + 3)
  mmMusic.loopPoint = loopPoint
  mmMusic.loop = loop
  mmMusic._threadSetVolume(mmMusic.vol)
  mmMusic._threadUpdate()
  mmMusic.music:play()
end

function mmMusic._threadDecode()
  mmMusic._dec:seek(mmMusic._time)
  local sd = mmMusic._dec:decode()
  if sd then
    mmMusic.music:queue(sd)
  else
    if mmMusic.loop then
      mmMusic._dec:seek(mmMusic.loopPoint)
      mmMusic.music:queue(mmMusic._dec:decode())
      mmMusic._time = mmMusic.loopPoint
    end
  end
  
  return sd
end

function mmMusic._threadTell()
  if mmMusic.music then
    return math.max(mmMusic._time + mmMusic.music:tell() - mmMusic._rate, 0)
  end
  
  return 0
end

function mmMusic._threadSeek(s)
  if s and mmMusic._time ~= s and mmMusic.music and mmMusic._dec then
    mmMusic.music:seek(mmMusic.music:getDuration()+1)
    mmMusic._time = s
    mmMusic._threadUpdate()
  end
end

function mmMusic._threadUnpause()
  if mmMusic.music and mmMusic.paused then
    mmMusic.music:play()
    mmMusic.paused = false
  end
end

function mmMusic._threadPause()
  if mmMusic.music and not mmMusic.paused then
    mmMusic.music:pause()
    mmMusic.paused = true
  end
end

function mmMusic._threadStopped()
  return mmMusic.music and not mmMusic.music:isPlaying()
end

function mmMusic._threadStop()
  if mmMusic.music then
    mmMusic.curID = nil
    mmMusic.loopPoint = 0
    mmMusic._time = 0
    mmMusic._tell = 0
    mmMusic._queue = nil
    mmMusic.music:stop()
    mmMusic.music:release()
    mmMusic.music = nil
    mmMusic._dec:release()
    mmMusic._dec = nil
  end
end

function mmMusic._threadSetVolume(v)
  if mmMusic.music and v then
    mmMusic.vol = math.clamp(v, 0, 1)
    mmMusic.music:setVolume(mmMusic.vol)
  end
end

function mmMusic._threadGetVolume()
  return mmMusic.vol
end