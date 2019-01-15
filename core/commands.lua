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

-- not sure exactly how to implement this cleanly with the state/stage system
function cmdMap(cmd)
	if not cmd[2] then return end
	local map
	for k, v in pairs(love.filesystem.getDirectoryItems("states/stages")) do
		if v:sub(1, 1) ~= '.' and v:sub(#v-3, #v) == ".lua" then
			if v:sub(1, -5) == cmd[2] then
				map = v
			end
		end
	end
	if map == nil then console.print("No such map \""..cmd[2].."\"") return end
	megautils.gotoState("states/stages/"..map, function()
    globals.resetState = true
    megautils.resetGameObjects()
    mmMusic.stopMusic()
  end)
end
concmd["map"] = {
	helptext = "load a map",
	flags = {},
	fun = cmdMap,
}

function cmdMaps(cmd)
	for k, v in pairs(love.filesystem.getDirectoryItems("states/stages")) do
		if v:sub(1, 1) ~= '.' and v:sub(#v-3, #v) == ".lua" then
			console.print(v:sub(1, -5))
		end
	end
end
concmd["maps"] = {
	helptext = "list maps",
	flags = {},
	fun = cmdMaps,
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

function cmdGive(cmd)
  if globals.mainPlayer and cmd[2] then
    addobjects.add({{["name"]=cmd[2], ["x"]=globals.mainPlayer.transform.x+numberSanitize(cmd[3]),
      ["y"]=globals.mainPlayer.transform.y+numberSanitize(cmd[4])}})
  end
end
concmd["give"] = {
  helptext = "spawn registered entity",
  flags = {},
  fun = cmdGive,
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
