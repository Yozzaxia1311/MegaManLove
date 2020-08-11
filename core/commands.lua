convar["cheats"] = {
  helptext = "enable cheats",
  flags = {},
  value = 0,
}
convar["fullscreen"] = {
  helptext = "fullscreen mode",
  flags = {"client"},
  value = 0,
  fun = function(arg) local n = numberSanitize(arg) love.window.setFullscreen(n == 1) end
}
convar["fps"] = {
  helptext = "fps",
  flags = {"cheat", "client"},
  value = defaultFPS,
}
convar["volume"] = {
  helptext = "game volume",
  flags = {"client"},
  value = 1,
  fun = function(arg)
    local n = math.clamp(numberSanitize(arg), 0, 1)
    convar.setValue("volume", n, false)
    love.audio.setVolume(n)
  end
}
convar["showcollision"] = {
  helptext = "draw hitboxes",
  flags = {"cheat", "client"},
  value = 0,
  fun = function(arg) local n = numberSanitize(arg) entitySystem.drawCollision = n == 1 end
}

convar["showfps"] = {
  helptext = "draw framerate",
  flags = {"client"},
  value = 0
}

convar["showentitycount"] = {
  helptext = "draw entity count",
  flags = {"cheats", "client"},
  value = 0
}

convar["infinitelives"] = {
  helptext = "never gameover",
  flags = {"cheat"},
  value = 0
}

convar["inv"] = {
  helptext = "invicibility",
  flags = {"cheat"},
  value = 0
}

convar["noclip"] = {
  helptext = "pass through everything",
  flags = {"cheat"},
  value = 0
}

convar["etanks"] = {
  helptext = "e-tanks in possession",
  flags = {"cheat"},
  value = 0
}

convar["wtanks"] = {
  helptext = "w-tanks in possession",
  flags = {"cheat"},
  value = 0
}

convar["lives"] = {
  helptext = "number of lives",
  flags = {"cheat"},
  value = 2
}

convar["diff"] = {
  helptext = "difficulty (easy, normal, hard, etc.)",
  flags = {"cheat"},
  value = "normal",
  fun = function(arg)
      for k, v in pairs(megautils.difficultyChangeFuncs) do
        v(arg, convar.getValue("diff"))
      end
    end
}

convar["scale"] = {
  helptext = "set scale of the window",
  flags = {"client"},
  value = math.ceil(love.graphics.getWidth() / view.w),
  fun = function(arg)
      local n = math.ceil(numberSanitize(arg))
      local w, h = love.graphics.getDimensions()
      
      if n <= 0 then
        convar.setValue("scale", convar.getValue("scale"), false)
        console.print("window scale must be a positive integer")
      else
        if view.w * n ~= love.graphics.getWidth() or view.h * n ~= love.graphics.getHeight() then
          local width, height = love.graphics.getDimensions()
          love.window.updateMode(n * view.w, n * view.h)
        end
      end
    end
}

concmd["help"] = {
  helptext = "get info about commands",
  flags = {},
  fun = function(cmd)
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
}

concmd["setskin"] = {
  helptext = "sets the skin for a player",
  flags = {},
  fun = function(cmd)
      if not cmd[2] or not cmd[3] then return end
      local player = numberSanitize(cmd[2])
      local path = cmd[3]
      local dir, file = love.filesystem.getInfo(path), love.filesystem.getInfo(path .. ".zip")
      if dir or file then
        if dir then
          if #megaMan.allPlayers > 0 then
            for k, v in ipairs(megaMan.allPlayers) do
              v:setSkin(path)
            end
          else
            megaMan.setSkin(player, path)
          end
        else
          if #megaMan.allPlayer > 0 then
            for k, v in ipairs(megaMan.allPlayers) do
              v:setSkin(path .. ".zip")
            end
          else
            megaMan.setSkin(player, path .. ".zip")
          end
        end
      else
        console.print("No such skin \"" .. path .. "\"")
      end
    end
}

concmd["rec"] = {
  helptext = "record after the state switches",
  flags = {},
  fun = function(cmd)
      if states.recordOnSwitch then
        states.recordOnSwitch = false
        console.print("Recording disabled")
      else
        states.recordOnSwitch = true
        console.print("Recording on state switch...")
      end
    end
}

