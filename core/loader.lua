loader = {}

loader.resources = {}
loader.locked = {}

loader.loaders = {
    imageData = function(path, lock)
        if lock then
          if loader.resources[path] then
            loader.locked[path] = loader.resources[path]
            loader.resources[path] = nil
          elseif not loader.locked[path] then
            local imgData = imageData(path)
            loader.locked[path] = {data = imgData, type = "imageData", img = imgData:toImageWrapper()}
          end
        else
          if not loader.resources[path] and not loader.locked[path] then
            local imgData = imageData(path)
            loader.resources[path] = {data = imgData, type = "imageData", img = imgData:toImageWrapper()}
          end
        end
      end,
    image = function(path, lock)
        if lock then
          if loader.resources[path] then
            loader.locked[path] = loader.resources[path]
            loader.resources[path] = nil
          elseif not loader.locked[path] then
            loader.locked[path] = {data = imageWrapper(path), type = "image"}
          end
        else
          if not loader.resources[path] and not loader.locked[path] then
            loader.resources[path] = {data = imageWrapper(path), type = "image", imgData = imgData}
          end
        end
      end,
      sound = function(path, lock)
          if lock then
            if loader.resources[path] then
              loader.locked[path] = loader.resources[path]
              loader.resources[path] = nil
            elseif not loader.locked[path] then
              loader.locked[path] = {data = love.audio.newSource(path, "static"), type = "sound",
                conf = love.filesystem.getInfo(path .. ".txt") and parseConf(path .. ".txt")}
            end
          else
            if not loader.resources[path] and not loader.locked[path] then
              loader.resources[path] = {data = love.audio.newSource(path, "static"), type = "sound",
                conf = love.filesystem.getInfo(path .. ".txt") and parseConf(path .. ".txt")}
            end
          end
        end,
      animation = function(path, lock)
          if lock then
            if loader.resources[path] then
              loader.locked[path] = loader.resources[path]
              loader.resources[path] = nil
              
              local imgPath = loader.locked[path].img.path
              
              if loader.resources[imgPath] then
                loader.locked[imgPath] = loader.resources[imgPath]
                loader.resources[imgPath] = nil
              end
            elseif not loader.locked[path] then
              local c = parseConf(path)
              local fx, fy, fw, fh, fb = unpack(c.quad)
              
              if not fw or not fh then
                fw = fx
                fh = fy
                fx = 0
                fy = 0
              end
              
              if c.image and not loader.get(c.image) then
                loader.loaders.image(c.image, true)
              end
              if c.image and loader.resources[c.image] then
                loader.locked[c.image] = loader.resources[c.image]
                loader.resources[c.image] = nil
              end
              
              loader.locked[path] = {data = anim8.newGrid(fw, fh, fx, fy, fb),
                type = "animation", frames = c.frames, durations = c.durations,
                onLoop = c.onLoop, img = loader.get(c.image)}
            end
          else
            if not loader.resources[path] and not loader.locked[path] then
              local c = parseConf(path)
              local fx, fy, fw, fh, fb = unpack(c.quad)
              
              if not fw or not fh then
                fw = fx
                fh = fy
                fx = 0
                fy = 0
              end
              
              if c.image and not loader.get(c.image) then
                loader.loaders.image(c.image, false)
              end
              
              loader.resources[path] = {data = anim8.newGrid(fw, fh, fx, fy, fb),
                type = "animation", frames = c.frames, durations = c.durations,
                onLoop = c.onLoop, img = loader.get(c.image)}
            end
          end
        end,
      animationSet = function(path, lock)
          if lock then
            if loader.resources[path] then
              loader.locked[path] = loader.resources[path]
              loader.resources[path] = nil
              
              local imgPath = loader.locked[path].img.path
              
              if loader.resources[imgPath] then
                loader.locked[imgPath] = loader.resources[imgPath]
                loader.resources[imgPath] = nil
              end
            elseif not loader.locked[path] then
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
              
              if c.image and not loader.get(c.image) then
                loader.loaders.image(c.image, true)
              end
              if c.image and loader.resources[c.image] then
                loader.locked[c.image] = loader.resources[c.image]
                loader.resources[c.image] = nil
              end
              
              loader.locked[path] = {data = grid, type = "animationSet", sets = data,
                default = c.default, img = loader.get(c.image)}
            end
          else
            if not loader.resources[path] and not loader.locked[path] then
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
              
              if c.image and not loader.get(c.image) then
                loader.loaders.image(c.image, false)
              end
              
              loader.resources[path] = {data = grid, type = "animationSet", sets = data,
                default = c.default, img = loader.get(c.image)}
            end
          end
        end
  }

