loader = {}

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
        loader.locked[nick] = {loader.tmp, path, love.graphics.newImage(img)}
      else
        loader.locked[nick] = {love.graphics.newImage(path), path}
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
        loader.resources[nick] = {loader.tmp, path, love.graphics.newImage(img)}
      else
        loader.resources[nick] = {love.graphics.newImage(path), path}
      end
      
      return loader.resources[nick]
    end
  elseif typ == "music" then
    if lock then
      loader.locked[nick] = {love.audio.newSource(path), path}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      loader.resources[nick] = {love.audio.newSource(path), path}
      
      return loader.resources[nick]
    end
  elseif typ == "sound" then
    if lock then
      loader.locked[nick] = {love.audio.newSource(path, "static"), path}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      loader.resources[nick] = {love.audio.newSource(path, "static"), path}
      
      return loader.resources[nick]
    end
  elseif typ == "grid" then
    if lock then
      loader.locked[nick] = {anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]), path}
      loader.resources[nick] = nil
      
      return loader.locked[nick]
    else
      if loader.locked[nick] then
        error("Cannot overwrite a locked resource.")
      end
      loader.resources[nick] = {anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]), path}
      
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
  return (loader.resources[nick] and loader.resources[nick][1]) or (loader.locked[nick] and loader.locked[nick][1])
end

function loader.unload(nick)
  if loader.resources[nick] then
    if loader.resources[nick][1]:type() == "Source" then
      loader.resources[nick][1]:stop()
    end
    loader.resources[nick] = nil
  end
end

function loader.getTable(nick)
  return loader.resources[nick] or loader.locked[nick]
end

function loader.clear()
  loader.resources = {}
end