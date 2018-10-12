local demostate = states.state:extend()

function demostate:begin()
  if globals.resetState then --Reset stage? Usually set to false to prevent reloading the stage after pausing
    if globals.manageStageResources then --Do stage resources need to be loaded?
      loader.clear() --Clear assets just incase
      loader.load("assets/global/objects/demo/demo_objects.png", "demo_objects", "texture")
      loader.load("assets/global/objects/bosses/stick_man.png", "stick_man", "texture")
      love.filesystem.load("entities/enemies/demo/met.lua")()
      love.filesystem.load("entities/mechanics/demo/moveAcrossPlatform.lua")()
      love.filesystem.load("entities/enemies/bosses/stickman.lua")()
    end 
    megautils.loadStage(self, "assets/maps/demo.lua") --Load lua exported tmx stage
    megautils.add(ready()) --READY
    megautils.add(fade(false):setAfter(fade.ready)) --Fade in from black
    mmMusic.playFromFile("assets/sfx/music/cut_loop.ogg", "assets/sfx/music/cut_intro.ogg") --Play music after everything is set up
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