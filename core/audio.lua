mmMusic = {}

local maxDecLength = 0.18575963718821

function mmMusic.ser()
  return {
      paused=mmMusic.paused,
      curID=mmMusic.curID,
      playing=not mmMusic.stopped(),
      lp=mmMusic.loopPoint,
      loop=mmMusic.isLooping(),
      volume=mmMusic.getVolume(),
      seek=mmMusic.music and mmMusic.dec and (mmMusic.from+(mmMusic.segment*maxDecLength)+mmMusic.music:tell()),
      queue=table.clone(mmMusic.queue),
      locked=mmMusic.locked
    }
end

function mmMusic.deser(t)
  mmMusic.curID = t.curID
  if t.curID and t.playing then
    mmMusic.play(t.curID, t.loop, t.lp, t.volume, t.seek)
  end
  if t.paused then
    mmMusic.pause()
  end
  mmMusic.locked = t.locked
  mmMusic._queue = t.queue
end

mmMusic.music = nil
mmMusic.dec = nil
mmMusic.curID = nil
mmMusic.locked = false
mmMusic.loopPoint = nil
mmMusic.loop = true
mmMusic.segment = 0
mmMusic.from = 0
mmMusic._queue = nil

function mmMusic.setVolume(v)
  if mmMusic.music and not mmMusic.locked and v then
    mmMusic.music:setVolume(math.clamp(v, 0, 1))
  end
end

function mmMusic.getVolume()
  return mmMusic.music and mmMusic.music:getVolume() or 1
end

function mmMusic.stop()
  if not mmMusic.locked and mmMusic.music then
    mmMusic.curID = nil
    mmMusic.loopPoint = nil
    mmMusic._queue = nil
    mmMusic.music:stop()
    mmMusic.music = nil
  end
end

function mmMusic.stopped()
  return mmMusic.music and not mmMusic.music:isPlaying()
end

function mmMusic.pause()
  if mmMusic.music and not mmMusic.locked then
    mmMusic.music:pause()
  end
end


function mmMusic.unpause()
  if mmMusic.music and not mmMusic.locked then
    mmMusic.music:resume()
  end
end

function mmMusic.setLooping(w)
  if not mmMusic.locked then
    mmMusic.loop = w == true
  end
end

function mmMusic.isLooping()
  return mmMusic.loop
end

function mmMusic.checkQueue()
  if mmMusic._queue then
    mmMusic.play(mmMusic._queue[1], mmMusic._queue[2], mmMusic._queue[3], mmMusic._queue[4], mmMusic._queue[5])
    mmMusic._queue = nil
  end
end

function mmMusic.playq(path, loop, loopPoint, vol, from)
  mmMusic._queue = {path, loop, loopPoint, vol, from}
end

function mmMusic.play(path, loop, loopPoint, vol, from)
  if mmMusic.locked or (mmMusic.music and mmMusic.curID == path and not mmMusic.stopped()) then return end
  
  mmMusic.stop()
  
  mmMusic.dec = love.sound.newDecoder(path)
  mmMusic.from = from or 0
  mmMusic.dec:seek(mmMusic.from)
  mmMusic.music = love.audio.newQueueableSource(mmMusic.dec:getSampleRate(), mmMusic.dec:getBitDepth(), mmMusic.dec:getChannelCount(), 8)
  mmMusic.music:queue(mmMusic.dec:decode())
  mmMusic.segment = 0
  mmMusic.curID = path
  mmMusic.loopPoint = loopPoint
  mmMusic.loop = loop == nil or loop
  
  mmMusic.music:play()
end

function mmMusic.update()
  if mmMusic.music then
    if mmMusic.music:tell() >= mmMusic.music:getDuration()-(mmMusic.music:getDuration()*0.2) then
      mmMusic.segment = mmMusic.segment + 1
      mmMusic.dec:seek(mmMusic.from+(mmMusic.segment*maxDecLength))
      local sd = mmMusic.dec:decode()
      if sd then
        mmMusic.music:queue(sd)
      else
        if mmMusic.loop then
          mmMusic.dec:seek(mmMusic.loopPoint or 0)
          mmMusic.music:queue(mmMusic.dec:decode())
        else
          mmMusic.music:stop()
        end
      end
    end
  end
end