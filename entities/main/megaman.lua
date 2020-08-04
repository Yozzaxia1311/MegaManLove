megaMan = entity:extend()

megaMan.mainPlayer = nil
megaMan.allPlayers = {}
megaMan.resources = {}

megaMan.resources.megaMan = function()
    megautils.loadResource("assets/players/megaman/megaManOne.png", "megaManOne")
    megautils.loadResource("assets/players/megaman/megaManTwo.png", "megaManTwo")
    megautils.loadResource("assets/players/megaman/megaManOutline.png", "megaManOutline")
    megautils.loadResource("assets/players/megaman/megaManFace.png", "megaManFace")
    megautils.loadResource("assets/sfx/mmLand.ogg", "land")
    megautils.loadResource("assets/sfx/mmHurt.ogg", "hurt")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/mmHeal.ogg", "heal")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/sfx/switch.ogg", "switch")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource(41, 30, "megaManGrid")
  end

megaMan.resources.protoMan = function()
    megautils.loadResource("assets/players/proto/protoManOne.png", "protoManOne")
    megautils.loadResource("assets/players/proto/protoManTwo.png", "protoManTwo")
    megautils.loadResource("assets/players/proto/protoManOutline.png", "protoManOutline")
    megautils.loadResource("assets/players/proto/protoManFace.png", "protoManFace")
    megautils.loadResource("assets/sfx/mmLand.ogg", "land")
    megautils.loadResource("assets/sfx/mmHurt.ogg", "hurt")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/mmHeal.ogg", "heal")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/sfx/switch.ogg", "switch")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge")
    megautils.loadResource(41, 30, "megaManGrid")
  end

megaMan.resources.bass = function()
    megautils.loadResource("assets/players/bass/bassOne.png", "bassOne")
    megautils.loadResource("assets/players/bass/bassTwo.png", "bassTwo")
    megautils.loadResource("assets/players/bass/bassOutline.png", "bassOutline")
    megautils.loadResource("assets/players/bass/bassFace.png", "bassFace")
    megautils.loadResource("assets/sfx/mmLand.ogg", "land")
    megautils.loadResource("assets/sfx/mmHurt.ogg", "hurt")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/mmHeal.ogg", "heal")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/sfx/switch.ogg", "switch")
    megautils.loadResource("assets/sfx/treble.ogg", "trebleStart")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource(45, 41, "bassGrid")
  end

megaMan.resources.roll = function()
    megautils.loadResource("assets/players/roll/rollOne.png", "rollOne")
    megautils.loadResource("assets/players/roll/rollTwo.png", "rollTwo")
    megautils.loadResource("assets/players/roll/rollOutline.png", "rollOutline")
    megautils.loadResource("assets/players/roll/rollFace.png", "rollFace")
    megautils.loadResource("assets/sfx/mmLand.ogg", "land")
    megautils.loadResource("assets/sfx/mmHurt.ogg", "hurt")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/mmHeal.ogg", "heal")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource("assets/sfx/switch.ogg", "switch")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource(45, 34, "rollGrid")
  end

megautils.reloadStateFuncs.megaMan = function()
    megaMan.once = nil
  end

megautils.cleanFuncs.megaMan = function()
    megaMan.mainPlayer = nil
    megaMan.allPlayers = {}
  end

megautils.resetGameObjectsFuncs.megaMan = function()
    megaMan.colorOutline = {}
    megaMan.colorOne = {}
    megaMan.colorTwo = {}
    megaMan.weaponHandler = {}
    megaMan.mainPlayer = nil
    megaMan.allPlayers = {}
    megaMan.once = nil
    megautils.setLives((megautils.getLives() > globals.startingLives) and megautils.getLives() or globals.startingLives)
    
    globals.checkpoint = globals.overrideCheckpoint or "start"
    globals.overrideCheckpoint = nil
    
    mmWeaponsMenu.resources()
    
    for i=1, globals.playerCount do
      megaMan.weaponHandler[i] = weaponHandler(nil, nil, 10)
      megaMan.loadPlayer(i)
      
      for k, v in pairs(globals.defeats) do
        if type(v) == "table" then
          megaMan.weaponHandler[i]:register(v.weaponSlot or 1,
            v.weaponName or "WEAPON",
            {v.activeQuad or quad(16, 32, 16, 16), v.inactiveQuad or quad(32, 32, 16, 16)},
            v.oneColor or {255, 255, 255},
            v.twoColor or {188, 188, 188},
            v.outlineColor or {0, 0, 0})
        end
      end
    end
    
    megaMan.individualLanded = {}
  end

megautils.postAddObjectsFuncs.megaMan = function()
    if megaMan.mainPlayer and megaMan.mainPlayer.ready then
      megautils.freeze(nil, "ready")
    end
  end

megautils.difficultyChangeFuncs.megaMan = function(d)
    if d == "easy" then
      self.jumpAnimation.ps = "jumpProtoShield2"
      self.protoShieldLeftCollision = {x=-7, y=0, w=8, h=20, goy=2}
      self.protoShieldRightCollision = {x=10, y=0, w=8, h=20, goy=2}
    else
      self.jumpAnimation.ps = "jumpProtoShield"
      self.protoShieldLeftCollision = {x=-7, y=0, w=8, h=14, goy=8}
      self.protoShieldRightCollision = {x=10, y=0, w=8, h=14, goy=8}
    end
  end

addObjects.register("player", function(v)
    if megaMan.once then return end
    if v.properties.checkpoint == globals.checkpoint and not camera.once then
      camera.once = true
      megautils.add(camera, v.x, v.y, v.properties.doScrollX, v.properties.doScrollY)
    end
  end, -1, true)

addObjects.register("player", function(v)
    if megaMan.once then return end
    if v.properties.checkpoint == globals.checkpoint and camera.main and camera.once then
      camera.main:setRectangleCollision(8, 8)
      if v.properties.name then
        camera.main.curBoundName = v.properties.name
      end
      camera.main:updateBounds()
      camera.main:setRectangleCollision(view.w, view.h)
      camera.main:doView(999, 999)
      camera.once = nil
    end
  end, 3, true)

