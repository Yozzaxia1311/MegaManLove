console = {
  scale = 1,
  input = "",
  inputOld = "",
  inputCycle = -1,
  state = 0,
  wait = 0,
  waitBuffer = {},
  x = 0,
  y = -math.huge,
  w = 256,
  h = 112,
  ignoreKeys = {
    ["`"] = true,
    ["$"] = true,
    ["~"] = true,
    ["\r"] = true,
    ["\n"] = true,
  },
  lines = {},
  inputList = {},
  aliases = {},
  font = love.graphics.newFont()
}

function console.ser()
  return {
    scale=console.scale,
    input=console.input,
    inputOld=console.inputOld,
    inputCycle=console.inputCycle,
    state=console.state,
    wait=console.wait,
    waitBuffer=console.waitBuffer,
    x=console.x,
    y=console.y,
    w=console.w,
    h=console.h,
    ignoreKeys=console.ignoreKeys,
    lines=console.lines,
    inputList=console.inputList,
    aliases=console.aliases
  }
end

function console.deser(t)
  console.scale = t.scale
  console.input = t.input
  console.inputOld = t.inputOld
  console.inputCycle = t.inputCycle
  console.state = t.state
  console.wait = t.wait
  console.waitBuffer = t.waitBuffer
  console.x = t.x
  console.y = t.y
  console.w = t.w
  console.h = t.h
  console.ignoreKeys = t.ignoreKeys
  console.lines = t.lines
  console.inputList = t.inputList
  console.aliases = t.aliases
end

function numberSanitize(v)
  local n = tonumber(v)
  -- if NaN then return 0
  if n == nil or n ~= n then
    return 0
  end
  return n
end

convar = {}
concmd = {}

conaction = {}

function conaction.new(str)
  conaction[str] = 0
  concmd['+'..str] = {
    helptext = '+'..str,
    flags = {"client", "action"},
    fun = function() conaction[str] = 1 end,
  }
  concmd['-'..str] = {
    helptext = '-'..str,
    flags = {"client", "action"},
    fun = function() conaction[str] = 2 end,
  }
end

-- unfortunately, this means concmd/convar are impossible to make if they are called function name
-- always run isValid so you never treat a function like a concmd/convar

function concmd.isValid(str)
  if not str then return false end
  if not concmd[str] then return false end
  if type(concmd[str]) ~= "table" then return false end
  if concmd[str].fun == nil or concmd[str].flags == nil then return false end
  return true
end

function convar.isValid(str)
  if not str then return false end
  if not convar[str] then return false end
  if type(convar[str]) ~= "table" then return false end
  if convar[str].value == nil or convar[str].flags == nil then return false end
  return true
end

function convar.getFlag(str, f)
  if not convar.isValid(str) then return end
  for _, v in pairs(convar[str].flags) do
    if v == f then
      return true
    end
  end
  return false
end

function concmd.getFlag(str, f)
  if not concmd.isValid(str) then return end
  for _, v in pairs(concmd[str].flags) do
    if v == f then
      return true
    end
  end
  return false
end


function convar.getValue(str)
  -- nil = does not exist or invalid
  if not convar.isValid(str) then return end
  local val = convar[str].value
  return val
end

function convar.getAllValues()
  local res = {}
  for k, v in pairs(convar) do
    if convar.isValid(k) then
      res[k] = v.value
    end
  end
  return res
end

function convar.setAllValues(t)
  for k, v in pairs(t) do
    if convar.isValid(k) then
      convar[k].value = v
    end
  end
end

function convar.getString(str)
  -- nil = does not exist or invalid
  if not convar.isValid(str) then return end
  -- should we return an empty string or nil when invalid?
  local val = tostring(convar[str].value)
  return val
end

function convar.getNumber(str, nan)
  -- nil = does not exist or invalid
  if not convar.isValid(str) then return end
  local val = tonumber(convar[str].value)
  -- if NaN then return 0 or nan override
  if val == nil or val ~= val then
    return nan == nil and 0 or nan
  end
  return val
