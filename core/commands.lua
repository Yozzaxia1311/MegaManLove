function cmdHelp(cmd)
  if not cmd or not cmd[1] or not cmd[2] then
    cmd = {"help", "help"}
  end
  if concmd.isValid(cmd[2]) then
    if concmd[cmd[2]].helptext then
      console.print(" - "..concmd[cmd[2]].helptext)
    end
  elseif convar.isValid(cmd[2]) then
    if convar[cmd[2]].helptext then
      console.print(" - "..convar[cmd[2]].helptext)
    end
  else
    console.print("Unknown command: "..cmd[2])
  end
end
concmd["help"] = {
  helptext = "get info about commands",
  flags = {},
  fun = cmdHelp,
}

function cmdGame(cmd)
  if not cmd[2] then return end
  local d = love.filesystem.getInfo(cmd[2])
  if d and d.type == "directory" and love.filesystem.getInfo(cmd[2] .. "/init.lua") then
    megautils.loadGame(cmd[2])
  else
    console.print("No such game \""..cmd[2].."\"")
  end
end
concmd["game"] = {
  helptext = "load a game",
  flags = {},
  fun = cmdGame,
}

function cmdGames(cmd)
  local result = {}
  for k, v in pairs(love.filesystem.getDirectoryItems("/")) do
    local info = love.filesystem.getInfo(v)
    if info and info.type == "directory" and love.filesystem.getInfo(v .. "/init.lua") then
      result[#result+1] = v
    end
  end
  if #result == 0 then
    console.print("No games available")
  else
    for i=1, #result do
      console.print(result[i])
    end
  end
end
concmd["games"] = {
  helptext = "gives a list of games",
  flags = {},
  fun = cmdGames,
}

function cmdEcho(cmd)
  if not cmd[2] then return end
  console.print(cmd[2])
end
concmd["echo"] = {
  helptext = "print to console",
  flags = {},
  fun = cmdEcho,
}

concmd["quit"] = {
  helptext = "quit the game",
  flags = {},
  fun = function() love.event.quit() end,
}
concmd["exit"] = concmd["quit"]

function cmdState(cmd)
  if not cmd[2] then return end
  local map
  if love.filesystem.getInfo(cmd[2] .. ".state.lua") then
    local path = cmd[2]:split("/")
    if #path > 1 then
      local d = love.filesystem.getInfo(path[1])
      if d and d.type == "directory" and love.filesystem.getInfo(path[1] .. "/init.lua") then
        if gamePath ~= path[1] then
          megautils.unload()
          initEngine()
          gamePath = path[1]
        end
        local data = love.filesystem.load(path[1] .. "/init.lua")()
        data.run()
        local result = path[2]
        for i=3, #path do
          result = result .. "/" .. path[i]
        end
        map = result .. ".state.lua"
      else
        gamePath = ""
        map = cmd[2] .. ".state.lua"
        megautils.resetGameObjects()
      end
    end
  end
  if map == nil then console.print("No such state \""..cmd[2].."\"") return end
  love.audio.stop()
  mmMusic.stopMusic()
  globals.manageStageResources = true
  globals.resetState = true
  if cmd[3] then globals.checkpoint = cmd[3] end
  states.set(map)
end
concmd["state"] = {
  helptext = "load a state",
  flags = {"cheat"},
  fun = cmdState,
}

function cmdStates(cmd)
  local check
  if cmd[2] then
    check = cmd[2]
    if not love.filesystem.getInfo(check) then console.print("No such directory \""..cmd[2].."\"") return end
  end
  local result = iterateDirs(function(f)
      return f:sub(-10) == ".state.lua"
    end, check)
  if #result == 0 then
    if check then
      console.print("No states in directory \""..cmd[2].."\"")
    else
      console.print("No states at all??")
    end
    return
  end
  for i=1, #result do
    console.print(result[i]:sub(1, -11))
  end
end
concmd["states"] = {
  helptext = "gives a list of states",
  flags = {},
  fun = cmdStates,
}

function cmdCheckpoint(cmd)
  if not cmd[2] then return end
  globals.checkpoint = cmd[2]
end
concmd["checkpoint"] = {
  helptext = "set the checkpoint",
  flags = {"cheat"},
  fun = cmdCheckpoint,
}

function cmdCheckpoints(cmd)
  if megautils.state().sectionHandler then
    local result = {globals.checkpoint}
    megautils.state().sectionHandler:iterate(function(e)
        if e:is(checkpoint) and e.name ~= globals.checkpoint then
          result[#result+1] = e.name
        end
      end)
    for i=1, #result do
      console.print(result[i])
    end
  else
    console.print("This state does not have a section handler")
  end
end
concmd["checkpoints"] = {
  helptext = "gives a list of checkpoints",
  flags = {},
  fun = cmdCheckpoints,
}

function cmdGivehealth(cmd)
  if not cmd[2] then return end
  if globals.mainPlayer then
    globals.mainPlayer:hurt({globals.mainPlayer}, numberSanitize(cmd[2]), 1)
  end
end
concmd["givehealth"] = {
  helptext = "negatively and positively add to your health",
  flags = {"cheat"},
  fun = cmdGivehealth,
}

function cmdKill(cmd)
  if globals.mainPlayer then
    globals.mainPlayer:hurt({globals.mainPlayer}, -999, 1)
  end
end
concmd["kill"] = {
  helptext = "suicide",
  flags = {},
  fun = cmdKill,
}

function cmdGetpos(cmd)
  if globals.mainPlayer then
    console.print(tostring(globals.mainPlayer.transform.x)..", "..tostring(globals.mainPlayer.transform.y))
  end
end
concmd["getpos"] = {
  helptext = "print player position",
  flags = {},
  fun = cmdGetpos,
}

function cmdClear(cmd)
  console.lines = {}
end
concmd["clear"] = {
  helptext = "clear the screen and line history",
  flags = {},
  fun = cmdClear,
}

function cmdLockCheats(cmd)
  if convar.getValue("cheats") ~= 0 then
    convar.setValue("cheats", 0)
  end
  if convar.isValid("cheats") and not table.contains(convar["cheats"].flags, "cheat") then table.insert(convar["cheats"].flags, "cheat") end
end
concmd["lock_cheats"] = {
  helptext = "lock cheats for the rest of the game",
  flags = {},
  fun = cmdLockCheats,
}

function cmdGive(cmd)
  if globals.mainPlayer and cmd[2] then
    addobjects.add({{["name"]=cmd[2], ["x"]=globals.mainPlayer.transform.x+numberSanitize(cmd[3]),
          ["y"]=globals.mainPlayer.transform.y+numberSanitize(cmd[4])}})
  end
end
concmd["give"] = {
  helptext = "spawn registered entity",
  flags = {"cheat"},
  fun = cmdGive,
}

function cmdRunLua(cmd)
  if not cmd[2] then return end
  if not love.filesystem.getInfo(cmd[2]) then
    console.print("\""..cmd[2].."\" does not exist")
    return
  end
  love.filesystem.load(cmd[2])()
end
concmd["run_lua"] = {
  helptext = "run a lua file",
  flags = {"cheat"},
  fun = cmdRunLua,
}

function cmdExec(cmd)
  if not cmd[2] then return end
  if not love.filesystem.getInfo("cfg/"..cmd[2]..".cfg") then
    console.print("\""..cmd[2]..".cfg\" does not exist")
    return
  end
  local cfg = love.filesystem.lines("cfg/"..cmd[2]..".cfg")
  for line in cfg do
    --console.print(line)
    console.parse(line)
  end
end
concmd["exec"] = {
  helptext = "execute a config file",
  flags = {},
  fun = cmdExec,
}

function cmdFindcvar(cmd)
  for k, v in pairs(convar) do
    if convar.isValid(k) then
      console.print(k)
    end
  end
end
concmd["findcvar"] = {
  helptext = "find convars by substring",
  flags = {},
  fun = cmdFindcvar,
}

function cmdFindcmd(cmd)
  for k, v in pairs(concmd) do
    if concmd.isValid(k) then
      console.print(k)
    end
  end
end
concmd["findcmd"] = {
  helptext = "find concommands by substring",
  flags = {},
  fun = cmdFindcmd,
}

function cmdWait(cmd)
  console.wait = console.wait + 1
end
concmd["wait"] = {
  helptext = "delay console execution by 1 frame",
  flags = {},
  fun = cmdWait,
}

function cmdAlias(cmd)
  if not cmd[2] or not cmd[3] then return end
  console.aliases[cmd[2]] = cmd[3]
end
concmd["alias"] = {
  helptext = "alias a command",
  flags = {},
  fun = cmdAlias,
}