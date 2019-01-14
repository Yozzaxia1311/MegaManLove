save = {}

function save.save(file, data)
  local sv = json.encode(data)
  if base64SaveFiles then
    sv = to_base64(sv)
  end
  love.filesystem.write(file, sv)
end

function save.load(file)
  local sv = love.filesystem.read(gamePath .. "/" .. file)
  if sv == nil then
    return nil
  end
  if base64SaveFiles then
    sv = from_base64(sv)
  end
  return json.decode(sv)
end