addobjects = {}
addobjects.registered = {{}}
addobjects.lowestRegister = 0
addobjects.highestRegister = 0

function addobjects.register(name, func, ord)
  local order = ternary(ord ~= nil, ord, 0)
  if order < addobjects.lowestRegister then
    addobjects.lowestRegister = order
  elseif order > addobjects.highestRegister then
    addobjects.highestRegister = order
  end
  if addobjects.registered[order] == nil then
    addobjects.registered[order] = {}
  end
  addobjects.registered[order][name] = func
end

function addobjects.unregister(name)
  for k, v in pairs(addobjects.registered) do
    v[name] = nil
  end
end

--Template register vvv
--addobjects.register("???", function(v)
--end)

function addobjects.add(ol)
  for i=addobjects.lowestRegister, addobjects.highestRegister do
    for k, v in pairs(ol) do
      if addobjects.registered[i] ~= nil and addobjects.registered[i][v.name] ~= nil then
        addobjects.registered[i][v.name](v)
      end
    end
  end
end