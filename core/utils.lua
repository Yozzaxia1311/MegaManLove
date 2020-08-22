local function cloneFunc(fn)
  local dumped = string.dump(fn)
  local cloned = loadstring(dumped)
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if not name then
      break
    end
    debug.upvaluejoin(cloned, i, fn, i)
    i = i + 1
  end
  return cloned
end

function toboolean(v)
  if type(v) == "string" then
    if v == "true" then
      return true
    elseif v == "false" then
      return false
    end
  elseif type(v) == "number" then
    return v > 0
  elseif type(v) == "boolean" then
    return v
  end
end

function booleanToString(v)
  if type(v) == "boolean" then
    return v and "true" or "false"
  end
end

function checkTrue(w)
  if w then
    for k, v in pairs(w) do
      if v then return true end
    end
  end
  return false
end

function checkFalse(w)
  if w then
    for k, v in pairs(w) do
      if not v then return false end
    end
  else
    return false
  end
  return true
end

function table.convert2Dto1D(t)
  local tmp = {}
  for y=1, table.length(t) do
    for x=1, table.length(t[y]) do
      tmp[table.length(tmp)+1] = t[y][x]
    end
  end
  return tmp
end

function table.convert1Dto2D(t, w)
  local tmp = {}
  for i=1, #t do
    local x, y = math.wrap(i, 1, w), math.ceil(i/w)
    if tmp[y] == nil then tmp[y] = {} end
    tmp[y][x] = t[i]
  end
  return tmp
end

function iterateDirs(func, path)
  local results = {}
  path = path or ""
  for k, v in pairs(love.filesystem.getDirectoryItems(path)) do
    if v:sub(1, 1) ~= "." and love.filesystem.getInfo(path .. (path ~= "" and "/" or path) .. v).type == "directory" then
      results = table.merge({results, iterateDirs(func, path .. (path ~= "" and "/" or path) .. v)})
    else
      if func(v) then results[#results+1] = path .. (path ~= "" and "/" or path) .. v end
    end
  end
  return results
end

function string:trimmed()
  return self:match("^%s*(.-)%s*$")
end

function string:split(inSplitPattern, outResults)
  if not outResults then
    outResults = {}
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
  while theSplitStart do
    table.insert(outResults, string.sub(self, theStart, theSplitStart-1))
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
  end
  table.insert(outResults, string.sub(self, theStart))
  return outResults
end

function table.merge(tables)
  local result = {}
  for k, v in pairs(tables) do
    for i, j in pairs(v) do
      result[#result+1] = j
    end
  end
  return result
end

function table.shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function math.even(n)
  return n % 2 == 0
end

function math.dist2d(x, y, x2, y2)
  return math.sqrt(math.pow(x-x2, 2)+math.pow(y-y2, 2))
end

function math.approach(v, to, am)
  if v < to then 
		v = math.min(v + am, to)
  elseif v > to then
    v = math.max(v - am, to)
  end
  return v
end

function math.clamp(val, min, max)
  if min < max then
    return math.max(math.min(max, val), min)
  else
    return math.max(math.min(min, val), max)
  end
end

function math.roundDecimal(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function math.between(val, min, max)
  return val >= min and val <= max
end

function math.lerp(a,b,t)
  return (1-t)*a + t*b
end

function math.sign(x)
  if x<0 then
    return -1
  elseif x>0 then
    return 1
  else
    return 0
  end
end

function math.round(x)
  if x-math.floor(x) >= 0.5 then
    return math.ceil(x)
  else
    return math.floor(x)
  end
end

function math.randomboolean()
  return love.math.random(0, 1) == 0
end

function math.wrap(v, min, max)
  local range = max - min + 1
  v = ((v-min) % range)
  if v < 0 then
    return max + 1 + v
  else
    return min + v
  end
end

function table.contains(t, va)
  if type(t) ~= "table" then return false end
  for k, v in pairs(t) do
    if v == va then return true end
  end
  return false
end

function table.clone(t, shallow, cache)
  if type(t) ~= 'table' then
    return t
  end
  local new = {}
  if shallow then
    for key, value in pairs(t) do
      new[key] = value
    end
    return new
  end
  table.copycache = cache or {}
  if table.copycache[t] then
    return table.copycache[t]
  end
  table.copycache[t] = New
  for key, value in pairs(t) do
    new[table.clone(key, nil, table.copycache)] = table.clone(value, nil, table.copycache)
  end
  return new
end

function table.length(t)
  local n = 0
  for k, v in pairs(t) do
    n = n + 1
  end
  return n
end

function table.containskey(t, ke)
  for k, v in pairs(t or {}) do
    if k == ke then return true end
  end
  return false
end

function table.stringtonumbervalues(t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = type(v) ~= "number" and tonumber(v) or v
  end
  return result
end

function table.removevalue(t, va)
  for k, v in pairs(t) do
    if v == va then
      t[k] = nil
    end
  end
end

function table.removevaluearray(t, va)
  if t[#t] == va then t[#t] = nil return end
  for i=1, #t do
    if t[i] == va then
      table.remove(t, i)
      break
    end
  end
end

function table.quickremovevaluearray(t, va)
  if t[#t] == va then t[#t] = nil return end
  for i=1, #t do
    if t[i] == va then
      t[i] = t[#t]
      t[#t] = nil
      return
    end
  end
end
