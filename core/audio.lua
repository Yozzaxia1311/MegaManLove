mmMusic = {}

function mmMusic.ser()
  return {
      paused=mmMusic.paused,
      curID=mmMusic.curID,
      playing=not mmMusic.stopped(),
      lp=mmMusic.loopPoint,
      lep=mmMusic.loopEndPoint,
      loop=mmMusic.isLooping(),
      volume=mmMusic.getVolume(),
      seek=mmMusic.music and mmMusic.music:tell("samples"),
      queue=table.clone(mmMusic.queue),
      locked=mmMusic.locked
    }
end

function mmMusic.deser(t)
  mmMusic.curID = t.curID
  if t.curID and t.playing then
    mmMusic.play(t.curID, t.loop, t.lp, t.lep, t.volume)
    if t.seek then
      mmMusic.music:seek(t.seek, "samples")
    end
  end
  mmMusic.paused = t.paused
  mmMusic.locked = t.locked
  mmMusic._queue = t.queue
end

mmMusic.paused = false
mmMusic.music = nil
mmMusic.curID = nil
mmMusic.locked = false
mmMusic.loopPoint = nil
mmMusic.loopEndPoint = nil
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
    mmMusic.paused = false
    mmMusic.curID = nil
    mmMusic.loopPoint = nil
    mmMusic.loopEndPoint = nil
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
    mmMusic.paused = true
  end
end


function mmMusic.unpause()
  if mmMusic.music and not mmMusic.locked then
    mmMusic.music:resume()
    mmMusic.paused = false
  end
end

function mmMusic.setLooping(w)
  if mmMusic.music and not mmMusic.locked then
    mmMusic.music:setLooping(w == true)
  end
end

function mmMusic.isLooping()
  return mmMusic.music and mmMusic.music:isLooping()
end

function mmMusic.checkQueue()
  if mmMusic._queue then
    mmMusic.play(unpack(mmMusic._queue))
    mmMusic._queue = nil
  end
end

function mmMusic.playq(...)
  mmMusic._queue = {...}
end

function mmMusic.play(path, loop, loopPoint, loopEndPoint, vol)
  if mmMusic.locked or (mmMusic.music and mmMusic.curID == path and not mmMusic.stopped()) then return end
  
  mmMusic.stop()
  
  mmMusic.music = love.audio.newSource(path, "stream")
  mmMusic.curID = path
  mmMusic.loopPoint = loopPoint
  mmMusic.loopEndPoint = loopEndPoint
  
  if mmMusic.loopPoint or mmMusic.loopEndPoint then
    if mmMusic.loopEndPoint >= mmMusic.music:getDuration("samples") then
      print("It's recommended to add a portion of music from the loop point to the loop end point; this makes the looping seamless.")
    end
    mmMusic.setLooping(false)
  else
    mmMusic.setLooping(loop == nil or loop)
  end
  
  mmMusic.music:play()
  mmMusic.paused = false
end

function mmMusic.update()
  if mmMusic.music and mmMusic.loopPoint and mmMusic.loopEndPoint then
    if not mmMusic.music:isPlaying() and not mmMusic.paused and mmMusic.music:tell("samples") == 0 then
      mmMusic.music:seek(mmMusic.music:getDuration("samples") - (mmMusic.loopEndPoint - mmMusic.loopPoint), "samples")
      mmMusic.music:play()
    elseif mmMusic.music:isPlaying() and mmMusic.music:tell("samples") > mmMusic.loopEndPoint then
      mmMusic.music:seek(mmMusic.music:tell("samples") - (mmMusic.loopEndPoint - mmMusic.loopPoint), "samples")
    end
  end
end