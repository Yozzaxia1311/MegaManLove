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

function checkTrue(w)
  if w then
    for _, v in pairs(w) do
      if v then return true end
    end
  end
  return false
end

function checkFalse(w)
  if w then
    for _, v in pairs(w) do
      if not v then return false end
    end
  else
    return false
  end
  return true
end

function table.intersects(t, t2, fully)
  if fully then
    for _, v in pairs(t) do
      if not table.contains(t2, v) then
        return false
      end
    end
    return true
  else
    for _, v in pairs(t) do
      for _, v2 in pairs(t2) do
        if v == v2 then
          return true
        end
      end
    end
  end
  return false
end

function table.convert2Dto1D(t)
  local tmp = {}
  for y=1, table.length(t) do
    for x=1, table.length(t[y]) do
      tmp[table.length(tmp) + 1] = t[y][x]
    end
  end
  return tmp
end

function table.convert1Dto2D(t, w)
  local tmp = {}
  for i=1, #t do
    local x, y = math.wrap(i, 1, w), math.ceil(i / w)
    if tmp[y] == nil then tmp[y] = {} end
    tmp[y][x] = t[i]
  end
  return tmp
end

function iterateDirs(func, path, noAppdata)
  local results = {}
  
  path = path or ""
  
  for _, v in pairs(love.filesystem.getDirectoryItems(path)) do
    local p = path .. (path ~= "" and "/" or path) .. v
    
    if not noAppdata or love.filesystem.getRealDirectory(p) ~= love.filesystem.getAppdataDirectory() then
      local info = love.filesystem.getInfo(p)
      
      if v:sub(1, 1) ~= "." then
        if not no and info.type == "directory" then
          results = table.merge({results, iterateDirs(func, p, noAppdata)})
        elseif not func or func(v) then
          results[#results+1] = p
        end
      end
    end
  end
  
  table.sort(results)
  
  return results
end

function string:trimmed()
  return self:match("^%s*(.-)%s*$")
end

function string:replaceIndex(i, s)
  local st = self:sub(1, i - 1)
  local en = self:sub(i + 1, self:len())
  
  return st .. s .. en
end

function string:split(inSplitPattern, outResults)
  if not outResults then
    outResults = {}
  end
  
  local theStart = 1
  local theSplitStart, theSplitEnd = self:find(inSplitPattern, theStart)
  
  while theSplitStart do
    table.insert(outResults, self:sub(theStart, theSplitStart - 1))
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = self:find(inSplitPattern, theStart)
  end
  
  table.insert(outResults, self:sub(theStart))
  
  return outResults
end

function table.merge(tables)
  local result = {}
  
  for _, v in pairs(tables) do
    for _, j in pairs(v) do
      result[#result + 1] = j
    end
  end
  
  return result
end

function table.imerge(tables, noDup, noClone)
  local result = noClone and tables[1] or {unpack(tables[1])}
  for i=2, #tables do
    for j=1, #tables[i] do
      if not noDup or not table.contains(result, tables[i][j]) then
        result[#result+1] = tables[i][j]
      end
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

function table.lazyShuffle(t)
  for i = 1, math.floor(#t / 2), love.math.random(1, math.max(math.floor(#t / 3), 1)) do
    t[i], t[#t] = t[#t], t[i]
  end
  
  return t
end

function math.even(n)
  return n % 2 == 0
end

function math.dist2d(x, y, x2, y2)
  return math.sqrt(((x - x2) ^ 2) + ((y - y2) ^ 2))
end

function math.approach(v, to, am)
  if v < to then 
    return math.min(v + am, to)
  elseif v > to then
    return math.max(v - am, to)
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

function math.roundDecimal(num, decimalPlaces)
  local mult = 10 ^ (decimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function math.between(val, min, max)
  return val >= min and val <= max
end

function math.lerp(a,b,t)
  return (1 - t) * a + t * b
end

function math.sign(x)
  if x < 0 then
    return -1
  elseif x > 0 then
    return 1
  end
  
  return 0
end

function math.round(x)
  return math.floor(x + 0.5)
end

function math.wrap(v, min, max)
  local wr = ((v - min) % (max - min + 1))
  
  if wr < 0 then
    return max + 1 + wr
  end
  
  return min + wr
end

function table.contains(t, va)
  for _, v in pairs(t) do
    if v == va then
      return true
    end
  end
  
  return false
end

function table.icontains(t, va)
  for i = 1, #t do
    if t[i] == va then
      return true
    end
  end
  
  return false
end

function table.clone(t, shallow, cache)
  if type(t) ~= 'table' then
    return t
  end
  
  local new = {}
  
  if shallow then
    for k, v in pairs(t) do
      new[k] = v
    end
    
    return new
  end
  
  table.copycache = cache or {}
  
  if table.copycache[t] then
    return table.copycache[t]
  end
  
  table.copycache[t] = new
  
  for k, v in pairs(t) do
    new[table.clone(k, nil, table.copycache)] = table.clone(v, nil, table.copycache)
  end
  
  return new
end

function table.length(t)
  local n = 0
  
  for _, _ in pairs(t) do
    n = n + 1
  end
  
  return n
end

function table.containskey(t, key)
  for k, _ in pairs(t) do
    if k == key then
      return true
    end
  end
  
  return false
end

function table.removevalue(t, value)
  for k, v in pairs(t) do
    if v == value then
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