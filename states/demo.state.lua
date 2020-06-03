local demoState = states.state:extend()

function demoState:begin()
  -- Reload stage at all?
  if megautils.reloadState then
    -- Do stage resources need to be loaded?
    if megautils.resetGameObjects then      
      megautils.loadResource("assets/misc/slopes/slopeLeft.png", "slopeLeft", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRight.png", "slopeRight", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftLong.png", "slopeLeftLong", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightLong.png", "slopeRightLong", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftInvert.png", "slopeLeftInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightInvert.png", "slopeRightInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftLongInvert.png", "slopeLeftLongInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightLongInvert.png", "slopeRightLongInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftHalf.png", "slopeLeftHalf", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightHalf.png", "slopeRightHalf", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftHalfInvert.png", "slopeLeftHalfInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightHalfInvert.png", "slopeRightHalfInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftHalfUpper.png", "slopeLeftHalfUpper", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightHalfUpper.png", "slopeRightHalfUpper", true, false)
      megautils.loadResource("assets/misc/slopes/slopeLeftHalfUpperInvert.png", "slopeLeftHalfUpperInvert", true, false)
      megautils.loadResource("assets/misc/slopes/slopeRightHalfUpperInvert.png", "slopeRightHalfUpperInvert", true, false)
      
      megautils.runFile("entities/mechanics/water.lua")
      megautils.runFile("entities/mechanics/ice.lua")
      megautils.runFile("entities/mechanics/gravflip.lua")
      
      megautils.runFile("entities/demo/met.lua")
      megautils.runFile("entities/demo/moveacrossplatform.lua")
      megautils.runFile("entities/demo/stickman.lua")
    end
    
    local f, lp, lep, vol = "assets/sfx/music/cut.wav", 139666, 1830670, 0.8
    local musicTable = {f, true, lp, lep, vol}
    local ol, oi, ov = "assets/sfx/music/cut_loop.ogg", "assets/sfx/music/cut_intro.ogg", 0.8
    local musicTableOld = {ol, oi, ov}
    
    -- Load stage from `.tmx`...
    megautils.loadStage(self, "assets/maps/demo.tmx")
    -- READY
    megautils.add(ready, nil, (globals.player[1] == "proto") and (isWeb and "old" or "new"), isWeb and musicTableOld or musicTable)
    -- Fade in from black
    megautils.add(fade, false, nil, nil, fade.ready)
    -- Play music after everything is set up. If the main player is Proto Man, then the READY object handles the music.
    if globals.player[1] ~= "proto" then
      if isWeb then
        megautils.playMusicWithSeperateIntroFile(ol, oi, ov)
      else
        megautils.playMusic(f, true, lp, lep, vol)
      end
    end
  end
end

return demoState