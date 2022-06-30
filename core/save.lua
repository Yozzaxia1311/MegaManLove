save = {}

function save.createDirChain(p)
  local part = p:split("/")
  local whole = ""
  
  if #part > 0 then
    for i=1, #part do
      if part[i]:find("%.") then break end
      if part[i] ~= "" then
        local f = love.filesystem.getInfo(whole .. (i == 1 and "" or "/") .. part[i])
        if f and (f.type == "directory" or f.type == "symlink") then
          whole = whole .. (i == 1 and "" or "/") .. part[i]
        else
          fs.createDirectory(whole .. (i>1 and "/" or "") .. part[i])
          whole = whole .. (i == 1 and "" or "/") .. part[i]
        end
      end
    end
  end
end

function save.save(file, data)
  assert(not (record.demo or record.recordInput), "Cannot save during recordings")
  
  local sv = binser.serialize(data)
  
  save.createDirChain(file)
  love.filesystem.write(file, sv)
end

function save.load(file)
  assert(not (record.demo or record.recordInput), "Cannot load during recordings")
  
  local sv = love.filesystem.getInfo(file) and love.filesystem.read(file)
  
  if not sv then
    return
  end
  
  return binser.deserialize(sv)
end