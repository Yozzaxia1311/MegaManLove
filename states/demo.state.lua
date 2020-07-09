local demoStage = states.stageState:extend()

function demoStage:begin()
  -- Reload stage at all?
  if megautils.reloadState then
    -- Do stage resources need to be loaded?
    if megautils.resetGameObjects then      
      megautils.runFile("entities/demo/met.lua")
      megautils.runFile("entities/demo/moveacrossplatform.lua")
      megautils.runFile("entities/demo/stickman.lua")
    end
    
    local f, lp, lep, vol = "assets/sfx/music/cut.wav", 139666, 1830670, 0.8
    local musicTable = {f, true, lp, lep, vol}
    local ol, oi, ov = "assets/sfx/music/cutLoop.ogg", "assets/sfx/music/cutIntro.ogg", 0.8
    local musicTableOld = {ol, oi, ov}
    
    -- Load stage from `.tmx` and add it and it's objects...
    megautils.addMapEntity("assets/maps/demo.tmx"):addObjects()
    -- READY
    megautils.add(ready, nil, (megaMan.mainPlayer.playerName == "proto") and (isWeb and "old" or "new"), isWeb and musicTableOld or musicTable)
    -- Fade in from black
    megautils.add(fade, false, nil, nil, fade.ready)
    -- Play music after everything is set up. If the main player is Proto Man, then the READY object handles the music.
    if megaMan.mainPlayer.playerName ~= "proto" then
      if isWeb then
        megautils.playMusicWithSeperateIntroFile(ol, oi, ov)
      else
        megautils.playMusic(f, true, lp, lep, vol)
      end
    end
  end
end

return demoStage