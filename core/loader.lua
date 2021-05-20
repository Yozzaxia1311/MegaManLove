loader = {}

function loader.ser()
  local result = {resources={}, locked={}}
  
  for k, v in pairs(loader.resources) do
    result.resources[k] = {path=v.path, nick=v.nick, type=v.type, parameters = v.parameters}
  end
  for k, v in pairs(loader.locked) do
    result.locked[k] = {path=v.path, nick=v.nick, type=v.type, parameters = v.parameters}
  end
  
  return result
end

function loader.deser(t)
  loader.resource = {}
  for k, v in pairs(t.resources) do
    loader.load(v.path, k, v.type, v.parameters, false)
  end
  loader.locked = {}
  for k, v in pairs(t.locked) do
    loader.load(v.path, k, v.type, v.parameters, true)
  end
end

loader.resources = {}
loader.locked = {}

function loader.load(path, nick, typ, parameters, lock)
  if not nick then
    error("Specify nickname for resource \"" .. path .. "\".")
  end
  
  if (loader.resources[nick] and loader.resources[nick][2] == path and not lock) or
    (loader.locked[nick] and loader.locked[nick][2] == path) then return end
  if typ == "texture" then
    if lock then
      if parameters and parameters[1] then
        local imgData = imageData(path)
        loader.locked[nick] = {data=imgData, path=path, img=imgData:toImageWrapper(), type=typ, parameters=parameters}
      else
        loader.locked[nick] = {data=imageWrapper(path), path=path, type=typ}
      end
      
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      if parameters and parameters[1] then
        local imgData = imageData(path)
        loader.resources[nick] = {data=imgData, path=path, img=imgData:toImageWrapper(), type=typ, parameters=parameters}
      else
        loader.resources[nick] = {data=imageWrapper(path), path=path, type=typ}
      end
      
      return loader.resources[nick]
    end
  elseif typ == "sound" then
    if lock then
      loader.locked[nick] = {data=love.audio.newSource(path, "static"), path=path, type=typ}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      loader.resources[nick] = {data=love.audio.newSource(path, "static"), path=path, type=typ}
      
      return loader.resources[nick]
    end
  elseif typ == "anim" then
    if lock then
      local c = parseConf(path)
      local fx, fy, fw, fh, fb = unpack(c.quad)
      if not fw or not fh then
        fw = fx
        fh = fy
        fx = 0
        fy = 0
      end
      local img
      if c.image and not loader.get(c.image) then
        loader.load(c.image, c.image, "texture", nil, lock)
      end
      img = loader.get(c.image)
      loader.locked[nick] = {path=path, data=anim8.newGrid(fw, fh, fx, fy, fb),
        parameters=parameters, type=typ, frames=c.frames, durations=c.durations,
        onLoop=c.onLoop, img=img}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      local c = parseConf(path)
      local fx, fy, fw, fh, fb = unpack(c.quad)
      if not fw or not fh then
        fw = fx
        fh = fy
        fx = 0
        fy = 0
      end
      local img
      if c.image and not loader.get(c.image) then
        loader.load(c.image, c.image, "texture", nil, lock)
      end
      img = loader.get(c.image)
      loader.resources[nick] = {path=path, data=anim8.newGrid(fw, fh, fx, fy, fb),
        parameters=parameters, type=typ, frames=c.frames, durations=c.durations,
        onLoop=c.onLoop, img=img}
      
      return loader.resources[nick]
    end
  elseif typ == "animSet" then
    if lock then
      local c = parseConf(path)
      local data = {}
      for k, v in pairs(c) do
        if k:sub(-6) == "Frames" then
          local l = k:sub(0, k:len() - 6)
          if not data[l] then
            data[l] = {frames = v}
          else
            data[l].frames = v
          end
        elseif k:sub(-9) == "Durations" then
          local l = k:sub(0, k:len() - 9)
          if not data[l] then
            data[l] = {durations = v}
          else
            data[l].durations = v
          end
        elseif k:sub(-6) == "OnLoop" then
          local l = k:sub(0, k:len() - 6)
          if not data[l] then
            data[l] = {onLoop = v}
          else
            data[l].onLoop = v
          end
        end
      end
      local fx, fy, fw, fh, fb = unpack(c.quad)
      if not fw or not fh then
        fw = fx
        fh = fy
        fx = 0
        fy = 0
      end
      local grid = anim8.newGrid(fw, fh, fx, fy, fb)
      for _, v in pairs(data) do
        v.data = grid
      end
      local img
      if c.image and not loader.get(c.image) then
        loader.load(c.image, c.image, "texture", nil, lock)
      end
      img = loader.get(c.image)
      loader.locked[nick] = {path=path, data=grid,
        parameters=parameters, type=typ, sets=data, default=c.default, img=img}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      local c = parseConf(path)
      local data = {}
      for k, v in pairs(c) do
        if k:sub(-6) == "Frames" then
          local l = k:sub(0, k:len() - 6)
          if not data[l] then
            data[l] = {frames = v}
          else
            data[l].frames = v
          end
        elseif k:sub(-9) == "Durations" then
          local l = k:sub(0, k:len() - 9)
          if not data[l] then
            data[l] = {durations = v}
          else
            data[l].durations = v
          end
        elseif k:sub(-6) == "OnLoop" then
          local l = k:sub(0, k:len() - 6)
          if not data[l] then
            data[l] = {onLoop = v}
          else
            data[l].onLoop = v
          end
        end
      end
      local fx, fy, fw, fh, fb = unpack(c.quad)
      if not fw or not fh then
        fw = fx
        fh = fy
        fx = 0
        fy = 0
      end
      local grid = anim8.newGrid(fw, fh, fx, fy, fb)
      for _, v in pairs(data) do
        v.data = grid
      end
      local img
      if c.image and not loader.get(c.image) then
        loader.load(c.image, c.image, "texture", nil, lock)
      end
      img = loader.get(c.image)
      loader.resources[nick] = {path=path, data=grid,
        parameters=parameters, type=typ, sets=data, default=c.default, img=img}
      
      return loader.resources[nick]
    end
  end
end

function loader.lock(nick)
  if loader.resources[nick] then
    loader.locked[nick] = loader.resources[nick]
    loader.resources[nick] = nil
  end
end

function loader.unlock(nick)
  if loader.locked[nick] then
    loader.resources[nick] = loader.locked[nick]
    loader.locked[nick] = nil
  end
end

function loader.get(nick)
  return (loader.resources[nick] and loader.resources[nick].data) or (loader.locked[nick] and loader.locked[nick].data)
end

function loader.unload(nick)
  if loader.resources[nick] then
    if loader.resources[nick].img then
      loader.resources[nick].img:release()
    elseif loader.resources[nick].data.type then
      if loader.resources[nick].data:type() == "Image" then
        loader.resources[nick].data:release()
      elseif loader.resources[nick].data:type() == "Source" then
        loader.resources[nick].data:stop()
        loader.resources[nick].data:release()
      end
    end
    loader.resources[nick] = nil
  end
end

function loader.getTable(nick)
  return loader.resources[nick] or loader.locked[nick]
end

function loader.clear()
  for k, _ in pairs(loader.resources) do
    loader.unload(k)
  end
end