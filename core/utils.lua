local function nothing() end

function safepairs(t)
  if next(t) == nil then return nothing end
  
  local new = {}
  for k, v in pairs(t) do
    new[k] = v
  end
  return next, new
end

function safeipairs(a)
  if #a == 0 then return nothing end
  return ipairs({unpack(a)})
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

function checkTrue(w)
  if w then
    for _, v in pairs(w) do
      if v then return true end
    end
  end
  return false
end

function checkFalse(w)
  if not w then
    return false
  end
  for _, v in pairs(w) do
    if not v then return false end
  end
  return true
end

function string:getDirectory()
  local parts = self:split("/")
  local result = ""
  
  if #parts[#parts]:split("%.") > 1 then
    parts[#parts] = nil
  end
  for k, v in ipairs(parts) do
    result = result .. v .. (next(parts, k) and "/" or "")
  end
  
  return result
end

function string:getFile()
  local parts = self:split("/")
  
  return parts[#parts]
end

function string:getAbsolutePath(base)
  local parts = self:split("/")
  local tmpTable = base:split("/")
  local result = ""
  
  for _, v in ipairs(parts) do
    if v == ".." then
      tmpTable[#tmpTable] = nil
    else
      tmpTable[#tmpTable + 1] = v
    end
  end
  
  for k, v in ipairs(tmpTable) do
    result = result .. v .. (next(tmpTable, k) and "/" or "")
  end
  
  return result
end

function parseConf(path)
  assert(love.filesystem.getInfo(path), "\"" .. path .. "\" does not exist")
  
  local result
  
  for line in love.filesystem.lines(path) do
    if line ~= "" and line:match(":") and not line:match("<>") then
      local data = line:split(":")
      local v = data[2]:trimmed()
      v = tonumber(v) or (toboolean(v) == nil and v) or toboolean(v)
      
      if type(v) == "string" and line:match(",") then
        local od = v:split(",")
        
        for i = 1, #od do
          od[i] = od[i]:trimmed()
          od[i] = tonumber(od[i]) or (toboolean(od[i]) == nil and od[i]) or toboolean(od[i])
        end
        
        v = od
      end
      
      if not result then
        result = {}
      end
      
      result[data[1]] = v
    end
  end
  
  return result
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
        elseif not func or func(v, p) then
          results[#results+1] = p
        end
      end
    end
  end
  
  table.sort(results)
  
  return results
end

function checkExt(path, list)
  local p = path:split("%.")
  p = p[#p]:lower()
  
  for _, v in ipairs(list) do
    if v:lower() == p then
      return true
    end
  end
  return false
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
  local half = math.floor(#t / 2)
  for i = 1, half, (#t >= 4 and 2 or 1) do
    local j = love.math.random(half, #t)
    t[i], t[j] = t[j], t[i]
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

local _max, _min = math.max, math.min

function math.clamp(val, min, max)
  if min < max then
    return _max(_min(max, val), min)
  else
    return _max(_min(min, val), max)
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
  return x > 0 and 1 or (x < 0 and -1 or 0)
end

local _floor = math.floor

function math.round(x)
  return _floor(x + 0.5)
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
      break
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

function table.findindexarray(t, va)
  for i=1, #t do
    if t[i] == va then
      return i
    end
  end
end

function table.quickremove(t, i)
  t[i] = t[#t]
  t[#t] = nil
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