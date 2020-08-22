loader = {}

function loader.ser()
  local result = {resources={}, locked={}}
  
  for k, v in pairs(loader.resources) do
    result.resources[k] = {path=v.path, nick=v.nick}
    if v.parameters then
      result.resources[k].parameters = v.parameters
    end
  end
  for k, v in pairs(loader.locked) do
    result.locked[k] = {path=v.path, nick=v.nick}
    if v.parameters then
      result.locked[k].parameters = v.parameters
    end
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

function loader.imgMap(x, y, r, g, b, a)
  if not loader.tmp[y+1] then
    loader.tmp[y+1] = {}
  end
  loader.tmp[y+1][x+1] = (a > 0) and 1 or 0
  return r, g, b, a
end

function loader.load(path, nick, typ, parameters, lock)
  if not nick then
    error("Specify nickname for resource \"" .. path .. "\".")
  end
  
  if (loader.resources[nick] and loader.resources[nick][2] == path and not lock) or
    (loader.locked[nick] and loader.locked[nick][2] == path) then return end
  if typ == "texture" then
    if lock then
      if parameters and parameters[1] then
        local img = love.image.newImageData(path)
        loader.tmp = {}
        img:mapPixel(loader.imgMap)
        loader.locked[nick] = {data=loader.tmp, path=path, img=love.graphics.newImage(img), type=typ}
      else
        loader.locked[nick] = {data=love.graphics.newImage(path), path=path, type=typ}
      end
      
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      if parameters and parameters[1] then
        local img = love.image.newImageData(path)
        loader.tmp = {}
        img:mapPixel(loader.imgMap)
        loader.resources[nick] = {data=loader.tmp, path=path, img=love.graphics.newImage(img), type=typ}
      else
        loader.resources[nick] = {data=love.graphics.newImage(path), path=path, type=typ}
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
  elseif typ == "grid" then
    if lock then
      loader.locked[nick] = {data=anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]),
        parameters=parameters, type=typ}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      loader.resources[nick] = {data=anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]),
        parameters=parameters, type=typ}
      
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
  for k, v in pairs(loader.resources) do
    loader.unload(k)
  end
end