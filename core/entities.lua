local _floor, _ceil = math.floor, math.ceil
local _icontains, _quickremovevaluearray = table.icontains, table.quickremovevaluearray

local function tableIsEmptyOrHoles(t)
  if #t == 0 then
    return true
  end
  
  for i = 1, #t do
    if t[i] ~= -1 then
      return false
    end
  end
  
  return true
end

local function removeTableHoles(t)
  local i = 1
  while i <= #t do
    if t[i] == -1 then
      table.quickremove(t, i)
    else
      i = i + 1
    end
  end
end

entities = {}

function entities.ser()
  return {
      layers = entities.layers,
      updates = entities.updates,
      groups = entities.groups,
      static = entities.static,
      all = entities.all,
      beginQueue = entities.beginQueue,
      recycle = entities.recycle,
      frozen = entities.frozen,
      hashes = entities.hashes,
      _HS = entities._HS,
      _updateHoles = entities._updateHoles,
      doSort = entities.doSort,
      inLoop = entities.inLoop,
      drawCollision = entities.drawCollision,
      doDrawFlicker = entities.doDrawFlicker,
      hashSize = entities.hashSize,
    }
end

function entities.deser(t)
  entities.layers = t.layers
  entities.updates = t.updates
  entities.groups = t.groups
  entities.static = t.static
  entities.all = t.all
  entities.beginQueue = t.beginQueue
  entities.recycle = t.recycle
  entities.frozen = t.frozen
  entities.hashes = t.hashes
  entities._HS = t._HS
  entities._updateHoles = t._updateHoles
  entities.doSort = t.doSort
  entities.inLoop = t.inLoop
  entities.drawCollision = t.drawCollision
  entities.doDrawFlicker = t.doDrawFlicker
  entities.hashSize = t.hashSize
end

megautils.initEngineFuncs.entities = {func=function()
    entities.init()
  end, autoClean=false}

function entities.init()
  entities.layers = {}
  entities.updates = {}
  entities.groups = {}
  entities.static = {}
  entities.all = {}
  entities.beginQueue = {}
  entities.recycle = {}
  entities.frozen = {}
  entities.hashes = {}
  entities._HS = {}
  entities._updateHoles = {}
  entities.doSort = false
  entities.inLoop = false
  entities.drawCollision = false
  entities.doDrawFlicker = true
  entities.hashSize = 96
end

