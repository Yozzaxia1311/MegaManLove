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
    local musicTable = {f, true, lp, lep, vol}
    local ol, oi, ov = "assets/sfx/music/cut_loop.ogg", "assets/sfx/music/cut_intro.ogg", 0.8
    local musicTableOld = {ol, oi, ov}
    
    -- Load stage from `.tmx`...
    megautils.loadStage(self, "assets/maps/demo.tmx")
    -- READY
    megautils.add(ready, nil, (globals.player[1] == "proto") and (cutBackForWeb and "old" or "new"), cutBackForWeb and musicTableOld or musicTable)
    -- Fade in from black
    megautils.add(fade, false, nil, nil, fade.ready)
    -- Play music after everything is set up. If the main player is Proto Man, then the READY object handles the music.
    if globals.player[1] ~= "proto" then
      if cutBackForWeb then
        megautils.playMusicWithSeperateIntroFile(ol, oi, ov)
      else
        megautils.playMusic(f, true, lp, lep, vol)
      end
    end
  end
end

return demoState