loader = {}

loader.resources = {}
loader.locked = {}

function loader.load(path, nick, typ, parameters, lock)
  if not table.containskey(loader.resources, nick) then
    if typ == "texture" then
      if lock then
        if parameters and parameters[1] then
          loader.locked[nick] = {table.stringtonumbervalues(love.filesystem.read(path):split(",")),
            parameters[2]}
        else
          loader.locked[nick] = love.graphics.newImage(path)
        end
      else
        if parameters and parameters[1] then
          loader.resources[nick] = {table.stringtonumbervalues(love.filesystem.read(path):split(",")),
            parameters[2]}
        else
          loader.resources[nick] = love.graphics.newImage(path)
        end
      end
    elseif typ == "music" then
      if lock then
        loader.locked[nick] = love.audio.newSource(path)
      else
        loader.resources[nick] = love.audio.newSource(path)
      end
    elseif typ == "sound" then
      if lock then
        loader.locked[nick] = love.audio.newSource(path, "static")
      else
        loader.resources[nick] = love.audio.newSource(path, "static")
      end
    elseif typ == "grid" then
      if lock then
        loader.locked[nick] = anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5] or 0,
        parameters[6] or 0)
      else
        loader.resources[nick] = anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5] or 0,
        parameters[6] or 0)
      end
    end
  end
end

function loader.get(nick)
  return loader.resources[nick] or loader.locked[nick]
end

function loader.unload(nick)
  if loader.resources[nick] then
    if loader.resources[nick]:type() == "Source" then
      loader.resources[nick]:stop()
    end
    loader.resources[nick] = nil
  end
end

function loader.clear()
  loader.resources = {}
end