end

function convar.setValue(str, val, call)
  call = call or false
  if val == true then val = 1 end
  if val == false or val == nil then val = 0 end
  if not convar.isValid(str) then return false end
  if call and convar[str].fun then
    convar[str].fun(val)
  end
  convar[str].value = val
  return true
end

function console.init()
  console.print("Welcome to Mega Man Love")
  console.print("Run \"findcmd\" for a list of commands")
  console.print("Run \"findcvar\" for a list of console variables")
end

function console.open()
  console.state = 1
end

function console.close()
  console.state = 0
end

function console.print(str)
  if str == "" then return end
  table.insert(console.lines, tostring(str))
end

function console.send()
  if console.input ~= console.inputList[#console.inputList] and #console.input > 0 then
    table.insert(console.inputList, console.input)
  end
  console.print("$ "..console.input)
  console.parse(console.input)
  console.input = ""
  console.inputCycle = -1
end

function console.printConvar(str)
  -- nice space padding
  local flagstr = " "
  console.print("\""..str.."\" is \""..tostring(convar.getValue(str)).."\"")
  for _, v in pairs(convar[str].flags) do
    flagstr = flagstr .. v .. ", "
  end
  if #flagstr > 1 then
    flagstr = flagstr:sub(1, -3)
  end
  console.print(flagstr)
  if convar[str].helptext and #convar[str].helptext > 0 then
    console.print(" - " .. convar[str].helptext)
  end
end

function console.parse(str, noalias)
  if console.wait > 0 then
    console.waitBuffer[#console.waitBuffer+1] = str
    return
  end
  if not str or #str == 0 then return end
  -- todo: FULL quotation mark support
  local nstr
  local cmd = {}
  local word = ""
  local wstart, wend
  local quote = false
  -- bug: lone/spaced quotation marks " like this " broken
  for arg in str:gmatch("%S+") do
    if quote then
      word = word.." "
    end
    word = word .. arg
    wstart = string.sub(arg, 1, 1)
    wend = string.sub(arg, #arg, -1)
    --console.print("wstart "..wstart)
    --console.print("wend "..wend)
    if wstart == "" or wend == "" then
      str, nstr = string.match(str, "([^]+)([^]+)")
      str = string.sub(str, 1, -1)
      arg = string.sub(arg, 1, -1)
    end
    if wstart == "\"" then
      quote = true
    end
    if (not quote) or (wend == "\"") then
      if quote then
        word = string.sub(word, 2, #word)
        word = string.sub(word, 1, -2)
      end
      table.insert(cmd, word)
      word = ""
      quote = false
    end
  end

  -- aliases, may have to change order in case they overwrite things
  if console.aliases[cmd[1]] then
    console.parse(console.aliases[cmd[1]])
    return
  end

  if concmd.isValid(cmd[1]) then
    if concmd[cmd[1]].fun then
      if concmd.getFlag(cmd[1], "cheat") then
        if tonumber(convar.getValue("cheats")) == 1 then
          concmd[cmd[1]].fun(cmd)
        else
          console.print("Cheating is disabled")
        end
      else
        concmd[cmd[1]].fun(cmd)
      end
    end
    if nstr then console.parse(nstr) end
    return
  end
  if convar.isValid(cmd[1]) then
    if #cmd == 1 then
      console.printConvar(cmd[1])
      if nstr then console.parse(nstr) end
      return
    else
      if convar.getFlag(cmd[1], "cheat") then
        if tonumber(convar.getValue("cheats")) == 1 then
          convar.setValue(cmd[1], cmd[2])
          if convar[cmd[1]].fun then
            convar[cmd[1]].fun(tostring(cmd[2]))
          end
          if nstr then console.parse(nstr) end
        else
          console.print("Cheating is disabled")
        end
      else
        convar.setValue(cmd[1], cmd[2])
        if convar[cmd[1]].fun then
          convar[cmd[1]].fun(tostring(cmd[2]))
        end
        if nstr then console.parse(nstr) end
      end
      return
    end
  end
  console.print("Unknown command: " .. cmd[1])
  if nstr then console.parse(nstr) end
end

function console.doInput(k)
  if console.state == 0 then return end
  if console.ignoreKeys[k] then return end
  console.input = console.input .. k
end

function console.cycle(k)
  if console.inputCycle == -1 then
    console.inputOld = console.input
  end
  if k == "up" then
    if console.inputList[#console.inputList-(console.inputCycle+1)] then
      console.inputCycle = console.inputCycle + 1
      console.input = console.inputList[#console.inputList-console.inputCycle]
    end
  elseif k == "down" then
    if console.inputList[#console.inputList-(console.inputCycle-1)] then
      console.inputCycle = console.inputCycle - 1
      console.input = console.inputList[#console.inputList-console.inputCycle]
    elseif console.inputCycle == 0 then
      console.inputCycle = -1
      console.input = console.inputOld or ""
      return -- set to what we typed before going up/down
    end
  end
end

function console.backspace(k)
  console.input = console.input:sub(1, -2)
end

function console.complete()
  console.input = console.getCompletion(console.input)
end

function console.update(dt)
  local sw, sh = love.window.getMode()
  console.scale = math.ceil((sh/224))
  console.w = sw -- in case aspect gets messed up
  console.h = 112*console.scale
  if console.state == 0 then
    if console.y > -console.h then
      console.y = console.y - ((300*console.scale)*dt)
    end
    if console.y < -console.h then
      console.y = -console.h
    end
  end
  if console.state == 1 then
    if console.y < 0 then
      console.y = console.y + ((300*console.scale)*dt)
    end
    if console.y > 0 then
      console.y = 0
    end
  end
  if console.wait == 0 and #console.waitBuffer > 0 then
    for k, v in pairs(console.waitBuffer) do
      console.parse(v)
      console.waitBuffer[k] = nil
      if console.wait > 0 then break end
    end
  end
  while #console.lines > 25 do
    table.remove(console.lines, 1)
  end
end

function console.getCompletion(str)
  -- todo: make them alphabetized instead of prioritized via type
  -- bye bye pattern matching errors
  if str:find('[', nil, true) ~= nil then return "" end
  for k, _ in pairs(convar) do
    if convar.isValid(k) then
      if k:find('^' .. str) ~= nil then
        return k
      end
    end
  end
  for k, _ in pairs(concmd) do
    if concmd.isValid(k) then
      if k:find('^' .. str) ~= nil then
        return k
      end
    end
  end
  return ""
end

function console.doWait()
  if console.wait > 0 then console.wait = console.wait - 1 end
end

function console.draw()
  local oldFont = love.graphics.getFont()
  local lineMax = math.floor(6.67*console.scale)

  love.graphics.setFont(console.font)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setColor(0, 0, 0, 0.95)
  love.graphics.rectangle("fill", console.x, console.y, console.w, console.h)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("fill", console.x, console.y+console.h-1, console.w, 1)
  if #console.input > 0 then
    love.graphics.setColor(1, 1, 1, 0.33)
    love.graphics.print("$ "..console.getCompletion(console.input), console.x+2, console.y+console.h-16)
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("$ "..console.input.."_", console.x+2, console.y+console.h-16)

  local i = #console.lines+1
  local amt = math.clamp(#console.lines-lineMax, 1, #console.lines-lineMax)
  while i > amt do
    if console.lines[i] then
      if amt >= 0 then
        love.graphics.print(console.lines[i], console.x+2, (console.y-16)+((i-amt)*16))
      else
        love.graphics.print(console.lines[i], console.x+2, (console.y-16)+((i)*16))
      end
    end
    i = i - 1
  end

  love.graphics.setFont(oldFont)
end