loader.unloaders = {
    imageData = function(path, bypassLock)
        local res = bypassLock and loader.locked[path] or loader.resources[path]
        
        if res then
          res.data:release()
          res.img:release()
          
          if bypassLock then
            loader.locked[path] = nil
          else
            loader.resources[path] = nil
          end
        end
      end,
    image = function(path, bypassLock)
        local res = bypassLock and loader.locked[path] or loader.resources[path]
        
        if res then
          res.data:release()
          
          if bypassLock then
            loader.locked[path] = nil
          else
            loader.resources[path] = nil
          end
        end
      end,
    sound = function(path, bypassLock)
        local res = bypassLock and loader.locked[path] or loader.resources[path]
        
        if res then
          res.data:stop()
          res.data:release()
          
          if bypassLock then
            loader.locked[path] = nil
          else
            loader.resources[path] = nil
          end
        end
      end,
    animation = function(path, bypassLock)
        local res = bypassLock and loader.locked[path] or loader.resources[path]
        
        if res then
          res.data:release()
          
          if bypassLock then
            loader.locked[path] = nil
          else
            loader.resources[path] = nil
          end
        end
      end,
    animationSet = function(path, bypassLock)
        local res = bypassLock and loader.locked[path] or loader.resources[path]
        
        if res then
          res.data:release()
          
          if bypassLock then
            loader.locked[path] = nil
          else
            loader.resources[path] = nil
          end
        end
      end
  }

function loader.ser()
  local result = {resources={}, locked={}}
  
  for path, _ in pairs(loader.resources) do
    result.resources[#result.resources + 1] = path
  end
  for path, _ in pairs(loader.locked) do
    result.locked[#result.locked + 1] = path
  end
  
  return result
end

function loader.deser(t)
  loader.resource = {}
  for _, path in pairs(t.resources) do
    loader.load(path, false)
  end
  loader.locked = {}
  for _, path in pairs(t.locked) do
    loader.load(path, true)
  end
end

function loader.load(path, lock)
  local resType 
  
  if checkExt(path, {"data.png", "data.jpeg", "data.jpg", "data.bmp", "data.tga",
      "data.hdr", "data.pic", "data.exr"}) then
    resType = "imageData"
  elseif checkExt(path, {"png", "jpeg", "jpg", "bmp", "tga", "hdr", "pic", "exr"}) then
    resType = "image"
  elseif checkExt(path, {"ogg", "mp3", "wav", "flac", "oga", "ogv", "xm", "it",
    "mod", "mid", "669", "amf", "ams", "dbm", "dmf", "dsm", "far",
    "j2b", "mdl", "med", "mt2", "mtm", "okt", "psm", "s3m", "stm", "ult", "umx", "abc", "pat"}) then
    resType = "sound"
  elseif checkExt(path, {"anim"}) then
    resType = "animation"
  elseif checkExt(path, {"animset"}) then
    resType = "animationSet"
  end
  
  assert(resType, "Resource type could not be determined from file extension")
  
  loader.loaders[resType](path, lock)
end

function loader.get(path)
  return path and ((loader.resources[path] and loader.resources[path].data) or
    (loader.locked[path] and loader.locked[path].data))
end

function loader.getTable(path)
  return loader.resources[path] or loader.locked[path]
end

function loader.getAll()
  local all = {}
  for k, v in pairs(loader.locked) do
    all[k] = v.data
  end
  for k, v in pairs(loader.resources) do
    all[k] = v.data
  end
  return all
end

function loader.getAllTables()
  local all = {}
  for k, v in pairs(loader.locked) do
    all[k] = v
  end
  for k, v in pairs(loader.resources) do
    all[k] = v
  end
  return all
end

function loader.unload(path, bypassLock)
  loader.unloaders[loader.getTable(path).type](path, bypassLock)
end

function loader.clear()
  for k, _ in safepairs(loader.resources) do
    loader.unload(k)
  end
end