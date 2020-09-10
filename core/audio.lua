mmMusic = {}

function mmMusic.ser()
  return {
      paused=mmMusic.paused,
      curID=mmMusic.curID,
      playing=not mmMusic.stopped(),
      volume=mmMusic.getVolume(),
      tell=mmMusic.mTell,
      queue=mmMusic.queue,
      locked=mmMusic.locked
    }
end

function mmMusic.deser(t)
  mmMusic.locked = false
  
  if mmMusic.thread and mmMusic.thread:isRunning() then
    mmMusic.stop()
    mmMusic.thread:wait()
  end
  
  mmMusic.curID = t.curID
  mmMusic._queue = t.queue
  if t.curID and t.playing then
    mmMusic.play(t.curID, t.volume, t.tell)
  end
  if t.paused then
    mmMusic.pause()
  end
  mmMusic.locked = t.locked
end

mmMusic.music = nil
mmMusic.dec = nil
mmMusic.curID = nil
mmMusic.locked = false
mmMusic.loopPoint = 0
mmMusic.loop = true
mmMusic.rate = 0
mmMusic.time = 0
mmMusic.mTell = 0
mmMusic.buffers = 3
mmMusic._queue = nil
mmMusic.paused = true
mmMusic.stopping = true
mmMusic.vol = 1

mmMusic.threadChannel = love.thread.getChannel("mmMusicThread")
mmMusic.mainChannel = love.thread.getChannel("mmMusicMain")

