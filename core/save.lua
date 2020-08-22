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
  if control.demo or control.recordInput then
    error("Cannot save during recordings")
  end
  local sv = lualzw.compress(binser.serialize(data))
  save.createDirChain(file)
  love.filesystem.write(file, sv)
end

function save.load(file)
  if control.demo or control.recordInput then
    error("Cannot load during recordings")
  end
  local sv = love.filesystem.read(file)
  if not sv then
    return nil
  end
  sv = lualzw.decompress(sv)
  if not sv then
    return nil
  end
  return binser.deserialize(sv)
end