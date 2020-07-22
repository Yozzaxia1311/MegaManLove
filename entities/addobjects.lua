addObjects = {}
addObjects.registered = {}
addObjects.ranFiles = {}
addObjects.doSort = false

function addObjects.register(n, f, l, lock)
  local done = false
  for i=1, #addObjects.registered do
    if addObjects.registered[i].layer == (l or 0) then
      addObjects.registered[i].data[#addObjects.registered[i].data+1] = {func=f, name=n, locked=lock}
      done = true
      break
    end
  end
  if not done then
    addObjects.registered[#addObjects.registered+1] = {layer=l or 0, data={{func=f, name=n, locked=lock}}}
    addObjects.doSort = true
  end
end

function addObjects.sort()
  local keys = {}
  local vals = {}
  for k, v in pairs(addObjects.registered) do
    keys[#keys+1] = v.layer
    vals[v.layer] = v
    addObjects.registered[k] = nil
  end
  table.sort(keys)
  for i=1, #keys do
    addObjects.registered[i] = vals[keys[i]]
  end
end

function addObjects.iter(f, dir)
  if not dir or dir == 1 then
    for i=1, #addObjects.registered do
      for j=1, #addObjects.registered[i].data do
        if f then f(addObjects.registered[i].data[j]) end
      end
    end
  elseif dir and dir == -1 then
    for i=#addObjects.registered, 1, -1 do
      for j=#addObjects.registered[i].data, 1, -1 do
        if f then f(addObjects.registered[i].data[j]) end
      end
    end
  end
end

function addObjects.unregister(name)
  addObjects.iter(function(r)
      if r.name == name then
        if r.locked then
          if addObjects.registered[i].data[j].locked then
            error("Cannot unregister \"" .. name .. "\", a locked register.")
          end
        else
          for i=1, #addObjects.registered do
            table.quickremovevaluearray(addObjects.registered[i].data, r)
            if #addObjects.registered[i].data == 0 then
              table.quickremovevaluearray(addObjects.registered, addObjects.registered[i])
            end
          end
        end
      end
    end)
end

function addObjects.add(ol, map)
  if addObjects.doSort then
    addObjects.sort()
    addObjects.doSort = false
  end
  for i=1, #addObjects.registered do
    local layer = addObjects.registered[i]
    for k, v in ipairs(ol) do
      if v.properties.run and not table.contains(addObjects.ranFiles, v.properties.run) then
        megautils.runFile(v.properties.run)
        addObjects.ranFiles[#addObjects.ranFiles+1] = v.properties.run
      end
      for j=1, #layer.data do
        if layer.data[j].name == v.name then
          layer.data[j].func(v, map)
        end
      end
    end
  end
end

megautils.cleanFuncs.addObjects = function()
    addObjects.iter(function(r)
        if not r.locked then
          for i=1, #addObjects.registered do
            table.quickremovevaluearray(addObjects.registered[i].data, r)
            if #addObjects.registered[i].data == 0 then
              table.quickremovevaluearray(addObjects.registered, addObjects.registered[i])
            end
          end
        end
      end, -1)
    addObjects.ranFiles = {}
  end