concmd["recend"] = {
  helptext = "stop recording",
  flags = {},
  fun = function(cmd)
      control.recordInput = false
      console.print("Recording ended")
      console.print("Remember to save with recsave")
    end
}

concmd["recsave"] = {
  helptext = "save recording",
  flags = {},
  fun = function(cmd)
      if not cmd[2] then return end
      if not control.recordInput and table.length(control.record) > 0 then
        control.recordName = cmd[2]
        control.finishRecord()
        console.print("Recording saved")
      else
        console.print("No recording ready to save")
      end
    end
}

concmd["recdel"] = {
  helptext = "delete recording",
  flags = {},
  fun = function(cmd)
      if not cmd[2] then return end
      if not love.filesystem.getInfo(cmd[2] .. ".rd") then
        console.print("No such record file \""..cmd[2].."\"")
      else
        love.filesystem.remove(cmd[2] .. ".rd")
        console.print("Recording deleted")
      end
    end
}

concmd["recopen"] = {
  helptext = "open recording file",
  flags = {},
  fun = function(cmd)
      if not cmd[2] then return end
      if love.filesystem.getInfo(cmd[2] .. ".rd") then
        states.openRecord = cmd[2] .. ".rd"
        megautils.add(fade, true, nil, nil, function(s)
              megautils.gotoState(nil, nil, function()
                  megautils.stopMusic()
                  love.audio.stop()
                  control.updateDemoFunc = function()
                      return console.state == 1
                    end
                end)
            end)
        console.close()
        console.y = -112*2
      else
        console.print("No such record file \""..cmd[2].."\"")
      end
    end
}

concmd["defbinds"] = {
  helptext = "load default input binds",
  flags = {"client"},
  fun = function(cmd)
      control.defaultBinds()
      console.print("Now using default input binds")
    end
}

concmd["opendir"] = {
  helptext = "open save directory",
  flags = {"client"},
  fun = function(cmd) love.system.openURL(love.filesystem.getSaveDirectory()) end
}

concmd["recs"] = {
  helptext = "gives a list of recordings",
  flags = {},
  fun = function(cmd)
      local check
      if cmd[2] then
        check = cmd[2]
        if not love.filesystem.getInfo(check) then console.print("No such directory \""..cmd[2].."\"") return end
      end
      local result = iterateDirs(function(f)
          return f:sub(-3) == ".rd"
        end, check)
      if #result == 0 then
        if check then
          console.print("No recordings in directory \""..cmd[2].."\"")
        else
          console.print("No recordings exist")
        end
        return
      end
      for i=1, #result do
        console.print(result[i]:sub(1, -4))
      end
    end
}

concmd["echo"] = {
  helptext = "print to console",
  flags = {},
  fun = function(cmd)
      if not cmd[2] then return end
      local result = ""
      for i=2, #cmd do
        result = result .. cmd[i]
        if i ~= #cmd then
          result = result .. " "
        end
      end
      console.print(result)
    end
}

concmd["quit"] = {
  helptext = "quit the game",
  flags = {},
  fun = function() love.event.quit() end,
}

concmd["state"] = {
  helptext = "load a state",
  flags = {"cheat"},
  fun = function(cmd)
      if not cmd[2] then return end
      local map
      if love.filesystem.getInfo(cmd[2] .. ".state.lua") then
        map = cmd[2] .. ".state.lua"
      elseif love.filesystem.getInfo(cmd[2] .. ".state.tmx") then
        map = cmd[2] .. ".state.tmx"
      elseif love.filesystem.getInfo(cmd[2] .. ".stage.lua") then
        map = cmd[2] .. ".stage.lua"
      elseif love.filesystem.getInfo(cmd[2] .. ".stage.tmx") then
        map = cmd[2] .. ".stage.tmx"
      end
      if not map then console.print("No such state \""..cmd[2].."\"") return end
      love.audio.stop()
      megautils.stopMusic()
      megautils.resetGameObjects = true
      megautils.reloadState = true
      if cmd[3] then globals.overrideCheckpoint = cmd[3] end
      megautils.gotoState(map)
    end
}

