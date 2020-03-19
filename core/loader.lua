loader = {}

loader.resources = {}
loader.locked = {}

local function imgColImage(x, y, r, g, b, a)
  if loader.tmp[y+1][x+1] == 1 then
    return 1, 1, 1, 1
  end
  return 1, 1, 1, 0
end

function loader.load(path, nick, typ, parameters, lock)
  if not table.containskey(loader.resources, nick) then
    if typ == "texture" then
      if lock then
        if parameters then
          local t = table.convert1Dto2D(table.stringtonumbervalues(love.filesystem.read(path):split(",")), parameters[1])
          local img = love.image.newImageData(#t[1]-1, #t-1)
          loader.tmp = t
          img:mapPixel(imgColImage)
          loader.tmp = nil
          loader.locked[nick] = {t, img}
        else
          loader.locked[nick] = love.graphics.newImage(path)
        end
        loader.resources[nick] = nil
      else
        if loader.locked[nick] then
          error("Cannot overwrite a locked resource")
        end
        if parameters then
          local t = table.convert1Dto2D(table.stringtonumbervalues(love.filesystem.read(path):split(",")), parameters[1])
          local img = love.image.newImageData(#t[1], #t)
          loader.tmp = t
          img:mapPixel(imgColImage)
          loader.tmp = nil
          loader.resources[nick] = {t, img}
        else
          loader.resources[nick] = love.graphics.newImage(path)
        end
      end
    elseif typ == "music" then
      if lock then
        loader.locked[nick] = love.audio.newSource(path)
        loader.resources[nick] = nil
      else
        if loader.locked[nick] then
          error("Cannot overwrite a locked resource")
        end
        loader.resources[nick] = love.audio.newSource(path)
      end
    elseif typ == "sound" then
      if lock then
        loader.locked[nick] = love.audio.newSource(path, "static")
        loader.resources[nick] = nil
      else
        if loader.locked[nick] then
          error("Cannot overwrite a locked resource")
        end
        loader.resources[nick] = love.audio.newSource(path, "static")
      end
    elseif typ == "grid" then
      if lock then
        loader.locked[nick] = anim8.newGrid(parameters[1], parameters[2], parameters[3], parameters[4], parameters[5] or 0,
        parameters[6] or 0)
        loader.resources[nick] = nil
      else
        if loader.locked[nick] then
          error("Cannot overwrite a locked resource")
        end
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