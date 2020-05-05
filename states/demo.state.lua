local demoState = states.state:extend()

function demoState:begin()
  if globals.reloadState then --Reload stage at all?
    if globals.manageStageResources then --Do stage resources need to be loaded?
      megautils.runFile("entities/demo/met.lua")
      megautils.runFile("entities/demo/moveacrossplatform.lua")
      megautils.runFile("entities/demo/stickman.lua")
      megautils.runFile("entities/mechanics/gravflip.lua")
    end
    
    local f, lp, lep, vol = "assets/sfx/music/cut.wav", 139666, 1830670, 0.8
    
    megautils.loadStage(self, "assets/maps/demo.tmx") --Load stage from .tmx
    megautils.add(ready, nil, globals.player[1] == "proto", {f, true, lp, lep, vol}) --READY
    megautils.add(fade, false, nil, nil, fade.ready) --Fade in from black
    if globals.player[1] ~= "proto" then --Play music after everything is set up. If the main player is Proto Man, then the READY object handles the music.
      megautils.playMusic(f, true, lp, lep, vol)
    end
  end
end

return demoState