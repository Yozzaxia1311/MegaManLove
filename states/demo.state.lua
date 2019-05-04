local demostate = states.state:extend()

function demostate:begin()
  if globals.resetState then --Reset stage? Usually set to false to prevent reloading the stage after pausing
    if globals.manageStageResources then --Do stage resources need to be loaded?
      loader.clear() --Clear assets just incase
      loader.load("assets/global/entities/demo_objects.png", "demo_objects", "texture")
      megautils.runFile("entities/demo/met.lua")
      megautils.runFile("entities/demo/moveAcrossPlatform.lua")
      megautils.runFile("entities/demo/stickman.lua")
      if megautils.networkGameStarted and megautils.networkMode == "server" then
        megautils.net:sendToAll("l", {p="assets/global/entities/demo_objects.png", n="demo_objects", t="texture"})
        megautils.net:sendToAll("rf", "entities/demo/met.lua")
        megautils.net:sendToAll("rf", "entities/demo/moveAcrossPlatform.lua")
        megautils.net:sendToAll("rf", "entities/demo/stickman.lua")
      end
    end 
    megautils.loadStage(self, "assets/maps/demo.lua") --Load lua exported tmx stage
    local id = megautils.nextID()
    megautils.add(ready, {nil, id}) --READY
    if megautils.networkMode == "server" and megautils.networkGameStarted then
      megautils.sendEntityToClients(client_ready, {nil, id})
    end
    id = megautils.nextID()
    megautils.add(fade, {false, nil, nil, fade.ready, id}) --Fade in from black
    if megautils.networkMode == "server" and megautils.networkGameStarted then
      megautils.sendEntityToClients(client_fade, {false, nil, id})
    end
    mmMusic.playFromFile("assets/sfx/music/cut_loop.ogg", "assets/sfx/music/cut_intro.ogg") --Play music after everything is set up
    if megautils.networkGameStarted and megautils.networkMode == "server" then
      --megautils.net:sendToAll("m", {l=loop, i=intro, v=vol})
    end
  end
end

function demostate:update(dt)
  megautils.update(self, dt)
end

function demostate:stop()
  megautils.unload()
  if megautils.networkGameStarted and megautils.networkMode == "server" then
    megautils.net:sendToAll("u", {rs=true, msr=true})
  end
end

function demostate:draw()
  megautils.draw(self)
end

--Calling code when the stage resets:
--megautils.resetStateFuncs["name_here"] = function() CODE HERE end
--Calling code when unloading assets:
--megautils.cleanFuncs["name_here"] = function() CODE HERE end

return demostate