concmd["resetstate"] = {
  helptext = "reset current state",
  flags = {"cheat"},
  fun = function(cmd)
      love.audio.stop()
      megautils.stopMusic()
      megautils.resetGameObjects = true
      megautils.reloadState = true
      if cmd[2] then globals.overrideCheckpoint = cmd[2] end
      megautils.gotoState(megautils.getCurrentState())
    end
}

concmd["states"] = {
  helptext = "gives a list of states",
  flags = {},
  fun = function(cmd)
      local check
      if cmd[2] then
        check = cmd[2]
        if not love.filesystem.getInfo(check) then console.print("No such directory \""..cmd[2].."\"") return end
      end
      local result = iterateDirs(function(f)
          return f:sub(-10) == ".state.lua" or f:sub(-10) == ".state.tmx" or f:sub(-10) == ".stage.lua" or f:sub(-10) == ".stage.tmx"
        end, check)
      if #result == 0 then
        if check then
          console.print("No states in directory \""..cmd[2].."\"")
        else
          console.print("No states exist")
        end
        return
      end
      for i=1, #result do
        console.print(result[i]:sub(1, -11))
      end
    end
}

concmd["checkpoint"] = {
  helptext = "set the checkpoint",
  flags = {"cheat"},
  fun = function(cmd)
      if not cmd[2] then return end
      globals.checkpoint = cmd[2]
    end
}

