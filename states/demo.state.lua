local demoState = states.state:extend()

function demoState:begin()
  -- Reload stage at all?
  if megautils.reloadState then
    -- Do stage resources need to be loaded?
    if megautils.manageStageResources then
      megautils.runFile("entities/demo/met.lua")
      megautils.runFile("entities/demo/moveacrossplatform.lua")
      megautils.runFile("entities/demo/stickman.lua")
      megautils.runFile("entities/mechanics/gravflip.lua")
    end
    
    local f, lp, lep, vol = "assets/sfx/music/cut.wav", 139666, 1830670, 0.8
    
    -- Load stage from `.tmx`...
    megautils.loadStage(self, "assets/maps/demo.tmx")
    -- READY
    megautils.add(ready, nil, globals.player[1] == "proto", {f, true, lp, lep, vol})
    -- Fade in from black
    megautils.add(fade, false, nil, nil, fade.ready)
    -- Play music after everything is set up. If the main player is Proto Man, then the READY object handles the music.
    if globals.player[1] ~= "proto" then
      megautils.playMusic(f, true, lp, lep, vol)
    end
  end
end

return demoState