local demostate = states.state:extend()

function demostate:begin()
  if globals.resetState then --Reset stage? Usually set to false to prevent reloading the stage after pausing
    if globals.manageStageResources then --Do stage resources need to be loaded?
      loader.clear() --Clear assets just incase
      loader.load("assets/demo_objects.png", "demo_objects", "texture")
      megautils.runFile("entities/met.lua")
      megautils.runFile("entities/moveAcrossPlatform.lua")
      megautils.runFile("entities/stickman.lua")
    end 
    megautils.loadStage(self, "assets/demo.lua") --Load lua exported tmx stage
    megautils.add(ready()) --READY
    megautils.add(fade(false):setAfter(fade.ready)) --Fade in from black
    mmMusic.playFromFile("assets/cut_loop.ogg", "assets/cut_intro.ogg") --Play music after everything is set up
  end
end

function demostate:update(dt)
  megautils.update(self, dt)
end

function demostate:stop()
  megautils.unload(self) 
end

function demostate:draw()
  megautils.draw(self)
end

--Calling code when the stage resets:
--megautils.resetStateFuncs["name_here"] = function() CODE HERE end
--Calling code when unloading assets:
--megautils.cleanFuncs["name_here"] = function() CODE HERE end

return demostate