mmMusic.thread = love.thread.newThread([[
    require("love.timer")
    require("love.sound")
    require("love.audio")
    require("core/utils")
    require("core/audio")
    
    local curID, loop, loopPoint, time, vol = ...
    local timer = love.timer
    local threadChannel = mmMusic.threadChannel
    local mainChannel = mmMusic.mainChannel
    local run = true
    
    mmMusic._threadPlay(curID, loop, loopPoint, time, vol)
    
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
      mainChannel:push(mmMusic.time)
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

function mmMusic._threadSetVolume(v)
  if mmMusic.music and not mmMusic.locked and v then
    mmMusic.music:setVolume(math.clamp(v, 0, 1))
    mmMusic.vol = math.clamp(v, 0, 1)
    mmMusic.mainChannel:push("vol")
    mmMusic.mainChannel:push(mmMusic.vol)
  end
end

function mmMusic._threadGetVolume()
  return mmMusic.vol
end

function mmMusic.setVolume(v)
  if mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("vol")
    mmMusic.threadChannel:push(v or mmMusic.vol)
  end
  
  mmMusic.vol = v or mmMusic.vol
end

function mmMusic.getVolume()
  return mmMusic.vol
end

function mmMusic._threadStop()
  if not mmMusic.locked and mmMusic.music then
    mmMusic.curID = nil
    mmMusic.loopPoint = 0
    mmMusic.time = 0
    mmMusic.mTell = 0
    mmMusic._queue = nil
    mmMusic.music:stop()
    mmMusic.music:release()
    mmMusic.music = nil
    mmMusic.dec:release()
    mmMusic.dec = nil
  end
end

function mmMusic.stop()
  if mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("stop")
    mmMusic.thread:wait()
  end
  
  mmMusic.curID = nil
  mmMusic._queue = nil
end

function mmMusic._threadStopped()
  return mmMusic.music and not mmMusic.music:isPlaying()
end

function mmMusic.stopped()
  return not mmMusic.thread:isRunning()
end

function mmMusic._threadPause()
  if mmMusic.music and not mmMusic.locked and not mmMusic.paused then
    mmMusic.music:pause()
    mmMusic.paused = true
  end
end

function mmMusic.pause()
  if mmMusic.thread:isRunning() and not mmMusic.paused then
    mmMusic.threadChannel:push("pause")
    mmMusic.paused = true
  end
end

function mmMusic._threadUnpause()
  if mmMusic.music and not mmMusic.locked and mmMusic.paused then
    mmMusic.music:resume()
    mmMusic.paused = false
  end
end

function mmMusic.unpause()
  if mmMusic.thread:isRunning() and mmMusic.paused then
    mmMusic.threadChannel:push("unpause")
    mmMusic.paused = false
  end
end

function mmMusic._threadSeek(s)
  if s and mmMusic.time ~= s and mmMusic.music and mmMusic.dec then
    mmMusic.music:seek(mmMusic.music:getDuration()+1)
    mmMusic.time = s
    mmMusic._threadUpdate()
  end
end

function mmMusic.seek(s)
  if mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("seek")
    mmMusic.threadChannel:push(s)
  end
end

function mmMusic._threadTell()
  if mmMusic.music then
    return math.max(mmMusic.time + mmMusic.music:tell() - mmMusic.rate, 0)
  end
  
  return 0
end

function mmMusic.tell()
  return mmMusic.mTell
end

function mmMusic.setLock(w)
  mmMusic.locked = w == true
  if mmMusic.thread:isRunning() then
    mmMusic.threadChannel:push("lock")
    mmMusic.threadChannel:push(mmMusic.locked)
  end
end

function mmMusic.isLocked()
  return mmMusic.locked
end

function mmMusic._threadDecode()
  mmMusic.dec:seek(mmMusic.time)
  local sd = mmMusic.dec:decode()
  if sd then
    mmMusic.music:queue(sd)
  else
    if mmMusic.loop then
      mmMusic.dec:seek(mmMusic.loopPoint)
      mmMusic.music:queue(mmMusic.dec:decode())
      mmMusic.time = mmMusic.loopPoint
    end
  end
  
  return sd
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

function mmMusic._threadPlay(curID, loop, loopPoint, time, vol)
  if mmMusic.locked or (mmMusic.music and mmMusic.curID == curID and not mmMusic._threadStopped()) then return end
  
  mmMusic._threadStop()
  
  mmMusic.dec = love.sound.newDecoder(curID, 1024*24)
  mmMusic.time = time or 0
  mmMusic.rate = ((1024*24) / ((mmMusic.dec:getBitDepth() * mmMusic.dec:getChannelCount()) / 8)) / mmMusic.dec:getSampleRate()
  mmMusic.buffers = 3
  while mmMusic.dec:getDuration() * mmMusic.buffers < mmMusic.rate do -- incase of unbelievably short "music".
    mmMusic.buffers = mmMusic.buffers + 1
  end
  mmMusic.music = love.audio.newQueueableSource(
    mmMusic.dec:getSampleRate(), mmMusic.dec:getBitDepth(), mmMusic.dec:getChannelCount(), mmMusic.buffers + 3)
  mmMusic.curID = curID
  mmMusic.loopPoint = loopPoint
  mmMusic.loop = loop
  mmMusic._threadSetVolume(mmMusic.vol)
  
  mmMusic._threadUpdate()
  mmMusic.music:play()
end

function mmMusic.play(path, vol, from)
  if mmMusic.locked or (mmMusic.curID == path and not mmMusic.stopped()) then return end
  
  mmMusic.stop()
  
  local t = {}
  
  if love.filesystem.getInfo(path .. ".txt") then
    for line in love.filesystem.lines(path .. ".txt") do
      if line ~= "" and line:match(":") then
        local data = line:split(":")
        local v = data[2]:trimmed()
        v = tonumber(v) or (toboolean(v) == nil and v) or toboolean(v)
        t[data[1]] = v
      end
    end
  end
  
  mmMusic.curID = path
  mmMusic.time = from or 0
  mmMusic.mTell = mmMusic.time
  mmMusic.loopPoint = t.loopPoint or 0
  mmMusic.loop = t.loop == nil or t.loop
  mmMusic.vol = vol or mmMusic.vol
  mmMusic.stopping = false
  
  mmMusic.thread:start(mmMusic.curID, mmMusic.loop, mmMusic.loopPoint, mmMusic.time, mmMusic.vol)
  mmMusic.setLock(mmMusic.locked)
end

function mmMusic._threadUpdate()
  if mmMusic.music then
    local stop = false
    
    while mmMusic.music:getFreeBufferCount() > mmMusic.buffers do
      if mmMusic.music:getDuration() == 0 then
        mmMusic._threadDecode()
      end
      mmMusic.time = math.min(mmMusic.time + mmMusic.rate, mmMusic.dec:getDuration())
      local sd = mmMusic._threadDecode()
      if not sd and not mmMusic.loop and mmMusic.music:tell() == 0 and mmMusic.time ~= 0 then
        stop = true
        break
      end
    end
    
    if stop then
      mmMusic._threadStop()
    end
  end
end

function mmMusic.update()
  while not mmMusic.stopping do
    local value = mmMusic.mainChannel:pop()
    if value ~= nil then
      if value == "time" then
        mmMusic.time = mmMusic.mainChannel:pop()
      elseif value == "tell" then
        mmMusic.mTell = mmMusic.mainChannel:pop()
      elseif value == "vol" then
        mmMusic.vol = mmMusic.mainChannel:pop()
      elseif value == "stop" then
        mmMusic.loopPoint = 0
        mmMusic.time = 0
        mmMusic.mTell = 0
        mmMusic.stopping = true
        mmMusic.vol = 1
      end
    else
      break
    end
  end
end