concmd["checkpoints"] = {
  helptext = "gives a list of checkpoints",
  flags = {"cheat"},
  fun = function(cmd)
      local result = {globals.checkpoint}
      section.iterate(function(e)
          if e:is(checkpoint) and e.name ~= globals.checkpoint then
            result[#result+1] = e.name
          end
        end)
      for i=1, #result do
        console.print(result[i])
      end
    end
}

concmd["hurt"] = {
  helptext = "hurt all players",
  flags = {"cheat"},
  fun = function(cmd)
      if not cmd[2] then return end
      for i=1, #megaMan.allPlayers do
        megaMan.allPlayers[i].iFrames = 0
        megaMan.allPlayers[i]:interact({megaMan.allPlayers[i]}, -numberSanitize(cmd[2]))
      end
    end
}

concmd["grav"] = {
  helptext = "set gravity multiplier",
  flags = {"cheat"},
  fun = function(cmd)
      if not cmd[2] then return end
      for i=1, #megaMan.allPlayers do
        megaMan.allPlayers[i]:setGravityMultiplier("global", numberSanitize(cmd[2]))
      end
    end
}

concmd["flip"] = {
  helptext = "flip gravity",
  flags = {"cheat"},
  fun = function(cmd)
      for i=1, #megaMan.allPlayers do
        megaMan.allPlayers[i]:setGravityMultiplier("gravityFlip", -megaMan.allPlayers[i].gravityMultipliers.gravityFlip)
        if i == 1 then
          if megautils.getResource("gravityFlip") then
            megautils.playSound("gravityFlip")
          else
            megautils.playSoundFromFile("assets/sfx/gravityFlip.ogg")
          end
        end
      end
    end
}

concmd["kill"] = {
  helptext = "kill all players",
  flags = {},
  fun = function(cmd)
      for i=1, #megaMan.allPlayers do
        megaMan.allPlayers[i].iFrames = 0
        megaMan.allPlayers[i]:interact(megaMan.allPlayers[i], -9999, nil)
      end
    end
}

concmd["getpos"] = {
  helptext = "print player position",
  flags = {},
  fun = function(cmd)
      if megaMan.mainPlayer then
        console.print(tostring(megaMan.mainPlayer.transform.x) .. ", " .. tostring(megaMan.mainPlayer.transform.y))
      end
    end
}

concmd["clear"] = {
  helptext = "clear the screen and line history",
  flags = {},
  fun = function(cmd) console.lines = {} end
}

concmd["lockcheats"] = {
  helptext = "lock cheats for the rest of the game",
  flags = {},
  fun = function(cmd)
      if convar.getValue("cheats") ~= 0 then
        convar.setValue("cheats", 0)
      end
      if convar.isValid("cheats") and not table.contains(convar["cheats"].flags, "cheat") then
        table.insert(convar["cheats"].flags, "cheat")
      end
    end
}

concmd["give"] = {
  helptext = "spawn entity",
  flags = {"cheat"},
  fun = function(cmd)
      if megaMan.mainPlayer and cmd[2] then
        if _G[cmd[2]] then
          local args = {_G[cmd[2]]}
          for i=3, #cmd do
            if cmd[i]:match("playerx") then
              local st, en = cmd[i]:find("playerx")
              local v = cmd[i]:sub(en+1, cmd[i]:len())
              args[#args+1] = megaMan.mainPlayer.transform.x+numberSanitize(v)
            elseif cmd[i]:match("playery") then
              local st, en = cmd[i]:find("playery")
              local v = cmd[i]:sub(en+1, cmd[i]:len())
              args[#args+1] = megaMan.mainPlayer.transform.y+numberSanitize(v)
            else
              args[#arg+1] = tonumber(cmd[i]) or toboolean(cmd[i]) or cmd[i]
            end
          end
          megautils.add(unpack(args))
        else
          console.print("Entity \"" .. cmd[2] .. "\" does not exist in global context.")
        end
      end
    end
}

concmd["runlua"] = {
  helptext = "run a lua file",
  flags = {"cheat"},
  fun = function(cmd)
      if not cmd[2] then return end
      if not love.filesystem.getInfo(cmd[2] .. ".lua") then
        console.print("\""..cmd[2]..".lua\" does not exist")
        return
      end
      love.filesystem.load(cmd[2])()
    end
}

concmd["reset"] = {
  helptext = "reset the game",
  flags = {},
  fun = function(cmd) megautils.resetGame() end
}

concmd["exec"] = {
  helptext = "execute a config file",
  flags = {},
  fun = function(cmd)
      if not cmd[2] then return end
      if not love.filesystem.getInfo(cmd[2]..".cfg") then
        console.print("\""..cmd[2]..".cfg\" does not exist")
        return
      end
      local cfg = love.filesystem.lines(cmd[2]..".cfg")
      for line in cfg do
        console.parse(line)
      end
    end
}

concmd["findcvar"] = {
  helptext = "gives a list of console variables",
  flags = {},
  fun = function(cmd)
      local result = {}
      local cut = 1
      local step = 0
      for k, v in pairs(convar) do
        if convar.isValid(k) then
          if not result[cut] then result[cut] = "" end
          result[cut] = result[cut] .. (result[cut] == "" and "" or ", ") .. k
          step = step + 1
          if step == 4 then
            step = 0
            cut = cut + 1
          end
        end
      end
      for k, v in ipairs(result) do
        if k ~= #result then
          result[k] = result[k] .. ","
        end
      end
      for k, v in ipairs(result) do
        console.print(v)
      end
    end
}

concmd["findcmd"] = {
  helptext = "gives a list of console commands",
  flags = {},
  fun = function(cmd)
      local result = {}
      local cut = 1
      local step = 0
      for k, v in pairs(concmd) do
        if concmd.isValid(k) then
          if not result[cut] then result[cut] = "" end
          result[cut] = result[cut] .. (result[cut] == "" and "" or ", ") .. k
          step = step + 1
          if step == 4 then
            step = 0
            cut = cut + 1
          end
        end
      end
      for k, v in ipairs(result) do
        if k ~= #result then
          result[k] = result[k] .. ","
        end
      end
      for k, v in ipairs(result) do
        console.print(v)
      end
    end
}

concmd["wait"] = {
  helptext = "delay console execution by n frames",
  flags = {},
  fun = function(cmd)
    if not cmd[2] then 
      console.wait = console.wait + 1 
    else
      console.wait = console.wait + numberSanitize(cmd[2])
    end
  end
}

concmd["alias"] = {
  helptext = "alias a command",
  flags = {},
  fun = function(cmd)
      if not cmd[2] or not cmd[3] then return end
      console.aliases[cmd[2]] = cmd[3]
    end
}