addObjects.register("player", function(v)
    if megaMan.once then return end
    if v.properties.checkpoint == globals.checkpoint then
      local g = v.properties.gravMult * v.properties.gravFlip
      if v.properties.individual and v.properties.individual > 0 then
        if v.properties.individual <= globals.playerCount then
          megaMan.individualLanded[#megaMan.individualLanded+1] = v.properties.individual
          megautils.add(megaMan, v.x+2, v.y+((g >= 0) and -5 or 0),
            v.properties.side, v.properties.draw, v.properties.individual, v.properties.gravMult, v.properties.gravFlip, v.properties.control)
        end
      else
        for i=1, globals.playerCount do
          if not table.contains(v.properties.individual, i) then
            megautils.add(megaMan, v.x+2, v.y+((g >= 0) and -5 or 0),
              v.properties.side, v.properties.drop, i, v.properties.gravMult, v.properties.gravFlip, v.properties.control)
          end
        end
      end
    end
  end, 0, true)

function megaMan.properties(self, g, gf, c)
  self.gravityType = 0
  self.normalGravity = 0.25
  self:setGravityMultiplier("global", g or 1)
  self:setGravityMultiplier("gravityFlip", gf or 1)
  self.maxChargeTime = 50
  self.jumpSpeed = -5.25
  self.jumpDecel = 5.25
  self.maxLeftSpeed = -1.3
  self.maxRightSpeed = 1.3
  self.leftSpeed = -1.3
  self.rightSpeed = 1.3
  self.leftDecel = 1.3
  self.rightDecel = 1.3
  self.maxLeftAirSpeed = -1.3
  self.maxRightAirSpeed = 1.3
  self.leftAirSpeed = -1.3
  self.rightAirSpeed = 1.3
  self.leftAirDecel = 1.3
  self.rightAirDecel = 1.3
  self.maxAirSpeed = 7
  self.wallKickSpeed = 1
  self.wallJumpSpeed = -4.725
  self.slideLeftSpeed = -2.5
  self.slideRightSpeed = 2.5
  self.dashJumpMultiplier = 1
  self.maxSlideTime = 26
  self.climbUpSpeed = -1.3
  self.climbDownSpeed = 1.3
  self.stepLeftSpeed = -1
  self.stepRightSpeed = 1
  self.maxStepTime = 8
  self.maxHitTime = 32
  self.leftKnockBackSpeed = -0.5
  self.rightKnockBackSpeed = 0.5
  self.maxShootTime = 14
  self.maxWallJumpTime = 8
  self.wallSlideSpeed = 0.5
  self.maxNormalBusterShots = 3
  self.cameraOffsetX = 0
  self.cameraOffsetY = 0
  self.cameraWidth = 11
  self.cameraHeight = 21
  self.dropSpeed = 8
  self.riseSpeed = -8
  self.maxBubbleTime = 120
  self.blockCollision.global = true
  self.maxStandSolidJumpTime = 4
  self.maxExtraJumps = 0
  self.maxRapidShotTime = 5
  self.maxTrebleSpeed = 2
  self.trebleDecel = 0.1
  if megautils.diff("easy") then
    self.protoShieldLeftCollision = {x=-7, y=0, w=8, h=20, goy=2}
    self.protoShieldRightCollision = {x=10, y=0, w=8, h=20, goy=2}
  else
    self.protoShieldLeftCollision = {x=-7, y=0, w=8, h=14, goy=8}
    self.protoShieldRightCollision = {x=10, y=0, w=8, h=14, goy=8}
  end
  self.canJumpOutFromDash = {global=true}
  self.canBackOutFromDash = {global=true}
  self.canSwitchWeapons = {global=true}
  self.canStandSolid = {global=true}
  self.canPause = {global=true}
  self.canDieFromSpikes = {global=true}
  self.canDashShoot = {global=false}
  self.canDashJump = {global=false}
  self.canDash = {global=true}
  self.canShoot = {global=true}
  self.canChargeBuster = {global=true}
  self.canWalk = {global=true}
  self.canJump = {global=true}
  self.canHaveCameraFocus = {global=true}
  self.canHaveThreeWeaponIcons = {global=false}
  self.canBeInvincible = {global=false}
  self.canGetCrushed = {global=false}
  self.canStopJump = {global=true}
  self.canStep = {global=true}
  self.canIgnoreKnockback = {global=false}
  self.canProtoShield = {global=false}
  self.canControl = {global=(c == nil) or c}
end

function megaMan:loadPlayer(name)
  local i = (type(self) == "number") and self or self.player
  local n = name or megautils.getPlayer(i)
  
  if n == "proto" then
    megaMan.resources.protoMan()
        
    megaMan.weaponHandler[i]:register(0, "P.BUSTER", {quad(48, 32, 16, 16), quad(64, 32, 16, 16)},
      {216, 40, 0}, {184, 184, 184}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(9, "PROTO C.", {quad(176, 0, 16, 16), quad(192, 0, 16, 16)},
      {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(10, "PROTO JET", {quad(176, 16, 16, 16), quad(192, 16, 16, 16)},
      {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    
  elseif n == "bass" then
    megaMan.resources.bass()
    
    megaMan.weaponHandler[i]:register(0, "B.BUSTER", {quad(144, 32, 16, 16), quad(160, 32, 16, 16)},
      {112, 112, 112}, {248, 152, 56}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(10, "T. BOOST", {quad(144, 16, 16, 16), quad(160, 16, 16, 16)},
      {112, 112, 112}, {128, 0, 240}, {0, 0, 0})
    
  elseif n == "roll" then
    megaMan.resources.roll()
    
    megaMan.weaponHandler[i]:register(0, "R.BUSTER", {quad(80, 32, 16, 16), quad(96, 32, 16, 16)},
      {248, 56, 0}, {0, 168, 0}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(9, "TANGO C.", {quad(208, 0, 16, 16), quad(224, 0, 16, 16)},
      {0, 168, 0}, {255, 255, 255}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(10, "TANGO JET", {quad(208, 16, 16, 16), quad(224, 16, 16, 16)},
      {0, 168, 0}, {255, 255, 255}, {0, 0, 0})
    
  else
    megaMan.resources.megaMan()
    
    megaMan.weaponHandler[i]:register(0, "M.BUSTER", {quad(16, 32, 16, 16), quad(32, 32, 16, 16)},
      {0, 120, 248}, {0, 232, 216}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(9, "RUSH C.", {quad(144, 0, 16, 16), quad(160, 0, 16, 16)},
      {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    
    megaMan.weaponHandler[i]:register(10, "RUSH JET", {quad(112, 32, 16, 16), quad(128, 32, 16, 16)},
      {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    
  end
end

function megaMan:switchCharacter(n)
  if self.playerName ~= n then
    self.playerName = n
    self:loadPlayer(self.playerName)
  end
  
  local pp = "megaManGrid"
  
  if self.playerName == "proto" then
    self.texOutline = megautils.getResource("protoManOutline")
    self.texOne = megautils.getResource("protoManOne")
    self.texTwo = megautils.getResource("protoManTwo")
    self.texFace = megautils.getResource("protoManFace")
    self.maxExtraJumps = 0
    self.canProtoShield.global = true
    self.canDashJump.global = false
  elseif self.playerName == "bass" then
    self.texOutline = megautils.getResource("bassOutline")
    self.texOne = megautils.getResource("bassOne")
    self.texTwo = megautils.getResource("bassTwo")
    self.texFace = megautils.getResource("bassFace")
    self.maxExtraJumps = 1
    self.canProtoShield.global = false
    self.canDashJump.global = true
    megaMan.weaponHandler[self.player]:unregister(9)
    pp = "bassGrid"
  elseif self.playerName == "roll" then
    self.texOutline = megautils.getResource("rollOutline")
    self.texOne = megautils.getResource("rollOne")
    self.texTwo = megautils.getResource("rollTwo")
    self.texFace = megautils.getResource("rollFace")
    self.maxExtraJumps = 0
    self.canProtoShield.global = false
    self.canDashJump.global = false
    pp = "rollGrid"
  else
    self.texOutline = megautils.getResource("megaManOutline")
    self.texOne = megautils.getResource("megaManOne")
    self.texTwo = megautils.getResource("megaManTwo")
    self.texFace = megautils.getResource("megaManFace")
    self.maxExtraJumps = 0
    self.canProtoShield.global = false
    self.canDashJump.global = false
  end
  
  self.dropAnimation = {regular="spawn"}
  self.dropLandAnimation = {regular="spawnLand"}
  self.idleAnimation = {regular="idle", shoot="idleShoot", s_dm="idleShootDM", s_um="idleShootUM", s_u="idleShootU"}
  self.nudgeAnimation = {regular="nudge", shoot="idleShoot", s_dm="idleShootDM", s_um="idleShootUM", s_u="idleShootU"}
  self.jumpAnimation = {regular="jump", shoot="jumpShoot", s_dm="jumpShootDM", s_um="jumpShootUM", s_u="jumpShootU",
    ps=megautils.diff("easy") and "jumpProtoShield2" or "jumpProtoShield"}
  self.runAnimation = {regular="run", shoot="runShoot"}
  self.climbAnimation = {regular="climb", shoot="climbShoot", s_dm="climbShootDM", s_um="climbShootUM", s_u="climbShootU"}
  self.climbTipAnimation = {regular="climbTip"}
  self.hitAnimation = {regular="hit"}
  self.wallJumpAnimation = {regular="wallJump", shoot="wallJumpShoot"}
  self.dashAnimation = {regular="dash", shoot="dashShoot"}
  self.trebleAnimation = {regular="treble", shoot="trebleShoot", start="trebleStart"}
  
  self.anims = animationSet()
  if self.playerName == "bass" then
    self.anims:add("trebleStart", megautils.newAnimation(pp, {4, 10, "1-4", 11, 1, 12}, 1/8, "pauseAtEnd"))
    self.anims:add("treble", megautils.newAnimation(pp, {"2-3", 12}, 1/12))
    self.anims:add("trebleShoot", megautils.newAnimation(pp, {4, 12, 1, 13}, 1/12))
  end
  if self.playerName == "proto" then
    self.anims:add("idle", megautils.newAnimation(pp, {1, 1, 2, 1}, 1/8))
  else
    self.anims:add("idle", megautils.newAnimation(pp, {1, 1, 2, 1}, {2.5, 0.1}))
  end
  self.anims:add("idleShoot", megautils.newAnimation(pp, {1, 4}))
  self.anims:add("idleShootDM", megautils.newAnimation(pp, {3, 6}))
  self.anims:add("idleShootUM", megautils.newAnimation(pp, {4, 6}))
  self.anims:add("idleShootU", megautils.newAnimation(pp, {1, 7}))
  self.anims:add("idleThrow", megautils.newAnimation(pp, {4, 7}))
  self.anims:add("nudge", megautils.newAnimation(pp, {3, 1}))
  self.anims:add("jump", megautils.newAnimation(pp, {4, 2}))
  self.anims:add("jumpShoot", megautils.newAnimation(pp, {1, 5}))
  self.anims:add("jumpShootDM", megautils.newAnimation(pp, {1, 10}))
  self.anims:add("jumpShootUM", megautils.newAnimation(pp, {2, 10}))
  self.anims:add("jumpShootU", megautils.newAnimation(pp, {3, 10}))
  self.anims:add("jumpThrow", megautils.newAnimation(pp, {1, 8}))
  self.anims:add("jumpProtoShield", megautils.newAnimation(pp, {3, 6}))
  self.anims:add("jumpProtoShield2", megautils.newAnimation(pp, {4, 6}))
  self.anims:add("run", megautils.newAnimation(pp, {4, 1, "1-2", 2, 1, 2}, 1/8))
  self.anims:add("runShoot", megautils.newAnimation(pp, {"2-4", 4, 3, 4}, 1/8))
  self.anims:add("runThrow", megautils.newAnimation(pp, {"2-4", 8, 3, 8}, 1/8))
  self.anims:add("climb", megautils.newAnimation(pp, {"1-2", 3}, 1/8))
  self.anims:add("climbShoot", megautils.newAnimation(pp, {2, 5}))
  self.anims:add("climbShootDM", megautils.newAnimation(pp, {2, 9}))
  self.anims:add("climbShootUM", megautils.newAnimation(pp, {3, 9}))
  self.anims:add("climbShootU", megautils.newAnimation(pp, {4, 9}))
  self.anims:add("climbThrow", megautils.newAnimation(pp, {1, 9}))
  self.anims:add("climbTip", megautils.newAnimation(pp, {3, 3}))
  self.anims:add("hit", megautils.newAnimation(pp, {4, 3}))
  self.anims:add("wallJump", megautils.newAnimation(pp, {2, 9}))
  self.anims:add("wallJumpShoot", megautils.newAnimation(pp, {3, 9}))
  self.anims:add("wallJumpThrow", megautils.newAnimation(pp, {4, 9}))
  self.anims:add("dash", megautils.newAnimation(pp, {3, 2}, 1/14, "pauseAtEnd"))
  self.anims:add("dashShoot", megautils.newAnimation(pp, {4, 10}))
  self.anims:add("dashThrow", megautils.newAnimation(pp, {1, 11}))
  self.anims:add("spawn", megautils.newAnimation(pp, {4, 5}))
  self.anims:add("spawnLand", megautils.newAnimation(pp, {1, 6, 4, 5, 2, 6}, 1/20))
  
  self:switchWeaponSlot(0)
end

function megaMan:initChargingColors()
  self.chargeColorOutlines = {}
  self.chargeColorOnes = {}
  self.chargeColorTwos = {}
  
  self.chargeColorOutlines["M.BUSTER"] = {}
  self.chargeColorOutlines["M.BUSTER"][0] = {}
  self.chargeColorOutlines["M.BUSTER"][1] = {}
  self.chargeColorOutlines["M.BUSTER"][2] = {}
  self.chargeColorOutlines["M.BUSTER"][0][1] = {0, 0, 0}
  self.chargeColorOutlines["M.BUSTER"][1][1] = {0, 232, 216}
  self.chargeColorOutlines["M.BUSTER"][1][2] = {0, 0, 0}
  self.chargeColorOutlines["M.BUSTER"][2][1] = {0, 120, 248}
  self.chargeColorOutlines["M.BUSTER"][2][2] = {0, 0, 0}
  self.chargeColorOutlines["M.BUSTER"][2][3] = {0, 232, 216}
  self.chargeColorOnes["M.BUSTER"] = {}
  self.chargeColorOnes["M.BUSTER"][0] = {}
  self.chargeColorOnes["M.BUSTER"][1] = {}
  self.chargeColorOnes["M.BUSTER"][2] = {}
  self.chargeColorOnes["M.BUSTER"][0][1] = {0, 120, 248}
  self.chargeColorOnes["M.BUSTER"][1][1] = {0, 120, 248}
  self.chargeColorOnes["M.BUSTER"][1][2] = {0, 120, 248}
  self.chargeColorOnes["M.BUSTER"][2][1] = {0, 232, 216}
  self.chargeColorOnes["M.BUSTER"][2][2] = {0, 120, 248}
  self.chargeColorOnes["M.BUSTER"][2][3] = {0, 0, 0}
  self.chargeColorTwos["M.BUSTER"] = {}
  self.chargeColorTwos["M.BUSTER"][0] = {}
  self.chargeColorTwos["M.BUSTER"][1] = {}
  self.chargeColorTwos["M.BUSTER"][2] = {}
  self.chargeColorTwos["M.BUSTER"][0][1] = {0, 232, 216}
  self.chargeColorTwos["M.BUSTER"][1][1] = {0, 232, 216}
  self.chargeColorTwos["M.BUSTER"][1][2] = {0, 232, 216}
  self.chargeColorTwos["M.BUSTER"][2][1] = {0, 0, 0}
  self.chargeColorTwos["M.BUSTER"][2][2] = {0, 232, 216}
  self.chargeColorTwos["M.BUSTER"][2][3] = {0, 120, 248}
  
  self.chargeColorOutlines["P.BUSTER"] = {}
  self.chargeColorOutlines["P.BUSTER"][0] = {}
  self.chargeColorOutlines["P.BUSTER"][1] = {}
  self.chargeColorOutlines["P.BUSTER"][2] = {}
  self.chargeColorOutlines["P.BUSTER"][0][1] = {0, 0, 0}
  self.chargeColorOutlines["P.BUSTER"][1][1] = {216, 40, 0}
  self.chargeColorOutlines["P.BUSTER"][1][2] = {0, 0, 0}
  self.chargeColorOutlines["P.BUSTER"][2][1] = {184, 184, 184}
  self.chargeColorOutlines["P.BUSTER"][2][2] = {216, 40, 0}
  self.chargeColorOutlines["P.BUSTER"][2][3] = {0, 0, 0}
  self.chargeColorOnes["P.BUSTER"] = {}
  self.chargeColorOnes["P.BUSTER"][0] = {}
  self.chargeColorOnes["P.BUSTER"][1] = {}
  self.chargeColorOnes["P.BUSTER"][2] = {}
  self.chargeColorOnes["P.BUSTER"][0][1] = {216, 40, 0}
  self.chargeColorOnes["P.BUSTER"][1][1] = {216, 40, 0}
  self.chargeColorOnes["P.BUSTER"][1][2] = {216, 40, 0}
  self.chargeColorOnes["P.BUSTER"][2][1] = {0, 0, 0}
  self.chargeColorOnes["P.BUSTER"][2][2] = {184, 184, 184}
  self.chargeColorOnes["P.BUSTER"][2][3] = {216, 40, 0}
  self.chargeColorTwos["P.BUSTER"] = {}
  self.chargeColorTwos["P.BUSTER"][0] = {}
  self.chargeColorTwos["P.BUSTER"][1] = {}
  self.chargeColorTwos["P.BUSTER"][2] = {}
  self.chargeColorTwos["P.BUSTER"][0][1] = {184, 184, 184}
  self.chargeColorTwos["P.BUSTER"][1][1] = {184, 184, 184}
  self.chargeColorTwos["P.BUSTER"][1][2] = {184, 184, 184}
  self.chargeColorTwos["P.BUSTER"][2][1] = {184, 184, 184}
  self.chargeColorTwos["P.BUSTER"][2][2] = {0, 0, 0}
  self.chargeColorTwos["P.BUSTER"][2][3] = {216, 40, 0}
  
  self.chargeColorOutlines["R.BUSTER"] = {}
  self.chargeColorOutlines["R.BUSTER"][0] = {}
  self.chargeColorOutlines["R.BUSTER"][1] = {}
  self.chargeColorOutlines["R.BUSTER"][2] = {}
  self.chargeColorOutlines["R.BUSTER"][0][1] = {0, 0, 0}
  self.chargeColorOutlines["R.BUSTER"][1][1] = {248, 56, 0}
  self.chargeColorOutlines["R.BUSTER"][1][2] = {0, 0, 0}
  self.chargeColorOutlines["R.BUSTER"][2][1] = {0, 168, 0}
  self.chargeColorOutlines["R.BUSTER"][2][2] = {248, 56, 0}
  self.chargeColorOutlines["R.BUSTER"][2][3] = {0, 0, 0}
  self.chargeColorOnes["R.BUSTER"] = {}
  self.chargeColorOnes["R.BUSTER"][0] = {}
  self.chargeColorOnes["R.BUSTER"][1] = {}
  self.chargeColorOnes["R.BUSTER"][2] = {}
  self.chargeColorOnes["R.BUSTER"][0][1] = {248, 56, 0}
  self.chargeColorOnes["R.BUSTER"][1][1] = {248, 56, 0}
  self.chargeColorOnes["R.BUSTER"][1][2] = {248, 56, 0}
  self.chargeColorOnes["R.BUSTER"][2][1] = {0, 0, 0}
  self.chargeColorOnes["R.BUSTER"][2][2] = {0, 168, 0}
  self.chargeColorOnes["R.BUSTER"][2][3] = {248, 56, 0}
  self.chargeColorTwos["R.BUSTER"] = {}
  self.chargeColorTwos["R.BUSTER"][0] = {}
  self.chargeColorTwos["R.BUSTER"][1] = {}
  self.chargeColorTwos["R.BUSTER"][2] = {}
  self.chargeColorTwos["R.BUSTER"][0][1] = {0, 168, 0}
  self.chargeColorTwos["R.BUSTER"][1][1] = {0, 168, 0}
  self.chargeColorTwos["R.BUSTER"][1][2] = {0, 168, 0}
  self.chargeColorTwos["R.BUSTER"][2][1] = {0, 168, 0}
  self.chargeColorTwos["R.BUSTER"][2][2] = {0, 0, 0}
  self.chargeColorTwos["R.BUSTER"][2][3] = {248, 56, 0}
end

function megaMan:new(x, y, side, drop, p, g, gf, c, dr, tp)
  megaMan.super.new(self)
  self.doWeaponGet = megautils.getCurrentState() == globals.weaponGetState
  self.transform.x = x or 0
  self.transform.y = y or 0
  self.player = p or 1
  megautils.registerPlayer(self)
  megaMan.properties(self, g, gf, c)
  self:switchCharacter(megautils.getPlayer(self.player))
  self.nextWeapon = 0
  self.prevWeapon = 0
  self.weaponSwitchTimer = 70
  self:regBox()
  self.doAnimation = true
  self.velocity = velocity()
  self.chargeTimer2 = 0
  self.chargeFrame = 1
  self.chargeState = 0
  self:initChargingColors()
  self.chargeTimer = 0
  self.step = false
  self.hitTimer = self.maxHitTime
  self.climbTip = false
  self.ground = true
  self.climb = false
  self.slide = false
  self.drop = drop==nil or drop
  self.rise = false
  self.stepTime = 0
  self.shootTimer = self.maxShootTime
  self.stopOnShot = false
  self.slideTimer = self.maxSlideTime
  self.dashJump = false
  self.wallJumpTimer = 0
  self.dropLanded = not self.drop
  self.bubbleTimer = 0
  self.runCheck = false
  self.standSolidJumpTimer = 0
  self.extraJumps = 0
  self.rapidShotTime = self.maxRapidShotTime
  self.treble = false
  self.trebleSine = 0
  self.trebleForce = velocity()
  self.protoShielding = false
  self.doSplashing = not self.drop
  self.teleportOffY = 0
  self.teleporter = tp
  if self.doWeaponGet then
    self.canControl.global = false
    self.drop = false
    self.transform.y = -self.collisionShape.h
    self.transform.x = math.floor(view.w/2)-(self.collisionShape.w/2)
    self.canDraw.global = false
  elseif (dr == nil or dr) and not self.teleporter and megaMan.mainPlayer == self then
    if self.playerName == "proto" then
      self.ready = megautils.add(ready, nil, 32)
      if megautils._musicQueue then
        self.mq = megautils._musicQueue
        megautils.stopMusic()
      end
      megautils.playSoundFromFile("assets/sfx/protoReady.ogg")
    else
      self.ready = megautils.add(ready)
    end
  end
  self.side = side or 1
  
  if not self.doWeaponGet then
    self.healthHandler = megautils.add(healthHandler, {252, 224, 168}, {255, 255, 255}, {0, 0, 0},
      nil, nil, globals.lifeSegments, self)
    self.healthHandler.canDraw.global = false
    
    megautils.adde(megaMan.weaponHandler[self.player])
    megaMan.colorOutline[self.player] = megaMan.weaponHandler[self.player].colorOutline[0]
    megaMan.colorOne[self.player] = megaMan.weaponHandler[self.player].colorOne[0]
    megaMan.colorTwo[self.player] = megaMan.weaponHandler[self.player].colorTwo[0]
    megaMan.weaponHandler[self.player]:reinit()
    megaMan.weaponHandler[self.player].canDraw.global = false
    
    if camera.main and not camera.main.funcs.megaMan then
      camera.main.funcs.megaMan = function(s)
        for i=0, #megaMan.allPlayers-1 do
          local player = megaMan.allPlayers[i+1]
          if player then
            player.healthHandler.canDraw.global = not player.drop
            megaMan.weaponHandler[player.player].canDraw.global = not player.drop
            player.healthHandler.transform.x = view.x+24 + (i*32)
            player.healthHandler.transform.y = view.y+80
            megaMan.weaponHandler[player.player].transform.x = view.x+32 + (i*32)
            megaMan.weaponHandler[player.player].transform.y = view.y+80
          end
        end
      end
    end
  end
  self.anims.flipX = self.side == 1
  self.anims:set(self.drop and "spawn" or "idle")
  
  for k, v in pairs(megautils.playerCreatedFuncs) do
    v(self)
  end
end

function megaMan:added()
  self:addToGroup("freezable")
  self:addToGroup("submergable")
  self:addToGroup("collision")
end

function megaMan:useShootAnimation()
  self.idleAnimation.shoot = "idleShoot"
  self.nudgeAnimation.shoot = "idleShoot"
  self.jumpAnimation.shoot = "jumpShoot"
  self.runAnimation.shoot = "runShoot"
  self.climbAnimation.shoot = "climbShoot"
  self.wallJumpAnimation.shoot = "wallJumpShoot"
  self.dashAnimation.shoot = "dashShoot"
end

function megaMan:useThrowAnimation()
  self.idleAnimation.shoot = "idleThrow"
  self.nudgeAnimation.shoot = "idleThrow"
  self.jumpAnimation.shoot = "jumpThrow"
  self.runAnimation.shoot = "runThrow"
  self.climbAnimation.shoot = "climbThrow"
  self.wallJumpAnimation.shoot = "wallJumpThrow"
  self.dashAnimation.shoot = "dashThrow"
end

function megaMan:transferState(to)
  to.ground = self.ground
  to.slide = self.slide
  to.climb = self.climb
  to.currentLadder = self.currentLadder
  if self.playerName == "bass" then
    self.transform.y = to.transform.y - (self.gravity >= 0 and (self.collisionShape.h - to.collisionShape.h) or 0)
  end
  if self.slideTimer ~= self.maxSlideTime then
    to.slideTimer = to.maxSlideTime - 2
  end
  to.collisionShape = self.collisionShape
  to.side = self.side
  to.gravityMultipliers = table.clone(self.gravityMultipliers)
  to.gravity = self.gravity
  for k, v in pairs(megautils.playerTransferFuncs) do
    v(self, to)
  end
end

function megaMan:resetStates()
  self.step = false
  self.stepTime = 0
  self.climb = false
  self.currentLadder = nil
  self.iFrames = 0
  self.canDraw.flash = true
  self.wallJumping = false
  self.dashJump = false
  self.treble = false
  self.trebleSine = 0
  self.trebleTimer = 0
  self.trebleForce.velx = 0
  self.trebleForce.vely = 0
  self.canBeInvincible.treble = false
  self.extraJumps = 0
  self.shootTimer = self.maxShootTime
  if self.slide then
    self:slideToReg()
    self.slide = false
  end
  self:useShootAnimation()
  self:animate()
end

function megaMan:camOffX()
  return self.cameraOffsetX
end

function megaMan:camOffY()
  return self.cameraOffsetY + ((self.gravity >= 0) and (self.slide and -3 or 0) or (self.slide and 4 or 0))
end

function megaMan:regBox()
  self:setRectangleCollision(11, 21)
end

function megaMan:basicSlideBox()
  self:setRectangleCollision(11, self.playerName == "bass" and 21 or 14)
end

function megaMan:slideBox()
  self:setRectangleCollision(17, self.playerName == "bass" and 21 or 14)
end

function megaMan:checkRegBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.transform.y
  self:regBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaMan:checkSlideBox(ox, oy)
  local w, h, olx, oly = self.collisionShape.w, self.collisionShape.h, self.transform.x, self.transform.y
  self:slideBox()
  self.transform.x = self.transform.x + (w-self.collisionShape.w)/2
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.transform.x = olx
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaMan:checkBasicSlideBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.transform.y
  self:basicSlideBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaMan:regToSlide()
  local w, h = self.collisionShape.w, self.collisionShape.h
  self:basicSlideBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
end

function megaMan:slideToReg()
  local w, h = self.collisionShape.w, self.collisionShape.h
  self:regBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
end

function megaMan:checkLadder(x, y, tip)
  local w, h, ox = self.collisionShape.w, self.collisionShape.h, self.transform.x
  self:setRectangleCollision(1, tip and 1 or h)
  self.transform.x = self.transform.x + (w/2)
  local result = self:collisionTable(megautils.groups().ladder, x, y)
  local highest = result[1]
  if highest then
    for k, v in ipairs(result) do
      if self.gravity >= 0 and (v.transform.y > highest.transform.y) or (v.transform.y < highest.transform.y) then
        highest = v
      end
    end
  end
  self:setRectangleCollision(w, h)
  self.transform.x = ox
  return highest
end

function megaMan:numberOfShots(n)
  local w = megaMan.weaponHandler[self.player]
  return megautils.groups()[n .. w.id] and #megautils.groups()[n .. w.id] or 0
end

function megaMan:checkWeaponEnergy(n)
  local w = megaMan.weaponHandler[self.player]
  return w.energy[w.slots[n]] > 0
end

function megaMan:attemptWeaponUsage()
  local w = megaMan.weaponHandler[self.player]
  local shots = {}
  if control.shootDown[self.player] then
    if w.current == "B.BUSTER" then
      self.rapidShotTime = math.min(self.rapidShotTime + 1, self.maxRapidShotTime)
      if self.rapidShotTime == self.maxRapidShotTime then
        self.rapidShotTime = 0
        if self:numberOfShots("bassBuster") < 4 then
          local dir = self.side == 1 and 0 or 180
          local tx = self.side == 1 and 22 or -19
          local ty = 6
          if control.upDown[self.player] then
            if control.leftDown[self.player] then
              dir = -45+180
              tx = -14
              ty = -3
            elseif control.rightDown[self.player] then
              dir = 45
              tx = 19
              ty = -3
            else
              if self.gravity >= 0 then
                dir = 90
                tx = self.side == 1 and 7 or -3
                ty = -8
                if self.climb then
                  tx = tx + (self.side == 1 and 0 or 1)
                end
              else
                dir = self.side == 1 and 45 or -45+180
                tx = self.side == 1 and 19 or -14
                ty = -3
              end
            end
          elseif control.downDown[self.player] then
            if control.leftDown[self.player] then
              dir = 45+180
              tx = -14
              ty = 15
            elseif control.rightDown[self.player] then
              dir = -45
              tx = 19
              ty = 15
            else
              if self.gravity >= 0 then
                dir = self.side == 1 and -45 or 45+180
                tx = self.side == 1 and 19 or -14
                ty = 15
              else
                dir = -90
                tx = self.side == 1 and 7 or -3
                ty = 15
                if self.climb then
                  tx = tx + (self.side == 1 and 0 or 1)
                end
              end
            end
          end
          if self.climb then
            ty = ty + (self.gravity >= 0 and -4 or 4)
          end
          if self.gravity < 0 then
            ty = ty + 3
          end
          shots[#shots+1] = megautils.add(bassBuster, self.transform.x+tx, self.transform.y+ty, self, dir)
        end
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
        self.stopOnShot = true
      end
    end
  else
    self.rapidShotTime = self.maxRapidShotTime
  end
  if control.shootPressed[self.player] then
    if (w.current == "M.BUSTER" or (w.weapons[0] == "M.BUSTER" and (w.current == "RUSH JET" or w.current == "RUSH C.")))
      and self:numberOfShots("megaBuster") < 3 and self:numberOfShots("megaChargedBuster") == 0 then
      if w.current == "RUSH C." and self:checkWeaponEnergy("RUSH C.") and self:numberOfShots("rushCoil") < 1 then
        shots[#shots+1] = megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self, self.side, "rush")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "RUSH JET" and self:checkWeaponEnergy("RUSH JET") and self:numberOfShots("rushJet") < 1 then
        shots[#shots+1] = megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y+6, self, self.side, "rush")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        shots[#shots+1] = megautils.add(megaBuster, self.transform.x+(self.side==1 and 21 or -18), 
          self.transform.y+(self.gravity >= 0 and 6 or (self.climb and 10 or 9)), self, self.side)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif (w.current == "P.BUSTER" or (w.weapons[0] == "P.BUSTER" and (w.current == "PROTO JET" or w.current == "PROTO C.")))
      and self:numberOfShots("megaBuster") < 3 and self:numberOfShots("protoChargedBuster") == 0 then
      if w.current == "PROTO C." and self:checkWeaponEnergy("PROTO C.") and self:numberOfShots("rushCoil") < 1 then
        shots[#shots+1] = megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self, self.side, "protoRush")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "PROTO JET" and self:checkWeaponEnergy("PROTO JET") and self:numberOfShots("rushJet") < 1 then
        shots[#shots+1] = megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y+6, self, self.side, "protoRush")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        shots[#shots+1] = megautils.add(megaBuster, self.transform.x+(self.side==1 and 16 or -13), 
          self.transform.y+(self.climb and (self.gravity >= 0 and 8 or 7) or (self.gravity >= 0 and 10 or 5)), self, self.side)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif (w.current == "R.BUSTER" or (w.weapons[0] == "R.BUSTER" and (w.current == "TANGO JET" or w.current == "TANGO C.")))
      and self:numberOfShots("megaBuster") < 3 and self:numberOfShots("protoChargedBuster") == 0 then
      if w.current == "TANGO C." and self:checkWeaponEnergy("TANGO C.") and self:numberOfShots("rushCoil") < 1 then
        shots[#shots+1] = megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self, self.side, "tango")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "TANGO JET" and self:checkWeaponEnergy("TANGO JET") and
      (not megautils.groups()["rushJet" .. w.id] or #megautils.groups()["rushJet" .. w.id] < 1) and self:numberOfShots("rushJet") then
        shots[#shots+1] = megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y+6, self, self.side, "tango")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        shots[#shots+1] = megautils.add(megaBuster, self.transform.x+(self.side==1 and 21 or -18), 
          self.transform.y+(self.gravity >= 0 and (self.climb and 5 or 6) or (self.climb and 8 or 9)), self, self.side)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "T. BOOST" and self:checkWeaponEnergy("T. BOOST") then
      if self.treble == 3 then
        if self:numberOfShots("bassBuster") < 1 then
          shots[#shots+1] = megautils.add(bassBuster, self.transform.x+(self.side==1 and 16 or -14), self.transform.y+(self.gravity >= 0 and 5 or 10),
            self, self.side==1 and 0 or 180, true)
          shots[#shots+1] = megautils.add(bassBuster, self.transform.x+(self.side==1 and 16 or -14), self.transform.y+(self.gravity >= 0 and 5 or 10),
            self, self.side==1 and 45 or 180+45, true)
          shots[#shots+1] = megautils.add(bassBuster, self.transform.x+(self.side==1 and 16 or -14), self.transform.y+(self.gravity >= 0 and 5 or 10),
            self, self.side==1 and -45 or 180-45, true)
          self.maxShootTime = 14
          self.shootTimer = 0
          self:resetCharge()
          self:useShootAnimation()
          megautils.playSound("buster")
        end
      elseif self:numberOfShots("trebleBoost") < 1 then
        shots[#shots+1] = megautils.add(trebleBoost, self.transform.x+(self.side==1 and 24 or -34), 
          self.transform.y, self, self.side)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "STICK W." and self:checkWeaponEnergy("STICK W.") and
      self:numberOfShots("stickWeapon") < 1 then
      shots[#shots+1] = megautils.add(stickWeapon, self.transform.x+(self.side==1 and 17 or -14), 
        self.transform.y+6, self, self.side)
      self.maxShootTime = 14
      self.shootTimer = 0
      self:resetCharge()
      self:useShootAnimation()
      w:updateCurrent(w.energy[w.currentSlot] - 1)
    end
  end
  if not control.shootDown[self.player] and self.chargeState ~= 0 then
    if w.current == "M.BUSTER" then
      if self.chargeState == 1 then
        shots[#shots+1] = megautils.add(megaSemiBuster, self.transform.x+(self.side==1 and 17 or -20), 
          self.transform.y+(self.gravity >= 0 and 4 or (self.climb and 8 or 7)), self, self.side)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        shots[#shots+1] = megautils.add(megaChargedBuster, self.transform.x+(self.side==1 and 17 or -20), 
          self.transform.y+(self.gravity >= 0 and -2 or 1), self, self.side)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "P.BUSTER" then
      if self.chargeState == 1 then
        shots[#shots+1] = megautils.add(protoSemiBuster, self.transform.x+(self.side==1 and 17 or -16), 
          self.transform.y+(self.climb and 9 or (self.gravity >= 0 and 10 or 7)), self, self.side, "protoBuster")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        shots[#shots+1] = megautils.add(protoChargedBuster, self.transform.x+(self.side==1 and 16 or -34), 
          self.transform.y+(self.climb and 7 or (self.gravity >= 0 and 9 or 5)), self, self.side, "protoBuster")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "R.BUSTER" then
      if self.chargeState == 1 then
        shots[#shots+1] = megautils.add(protoSemiBuster, self.transform.x+(self.side==1 and 19 or -18), 
          self.transform.y+(self.climb and (self.gravity >= 0 and 5 or 9) or (self.gravity >= 0 and 7 or 10)), self, self.side, "rollBuster")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        shots[#shots+1] = megautils.add(protoChargedBuster, self.transform.x+(self.side==1 and 16 or -34), 
          self.transform.y+(self.climb and (self.gravity >= 0 and 4 or 7) or (self.gravity >= 0 and 6 or 8)), self, self.side, "rollBuster")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    end
  end
  if control.shootDown[self.player] then
    if checkFalse(self.canChargeBuster) and self.chargeColorOutlines[w.current] and
      self.chargeColorOnes[w.current] and self.chargeColorTwos[w.current] then
      self:charge()
    end
  end
  for k, v in pairs(megautils.playerAttemptWeaponFuncs) do
    v(self, shots)
  end
end

function megaMan:attemptClimb()
  if not control.downDown[self.player] and not control.upDown[self.player] then
    return
  end
  local lad = self:checkLadder(0, self.gravity >= 0 and 1 or -1)
  local downDown, upDown
  if self.gravity >= 0 then
    downDown = control.downDown[self.player]
    upDown = control.upDown[self.player]
  else
    downDown = control.upDown[self.player]
    upDown = control.downDown[self.player]
  end
  if lad then
    self.currentLadder = lad
    if (downDown and self.ground and self:collision(self.currentLadder)) or
      (upDown and self.ground and not self:collision(self.currentLadder)) then
      self.currentLadder = nil
      return
    end
    if self.slide then
      self:slideToReg()
    end
    if downDown and self.ground and not self:collision(self.currentLadder) then
      self.transform.y = self.transform.y + (self.gravity >= 0 and (math.round(self.collisionShape.h*0.3)) or (-math.round(self.collisionShape.h*0.3)))
    end
    self.velocity.vely = 0
    self.velocity.velx = 0
    self.climb = true
    self.dashJump = false
    self.wallJumpTimer = 0
    self.wallJumping = false
    self.ground = false
    self.slide = false
    self.extraJumps = 0
    self.slideTimer = self.maxSlideTime
    self.climbTip = self.currentLadder and
      not self:checkLadder(0, (self.gravity >= 0) and (self.collisionShape.h * 0.4) or (self.collisionShape.h * 0.6), true)
      and not self:checkLadder(0, self.gravity >= 0 and -1 or self.collisionShape.h, true)
    self.transform.x = self.currentLadder.transform.x+(self.currentLadder.collisionShape.w/2)-
      ((self.collisionShape.w)/2)
  end
end

function megaMan:checkProtoShield(e, side)
  local x, y = self.transform.x, self.transform.y
  local w, h = self.collisionShape.w, self.collisionShape.h
  
  if side == -1 then
    self.transform.x = x+self.protoShieldLeftCollision.x
    self.transform.y = y+self.protoShieldLeftCollision.y+(self.gravity >= 0 and 0 or self.protoShieldLeftCollision.goy)
    self.collisionShape.w = self.protoShieldLeftCollision.w
    self.collisionShape.h = self.protoShieldLeftCollision.h
  else
    self.transform.x = x+self.protoShieldRightCollision.x
    self.transform.y = y+self.protoShieldRightCollision.y+(self.gravity >= 0 and 0 or self.protoShieldRightCollision.goy)
    self.collisionShape.w = self.protoShieldRightCollision.w
    self.collisionShape.h = self.protoShieldRightCollision.h
  end
  
  local result = self:collision(e)
  
  self.transform.x = x
  self.transform.y = y
  self.collisionShape.w = w
  self.collisionShape.h = h
  
  return result
end

function megaMan:interactedWith(o, c)
  if not checkFalse(self.canControl) or megautils.isInvincible() or megautils.isNoClip() then return end
  if self.protoShielding and not o.dinked and o.dink and self:checkProtoShield(o, self.side) then
    o:dink(self)
    v.pierceType = pierce.NOPIERCE
    return
  end
  if c < 0 and checkTrue(self.canBeInvincible) then
    self.changeHealth = 0
  else
    self.changeHealth = c
    if self.changeHealth < 0 and self.iFrames <= 0 then
      self.iFrames = o:determineIFrames(self)
    else
      return
    end
  end
  for k, v in pairs(megautils.playerInteractedWithFuncs) do
    v(self)
  end
  self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
  if self.changeHealth < 0 then
    if self.healthHandler.health <= 0 and not self.dying then
      self.dying = true
      megautils.freeze({self}, "dying")
      if camera.main then
        if #megaMan.allPlayers == 1 then
          self.cameraTween = timer((((self.gravity >= 0 and self.transform.y < view.y+view.h) or
            (self.gravity < 0 and self.transform.y+self.collisionShape.h > view.y)) and 28 or 0))
          megautils.stopMusic()
        else
          local dx, dy
          local ox, oy = camera.main.transform.x, camera.main.transform.y
          camera.main:doView(nil, nil, self)
          dx = camera.main.transform.x
          dy = camera.main.transform.y
          camera.main.transform.x = ox
          camera.main.transform.y = oy
          self.cameraTween = tween.new(0.4, camera.main.transform, {x=dx, y=dy})
        end
      else
        self.cameraTween = true
      end
      if o.pierceType == pierce.NOPIERCE and o.pierceType ~= pierce.PIERCEIFKILLING then
        megautils.removeq(o)
      end
      return
    else
      if not checkTrue(self.canIgnoreKnockback) then
        self.velocity.velx = (self.side==1 and self.leftKnockBackSpeed or self.rightKnockBackSpeed)
        self.velocity.vely = 0
        self.hitTimer = 0
      end
      if self.slide and not self:checkRegBox() then
        self.slide = false
        self:slideToReg()
      elseif self.slide and self:checkRegBox() then
        self.hitTimer = self.maxHitTime
        self.velocity.velx = 0
      end
      self.climb = false
      self.dashJump = false
      megautils.add(harm, self)
      megautils.add(damageSteam, self.transform.x+(self.collisionShape.w/2)-2.5-11,
        self.transform.y+(self.gravity >= 0 and -8 or self.collisionShape.h), self)
      megautils.add(damageSteam, self.transform.x+(self.collisionShape.w/2)-2.5,
        self.transform.y+(self.gravity >= 0 and -8 or self.collisionShape.h), self)
      megautils.add(damageSteam, self.transform.x+(self.collisionShape.w/2)-2.5+11,
        self.transform.y+(self.gravity >= 0 and -8 or self.collisionShape.h), self)
      if o.pierceType == pierce.NOPIERCE or o.pierceType == pierce.PIERCEIFKILLING then
        megautils.removeq(o)
      end
      megautils.playSound("hurt")
    end
  end
end

function megaMan:crushed(other)
  if not other.dontKillWhenCrushing then
    for k, v in pairs(self.canBeInvincible) do
      self.canBeInvincible[k2] = false
    end
    self.iFrames = 0
    self:interact(self, -99999, true)
  end
end

function megaMan:code(dt)
  if checkFalse(self.blockCollision) and megautils.groups().bossDoor then
    for k, v in ipairs(megautils.groups().bossDoor) do
      v.lastSolid = v.solidType
      v.solidType = v.canWalkThrough and 0 or 1
    end
  end
  
  self.canIgnoreKnockback.global = false
  self.protoShielding = false
  self.runCheck = ((control.leftDown[self.player] and not control.rightDown[self.player]) or (control.rightDown[self.player] and not control.leftDown[self.player]))
  self.blockCollision.noClip = true
  if megautils.isNoClip() then
    self.blockCollision.noClip = false
    self.velocity.velx = 0
    self.velocity.vely = 0
    local m = control.jumpDown[self.player] and 2 or 1
    if self.runCheck then
      if control.rightDown[self.player] then
        self.velocity.velx = 2*m
        self.side = 1
      else
        self.velocity.velx = -2*m
        self.side = -1
      end
    end
    if ((control.upDown[self.player] and not control.downDown[self.player]) or
      (control.downDown[self.player] and not control.upDown[self.player])) then
      if control.downDown[self.player] then
        self.velocity.vely = 2*m
      else
        self.velocity.vely = -2*m
      end
    end
    self:phys()
    self:attemptWeaponUsage()
  elseif self.treble then
    self.hitTimer = math.min(self.hitTimer+1, self.maxHitTime)
    if self.treble == 1 then
      self.canBeInvincible.treble = true
      self.trebleTimer = self.trebleTimer + 1
      if self.trebleTimer == 30 then
        self.trebleTimer = 0
        self.treble = 2
      end
    elseif self.treble == 2 then
      if self.anims.current == self.trebleAnimation.start then
        if self.anims:frame() == 4 and self.trebleTimer == 0 then
          self.trebleTimer = 1
          megautils.playSound("trebleStart")
        end
        if self.anims:looped() then
          self.treble = 3
          self.trebleTimer = 0
          self.canBeInvincible.treble = false
        end
      end
    elseif self.treble == 3 and self.hitTimer == self.maxHitTime then
      if self.runCheck then
        self.side = control.leftDown[self.player] and -1 or 1
        self.trebleForce.velx = math.clamp(self.trebleForce.velx + (self.side == 1 and 0.1 or -0.1),
          -self.maxTrebleSpeed, self.maxTrebleSpeed)
      else
        self.trebleForce:slowX(self.trebleDecel)
      end
      if ((control.upDown[self.player] and not control.downDown[self.player]) or
        (control.downDown[self.player] and not control.upDown[self.player])) then
        self.trebleForce.vely = math.clamp(self.trebleForce.vely + (control.downDown[self.player] and 0.1 or -0.1),
          -self.maxTrebleSpeed, self.maxTrebleSpeed)
      else
        self.trebleForce:slowY(self.trebleDecel)
      end
      self.velocity.velx = self.trebleForce.velx
      self.velocity.vely = self.trebleForce.vely
      self.trebleSine = self.trebleSine + 0.13
      self.velocity.vely = self.velocity.vely + (math.sin(self.trebleSine) * 0.3)
      self.velocity:clampX(self.maxTrebleSpeed)
      self.velocity:clampY(self.maxTrebleSpeed)
      self.trebleTimer = self.trebleTimer + 1
      if self.trebleTimer == 60 then
        self.trebleTimer = 0
        local w = megaMan.weaponHandler[self.player]
        w:updateCurrent(w:currentWE() - 1)
      end
      
      self:attemptWeaponUsage()
    end
    for k, v in pairs(megautils.playerTrebleFuncs) do
      v(self)
    end
    self:phys()
    if megaMan.weaponHandler[self.player].current ~= "T. BOOST" or
      (megaMan.weaponHandler[self.player].current == "T. BOOST" and
      megaMan.weaponHandler[self.player].energy[megaMan.weaponHandler[self.player].currentSlot] <= 0) then
      self.treble = false
      self.canBeInvincible.treble = false
      self.trebleSine = 0
      self.trebleTimer = 0
      self.trebleForce.velx = 0
      self.trebleForce.vely = 0
    end
  elseif self.hitTimer ~= self.maxHitTime then
    collision.doGrav(self)
    self.hitTimer = math.min(self.hitTimer+1, self.maxHitTime)
    for k, v in pairs(megautils.playerKnockbackFuncs) do
      v(self)
    end
    self:phys()
    if checkFalse(self.canShoot) and control.shootDown[self.player] then
      self:charge()
    else
      self:charge(true)
    end
  elseif self.climb then
    self.currentLadder = self:checkLadder(0, (self.gravity >= 0) and (self.collisionShape.h * 0.4) or (self.collisionShape.h * 0.6), true)
    local tipc = self.currentLadder ~= nil
    if not self.currentLadder then
      self.currentLadder = self:checkLadder()
    end
    
    self.velocity.velx = 0
    self.velocity.vely = 0
    
    local downDown, upDown
    if self.gravity >= 0 then
      downDown = control.downDown[self.player]
      upDown = control.upDown[self.player]
    else
      downDown = control.upDown[self.player]
      upDown = control.downDown[self.player]
    end
    
    if not self.currentLadder or self.ground or
      (control.jumpPressed[self.player] and not (downDown or upDown)) or
      self.transform.x <= view.x-(self.collisionShape.w/2)+2 or
      self.transform.x >= (view.x+view.w)-(self.collisionShape.w/2)-2 then
      self.climb = false
    elseif upDown and ((self.gravity >= 0 and self.transform.y+(self.collisionShape.h*0.8) < self.currentLadder.transform.y) or 
      (self.gravity < 0 and self.transform.y+(self.collisionShape.h*0.2) > self.currentLadder.transform.y+self.currentLadder.collisionShape.h)) and
      not tipc then
        self.velocity.vely = 0
        self.transform.y = math.round(self.transform.y)
        local hit = false
        while self:collision(self.currentLadder) do
          collision.shiftObject(self, 0, self.gravity >= 0 and -1 or 1, true)
          if self.yColl ~= 0 then
            hit = true
            break
          end
        end
        if not hit then
          collision.shiftObject(self, 0, self.gravity >= 0 and 1 or -1, true)
        end
        self.climb = false
    else
      if control.leftDown[self.player] then
        self.side = -1
      elseif control.rightDown[self.player] then
        self.side = 1
      end
      self.transform.x = self.currentLadder.transform.x+(self.currentLadder.collisionShape.w/2)-(self.collisionShape.w/2)
      if control.upDown[self.player] and self.shootTimer == self.maxShootTime then
        self.velocity.vely = self.climbUpSpeed
      elseif control.downDown[self.player] and self.shootTimer == self.maxShootTime then
        self.velocity.vely = self.climbDownSpeed
      end
      self.velocity.vely = self.velocity.vely + self.currentLadder.velocity.vely
    end
    for k, v in pairs(megautils.playerClimbFuncs) do
      v(self)
    end
    self:attemptWeaponUsage()
    if self.shootTimer ~= self.maxShootTime then
      self.velocity.vely = 0      
    end
    self:phys()
    self.currentLadder = self:checkLadder()
    if not self.currentLadder then
      self.climb = false
      self.velocity.vely = 0 
    end
    self.climbTip = self.currentLadder and not tipc and not self:checkLadder(0, self.gravity >= 0 and -1 or self.collisionShape.h, true)
  elseif self.slide then
    collision.checkGround(self, true)
    local lastSide = self.side
    if control.leftDown[self.player] then
      self.side = -1
      self.step = true
      self.stepTime = 0
    elseif control.rightDown[self.player] then
      self.side = 1
      self.step = true
      self.stepTime = 0
    end
    self.velocity.velx = self.side==1 and self.slideRightSpeed or self.slideLeftSpeed
    self.velocity.velx = math.clamp(self.velocity.velx, self.slideLeftSpeed, self.slideRightSpeed)
    local jumped = false
    local sb = self:checkSlideBox(0, math.sign(self.gravity))
    if not sb and not self.ground then
      self.slide = false
      self.velocity.velx = 0
      local w = self.collisionShape.w
      self:regBox()
      self.slideTimer = self.maxSlideTime
      if self:checkRegBox() then
        while collision.checkSolid(self) do
          self.transform.y = self.transform.y + math.sign(self.gravity)
        end
      else
        if collision.checkSolid(self) then
          self.transform.y = math.round(self.transform.y + math.sign(self.gravity))
          while collision.checkSolid(self) do
            self.transform.y = self.transform.y - math.sign(self.gravity)
          end
        end
      end
    else
      self.slideTimer = math.min(self.slideTimer+1, self.maxSlideTime)
      local rb = self:checkRegBox()
      self.canIgnoreKnockback.global = rb
      if self.slideTimer == self.maxSlideTime and not rb and (self.ground or sb) then
        self.slide = false
        self:slideToReg()
      elseif not rb and self.xColl ~= 0 then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self:slideToReg()
      elseif checkFalse(self.canJump) and checkFalse(self.canJumpOutFromDash) and
        control.jumpPressed[self.player] and not rb
        and (self.ground or sb) and not control.downDown[self.player] then
        self.slide = false
        jumped = true
        self.velocity.vely = self.jumpSpeed * (self.gravity < 0 and -1 or 1)
        self.ground = false
        self.slideTimer = self.maxSlideTime
        self.hitTimer = self.maxHitTime
        self:slideToReg()
        self.dashJump = checkFalse(self.canDashJump)
      elseif not (self.ground or sb) and rb then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self.hitTimer = self.maxHitTime
        local w = self.collisionShape.w
        self:regBox()
        while collision.checkSolid(self) do
          self.transform.y = self.transform.y + 1
        end
      elseif checkFalse(self.canBackOutFromDash) and lastSide ~= self.side and not rb then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self:slideToReg()
      end
    end
    if not self.slide and not jumped then self.velocity.vely = 0 end
    for k, v in pairs(megautils.playerSlideFuncs) do
      v(self)
    end
    self:phys()
    local cd, cs = checkFalse(self.canDashShoot), checkFalse(self.canShoot)
    if cs and not cd and control.shootDown[self.player] then
      self:charge()
    elseif cs and cd then
      self:attemptWeaponUsage()
    else
      self:charge(true)
    end
    self:attemptClimb()
  elseif self.ground then
    collision.doGrav(self)
    if checkFalse(self.canWalk) and not (self.stopOnShot and self.shootTimer ~= self.maxShootTime) then
      if self.runCheck and not self.step then
        self.side = control.leftDown[self.player] and -1 or 1
        local sv = checkFalse(self.canStep)
        if sv and self.stepTime == 0 then
          collision.shiftObject(self, (self.side == -1) and self.stepLeftSpeed or self.stepRightSpeed, 0, true)
        end
        self.stepTime = math.min(self.stepTime+1, self.maxStepTime)
        if self.stepTime == self.maxStepTime then
          self.step = true
          self.stepTime = 0
        end
      elseif self.runCheck then
        self.side = control.leftDown[self.player] and -1 or 1
        self.velocity.velx = self.velocity.velx + (self.side == -1 and self.leftSpeed or self.rightSpeed)
      else
        self.velocity:slowX(self.side == -1 and self.leftDecel or self.rightDecel)
        self.stepTime = 0
        self.step = false
      end
    else
      if self.runCheck then
        self.side = control.leftDown[self.player] and -1 or 1
      end
      self.velocity:slowX(self.side == -1 and self.leftDecel or self.rightDecel)
      self.stepTime = 0
      self.step = false
    end
    if checkFalse(self.canDash) and (control.dashPressed[self.player] or
      (control[self.gravity >= 0 and "downDown" or "upDown"][self.player] and control.jumpPressed[self.player])) and
      not self:checkBasicSlideBox(self.side, 0) then
      self.slide = true
      self:regToSlide()
      self.slideTimer = 0
      megautils.add(slideParticle, self.transform.x+(self.side==-1 and self.collisionShape.w-8 or 0),
        self.transform.y+(self.gravity >= 0 and self.collisionShape.h-6 or -2), self, self.side)
    elseif checkFalse(self.canJump) and self.inStandSolid and control.jumpDown[self.player] and
      self.standSolidJumpTimer ~= self.maxStandSolidJumpTime and
      self.standSolidJumpTimer ~= -1 then
      self.velocity.vely = self.jumpSpeed * (self.gravity < 0 and -1 or 1)
      self.standSolidJumpTimer = math.min(self.standSolidJumpTimer+1, self.maxStandSolidJumpTime)
    elseif checkFalse(self.canJump) and control.jumpPressed[self.player] and
      not (control[self.gravity >= 0 and "downDown" or "upDown"][self.player] and self:checkBasicSlideBox(self.side, 0)) then
      self.velocity.vely = self.jumpSpeed * (self.gravity < 0 and -1 or 1)
      self.protoShielding = checkFalse(self.canProtoShield)
      self.ground = false
    else
      self.velocity.vely = 0
    end
    if self.standSolidJumpTimer > 0 and (not control.jumpDown[self.player] or
      self.standSolidJumpTimer == self.maxStandSolidJumpTime) then
      self.standSolidJumpTimer = -1
      megautils.playSound("land")
    end
    if self.standSolidJumpTimer == -1 and not control.jumpDown[self.player] then
      self.standSolidJumpTimer = 0
    end
    self.velocity.velx = math.clamp(self.velocity.velx, self.maxLeftSpeed, self.maxRightSpeed)
    for k, v in pairs(megautils.playerGroundFuncs) do
      v(self)
    end
    self:phys()
    if not self.ground then
      self.standSolidJumpTimer = -1
    end
    if checkFalse(self.canShoot) then
      self:attemptWeaponUsage()
    end
    self:attemptClimb()
  else
    collision.doGrav(self)
    self.protoShielding = checkFalse(self.canProtoShield)
    if self.runCheck then
      self.side = control.leftDown[self.player] and -1 or 1
      self.velocity.velx = self.velocity.velx + (self.side == -1 and 
        (self.dashJump and self.slideLeftSpeed*self.dashJumpMultiplier or self.leftAirSpeed) or 
        (self.dashJump and self.slideRightSpeed*self.dashJumpMultiplier or self.rightAirSpeed))
      if self.dashJump then
        self.velocity.velx = math.clamp(self.velocity.velx, -(self.slideLeftSpeed*self.dashJumpMultiplier),
          (self.slideLeftSpeed*self.dashJumpMultiplier))
      else
        self.velocity.velx = math.clamp(self.velocity.velx, self.maxLeftAirSpeed, self.maxRightAirSpeed)
      end
      self.stepTime = 0
      self.step = true
    else
      self.velocity:slowX(self.side == -1 and self.leftAirDecel or self.rightAirDecel)
      self.velocity.velx = math.clamp(self.velocity.velx, self.maxLeftAirSpeed, self.maxRightAirSpeed)
      self.stepTime = 0
      self.step = false
    end
    if control.jumpPressed[self.player] and self.extraJumps < self.maxExtraJumps then
      self.extraJumps = self.extraJumps + 1
      self.velocity.vely = self.jumpSpeed * (self.gravity >= 0 and 1 or -1)
    end
    if checkFalse(self.canStopJump) and not control.jumpDown[self.player] and
      ((self.gravity < 0 and self.velocity.vely > 0) or (self.gravity >= 0 and self.velocity.vely < 0)) then
      self.velocity:slowY(self.jumpDecel)
    end
    for k, v in pairs(megautils.playerAirFuncs) do
      v(self)
    end
    self:phys()
    if self.died then return end
    if self.ground then
      self.dashJump = false
      self.canStopJump.global = true
      self.extraJumps = 0
      megautils.playSound("land")
    else
      self:attemptClimb()
    end
    if checkFalse(self.canShoot) then
      self:attemptWeaponUsage()
    end
  end
  if megautils.groups().enemyWeapon then
    for k, v in ipairs(megautils.groups().enemyWeapon) do
      if self.protoShielding and not v.dinked and v.dink and self:checkProtoShield(v, self.side) then
        v:dink(self)
        v.pierceType = pierce.NOPIERCE
      end
    end
  end
  if self:collisionNumber(megautils.groups().water) ~= 0 then
    self.bubbleTimer = math.min(self.bubbleTimer+1, self.maxBubbleTime)
    if self.bubbleTimer == self.maxBubbleTime then
      self.bubbleTimer = 0
      megautils.add(airBubble, self.transform.x+(self.side==-1 and -4 or self.collisionShape.w), self.transform.y+4, self)
    end
  end
  self.transform.x = math.clamp(self.transform.x, view.x+(-self.collisionShape.w/2)+2,
    (view.x+view.w)+(-self.collisionShape.w/2)-2)
  self.transform.y = math.clamp(self.transform.y, view.y-(self.collisionShape.h*1.4),
    view.y+view.h+4)
  self.shootTimer = math.min(self.shootTimer+1, self.maxShootTime)
  if ((self.gravity >= 0 and self.transform.y >= view.y+view.h) or (self.gravity < 0 and self.transform.y+self.collisionShape.h <= view.y)) or 
    (checkFalse(self.blockCollision) and checkTrue(self.canGetCrushed) and collision.checkSolid(self)) then
    self.iFrames = 0
    for k, v in pairs(self.canBeInvincible) do
      self.canBeInvincible[k] = false
    end
    self:interact(self, -99999, true)
  end
  self:updateIFrame()
  self:updateFlash()
  if self.stopOnShot and self.shootTimer == self.maxShootTime then
    self.stopOnShot = false
  end
  if megaMan.mainPlayer and control.startPressed[self.player] and
    checkFalse(megaMan.mainPlayer.canControl) and checkFalse(megaMan.mainPlayer.canUpdate) and checkFalse(self.canPause) then
    self.weaponSwitchTimer = 70
    mmWeaponsMenu.pause(self)
  end
  
  if megautils.groups().bossDoor then
    for k, v in ipairs(megautils.groups().bossDoor) do
      v.solidType = v.lastSolid
    end
  end
end

function megaMan:resetCharge()
  self.chargeState = 0
  self.chargeFrame = 1
  self.chargeTimer = 0
  self.chargeTimer2 = 0
  if self.chargeColorOutlines[megaMan.weaponHandler[self.player].current]
   and self.chargeColorOnes[megaMan.weaponHandler[self.player].current]
    and self.chargeColorTwos[megaMan.weaponHandler[self.player].current] then
    megaMan.colorOutline[self.player] = self.chargeColorOutlines[megaMan.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
    megaMan.colorOne[self.player] = self.chargeColorOnes[megaMan.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
    megaMan.colorTwo[self.player] = self.chargeColorTwos[megaMan.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
  end
  megautils.stopSound("charge")
  megautils.stopSound("protoCharge")
end

function megaMan:charge(animOnly)
  if self.chargeColorOutlines[megaMan.weaponHandler[self.player].current] then
    self.chargeTimer2 = math.min(self.chargeTimer2+1, 4)
    if self.chargeTimer2 == 4 and self.chargeColorOutlines[megaMan.weaponHandler[self.player].current]
    and self.chargeColorOnes[megaMan.weaponHandler[self.player].current]
      and self.chargeColorTwos[megaMan.weaponHandler[self.player].current] then
      self.chargeTimer2 = 0
      self.chargeFrame = math.wrap(self.chargeFrame+1, 1,
        table.length(self.chargeColorOutlines[megaMan.weaponHandler[self.player].current][self.chargeState]))
    end
    if not animOnly then
      self.chargeTimer = math.min(self.chargeTimer+1, self.maxChargeTime)
    end
    if self.chargeTimer == self.maxChargeTime and self.chargeState <
      table.length(self.chargeColorOutlines[megaMan.weaponHandler[self.player].current])-1 then
      self.chargeTimer = 0
      self.chargeFrame = 1
      if self.chargeState == 0 then
        if megaMan.weaponHandler[self.player].current == "P.BUSTER" then
          megautils.playSound("protoCharge")
        else
          megautils.playSound("charge")
        end
      end
      if animOnly==nil and true or not animOnly then
        self.chargeState = math.min(self.chargeState+1, 
          table.length(self.chargeColorOutlines[megaMan.weaponHandler[self.player].current])-1)
      end
    end
    if self.chargeColorOutlines[megaMan.weaponHandler[self.player].current]
    and self.chargeColorOnes[megaMan.weaponHandler[self.player].current]
      and self.chargeColorTwos[megaMan.weaponHandler[self.player].current] then
      megaMan.colorOutline[self.player] = self.chargeColorOutlines[megaMan.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
      megaMan.colorOne[self.player] = self.chargeColorOnes[megaMan.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
      megaMan.colorTwo[self.player] = self.chargeColorTwos[megaMan.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
    end
  end
end

function megaMan:grav()
  if self.ground then return end
  if self.gravityType == 0 then
    self.velocity.vely = self.velocity.vely+self.gravity
  elseif self.gravityType == 1 then
    self.velocity:slowY(self.gravity)
  end
end

function megaMan:phys()
  self.velocity.vely = self.gravity >= 0 and math.min(self.maxAirSpeed, self.velocity.vely) or math.max(-self.maxAirSpeed, self.velocity.vely)
  collision.doCollision(self)
  if checkFalse(self.blockCollision) and checkFalse(self.canDieFromSpikes) and
    (self.xColl ~= 0 or self.yColl ~= 0 or (self.ground and self.gravity ~= 0)) then
    local t = self:collisionTable(megautils.groups().death, self.xColl, self.yColl+math.sign(self.gravity))
    if #t ~= 0 then
      local lx, ly = self.transform.x, self.transform.y
      local lg = self.ground
      local lcx, lcy = self.xColl, self.yColl
      local lss = self.inStandSolid
      local lmf = self.onMovingFloor
      for i=1, #t do
        t[i].solidType = collision.NONE
      end
      collision.shiftObject(self, self.xColl, self.yColl+math.sign(self.gravity), true, false)
      for i=1, #t do
        t[i].solidType = collision.SOLID
      end
      if collision.checkSolid(self) then
        local dv = self:collisionTable(megautils.groups().death)
        if dv[1] and dv[1].harm > 0 then
          dv[1]:interact(self, dv[1].harm, true)
        end
        if self.healthHandler.health <= 0 then
          self.ground = false
        else
          self.ground = lg
          self.xColl = lcx
          self.yColl = lcy
          self.inStandSolid = lss
          self.onMovingFloor = lmf
        end
      else
        self.ground = lg
        self.xColl = lcx
        self.yColl = lcy
        self.inStandSolid = lss
        self.onMovingFloor = lmf
      end
      self.transform.x = lx
      self.transform.y = ly
    end
  end
end

function megaMan:attemptWeaponSwitch()
  if control.prevDown[self.player] and control.nextDown[self.player]
    and megaMan.weaponHandler[self.player].currentSlot ~= 0 then
    self:switchWeaponSlot(0)
    local w = math.wrap(megaMan.weaponHandler[self.player].currentSlot+1, 0, megaMan.weaponHandler[self.player].slotSize)
    while not megaMan.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w+1, 0, megaMan.weaponHandler[self.player].slotSize)
    end
    self.nextWeapon = w
    w = math.wrap(megaMan.weaponHandler[self.player].currentSlot-1, 0, megaMan.weaponHandler[self.player].slotSize)
    while not megaMan.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w-1, 0, megaMan.weaponHandler[self.player].slotSize)
    end
    self.prevWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    megautils.playSound("switch")
  elseif control.nextPressed[self.player] and not control.prevDown[self.player] then
    self.prevWeapon = megaMan.weaponHandler[self.player].currentSlot
    local w = math.wrap(megaMan.weaponHandler[self.player].currentSlot+1, 0, megaMan.weaponHandler[self.player].slotSize)
    while not megaMan.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w+1, 0, megaMan.weaponHandler[self.player].slotSize)
    end
    self:switchWeaponSlot(w)
    w = math.wrap(megaMan.weaponHandler[self.player].currentSlot+1, 0, megaMan.weaponHandler[self.player].slotSize)
    while not megaMan.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w+1, 0, megaMan.weaponHandler[self.player].slotSize)
    end
    self.nextWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    megautils.playSound("switch")
  elseif control.prevPressed[self.player] and not control.nextDown[self.player] then
    self.nextWeapon = megaMan.weaponHandler[self.player].currentSlot
    local w = math.wrap(megaMan.weaponHandler[self.player].currentSlot-1, 0, megaMan.weaponHandler[self.player].slotSize)
    while not megaMan.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w-1, 0, megaMan.weaponHandler[self.player].slotSize)
    end
    self:switchWeaponSlot(w)
    w = math.wrap(megaMan.weaponHandler[self.player].currentSlot-1, 0, megaMan.weaponHandler[self.player].slotSize)
    while not megaMan.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w-1, 0, megaMan.weaponHandler[self.player].slotSize)
    end
    self.prevWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    megautils.playSound("switch")
  end
end

function megaMan:switchWeapon(n)
  local w = megaMan.weaponHandler[self.player]
  w:switchName(n)
  megaMan.colorOutline[self.player] = w.colorOutline[w.currentSlot]
  megaMan.colorOne[self.player] = w.colorOne[w.currentSlot]
  megaMan.colorTwo[self.player] = w.colorTwo[w.currentSlot]
end

function megaMan:switchWeaponSlot(s)
  local w = megaMan.weaponHandler[self.player]
  w:switch(s)
  megaMan.colorOutline[self.player] = w.colorOutline[w.currentSlot]
  megaMan.colorOne[self.player] = w.colorOne[w.currentSlot]
  megaMan.colorTwo[self.player] = w.colorTwo[w.currentSlot]
end

function megaMan:bassBusterAnim(shoot)
  if megaMan.weaponHandler[self.player].current ~= "B.BUSTER" then return shoot end
  local dir = shoot
  if self.shootTimer ~= self.maxShootTime then
    if control.upDown[self.player] then
      if control.leftDown[self.player] or control.rightDown[self.player] then
        dir = self.gravity >= 0 and "s_um" or "s_dm"
      else
        dir = self.gravity >= 0 and "s_u" or "s_dm"
      end
    elseif control.downDown[self.player] then
      if self.gravity < 0 and (control.leftDown[self.player] or control.rightDown[self.player]) then
        dir = "s_um"
      else
        dir = self.gravity >= 0 and "s_dm" or "s_u"
      end
    end
  end
  return dir
end

function megaMan:animate()
  if self.drop or self.rise then
    self.anims:set(self.dropLanded and self.dropLandAnimation.regular or self.dropAnimation.regular)
  elseif checkFalse(self.canControl) then
    local shoot = "regular"
    if self.shootTimer ~= self.maxShootTime then
      shoot = "shoot"
    end
    if self.treble then
      if self.treble == 1 then
        self.anims:set(self.idleAnimation.regular)
      elseif self.treble == 2 then
        self.anims:set(self.trebleAnimation.start)
      elseif self.treble == 3 then
        if table.contains(self.trebleAnimation, self.anims.current) and
          self.anims.current ~= self.trebleAnimation.start and
          self.anims.current ~= self.trebleAnimation[shoot] then
          self.anims:set(self.trebleAnimation[shoot], self.anims:frame(), self.anims:time())
        else
          self.anims:set(self.trebleAnimation[shoot])
        end
      end
    elseif self.hitTimer ~= self.maxHitTime then
      self.anims:set(self.hitAnimation.regular)
    elseif self.climb then
      shoot = self:bassBusterAnim(shoot)
      self.anims:set(self.climbAnimation[shoot])
      if self.climbTip then
        if self.shootTimer ~= self.maxShootTime then
          self.anims:set(self.climbAnimation[shoot])
        else
          self.anims:set(self.climbTipAnimation.regular)
        end
      elseif not (control.downDown[self.player] or control.upDown[self.player]) and not self.anims:isPaused() then
        self.anims:pause()
        if shoot ~= "regular" then
          if self.side == -1 then
            self.anims:gotoFrame(2)
          else
            self.anims:gotoFrame(1)
          end
        end
      elseif control.downDown[self.player] or control.upDown[self.player] and self.anims:isPaused() then
        self.anims:resume()
      end
    elseif self.slide then
      self.anims:set(self.dashAnimation[checkFalse(self.canDashShoot) and shoot or "regular"])
      if checkFalse(self.canDashShoot) and self.shootTimer ~= self.maxShootTime then
        self.anims:gotoFrame(self.anims:length())
      end
    elseif self.ground then
      if checkFalse(self.canWalk) and not self.step and self.runCheck then
        shoot = self:bassBusterAnim(shoot)
        if self.standSolidJumpTimer > 0 then
          if self.protoShielding and shoot == "regular" then
            shoot = "ps"
          end
          self.anims:set(self.jumpAnimation[shoot])
        else
          self.anims:set(self.nudgeAnimation[shoot])
        end
      elseif checkFalse(self.canWalk) and self.runCheck and
        not (self.stopOnShot and self.shootTimer ~= self.maxShootTime) then
        if table.contains(self.runAnimation, self.anims.current) and self.anims.current ~= self.runAnimation[shoot] then
          self.anims:set(self.runAnimation[shoot], self.anims:frame(), self.anims:time())
        else
          self.anims:set(self.runAnimation[shoot])
        end
      else
        shoot = self:bassBusterAnim(shoot)
        if self.standSolidJumpTimer > 0 then
          if self.protoShielding and shoot == "regular" then
            shoot = "ps"
          end
          self.anims:set(self.jumpAnimation[shoot])
        else
          self.anims:set(self.idleAnimation[shoot])
        end
      end
    else
      shoot = self:bassBusterAnim(shoot)
      if self.protoShielding and shoot == "regular" then
        shoot = "ps"
      end
      self.anims:set(self.jumpAnimation[shoot])
    end
  end
  if self.anims.current ~= self.climbAnimation.regular and self.anims.current ~= self.climbTipAnimation.regular then
    self.anims.flipX = self.side == 1
  else
    self.anims.flipX = false
  end
  self.anims:update(defaultFramerate)
end

function megaMan:die()
  if ((self.gravity >= 0 and self.transform.y < view.y+view.h) or (self.gravity < 0 and self.transform.y+self.collisionShape.h > view.y)) then
    deathExplodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-12),
      self.transform.y+((self.collisionShape.h/2)-12))
  end
  
  if self.healthHandler.health ~= 0 then
    self.healthHandler:updateThis(0)
  end
  
  if #megaMan.allPlayers == 1 then
    healthHandler.playerTimers = {}
    for i=1, maxPlayerCount do
      healthHandler.playerTimers[i] = -2
    end
    
    megautils.add(timer, 160, function(t)
      megautils.add(fade, true, nil, nil, function(s)
        megautils.reloadState = true
        if not megautils.hasInfiniteLives() then
          megautils.setLives(math.max(megautils.getLives()-1, -1))
        end
        if not megautils.hasInfiniteLives() and megautils.getLives() < 0 then
          megautils.reloadState = true
          megautils.resetGameObjects = true
          globals.gameOverContinueState = megautils.getCurrentState()
          megautils.gotoState("assets/states/menus/gameover.state.lua")
        else
          megautils.reloadState = true
          megautils.resetGameObjects = false
          megautils.gotoState(megautils.getCurrentState())
        end
        megautils.removeq(s)
      end)
      megautils.removeq(t)
    end)
  else
    healthHandler.playerTimers[self.player] = 180
    megautils.removeq(megaMan.weaponHandler[self.player])
    megautils.removeq(self.healthHandler)
  end
  self.canDraw.global = false
  self.canControl.global = false
  self.died = true
  megautils.unregisterPlayer(self)
  megautils.removeq(self)
  megautils.playSoundFromFile("assets/sfx/dieExplode.ogg")
end

function megaMan:update(dt)
  if self.doWeaponGet then
    if not self._subState then
      self._subState = 0
      self._wgs = globals.wgMenuState
      globals.wgMenuState = nil
      self._wgv = globals.wgValue
      globals.wgValue = nil
      self._wgb = globals.weaponGetBehaviour
      globals.weaponGetBehaviour = nil
      self._text = globals.weaponGetText
      globals.weaponGetText = nil
      self._textPos = 0
      self._textTimer = 0
      self._timer = 0
      self._textObj = love.graphics.newText(mmFont, self._text)
      self._halfWidth = self._textObj:getWidth()/2
      self._textObj:set("")
      self._w1 = megaMan.weaponHandler[self.player].current
      self._w2 = self._wgv and self._wgv.weaponName
      self.canDraw.global = true
    elseif self._subState == 0 then
      self.transform.y = math.min(self.transform.y + 10, math.floor(view.h/2)-(self.collisionShape.h/2))
      if self.transform.y == math.floor(view.h/2)-(self.collisionShape.h/2) then
        self._subState = (type(self._wgv) == "table") and 1 or 2
        if self._subState == 1 then
          megaMan.weaponHandler[self.player]:register(self._wgv.weaponSlot or 1,
            self._wgv.weaponName or "WEAPON",
            {self._wgv.activeQuad or quad(16, 32, 16, 16), self._wgv.inactiveQuad or quad(32, 32, 16, 16)},
            self._wgv.oneColor or {255, 255, 255},
            self._wgv.twoColor or {188, 188, 188},
            self._wgv.outlineColor or {0, 0, 0})
        end
      end
    elseif self._subState == 1 then
      self._timer = self._timer + 1
      self:switchWeapon((self._timer % 16 > 8) and self._w2 or self._w1)
      local w = megaMan.weaponHandler[self.player]
      banner.colorOutline = w.colorOutline[w.currentSlot]
      banner.colorOne = w.colorOne[w.currentSlot]
      banner.colorTwo = w.colorTwo[w.currentSlot]
      if self._timer > 100 and w.current == self._w2 then
        self._timer = 0
        self._subState = 2
      end
    elseif self._subState == 2 then
      if self._text then
        self._textTimer = math.min(self._textTimer+1, 8)
        if self._textTimer == 8 then
          self._textTimer = 0
          self._textPos = math.min(self._textPos+1, self._text:len())
        end
      end
      
      if self._wgb(self) and (not self._text or self._textPos == self._text:len()) then
        self._subState = 3
      end
    elseif self._subState == 3 then
      self._timer = self._timer + 1
      if self._timer == 120 then
        self._subState = 4
        globals.wgsToMenu = true
        megautils.transitionToState(self._wgs)
      end
    end
    self.anims:update(defaultFramerate)
  else
    if not megaMan.once then
      megaMan.once = true
    end
    if self.ready then
      if self.ready.isRemoved then
        self.ready = nil
        self.teleportOffY = self.drop and (view.y-self.transform.y) or 0
        if self.mq then
          megautils.playMusic(unpack(self.mq))
          self.mq = nil
        end
      end
    elseif self.dying then
      for k, v in pairs(megautils.playerDeathFuncs) do
        v(self)
      end
      if self.cameraTween:update(defaultFramerate) then
        self:die()
        megautils.unfreeze(nil, "dying")
        return
      end
      if camera.main then
        view.x, view.y = math.round(camera.main.transform.x), math.round(camera.main.transform.y)
        camera.main:updateFuncs()
      end
    else
      self.runCheck = false
      if self.rise then
        if self.dropLanded then
          self.dropLanded = not self.anims:looped()
          if not self.dropLanded then
            self.doSplashing = false
            megautils.playSound("ascend")
          end
        else
          self.teleportOffY = self.teleportOffY+self.riseSpeed
        end
      elseif self.drop then
        self.teleportOffY = math.min(self.teleportOffY+self.dropSpeed, 0)
        if self.teleportOffY == 0 then
          self.dropLanded = true
          if self.anims:looped() then
            self.drop = false
            self.doSplashing = true
            megautils.playSound("start")
          end
        end
      elseif checkFalse(self.canControl) then
        self:code(dt)
      end
      if self.doAnimation then self:animate(dt) end
      if checkFalse(self.canSwitchWeapons) and not self.drop and not self.rise then self:attemptWeaponSwitch() end
      self.weaponSwitchTimer = math.min(self.weaponSwitchTimer+1, 70)
    end
  end
end

function megaMan:afterUpdate(dt)
  if not self.dying and camera.main and megaMan.mainPlayer == self and
    checkFalse(self.canHaveCameraFocus) and not self.drop and not self.rise
    and self.collisionShape then
    camera.main:updateCam()
  end
end

function megaMan:draw()
  if megaMan.mainPlayer and megaMan.mainPlayer.ready then return end
  self.anims.flipY = self.gravity < 0
  local roundx, roundy = math.round(self.transform.x), math.round(self.transform.y)
  local offsetx, offsety = 0, 0
  local c = self.anims.current
  
  if self.playerName == "bass" then
    offsety, offsetx = -10, -18
    if table.contains(self.climbAnimation, c) or 
      table.contains(self.jumpAnimation, c) or 
      table.contains(self.wallJumpAnimation, c) then
      offsety = self.gravity >= 0 and -8 or -12
    elseif table.contains(self.climbTipAnimation, c) then
      offsety = self.gravity >= 0 and -2 or -18
    elseif table.contains(self.hitAnimation, c) then
      offsety = self.gravity >= 0 and -6 or -14
    elseif table.contains(self.dashAnimation, c) then
      offsety = -10
    end
  elseif self.playerName == "roll" then
    offsety, offsetx = self.gravity >= 0 and -10 or -3, -18
    if table.contains(self.climbAnimation, c) or 
      table.contains(self.jumpAnimation, c) or 
      table.contains(self.wallJumpAnimation, c) then
      offsety = self.gravity >= 0 and -8 or -7
    elseif table.contains(self.climbTipAnimation, c) then
      offsety = self.gravity >= 0 and -4 or -11
    elseif table.contains(self.hitAnimation, c) then
      offsety = self.gravity >= 0 and -6 or -14
    elseif table.contains(self.dashAnimation, c) then
      offsety = self.gravity >= 0 and -17 or -3
    end
  else
    offsety, offsetx = self.gravity >= 0 and -8 or -1, -15
    if table.contains(self.climbAnimation, c) or 
      table.contains(self.jumpAnimation, c) or 
      table.contains(self.wallJumpAnimation, c) then
      offsety = self.gravity >= 0 and -2 or -6
    elseif table.contains(self.climbTipAnimation, c) then
      offsety = self.gravity >= 0 and 5 or -12
    elseif table.contains(self.hitAnimation, c) then
      offsety = self.gravity >= 0 and -4 or -5
    elseif table.contains(self.dashAnimation, c) then
      offsety = self.gravity >= 0 and -13 or -3
    end
  end
  offsety = offsety + self.teleportOffY
  if self.playerName == "bass" or self.playerName == "roll" then
    if c == "climbShoot" or c == "climbShootDM" or c == "climbShootUM"
      or c == "climbShootU" or c == "climbThrow" then
      offsetx = self.side == -1 and -17 or -18
    elseif c == "climb" or c == "climbTip" then
      offsetx = self.anims:frame() == 1 and -18 or -17
    elseif c == "slide" then
      offsetx = self.side==1 and -14 or -20
    end
  else
    if c == "climbShoot" or c == "climbShootDM" or c == "climbShootUM"
      or c == "climbShootU" or c == "climbThrow" then
      offsetx = self.side == -1 and -15 or -16
    elseif c == "climb" or c == "climbTip" then
      offsetx = self.anims:frame() == 1 and -16 or -15
    elseif c == "slide" then
      offsetx = self.side==1 and -12 or -18
    end
  end
  
  love.graphics.setColor(megaMan.colorOutline[self.player][1]/255, megaMan.colorOutline[self.player][2]/255, megaMan.colorOutline[self.player][3]/255, 1)
  self.anims:draw(self.texOutline, roundx+offsetx, roundy+offsety)
  love.graphics.setColor(megaMan.colorOne[self.player][1]/255, megaMan.colorOne[self.player][2]/255, megaMan.colorOne[self.player][3]/255, 1)
  self.anims:draw(self.texOne, roundx+offsetx, roundy+offsety)
  love.graphics.setColor(megaMan.colorTwo[self.player][1]/255, megaMan.colorTwo[self.player][2]/255, megaMan.colorTwo[self.player][3]/255, 1)
  self.anims:draw(self.texTwo, roundx+offsetx, roundy+offsety)
  love.graphics.setColor(1, 1, 1, 1)
  self.anims:draw(self.texFace, roundx+offsetx, roundy+offsety)
  
  if self.weaponSwitchTimer ~= 70 then
    love.graphics.setColor(1, 1, 1, 1)
    if checkFalse(self.canHaveThreeWeaponIcons) then
      megaMan.weaponHandler[self.player]:drawIcon(self.nextWeapon, true, roundx+math.round(math.round(self.collisionShape.w/2))+8, roundy-18)
      megaMan.weaponHandler[self.player]:drawIcon(self.prevWeapon, true, roundx+math.round(math.round(self.collisionShape.w/2))-24, roundy-18)
    end
    megaMan.weaponHandler[self.player]:drawIcon(megaMan.weaponHandler[self.player].currentSlot,
      true, roundx+math.round(math.round(self.collisionShape.w/2))-8, roundy-20)
  end
  
  if self.doWeaponGet and self._text and self._textObj then
    love.graphics.setFont(mmFont)
    self._textObj:set(self._text:sub(0, self._textPos or 0))
    love.graphics.draw(self._textObj, (view.w/2)-self._halfWidth, 142)
  end
  --self:drawCollision()
end
