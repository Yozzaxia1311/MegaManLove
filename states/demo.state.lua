local demoState = states.state:extend()

function demoState:begin()
  if globals.resetState then --Reset stage? Usually set to false to prevent reloading the stage after pausing
    if globals.manageStageResources then --Do stage resources need to be loaded?
      loader.clear() --Clear assets just incase
      megautils.runFile("entities/demo/met.lua")
      megautils.runFile("entities/demo/moveacrossplatform.lua")
      megautils.runFile("entities/demo/stickman.lua")
    end
    
    local lf, inf = "assets/sfx/music/cutLoop.ogg", "assets/sfx/music/cutIntro.ogg"
    
    megautils.loadStage(self, "assets/maps/demo.tmx") --Load stage from .tmx
    megautils.add(ready, nil, globals.player[1] == "proto", lf, inf) --READY
    megautils.add(fade, false, nil, nil, fade.ready) --Fade in from black
    if globals.player[1] ~= "proto" then
      mmMusic.playFromFile(lf, inf) --Play music after everything is set up
    end
  end
end

function demoState:update(dt)
  megautils.update(self, dt)
end

function demoState:stop()
  megautils.unload()
end

function demoState:draw()
  megautils.draw(self)
end

--Calling code when the stage resets:
--megautils.resetStateFuncs.nameHere = function() CODE HERE end
--Calling code when unloading assets:
--megautils.cleanFuncs.nameHere = function() CODE HERE end

return demoState