function entities.updateHashForEntity(e, doAnyway)
  local hashes = entities.hashes
  local HS = entities._HS
  
  if e.collisionShape and not e.invisibleToHash then
    local xx, yy, ww, hh = e.x - (e.collisionShape.r or 0), e.y - (e.collisionShape.r or 0),
      e.collisionShape.w, e.collisionShape.h
    local hashSize = entities.hashSize
    local cx, cy = _floor((xx - 2) / hashSize), _floor((yy - 2) / hashSize)
    local cx2, cy2 = _ceil((xx + ww + 2) / hashSize), _ceil((yy + hh + 2) / hashSize)
    
    if doAnyway or e._lastHashX ~= cx or e._lastHashY ~= cy or e._lastHashX2 ~= cx2 or e._lastHashY2 ~= cy2 then
      e._lastHashX = cx
      e._lastHashY = cy
      e._lastHashX2 = cx2
      e._lastHashY2 = cy2
      
      if not e.currentHashes then
        e.currentHashes = {}
      end
      
      local emptyBefore = #e.currentHashes == 0
      local check = {}
      
      for x = cx, cx2 do
        for y = cy, cy2 do
          if not hashes[x] then
            hashes[x] = {[y] = {x = x, y = y, data = {e}, isRemoved = false}}
            HS[x] = 1
          elseif not hashes[x][y] then
            hashes[x][y] = {x = x, y = y, data = {e}, isRemoved = false}
            HS[x] = HS[x] + 1
          elseif not _icontains(hashes[x][y].data, e) then
            hashes[x][y].data[#hashes[x][y].data+1] = e
            hashes[x][y].data[#hashes[x][y].data].isRemoved = false
          end
          
          if not _icontains(e.currentHashes, hashes[x][y]) then
            e.currentHashes[#e.currentHashes+1] = hashes[x][y]
          end
          
          if hashes[x] and hashes[x][y] then
            check[#check + 1] = hashes[x][y]
          end
        end
      end
      
      if not emptyBefore then
        for _, v in safeipairs(e.currentHashes) do
          if v.isRemoved or not _icontains(check, v) then
            if not v.isRemoved then
              _quickremovevaluearray(v.data, e)
              
              if #v.data == 0 then
                v.isRemoved = true
                hashes[v.x][v.y] = nil
                HS[v.x] = HS[v.x] - 1
                
                if HS[v.x] == 0 then
                  hashes[v.x] = nil
                  HS[v.x] = nil
                end
              end
            end
            
            _quickremovevaluearray(e.currentHashes, v)
          end
        end
      end
    end
  elseif e.currentHashes then -- If there's no collision, then remove from hash.
    e._lastHashX = nil
    e._lastHashY = nil
    e._lastHashX2 = nil
    e._lastHashY2 = nil
    
    if #e.currentHashes ~= 0 then
      for i = 1, #e.currentHashes do
        local v = e.currentHashes[i]
        
        if not v.isRemoved then
          _quickremovevaluearray(v.data, e)
          
          if #v.data == 0 then
            v.isRemoved = true
            hashes[v.x][v.y] = nil
            HS[v.x] = HS[v.x] - 1
            
            if HS[v.x] == 0 then
              hashes[v.x] = nil
              HS[v.x] = nil
            end
          end
        end
      end
    end
    
    e.currentHashes = nil
  end
end

function entities.getEntitiesAt(xx, yy, ww, hh)
  local hashSize = entities.hashSize
  local result
  
  for x = _floor((xx - 2) / hashSize), _floor((xx + ww + 2) / hashSize) do
    for y = _ceil((yy - 2) / hashSize), _ceil((yy + hh + 2) / hashSize) do
      if entities.hashes[x] and entities.hashes[x][y] then
        local hash = entities.hashes[x][y]
        
        if not result and #hash.data > 0 then
          result = {unpack(hash.data)}
        else 
          for i = 1, #hash.data do
            if not _icontains(result, hash.data[i]) then
              result[#result+1] = hash.data[i]
            end
          end
        end
      end
    end
  end
  
  return result or {}
end

function entities.freeze(n)
  if not _icontains(entities.frozen, n or "global") then
    entities.frozen[#entities.frozen + 1] = n or "global"
  end
end

function entities.unfreeze(n)
  _quickremovevaluearray(entities.frozen, n or "global")
end

function entities.checkFrozen(name)
  for _, v in ipairs(entities.frozen) do
    if v == name then
      return true
    end
  end
  
  return false
end

function entities.emptyRecycling(c, num)
  if not num or num < 1 then
    entities.recycle[c] = {}
  elseif num < entities.recycle[c] then
    for i=num, #entities.recycle[c] do
      entities.recycle[c][i] = nil
    end
  end
end

function entities.getRecycled(c, ...)
  if not c then error("Class does not exist.") end
  
  local e
  local vr = entities.recycle[c]
  
  if vr and #vr > 0 then
    e = vr[#vr]
    e.recycling = true
    e.registerValues = nil
    e:new(...)
    e.recycling = false
    vr[#vr] = nil
  end
  
  if not e then e = c(...) end
  
  return e
end

function entities._sortLayers()
  local keys = {}
  local vals = {}
  
  for k, v in safepairs(entities.layers) do
    keys[#keys + 1] = v.layer
    vals[v.layer] = v
    entities.layers[k] = nil
  end
  
  table.sort(keys)
  
  for i=1, #keys do
    entities.layers[i] = vals[keys[i]]
  end
end

function entities.getLayer(l)
  for i=1, #entities.layers do
    local v = entities.layers[i]
    
    if v.layer == l then
      return v
    end
  end
end

function entities.setLayer(e, l)
  if e.layer ~= l then
    if not e.isAdded or e.static then
      e.layer = l
    else
      local al = entities.getLayer(e.layer)
      
      if al then
        local i = table.findindexarray(al.data, e)
        al.data[i] = -1
        al.holes[i] = true
        
        if tableIsEmptyOrHoles(al.data) then
          table.removevaluearray(entities.layers, al)
        end
      end
      
      e.layer = l
      
      local done = false
      
      for i=1, #entities.layers do
        local v = entities.layers[i]
        
        if v.layer == e.layer then
          local nextHole = not entities.inLoop and next(v.holes)
          if nextHole then
            v.data[nextHole] = e
            v.holes[nextHole] = nil
          else
            v.data[#v.data + 1] = e
          end
          done = true
          break
        end
      end
      
      if not done then
        entities.layers[#entities.layers + 1] = {layer = e.layer, data = {e}, flicker = true, holes = {}}
        entities.doSort = true
      end
    end
  end
end

function entities.setLayerFlicker(l, b)
  for i=1, #entities.layers do
    if entities.layers[i].layer == l then
      entities.layers[i].flicker = b
      break
    end
  end
end

function entities.add(c, ...)
  local e = entities.getRecycled(c, ...)
  
  if not e.static then
    local done = false
    
    for i=1, #entities.layers do
      local v = entities.layers[i]
      if v.layer == e.layer then
        local nextHole = not entities.inLoop and next(v.holes)
        if nextHole then
          v.data[nextHole] = e
          v.holes[nextHole] = nil
        else
          v.data[#v.data + 1] = e
        end
        done = true
        break
      end
    end
    
    if not done then
      entities.layers[#entities.layers + 1] = {layer = e.layer, data = {e}, flicker = true, holes = {}}
      entities.doSort = true
    end
    
    local nextHole = not entities.inLoop and next(entities._updateHoles)
    if nextHole then
      entities.updates[nextHole] = e
      entities._updateHoles[nextHole] = nil
    else
      entities.updates[#entities.updates + 1] = e
    end
  else
    entities.static[#entities.static + 1] = e
  end
  
  entities.all[#entities.all + 1] = e
  
  for i = 1, #e.groupNames do
    entities.addToGroup(e, e.groupNames[i])
  end
  
  e.isRemoved = false
  e.isAdded = true
  e.justAddedIn = true
  e._lastHashX = nil
  e._lastHashY = nil
  e._lastHashX2 = nil
  e._lastHashY2 = nil
  e.currentHashes = nil
  if not e.invisibleToHash then
    entities.updateHashForEntity(e, true)
  end
  e:added()
  
  if entities.inLoop then
    e:begin()
  else
    entities.beginQueue[#entities.beginQueue + 1] = e
  end
  
  if e.calcGrav then
    e:calcGrav()
  end
  
  return e
end

function entities.adde(e)
  if e.isAdded then return e end
  if not e then return end
  
  if not e.static then
    local done = false
    
    for i=1, #entities.layers do
      local v = entities.layers[i]
      if v.layer == e.layer then
        local nextHole = not entities.inLoop and next(v.holes)
        if nextHole then
          v.data[nextHole] = e
          v.holes[nextHole] = nil
        else
          v.data[#v.data + 1] = e
        end
        done = true
        break
      end
    end
    
    if not done then
      entities.layers[#entities.layers + 1] = {layer = e.layer, data = {e}, flicker = true, holes = {}}
      entities.doSort = true
    end
    
    local nextHole = not entities.inLoop and next(entities._updateHoles)
    if nextHole then
      entities.updates[nextHole] = e
      entities._updateHoles[nextHole] = nil
    else
      entities.updates[#entities.updates + 1] = e
    end
  else
    entities.static[#entities.static + 1] = e
  end
  
  entities.all[#entities.all + 1] = e
  
  for i = 1, #e.groupNames do
    entities.addToGroup(e, e.groupNames[i])
  end
  
  e.isRemoved = false
  e.isAdded = true
  e.justAddedIn = true
  e._lastHashX = nil
  e._lastHashY = nil
  e._lastHashX2 = nil
  e._lastHashY2 = nil
  e.currentHashes = nil
  if not e.invisibleToHash then
    entities.updateHashForEntity(e, true)
  end
  e:added()
  
  if entities.inLoop then
    e:begin()
  else
    entities.beginQueue[#entities.beginQueue + 1] = e
  end
  
  if e.calcGrav then
    e:calcGrav()
  end
  
  return e
end

function entities.addToGroup(e, g)
  if not entities.groups[g] then
    entities.groups[g] = {}
  end
  
  if not _icontains(entities.groups[g], e) then
    entities.groups[g][#entities.groups[g] + 1] = e
  end
  
  if not _icontains(e.groupNames, g) then
    e.groupNames[#e.groupNames + 1] = g
  end
end

function entities.removeFromGroup(e, g)
  _quickremovevaluearray(entities.groups[g], e)
  _quickremovevaluearray(e.groupNames, g)
  
  if #entities.groups[g] == 0 then
    entities.groups[g] = nil
  end
end

function entities.removeFromAllGroups(e)
  for k, _ in safepairs(entities.groups) do
    entities.removeFromGroup(e, k)
  end
end

function entities.makeStatic(e)
  if not e.static then
    local i = table.findindexarray(entities.updates, e)
    entities.updates[i] = -1
    entities._updateHoles[i] = true
    
    local al = entities.getLayer(e.layer)
    
    if al then
      local i = table.findindexarray(al.data, e)
      al.data[i] = -1
      al.holes[i] = true
      
      if tableIsEmptyOrHoles(al.data) then
        table.removevaluearray(entities.layers, al)
      end
    end
    
    entities.static[#entities.static + 1] = e
    
    e.static = true
    e._staticX = e.x
    e._staticY = e.y
    if e.collisionShape then
      e._staticW = e.collisionShape.w
      e._staticH = e.collisionShape.h
    end
    
    e._lastHashX = nil
    e._lastHashY = nil
    e._lastHashX2 = nil
    e._lastHashY2 = nil
    e.currentHashes = nil
    
    e:staticToggled()
  end
end

function entities.revertFromStatic(e)
  if e.static then
    _quickremovevaluearray(entities.static, e)
    
    local done = false
    
    for i=1, #entities.layers do
      local v = entities.layers[i]
      if v.layer == e.layer then
        local nextHole = not entities.inLoop and next(v.holes)
        if nextHole then
          v.data[nextHole] = e
          v.holes[nextHole] = nil
        else
          v.data[#v.data + 1] = e
        end
        done = true
        break
      end
    end
    
    if not done then
      entities.layers[#entities.layers + 1] = {layer = e.layer, data = {e}, flicker = true, holes = {}}
      entities.doSort = true
    end
    
    local nextHole = not entities.inLoop and next(entities._updateHoles)
    if nextHole then
      entities.updates[nextHole] = e
      entities._updateHoles[nextHole] = nil
    else
      entities.updates[#entities.updates + 1] = e
    end
    
    local hashes = entities.hashes
    local HS = entities._HS
    
    if e.collisionShape and e._staticX == e.x and e._staticY == e.y and
      e._staticW == e.collisionShape.w and e._staticH == e.collisionShape.h then
      local xx, yy, ww, hh = e.x - (e.collisionShape.r or 0), e.y - (e.collisionShape.r or 0),
        e.collisionShape.w, e.collisionShape.h
      local hashSize = entities.hashSize
      local cx, cy = _floor((xx - 2) / hashSize), _floor((yy - 2) / hashSize)
      local cx2, cy2 = _ceil((xx + ww + 2) / hashSize), _ceil((yy + hh + 2) / hashSize)
      
      for x = cx, cx2 do
        for y = cy, cy2 do
          if hashes[x] and hashes[x][y] and not hashes[x][y].isRemoved then
            _quickremovevaluearray(hashes[x][y].data, e)
            
            if #hashes[x][y].data == 0 then
              hashes[x][y].isRemoved = true
              hashes[x][y] = nil
              HS[x] = HS[x] - 1
              
              if HS[x] == 0 then
                hashes[x] = nil
                HS[x] = nil
              end
            end
          end
        end
      end
    else
      for x, xt in safepairs(hashes) do
        for y, yt in safepairs(xt) do
          if _icontains(yt.data, e) then
            _quickremovevaluearray(yt.data, e)
          end
          
          if #yt.data == 0 and not yt.isRemoved then
            yt.isRemoved = true
            hashes[x][y] = nil
            HS[x] = HS[x] - 1
            
            if HS[x] == 0 then
              hashes[x] = nil
              HS[x] = nil
            end
          end
        end
      end
    end
    
    e.static = false
    e._staticX = nil
    e._staticY = nil
    e._staticW = nil
    e._staticH = nil
    e._lastHashX = nil
    e._lastHashY = nil
    e._lastHashX2 = nil
    e._lastHashY2 = nil
    e.currentHashes = nil
    
    if not e.invisibleToHash then
      entities.updateHashForEntity(e)
    end
    
    e:staticToggled()
  end
end

function entities.remove(e)
  if not e or e.isRemoved then return end
  
  e.isRemoved = true
  e:removed()
  entities.removeFromAllGroups(e)
  
  local al = entities.getLayer(e.layer)
  
  if e.static then
    _quickremovevaluearray(entities.static, e)
  else
    if al then
      local i = table.findindexarray(al.data, e)
      al.data[i] = -1
      al.holes[i] = true
    end
    
    local i = table.findindexarray(entities.updates, e)
    entities.updates[i] = -1
    entities._updateHoles[i] = true
  end
  
  if not e.static and al and tableIsEmptyOrHoles(al.data) then
    table.removevaluearray(entities.layers, al)
  end
  
  _quickremovevaluearray(entities.all, e)
  
  local i = table.findindexarray(entities.beginQueue, e)
  if i then
    entities.beginQueue[i] = -1
  end
  
  local hashes = entities.hashes
  local HS = entities._HS
  
  if e.currentHashes then
    for _, v in safeipairs(e.currentHashes) do
      if not v.isRemoved then
        _quickremovevaluearray(v.data, e)
        
        if #v.data == 0 then
          v.isRemoved = true
          hashes[v.x][v.y] = nil
          HS[v.x] = HS[v.x] - 1
          
          if HS[v.x] == 0 then
            hashes[v.x] = nil
            HS[v.x] = nil
          end
        end
      end
    end
  elseif e.static then
    if e.collisionShape and e._staticX == e.x and e._staticY == e.y and
      e._staticW == e.collisionShape.w and e._staticH == e.collisionShape.h then
      local xx, yy, ww, hh = e.x - (e.collisionShape.r or 0), e.y - (e.collisionShape.r or 0),
        e.collisionShape.w, e.collisionShape.h
      local hashSize = entities.hashSize
      local cx, cy = _floor((xx - 2) / hashSize), _floor((yy - 2) / hashSize)
      local cx2, cy2 = _ceil((xx + ww + 2) / hashSize), _ceil((yy + hh + 2) / hashSize)
      
      for x = cx, cx2 do
        for y = cy, cy2 do
          if hashes[x] and hashes[x][y] and not hashes[x][y].isRemoved then
            _quickremovevaluearray(hashes[x][y].data, e)
            
            if #hashes[x][y].data == 0 then
              hashes[x][y].isRemoved = true
              hashes[x][y] = nil
              HS[x] = HS[x] - 1
              
              if HS[x] == 0 then
                hashes[x] = nil
                HS[x] = nil
              end
            end
          end
        end
      end
    else
      for x, xt in safepairs(hashes) do
        for y, yt in safepairs(xt) do
          _quickremovevaluearray(yt.data, e)
          
          if #yt.data == 0 and not yt.isRemoved then
            yt.isRemoved = true
            hashes[x][y] = nil
            HS[x] = HS[x] - 1
            
            if HS[x] == 0 then
              hashes[x] = nil
              HS[x] = nil
            end
          end
        end
      end
    end
  end
  
  e._lastHashX = nil
  e._lastHashY = nil
  e._lastHashX2 = nil
  e._lastHashY2 = nil
  e._staticX = nil
  e._staticY = nil
  e._staticW = nil
  e._staticH = nil
  e.currentHashes = nil
  
  e.isAdded = false
  e.justAddedIn = false
  
  if e.recycle then
    if not entities.recycle[e.__index] then
      entities.recycle[e.__index] = {e}
    elseif not _icontains(entities.recycle[e.__index], e) then
      entities.recycle[e.__index][#entities.recycle[e.__index] + 1] = e
    end
  end
end

function entities.clear()
  while entities.all[#entities.all] do
    entities.remove(entities.all[#entities.all])
  end
  
  entities.recycle = {}
  entities.all = {}
  entities.sections = {}
  entities.current = nil
  entities.layers = {}
  entities.updates = {}
  entities.groups = {}
  entities.static = {}
  entities.frozen = {}
  entities.hashes = {}
  entities._HS = {}
  entities.cameraUpdate = nil
  entities.doSort = false
  entities._updateHoles = {}
  entities.beginQueue = {}
  
  collectgarbage()
  collectgarbage()
end

function entities.draw()
  if entities._doSort then
    entities._doSort = false
    entities:_sortLayers()
  end
  
  entities.inLoop = true
  
  for _, layer in safeipairs(entities.layers) do
    for _, e in ipairs(layer.data) do
      if e ~= -1 and checkFalse(e.canDraw) then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(mmFont)
        e:_draw()
      end
    end
    
    if next(layer.holes) then
      removeTableHoles(layer.data)
      layer.holes = {}
    end
  end
  
  if entities.drawCollision then
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #entities.layers do
      for j = 1, #entities.layers[i].data do
        entities.layers[i].data[j]:drawCollision()
      end
    end
  end
  
  entities.inLoop = false
end

function entities.update(dt)
  for _, e in ipairs(entities.beginQueue) do
    if states.switched then
      return
    end
    if e ~= -1 then
      e:begin()
    end
  end
  if #entities.beginQueue > 0 then
    entities.beginQueue = {}
  end
  
  if next(entities._updateHoles) then
    removeTableHoles(entities.updates)
    entities._updateHoles = {}
  end
  
  entities.inLoop = true
  
  for j = 1, #entities.updates do
    if not entities.updates[j].invisibleToHash then
      entities.updateHashForEntity(entities.updates[j])
    end
  end
  
  for i = 1, #entities.updates do
    local e = entities.updates[i]
    
    if e ~= -1 and ((type(e.noFreeze) == "table" and table.intersects(entities.frozen, e.noFreeze, true)) or
      e.noFreeze or not checkTrue(entities.frozen)) and not e.isRemoved and checkFalse(e.canUpdate) then
      collision.doCollision(e, e.noSlope, not checkFalse(e.autoCollision), not checkFalse(e.autoGravity))
      if not e.invisibleToHash then
        entities.updateHashForEntity(e)
      end
    end
    
    if states.switched then
      return
    end
  end
  
  for i = 1, #entities.updates do
    local e = entities.updates[i]
    
    if e ~= -1 and ((type(e.noFreeze) == "table" and table.intersects(entities.frozen, e.noFreeze, true)) or
      e.noFreeze == true or not checkTrue(entities.frozen)) and not e.isRemoved and checkFalse(e.canUpdate) then
      e:_beforeUpdate(dt)
    end
    
    if states.switched then
      return
    end
  end
  
  for i = 1, #entities.updates do
    local e = entities.updates[i]
    
    if e ~= -1 and ((type(e.noFreeze) == "table" and table.intersects(entities.frozen, e.noFreeze, true)) or
      e.noFreeze == true or not checkTrue(entities.frozen)) and not e.isRemoved and checkFalse(e.canUpdate) then
      e:_update(dt)
    end
    
    if states.switched then
      return
    end
  end
  
  for i = 1, #entities.updates do
    local e = entities.updates[i]
    
    if e ~= -1 then
      if ((type(e.noFreeze) == "table" and table.intersects(entities.frozen, e.noFreeze, true)) or
        e.noFreeze or not checkTrue(entities.frozen)) and not e.isRemoved and checkFalse(e.canUpdate) then
        e:_afterUpdate(dt)
      end
      
      e.justAddedIn = false
    end
    
    if states.switched then
      return
    end
  end
  
  entities.inLoop = false
  
  if entities.cameraUpdate then
    entities.cameraUpdate(entities)
  end
  if camera.main then
    camera.main:updateFuncs()
  end
  
  if states.switched then
    return
  end
  
  if entities.doSort then
    entities.doSort = false
    entities._sortLayers()
  end
  
  if entities.doDrawFlicker then
    for i=1, #entities.layers do
      if entities.layers[i].flicker and #entities.layers[i].data > 1 then
        table.lazyShuffle(entities.layers[i].data)
      end
    end
  end
end

basicEntity = class:extend()

basicEntity.autoClean = false
basicEntity.insertVars = {}

function basicEntity:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  cls.autoClean = true
  setmetatable(cls, self)
  return cls
end

function basicEntity:__tostring()
  return "_Ent"
end

function basicEntity:new()
  if not self.recycling then
    self.collisionShape = nil
    self.layer = 1
    self.isRemoved = true
    self.isAdded = false
    self.suggestedIFrameForInteracted = nil
    self.gfx = {}
    self.recycle = false
  end
  
  self.currentHashes = nil
  self.groupNames = {}
  self.x = 0
  self.y = 0
  self.iFrames = 0
  self.changeHealth = 0
  self.canUpdate = {global=true}
  self.canDraw = {global=true}
  
  if not self.cancelInsertBasicEntity and #basicEntity.insertVars ~= 0 then
    for k, v in pairs(basicEntity.insertVars[#basicEntity.insertVars]) do
      self[k] = v ~= nil and v or self[k]
    end
    basicEntity.insertVars[#basicEntity.insertVars] = nil
  end
end

function basicEntity:addGFX(name, gfx, noSync)
  if not table.icontains(self.gfx, gfx) then
    gfx.name = name or "GFX"
    gfx.syncPos = not noSync and self
    self.gfx[#self.gfx + 1] = gfx
  end
  
  return gfx
end

function basicEntity:removeGFX(gfx)
  table.removevaluearray(self.gfx, gfx)
end

function basicEntity:removeGFXByName(n)
  for i = 1, #self.gfx do
    if self.gfx[i].name == n then
      table.remove(self.gfx, i)
      return
    end
  end
end

function basicEntity:getGFXByName(n)
  for i = 1, #self.gfx do
    if self.gfx[i].name == n then
      return self.gfx[i]
    end
  end
end

function basicEntity:determineIFrames(o)
  return o.suggestedIFrameForInteracted or 2
end

function basicEntity:interact(t, h, single)
  if single then
    t:interactedWith(self, h)
  else
    for _, v in pairs(t) do
      v:interactedWith(self, h)
    end
  end
end

function basicEntity:updateIFrame()
  self.iFrames = math.max(self.iFrames - 1, 0)
end

function basicEntity:interactedWith(other, c) end

function basicEntity:setLayer(l)
  entities.setLayer(self, l)
end

function basicEntity:makeStatic()
  entities.makeStatic(self)
end

function basicEntity:revertFromStatic()
  entities.revertFromStatic(self)
end

function basicEntity:removeFromGroup(g)
  entities.removeFromGroup(self, g)
end

function basicEntity:inGroup(g)
  return table.icontains(self.groupNames, g)
end

function basicEntity:removeFromAllGroups()
  entities.removeFromAllGroups(self)
end

function basicEntity:addToGroup(g)
  entities.addToGroup(self, g)
end

function basicEntity:updateHash(doAnyway)
  
end

function basicEntity:setRectangleCollision(w, h)
  if not self.collisionShape then
    self.collisionShape = {}
  end
  
  self.collisionShape.type = 1
  self.collisionShape.w = w or 1
  self.collisionShape.h = h or 1
  
  self.collisionShape.r = nil
  self.collisionShape.data = nil
  
  entities.updateHashForEntity(self)
end

function basicEntity:setImageCollision(path)
  local res = loader.getTable(path)
  
  if not self.collisionShape then
    self.collisionShape = {}
  end
  
  self.collisionShape.type = 2
  self.collisionShape.w = res.data:getWidth()
  self.collisionShape.h = res.data:getHeight()
  self.collisionShape.data = res.data
  self.collisionShape.image = res.img
  
  self.collisionShape.r = nil
  
  entities.updateHashForEntity(self)
end

function basicEntity:setCircleCollision(r)
  if not self.collisionShape then
    self.collisionShape = {}
  end
  
  self.collisionShape.type = 3
  self.collisionShape.w = (r or 1) * 2
  self.collisionShape.h = (r or 1) * 2
  self.collisionShape.r = r or 1
  
  self.collisionShape.data = nil
  
  entities.updateHashForEntity(self)
end

local _rectOverlapsRect = rectOverlapsRect
local _imageOverlapsRect = imageOverlapsRect
local _roundCircleOverlapsRect = roundCircleOverlapsRect
local _imageOverlapsImage = imageOverlapsImage
local _floorImageOverlapsCircle = floorImageOverlapsCircle
local _floorCircleOverlapsCircle = floorCircleOverlapsCircle

entityCollision = {
    {
      function(e, other, x, y)
          return _rectOverlapsRect(e.x + (x or 0), e.y + (y or 0),
            e.collisionShape.w, e.collisionShape.h,
            other.x, other.y, other.collisionShape.w, other.collisionShape.h)
        end,
      function(e, other, x, y)
          return _imageOverlapsRect(other.x, other.y, other.collisionShape.data,
            e.x + (x or 0), e.y + (y or 0), e.collisionShape.w, e.collisionShape.h)
        end,
      function(e, other, x, y)
          return _circleOverlapsRect(other.x, other.y, other.collisionShape.r,
            e.x + (x or 0), e.y + (y or 0), e.collisionShape.w, e.collisionShape.h)
        end
    },
    {
      function(e, other, x, y)
          return _imageOverlapsRect(e.x + (x or 0), e.y + (y or 0), e.collisionShape.data,
            other.x, other.y, other.collisionShape.w, other.collisionShape.h)
        end,
      function(e, other, x, y)
          return _imageOverlapsImage(e.x + (x or 0), e.y + (y or 0), e.collisionShape.data,
            other.x, other.y, other.collisionShape.data)
        end,
      function(e, other, x, y)
          return _floorImageOverlapsCircle(e.x + (x or 0), e.y + (y or 0), e.collisionShape.data,
            other.x, other.y, other.collisionShape.r)
        end
    },
    {
      function(e, other, x, y)
          return _circleOverlapsRect(e.x + (x or 0), e.y + (y or 0), e.collisionShape.r,
            other.x, other.y, other.collisionShape.w, other.collisionShape.h)
        end,
      function(e, other, x, y)
          return _floorImageOverlapsCircle(other.x, other.y, other.collisionShape.data,
            e.x + (x or 0), e.y + (y or 0), e.collisionShape.r)
        end,
      function(e, other, x, y)
          return _floorCircleOverlapsCircle(e.x + (x or 0), e.y + (y or 0), e.collisionShape.r,
            other.x, other.y, other.collisionShape.r)
        end
    }
  }

function basicEntity:collision(e, x, y, notme)
  return e and (not notme or e ~= self) and self.collisionShape and e.collisionShape and
    entityCollision[self.collisionShape.type][e.collisionShape.type](self, e, x, y)
end

function basicEntity:drawCollision()
  if not self.collisionShape or megautils.outside(self) then return end
  if self.collisionShape.type == 1 then
    love.graphics.rectangle("line", math.round(self.x), math.round(self.y),
      self.collisionShape.w, self.collisionShape.h)
  elseif self.collisionShape.type == 2 then
    self.collisionShape.image:draw(math.round(self.x), math.round(self.y))
  elseif self.collisionShape.type == 3 then
    love.graphics.circle("line", math.round(self.x), math.round(self.y), self.collisionShape.r)
  end
end

function basicEntity:collisionTable(t, x, y, notme, func)
  local result = {}
  if not t then return result end
  for i=1, #t do
    local v = t[i]
    if self:collision(v, x, y, notme) and (func == nil or func(v)) then
      result[#result+1] = v
    end
  end
  return result
end

function basicEntity:collisionNumber(t, x, y, notme, func)
  local result = 0
  if not t then return result end
  for i=1, #t do
    if self:collision(t[i], x, y, notme) and (func == nil or func(t[i])) then
      result = result + 1
    end
  end
  return result
end

function basicEntity:updateHash(doAnyway)
  entities.updateHashForEntity(e, doAnyway)
end

function basicEntity:getSurroundingEntities(extentsLeft, extentsRight, extentsUp, extentsDown)
  if self.invisibleToHash then
    return {}
  end
  
  entities.updateHashForEntity(self)
  
  if extentsLeft or extentsRight or extentsUp or extentsDown or not self.currentHashes then
    return entities.getEntitiesAt(self.x - (extentsLeft or 0), self.y - (extentsUp or 0),
      self.collisionShape.w + (extentsLeft or 0) + (extentsRight or 0),
      self.collisionShape.h + (extentsUp or 0) + (extentsDown or 0))
  end
  
  local result = self.currentHashes[1] and {unpack(self.currentHashes[1].data)} or {}
  
  for i = 2, #self.currentHashes do
    for j = 1, #self.currentHashes[i].data do
      if not table.icontains(result, self.currentHashes[i].data[j]) then
        result[#result + 1] = self.currentHashes[i].data[j]
      end
    end
  end
  
  return result
end

function basicEntity:beforeUpdate() end
function basicEntity:update() end
function basicEntity:afterUpdate() end
function basicEntity:draw() end
function basicEntity:added() end
function basicEntity:removed() end
function basicEntity:begin() end
function basicEntity:staticToggled() end

function basicEntity:_beforeUpdate(dt)
  for i = 1, #self.gfx do
    self.gfx[i]:_update(dt)
  end
  
  self:beforeUpdate(dt)
end

function basicEntity:_update(dt)
  self:update(dt)
end

function basicEntity:_afterUpdate(dt)
  self:afterUpdate(dt)
end

function basicEntity:_draw()
  for i = 1, #self.gfx do
    self.gfx[i]:_draw()
  end
  
  self:draw()
end

megautils.cleanFuncs.autoCleaner = {func=function()
    local removed = {}
    for k, v in pairs(_G) do
      if type(v) == "table" and tostring(v) == "_Ent" and v.autoClean then
        removed[#removed + 1] = k
      end
    end
    for i = 1, #removed do
      _G[removed[i]] = nil
    end
  end, autoClean=false}

entity = basicEntity:extend()

entity.autoClean = false

function entity:new()
  self.cancelInsertBasicEntity = true
  entity.super.new(self)
  
  self.gravityMultipliers = {global=1}
  
  if self.recycling then
    self.velX = 0
    self.velY = 0
  else
    self.solidType = collision.NONE
    self.velX = 0
    self.velY = 0
    self.normalGravity = 0.25
    self:calcGrav()
    self.doShake = false
    self.maxShakeTime = 5
  end
  
  self.canDraw.flash = true
  self.blockCollision = {global = false}
  self.autoCollision = {global = true}
  self.autoGravity = {global = false}
  self.ground = false
  self.snapToMovingFloor = true
  self.xColl = 0
  self.yColl = 0
  self.shakeX = 0
  self.shakeY = 0
  self.shakeTime = 0
  self.shakeSide = 1
  self.moveByMoveX = 0
  self.moveByMoveY = 0
  self.canBeInvincible = {global=false}
  self.canStandSolid = {global=true}
  
  if not self.cancelInsertEntity and #basicEntity.insertVars ~= 0 then
    for k, v in pairs(basicEntity.insertVars[#basicEntity.insertVars]) do
      self[k] = v ~= nil and v or self[k]
    end
    basicEntity.insertVars[#basicEntity.insertVars] = nil
  end
end

function entity:moveBy(xx, yy, round)
  local x, y = xx or 0, yy or 0
  if round then
    self.moveByMoveX = self.moveByMoveX + x
    self.moveByMoveY = self.moveByMoveY + y
    x = math.round(self.moveByMoveX)
    y = math.round(self.moveByMoveY)
    self.moveByMoveX = self.moveByMoveX - x
    self.moveByMoveY = self.moveByMoveY - y
  end
  self.x = self.x + x
  self.y = self.y + y
end

function entity:calcGrav()
  self.gravity = self.normalGravity
  for _, v in pairs(self.gravityMultipliers) do
    self.gravity = self.gravity * v
  end
end

function entity:setGravityMultiplier(name, to)
  local old = self.gravityMultipliers[name]
  self.gravityMultipliers[name] = to
  if old ~= self.gravityMultipliers[name] then
    self:calcGrav()
  end
end

function entity:updateShake()
  if self.doShake then
    self.shakeTime = math.min(self.shakeTime+1, self.maxShakeTime)
    if self.shakeTime == self.maxShakeTime then
      self.shakeTime = 0
      self.shakeX = math.abs(self.shakeX) * self.shakeSide
      self.shakeY = math.abs(self.shakeY) * self.shakeSide
      self.shakeSide = -self.shakeSide
    end
  end
end

function entity:setShake(x, y, t)
  self.shakeX = x
  self.shakeY = y
  self.maxShakeTime = t or self.maxShakeTime
  self.doShake = x ~= 0 or y ~= 0
end

function entity:updateFlash(length, range)
  if self.iFrames == 0 or (camera.main and camera.main.transition) then
    self.canDraw.flash = true
  else
    self.canDraw.flash = math.wrap(self.iFrames, 0, length or 4) > (range or 2)
  end
end

mapEntity = basicEntity:extend()

mapEntity.autoClean = false
mapEntity.invisibleToHash = true

function mapEntity.ser()
  return {
      registered = mapEntity.registered,
      doSort = mapEntity.doSort
    }
end

function mapEntity.deser(t)
  mapEntity.registered = t.registered
  mapEntity.doSort = t.doSort
end

mapEntity.registered = {}
mapEntity.doSort = false

function mapEntity:new(map, x, y)
  mapEntity.super.new(self)
  self.x = x or 0
  self.y = y or 0
  self.map = map
  self.path = self.map.path
  self.layers = {}
  self:setLayer(-200)
  self.visibleDuringPause = true
  self.didDrawRange = false
end

function mapEntity:begin()
  self:addToGroup("map")
  
  for i=1, #self.map.layers do
    local v = self.map.layers[i]
    if v.draw then
      self.layers[#self.layers+1] = entities.add(trigger, nil, function(s)
          if s.l.visible then
            if meShader then love.graphics.setShader(meShader) end
            s.l:draw()
            love.graphics.setShader()
          end
        end)
      self.layers[#self.layers].mapEnt = self
      self.layers[#self.layers].l = v
      self.layers[#self.layers]:setLayer(v.properties.layer or (i-100))
      self.layers[#self.layers].visibleDuringPause = true
    end
  end
  
  megautils.runCallback(megautils.addMapFuncs, self)
end

function mapEntity:removed()
  for _, v in safeipairs(self.layers) do
    entities.remove(v)
  end
  
  megautils.runCallback(megautils.removeMapFuncs, self)
  self.map:release()
end

function mapEntity:recursiveChecker(tab, index, name)
  if tab and tab.layers then
    for _, v in pairs(tab.layers) do
      if v[index] == name then
        return v
      elseif v.type == "group" then
        return self:recursiveChecker(v, index, name)
      end
    end
  end
end

function mapEntity:recursiveObjectFinder(tab, otab)
  if not otab then
    otab = {}
  end
  for _, v in pairs(tab.layers) do
    if v.type == "objectgroup" then
      for _, j in pairs(v.objects) do
        otab[#otab+1] = j
      end
    elseif v.type == "group" then
      self:recursiveObjectFinder(v, otab)
    end
  end
  return otab
end

function mapEntity:getLayerByName(name)
  return self:recursiveChecker(self.map, "name", name)
end

function mapEntity:getLayerByID(id)
  return self:recursiveChecker(self.map, "id", name)
end

function mapEntity:addObjects()
  mapEntity.add(self:recursiveObjectFinder(self.map), self.map)
  megautils.runCallback(megautils.postAddObjectsFuncs, self)
end

function mapEntity:update()
  self.didDrawRange = true
  self.map:setDrawRange((view.x - self.x) - self.map.tilewidth, (view.y - self.y) - self.map.tileheight,
    view.w + (self.map.tilewidth * 2), view.h + (self.map.tileheight * 2))
  self.map:update(1/60)
end

function mapEntity:draw()
  love.graphics.push()
  love.graphics.translate(-self.x, -self.y)
  if not self.didDrawRange then
    self.map:setDrawRange((view.x - self.x) - self.map.tilewidth, (view.y - self.y) - self.map.tileheight,
      view.w + (self.map.tilewidth * 2), view.h + (self.map.tileheight * 2))
  else
    self.didDrawRange = false
  end
  self.map:drawBackground()
  love.graphics.pop()
end

-- Possible args:
--
-- From class: class, layer (call order), locked (protected from auto-unloading), spawnX, spawnY,
--    spawnWidth, spawnHeight, ...
-- Ex: `mapEntity.register(objClassHere, 1, false, 0, 0, 16, 16)`
-- Note: Object properties in the tilemap will be written directly in the object instance as variables.
--
-- Custom: string nickname, function callback,
--    layer (call order), locked (protected from auto-unloading)
-- Ex: `mapEntity.register("registerNickname", function(mapProperties) end, 1, false)`
function mapEntity.register(n, f, l, lock, spawnOffY, spawnWidth, spawnHeight, ...)
  if type(n) == "table" then
    local done = false
    for i=1, #mapEntity.registered do
      if mapEntity.registered[i].layer == f or 0 then
        mapEntity.registered[i].data[#mapEntity.registered[i].data+1] = {func=n, name=getClassName(n),
          locked=l, spawnInfo={lock, spawnOffY, spawnWidth, spawnHeight, ...}}
        done = true
        break
      end
    end
    if not done then
      mapEntity.registered[#mapEntity.registered+1] = {layer=f or 0, data={{func=n, name=getClassName(n),
        locked=l, spawnInfo={lock, spawnOffY, spawnWidth, spawnHeight, ...}}}}
      mapEntity.doSort = true
    end
  else
    local done = false
    for i=1, #mapEntity.registered do
      if mapEntity.registered[i].layer == (l or 0) then
        mapEntity.registered[i].data[#mapEntity.registered[i].data+1] = {func=f, name=n, locked=lock,
          args={spawnOffY, spawnWidth, spawnHeight, ...}}
        done = true
        break
      end
    end
    if not done then
      mapEntity.registered[#mapEntity.registered+1] = {layer=l or 0, data={{func=f, name=n, locked=lock,
        args={spawnOffY, spawnWidth, spawnHeight, ...}}}}
      mapEntity.doSort = true
    end
  end
end

function mapEntity.sortReg()
  local keys = {}
  local vals = {}
  for k, v in safepairs(mapEntity.registered) do
    keys[#keys+1] = v.layer
    vals[v.layer] = v
    mapEntity.registered[k] = nil
  end
  table.sort(keys)
  for i=1, #keys do
    mapEntity.registered[i] = vals[keys[i]]
  end
end

function mapEntity.iterReg(f, dir)
  if not dir or dir == 1 then
    for i=1, #mapEntity.registered do
      for j=1, #mapEntity.registered[i].data do
        if f then f(mapEntity.registered[i].data[j]) end
      end
    end
  elseif dir and dir == -1 then
    for i=#mapEntity.registered, 1, -1 do
      for j=#mapEntity.registered[i].data, 1, -1 do
        if f then f(mapEntity.registered[i].data[j]) end
      end
    end
  end
end

function mapEntity.unregister(name)
  mapEntity.iterReg(function(r)
      if r.name == name then
        if r.locked then
          error("Cannot unregister \"" .. name .. "\", a locked register.")
        else
          for i=1, #mapEntity.registered do
            table.quickremovevaluearray(mapEntity.registered[i].data, r)
            if #mapEntity.registered[i].data == 0 then
              table.quickremovevaluearray(mapEntity.registered, mapEntity.registered[i])
            end
          end
        end
      end
    end)
end

function mapEntity.add(ol, map)
  if mapEntity.doSort then
    mapEntity.sortReg()
    mapEntity.doSort = false
  end
  for _, v in ipairs(ol) do
    if v.properties.run then
      megautils.runFile(v.properties.run, true)
    end
  end
  for i=1, #mapEntity.registered do
    local layer = mapEntity.registered[i]
    for _, v in ipairs(ol) do
      for j=1, #layer.data do
        if layer.data[j].name == v.name then
          if type(layer.data[j].func) == "table" then
            local ox, oy, w, h, typ = unpack(layer.data[j].spawnInfo)
            ox, oy, w, h = ox or 0, oy or 0, w or 16, h or 16
            local insert = unpack({v.properties})
            insert.id = v.id
            insert.x = v.x + ox
            insert.y = v.y + oy
            insert.spawnWidth = v.width
            insert.spawnHeight = v.height
            insert.spawnRotation = v.rotation
            insert.mapObjectProperties = insert
            
            if typ == nil or typ == "spawner" then
              entities.add(spawner, v.x + ox, v.y + oy, w, h, nil, layer.data[j].func).insert = insert
            elseif typ == "interval" then
              entities.add(intervalSpawner, v.x + ox, v.y + oy, w, h,
                args.interval, nil, layer.data[j].func).insert = insert
            elseif typ == "none" then
              basicEntity.insertVars[#basicEntity.insertVars + 1] = insert
              entities.add(layer.data[j].func)
            end
          else
            layer.data[j].func(v, map, unpack(layer.data[j].args))
          end
        end
      end
    end
  end
end

megautils.cleanFuncs.mapEntity = {func=function()
    mapEntity.iterReg(function(r)
        if not r.locked then
          for _, v in safeipairs(mapEntity.registered) do
            table.quickremovevaluearray(v.data, r)
            if #v.data == 0 then
              table.quickremovevaluearray(mapEntity.registered, v)
            end
          end
        end
      end, -1)
  end, autoClean=false}

pierce = {}

pierce.NOPIERCE = 0
pierce.PIERCE = 1
pierce.PIERCEIFKILLING = 2

loader.load("assets/sfx/enemyHit.ogg", true)
loader.load("assets/sfx/enemyExplode.ogg", true)
loader.load("assets/sfx/hugeExplode.ogg", true)
loader.load("assets/sfx/dieExplode.ogg", true)

advancedEntity = entity:extend()

advancedEntity.autoClean = false

advancedEntity.SMALLBLAST = 1
advancedEntity.BIGBLAST = 2
advancedEntity.DEATHBLAST = 3

function advancedEntity:new()
  self.cancelInsertEntity = true
  advancedEntity.super.new(self)
  
  if not self.recycling then
    self.explosionType = advancedEntity.SMALLBLAST
    self.removeOnDeath = true
    self.dropItem = true
    self.health = 1
    self.soundOnHit = "assets/sfx/enemyHit.ogg"
    self.soundOnDeath = "assets/sfx/enemyExplode.ogg"
    self.autoHitPlayer = true
    self.damage = -1
    self.hurtable = true
    self.flipWithPlayer = true
    self.defeatSlot = nil
    self.defeatSlotValue = nil
    self.removeWhenOutside = true
    self.removeHealthBarWithSelf = true
    self.barRelativeToView = true
    self.barOffsetX = (view.w - 24)
    self.barOffsetY = 80
    self.applyAutoFace = true
    self.flipFace = false
    self.autoGravity.global = true
    self.applyGravFace = true
    self.flipGravFace = false
    self.gravFace = self.gravity >= 0 and 1 or -1
    self.autoGravFace = self.gravFace
    self.pierceType = pierce.PIERCE
    self.crushable = true
    self.blockCollision.global = true
    self.maxFallingSpeed = 7
    self.noSlope = false
  end
  
  self.dead = false
  self.closest = nil
  self._didCol = false
  self.healthHandler = nil
  self.autoFace = -1
  self.side = -1
  
  if not self.cancelInsertAdvancedEntity and #basicEntity.insertVars ~= 0 then
    for k, v in pairs(basicEntity.insertVars[#basicEntity.insertVars]) do
      self[k] = v ~= nil and v or self[k]
    end
    basicEntity.insertVars[#basicEntity.insertVars] = nil
  end
end

function advancedEntity:added()
  self:addToGroup("removeOnTransition")
  self:addToGroup("handledBySections")
  self:addToGroup("interactable")
  self:addToGroup("advancedEntity")
end

function advancedEntity:useHealthBar(oneColor, twoColor, outlineColor, add)
  if ((add == nil) or add) and self.healthHandler and not self.healthHandler.isRemoved then
    entities.remove(self.healthHandler)
  end
  
  if (add == nil) or add then
    self.healthHandler = entities.add(healthHandler, oneColor or {128, 128, 128},
      twoColor or {255, 255, 255}, outlineColor or {0, 0, 0},
      nil, nil, math.ceil(self.health/4))
  else
    self.healthHandler = healthHandler(oneColor or {128, 128, 128},
      twoColor or {255, 255, 255}, outlineColor or {0, 0, 0},
      nil, nil, math.ceil(self.health/4))
  end
  self.healthHandler:instantUpdate(self.health)
  self.health = nil
  if camera.main then
    camera.main.funcs.advancedEntity = function(s)
        if entities.groups.advancedEntity then
          for i = 1, #entities.groups.advancedEntity do
            if entities.groups.advancedEntity[i].healthHandler then
              local v = entities.groups.advancedEntity[i]
              v.healthHandler.x = (v.barRelativeToView and view.x or 0) + v.barOffsetX
              v.healthHandler.y = (v.barRelativeToView and view.y or 0) + v.barOffsetY
            end
          end
        end
      end
  end
end

function advancedEntity:removed()
  if self.removeHealthBarWithSelf and self.healthHandler then
    if not self.healthHandler.isRemoved then
      entities.remove(self.healthHandler)
    end
  end
end

function advancedEntity:grav()
  self.velY = math.clamp(self.velY + self.gravity, -self.maxFallingSpeed, self.maxFallingSpeed)
end

function advancedEntity:crushed(o)
  if self.crushable and self.hurtable then
    local oldInv, oldIF = table.clone(self.canBeInvincible), self.iFrames
    self.iFrames = 0
    for k, _ in pairs(self.canBeInvincible) do
      self.canBeInvincible[k] = false
    end
    o:interact(self, -99999, true)
    if not self.dead then
      self.iFrames = oldIF
      self.canBeInvincible = oldInv
    end
  end
end

function advancedEntity:getHealth()
  return self.healthHandler and self.healthHandler.health or self.health
end

function advancedEntity:hit(o) end
function advancedEntity:die(o) end
function advancedEntity:determineDink(o) return checkTrue(self.canBeInvincible) end
function advancedEntity:weaponTable(o) end
function advancedEntity:heal(o) end

function advancedEntity:beforeUpdate()
  if self.flipWithPlayer and megaMan.mainPlayer then
    self:setGravityMultiplier("flipWithPlayer", megaMan.mainPlayer.gravityMultipliers.gravityFlip or 1)
  end
  local s, n = megautils.side(self, megaMan.allPlayers)
  self.autoFace = s or self.autoFace
  if self.applyAutoFace then
    self.side = self.autoFace
  end
  if self.applyAutoGravFace then
    self.gravFace = self.autoGravFace
  end
  for i = 1, #self.gfx do
    self.gfx[i]:flip(self.side == (self.flipFace and -1 or 1), (self.gravity * (self.flipGravFace and 1 or -1)) >= 0)
  end
  self.closest = n
  self:updateFlash()
  self:updateIFrame()
  self:updateShake()
end

function advancedEntity:afterUpdate()
  if self.autoHitPlayer then
    self:interact(self:collisionTable(megaMan.allPlayers), self.damage)
  end
  if self.removeWhenOutside and megautils.outside(self) then
    entities.remove(self)
  end
end

function advancedEntity:interactedWith(o, c)
  if self.dead then return end
  
  local doDink = self:determineDink(o)
  
  if checkTrue(self.canBeInvincible) or doDink or not self.hurtable then
    if doDink and o.dink and not o.dinked then
      o:dink(self)
    end
    return
  end
  
  local health = self.healthHandler and self.healthHandler.health or self.health
  
  self.changeHealth = c
  self.changeHealth = self:weaponTable(o) or self.changeHealth
  
  if self.changeHealth < 0 then
    if o.pierceType == pierce.NOPIERCE or (o.pierceType == pierce.PIERCEIFKILLING and health + self.changeHealth > 0) then
      entities.remove(o)
    end
    if self.iFrames <= 0 then
      self.iFrames = self:determineIFrames(o)
    else
      return
    end
  end
  
  if health + self.changeHealth <= 0 then
    self.dead = true
    if self.healthHandler then
      self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
    else
      self.health = math.max(self.health + self.changeHealth, 0)
    end
    self:die(o)
    if self.defeatSlot then
      globals.defeats[self.defeatSlot] = self.defeatSlotValue or true
    end
    if self.explosionType == advancedEntity.SMALLBLAST then
      entities.add(smallBlast, self.x+(self.collisionShape.w/2)-12, self.y+(self.collisionShape.h/2)-12, self)
    elseif self.explosionType == advancedEntity.BIGBLAST then
      entities.add(blast, self.x+(self.collisionShape.w/2)-12, self.y+(self.collisionShape.h/2)-12, self)
    elseif self.explosionType == advancedEntity.DEATHBLAST then
      deathExplodeParticle.createExplosion(self.x+((self.collisionShape.w/2)-12),
        self.y+((self.collisionShape.h/2)-12), self)
    end
    if self.dropItem then
      local item
      if self.dropItem == true then
        item = megautils.dropItem(self.x, self.y)
      else
        item = entities.adde(self.dropItem)
      end
      if item then
        item.x = self.x+(self.collisionShape.w/2)-(item.collisionShape.w/2)
        item.y = self.y+(self.collisionShape.h/2)-(item.collisionShape.h/2) + (self.gravity >= 0 and -8 or 8)
      end
    end
    if self.removeOnDeath then
      entities.remove(self)
    end
    if self.soundOnDeath then
      if loader.get(self.soundOnDeath) then
        sfx.play(self.soundOnDeath)
      else
        sfx.playFromFile(self.soundOnDeath)
      end
    end
  elseif self.changeHealth < 0 then
    if self.healthHandler then
      self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
    else
      self.health = math.max(self.health + self.changeHealth, 0)
    end
    self:hit(o)
    if o.pierceIfKilling then
      entities.remove(o)
    end
    if self.soundOnHit then
      if loader.get(self.soundOnHit) then
        sfx.play(self.soundOnHit)
      else
        sfx.playFromFile(self.soundOnHit)
      end
    end
  elseif self.changeHealth > 0 then
    self:heal(o)
    
    if self.healthHandler then
      self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
    else
      self.health = math.max(self.health + self.changeHealth, 0)
    end
  end
end

bossEntity = advancedEntity:extend()

bossEntity.autoClean = false

function bossEntity:new()
  self.cancelInsertAdvancedEntity = true
  bossEntity.super.new(self)
  self.soundOnDeath = "assets/sfx/dieExplode.ogg"
  self.dropItem = false
  self.explosionType = advancedEntity.DEATHBLAST
  self.defeatSlot = nil
  self.flipWithPlayer = false
  self.removeWhenOutside = false
  self.removeHealthBarWithSelf = false
  self.state = 0
  self._subState = 0
  self.skipBoss = nil
  self.skipBossState = globals.menuState
  self.doIntro = true
  self.strikePose = true
  self.continueAfterDeath = false
  self.afterDeathState = globals.weaponGetState
  self.weaponGetMenuState = globals.menuState
  self.doBossIntro = states.currentStatePath == globals.bossIntroState
  self.bossIntroText = nil
  self.weaponGetText = "WEAPON GET... (NAME HERE)"
  self.stageState = nil
  self.mugshotPath = nil
  self.bossIntroWaitTime = 400
  self.health = 28
  self.lockBossDoors = true
  self.weaponGetBehaviour = function(s)
      return true
    end
  self.skipStart = false
  self.replayMusicWhenContinuing = true
  self:setMusic("assets/sfx/mm5.nsf", nil, 10)
  self:setBossIntroMusic("assets/sfx/mm5.nsf", nil, 14)
  
  if not self.cancelInsertBossEntity and #basicEntity.insertVars ~= 0 then
    for k, v in pairs(basicEntity.insertVars[#basicEntity.insertVars]) do
      self[k] = v ~= nil and v or self[k]
    end
    basicEntity.insertVars[#basicEntity.insertVars] = nil
  end
end

function bossEntity:added()
  bossEntity.super.added(self)
  
  self.canDraw.firstFrame = false
  self.canBeInvincible.firstFrame = true
  self.autoCollision.firstFrame = false
  self.autoGravity.firstFrame = false
  self.lastMusic = music.curID
  self.lastVol = music.vol
  self.lastGMETrack = music.track
end

function bossEntity:useHealthBar(oneColor, twoColor, outlineColor, add)
  bossEntity.super.useHealthBar(self, oneColor, twoColor, outlineColor, add or add ~= nil)
end

function bossEntity:setMusic(p, v, track)
  self.musicPath = p
  self.musicVolume = v or 1
  self.gmeTrack = track or 0
end

function bossEntity:setBossIntroMusic(p, v, track)
  self.musicBIPath = p
  self.musicBIVolume = v or 1
  self.gmeBITrack = track or 0
end

function bossEntity:intro()
  if not self.ds then
    self.screen = entities.add(trigger, nil, function(s)
        love.graphics.setColor(0, 0, 0, s.o)
        love.graphics.rectangle("fill", view.x-1, view.y-1, view.w+2, view.h+2)
      end)
    self.screen.o = 0
    self.screen:setLayer(0)
    self.ds = 1
    self.dOff = view.y-self.y
    self.oldY = self.y
    self.y = self.oldY + self.dOff
  elseif self.ds == 1 then
    self.screen.o = math.min(self.screen.o+0.05, 0.4)
    self.dOff = math.min(self.dOff+1, 0)
    self.y = self.oldY + self.dOff
    if self.y == self.oldY then
      self.ds = 2
    end
  elseif self.ds == 2 then
    self.screen.o = math.max(self.screen.o-0.05, 0)
    if self.screen.o == 0 then
      entities.remove(self.screen)
      self.screen = nil
      self.dOff = nil
      self.oldY = nil
      self.ds = nil
      return true
    end
  end
end

function bossEntity:pose()
  return true
end

function bossEntity:skip()
  if not self.continueAfterDeath then
    timer.winCutscene(function()
        megautils.reloadState = true
        megautils.resetGameObjects = true
        states.setq(self.skipBossState)
      end)
    music.stop()
  end
  entities.remove(self)
  return true
end

function bossEntity:start()
  if self._subState == 0 then
    if megaMan.allPlayers then
      for _, v in ipairs(megaMan.allPlayers) do
        v.canControl.boss = false
        v.canBeInvincible.intro = true
        v.velX = 0
        v:resetStates()
        v.side = megautils.side(v, self, true)
      end
      self._subState = 1
    end
    
    self.canDraw.intro = false
    self.canBeInvincible.intro = true
    self.autoCollision.intro = false
    self.autoGravity.intro = false
    
    music.stop()
  elseif self._subState == 1 then
    local result = {}
    for k, v in ipairs(megaMan.allPlayers) do
      if not v.drop and not v.rise then
        if v.ground then
          result[k] = true
          v.anims:set("idle")
        else
          result[k] = false
        end
      else
        result[k] = false
      end
    end
    if not table.contains(result, false) then
      self._subState = 2
      music.play(self.musicPath, self.musicVolume, self.gmeTrack)
      self.canDraw.intro = nil
      if not self.doIntro or self:intro() then
        self._subState = 3
      end
    end
  elseif self._subState == 2 then
    if not self.doIntro or self:intro() then
      self._subState = 3
    end
  elseif self._subState == 3 then
    if not self.strikePose or self:pose() then
      self._subState = nil
      if megaMan.allPlayers then
        for _, v in ipairs(megaMan.allPlayers) do
          v.canControl.boss = nil
          v.canBeInvincible.intro = nil
        end
        self.canBeInvincible.intro = nil
        self.autoCollision.intro = nil
        self.autoGravity.intro = nil
      end
      return true
    end
  end
end

function bossEntity:die(o)
  megautils.removeEnemyShots()
  if not self.continueAfterDeath then
    timer.absorbCutscene(function()
        if self.afterDeathState == globals.weaponGetState then
          globals.weaponGetText = self.weaponGetText
          globals.weaponGetBehaviour = self.weaponGetBehaviour
          globals.wgMenuState = self.weaponGetMenuState
          globals.wgValue = self.defeatSlotValue
        end
        megautils.reloadState = true
        megautils.resetGameObjects = true
        states.setq(self.afterDeathState)
      end)
    music.stop()
  else
    if entities.groups.bossDoor then
      for _, v in ipairs(entities.groups.bossDoor) do
        v.isLocked.boss = nil
      end
    end
    if self.replayMusicWhenContinuing and not self._onceReplay then
      self._onceReplay = true
      music.play(self.lastMusic, self.lastVol, self.lastGMETrack)
    end
  end
end

function bossEntity:determineIFrames(o)
  return o.suggestedIFrameForInteracted or 50
end

function bossEntity:hit(o)
  entities.add(harm, self, 50)
end

function bossEntity:bossIntro()
  if self._subState == 0 then
    self.autoCollision.intro = false
    self.autoGravity.intro = false
    self.x = math.floor(view.w/2)-(self.collisionShape.w/2)
    self.y = -self.collisionShape.h
    self._timer = 0
    self._textPos = 0
    self._textTimer = 0
    self._subState = 1
    self._halfWidth = love.graphics.newText(mmFont, self.bossIntroText):getWidth()/2
    if self.musicBIPath then
      music.play(self.musicBIPath, self.musicBIVolume, self.gmeBITrack)
    end
  elseif self._subState == 1 then
    self.y = math.min(self.y+10, math.floor(view.h/2)-(self.collisionShape.h/2))
    if self.y == math.floor(view.h/2)-(self.collisionShape.h/2) then
      self._subState = 2
    end
  elseif self._subState == 2 then
    if self:pose() then
      self._subState = 3
    end
  elseif self._subState == 3 then
    self._timer = self._timer + 1
    if self._timer < self.bossIntroWaitTime then
      if self.bossIntroText then
        self._textTimer = math.min(self._textTimer+1, 8)
        if self._textTimer == 8 then
          self._textTimer = 0
          self._textPos = math.min(self._textPos+1, self.bossIntroText:len())
        end
      end
    else
      states.fadeToState(self.stageState)
    end
  end
end

function bossEntity:_update()
  if self.doBossIntro then
    self:bossIntro()
  else
    if not self.didOnce then
      self.didOnce = true
      if (self.skipBoss == nil and self.defeatSlot and globals.defeats[self.defeatSlot]) or self.skipBoss then
        if self:skip() then
          self.skipStart = true
          return
        end
      else
        if self.lockBossDoors and entities.groups.bossDoor then
          for _, v in ipairs(entities.groups.bossDoor) do
            v.isLocked.boss = true
          end
        end
        if self.musicPath then
          music.play(self.musicPath, self.musicVolume, self.gmeTrack)
        end
      end
    end
    if not self.didIntro and (self.skipStart or self:start()) then
      self._subState = nil
      self.didIntro = true
      
      if self.healthHandler then
        local lh = self.healthHandler.health
        self.healthHandler:instantUpdate(0)
        self.healthHandler:updateThis(lh)
      
        if not self.healthHandler.isAdded then
          entities.adde(self.healthHandler)
        end
      end
    elseif self.didIntro then
      self:update()
    end
  end
  self.canDraw.firstFrame = nil
  self.canBeInvincible.firstFrame = nil
  self.autoCollision.firstFrame = nil
  self.autoGravity.firstFrame = nil
end

function bossEntity:_draw()
  bossEntity.super._draw(self)
  
  if self.doBossIntro and self.bossIntroText and self._halfWidth then
    love.graphics.print(self.bossIntroText:sub(0, self._textPos or 0), (view.w/2)-self._halfWidth, 142)
  end
end
