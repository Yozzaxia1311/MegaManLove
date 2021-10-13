save = {}

function save.createDirChain(p)
  local part = p:split("/")
  local whole = ""
  local fs = nativefs or love.filesystem
  
  if #part > 0 then
    for i=1, #part do
      if part[i]:find("%.") then break end
      if part[i] ~= "" then
        local f = fs.getInfo(whole .. (i == 1 and "" or "/") .. part[i])
        if f and f.type == "directory" then
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
  assert(not isWeb, "Web cannot save! (Another frustating web bug)")
  assert(not (record.demo or record.recordInput), "Cannot save during recordings")
  
  local baseDir = nativefs and (nativeSaveDir .. "/") or ""
  local fs = nativefs or love.filesystem
  local sv = binser.serialize(data)
  
  save.createDirChain(baseDir .. file)
  
  fs.write(baseDir .. file, sv)
end

function save.load(file)
  assert(not isWeb, "Web cannot load save! (Another frustating web bug)")
  assert(not (record.demo or record.recordInput), "Cannot load during recordings")
  
  local baseDir = nativefs and (nativeSaveDir .. "/") or ""
  local fs = nativefs or love.filesystem
  local sv = fs.getInfo(baseDir .. file) and fs.read(baseDir .. file)
  
  if not sv then
    return
  end
  
  return binser.deserialize(sv)
end