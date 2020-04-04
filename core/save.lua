save = {}

function save.createDirChain(p)
  local part = p:split("/")
  local whole = ""
  
  if #part > 0 then
    for i=1, #part do
      if part[i]:find("%.") then break end
      if part[i] ~= "" then
        local f = love.filesystem.getInfo(whole .. (i == 1 and "" or "/") .. part[i])
        if f and f.type == "directory" then
          whole = whole .. (i == 1 and "" or "/") .. part[i]
        else
          love.filesystem.createDirectory(whole .. (i>1 and "/" or "") .. part[i])
          whole = whole .. (i == 1 and "" or "/") .. part[i]
        end
      end
    end
  end
end

function save.save(file, data)
  local sv = binser.serialize(data)
  save.createDirChain(dataDir .. file)
  love.filesystem.write(dataDir .. file, sv)
end

function save.load(file)
  local sv = love.filesystem.read(dataDir .. file)
  if not sv then
    return nil
  end
  return unpack(binser.deserialize(sv))
end