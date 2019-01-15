save = {}

function save.save(file, data, ignoreGamePath)
  local sv = json.encode(data)
  if base64SaveFiles then
    sv = to_base64(sv)
  end
  if ignoreGamePath then
    love.filesystem.write(file, sv)
  else
    if not love.filesystem.getInfo(love.filesystem.getSaveDirectory() .. "/" .. gamePath) then
      love.filesystem.createDirectory(gamePath)
    end
    love.filesystem.write(gamePath .. "/" .. file, sv)
  end
end

function save.load(file, ignoreGamePath)
  local sv
  if ignoreGamePath then
    sv = love.filesystem.read(file)
  else
    sv = love.filesystem.read(gamePath .. "/" .. file)
  end
  if sv == nil then
    return nil
  end
  if base64SaveFiles then
    sv = from_base64(sv)
  end
  return json.decode(sv)
end