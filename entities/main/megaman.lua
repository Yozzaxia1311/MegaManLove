megautils.resetGameObjectsFuncs["megaman"] = function()
  megaman.colorOutline = {}
  megaman.colorOne = {}
  megaman.colorTwo = {}
  megaman.weaponHandler = {}
  globals.mainPlayer = nil
  globals.allPlayers = {}
  weaponhandler.id = 0
  
  for i=1, globals.playerCount do
    megaman.weaponHandler[i] = weaponhandler(nil, nil, 10)
    if globals.player[i] == "proto" then
      megaman.weaponHandler[i]:register(0, "protoBuster", {"p.buster", {48, 32, 16, 16}, {64, 32, 16, 16}},
        {216, 40, 0}, {184, 184, 184}, {0, 0, 0})
    elseif globals.player[i] == "bass" then
      megaman.weaponHandler[i]:register(0, "bassBuster", {"b.buster", {144, 32, 16, 16}, {160, 32, 16, 16}},
        {112, 112, 112}, {248, 152, 56}, {0, 0, 0})
    elseif globals.player[i] == "roll" then
      megaman.weaponHandler[i]:register(0, "rollBuster", {"r.buster", {80, 32, 16, 16}, {96, 32, 16, 16}},
        {248, 56, 0}, {0, 168, 0}, {0, 0, 0})
    else
      megaman.weaponHandler[i]:register(0, "megaBuster", {"m.buster", {16, 32, 16, 16}, {32, 32, 16, 16}},
        {0, 120, 248}, {0, 232, 216}, {0, 0, 0})
    end
    
    if globals.player[i] == "bass" then
      megaman.weaponHandler[i]:register(9, "trebleBoost", {"t. boost", {144, 16, 16, 16}, {160, 16, 16, 16}},
        {112, 112, 112}, {128, 0, 240}, {0, 0, 0})
    elseif globals.player[i] == "proto" then
      megaman.weaponHandler[i]:register(9, "rushCoil", {"proto c.", {176, 0, 16, 16}, {192, 0, 16, 16}},
        {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
      megaman.weaponHandler[i]:register(10, "rushJet", {"proto jet", {176, 16, 16, 16}, {192, 16, 16, 16}},
        {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    elseif globals.player[i] == "roll" then
      megaman.weaponHandler[i]:register(9, "rushCoil", {"tango c.", {208, 0, 16, 16}, {224, 0, 16, 16}},
        {0, 168, 0}, {255, 255, 255}, {0, 0, 0})
      megaman.weaponHandler[i]:register(10, "rushJet", {"tango jet", {208, 16, 16, 16}, {224, 16, 16, 16}},
        {0, 168, 0}, {255, 255, 255}, {0, 0, 0})
    else
      megaman.weaponHandler[i]:register(9, "rushCoil", {"rush c.", {144, 0, 16, 16}, {160, 0, 16, 16}},
        {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
      megaman.weaponHandler[i]:register(10, "rushJet", {"rush jet", {112, 32, 16, 16}, {128, 32, 16, 16}},
        {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
    end
    
    if globals.defeats.stickMan then
      megaman.weaponHandler[i]:register(1, "stickWeapon", {"stick w.", {16, 0, 16, 16}, {32, 0, 16, 16}},
        {188, 188, 188}, {124, 124, 124}, {0, 0, 0})
    end
  end
end

megaman = entity:extend()

megaman.weaponHandler = {}
megaman.colorOutline = {}
megaman.colorOne = {}
megaman.colorTwo = {}

addobjects.register("player", function(v)
  if (not v.properties["spawnCamera"] or v.properties["spawnCamera"]) and
    v.properties["checkpoint"] == globals.checkpoint then
    megautils.add(camera, v.x, v.y, v.properties["doScrollX"], v.properties["doScrollY"])
    camera.once = false
  end
end, -1)

addobjects.register("player", function(v)
  if (not v.properties["spawnCamera"] or v.properties["spawnCamera"]) and
    v.properties["checkpoint"] == globals.checkpoint and not camera.once and camera.main then
    camera.once = true
    camera.main:setRectangleCollision(8, 8)
    camera.main:updateBounds()
    camera.main:setRectangleCollision(view.w, view.h)
    camera.main:doView()
  end
end, 2)

addobjects.register("player", function(v)
  if v.properties["checkpoint"] == globals.checkpoint then
    if v.properties["individual"] then
      if v.properties["individual"] <= globals.playerCount then
        megautils.add(megaman, v.x, v.y+((v.properties["grav"] == nil or v.properties["grav"] >= 0) and -5 or 0),
          v.properties["side"], v.properties["drop"], v.properties["individual"], v.properties["grav"])
      end
    else
      for i=1, globals.playerCount do
        megautils.add(megaman, v.x, v.y+((v.properties["grav"] == nil or v.properties["grav"] >= 0) and -5 or 0),
          v.properties["side"], v.properties["drop"], i, v.properties["grav"])
      end
    end
  end
end)

function megaman.properties(self, g)
  self.gravityType = 0
  self.normalGravity = 0.25
  self.gravityMultipliers = {global=g or 1}
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
  self.blockCollision = true
  self.maxStandSolidJumpTime = 4
  self.maxExtraJumps = globals.player[self.player] == "bass" and 1 or 0
  self.maxRapidShotTime = 5
  self.maxTrebleSpeed = 2
  self.trebleDecel = 0.1
  if megautils.diff("easy") then
    self.protoShieldLeftCollision = {x=-7, y=0, w=8, h=20}
    self.protoShieldRightCollision = {x=10, y=0, w=8, h=20}
  else
    self.protoShieldLeftCollision = {x=-7, y=0, w=8, h=14}
    self.protoShieldRightCollision = {x=10, y=0, w=8, h=14}
  end
  
  self.canJumpOutFromDash = {global=true}
  self.canBackOutFromDash = {global=true}
  self.canSwitchWeapons = {global=true}
  self.canStandSolid = {global=true}
  self.canPause = {global=true}
  self.canDieFromSpikes = {global=true}
  self.canDashShoot = {global=false}
  self.canDashJump = {global=globals.player[self.player] == "bass"}
  self.canDash = {global=true}
  self.canShoot = {global=true}
  self.canWallJump = {global=false}
  self.canChargeBuster = {global=true}
  self.canWalk = {global=true}
  self.canJump = {global=true}
  self.canHaveCameraFocus = {global=true}
  self.canHaveThreeWeaponIcons = {global=false}
  self.canBeInvincible = {global=false}
  self.canGetCrushed = {global=false}
  self.canStopJump = {global=true}
  self.canStepVelocity = {global=false}
  self.canIgnoreKnockback = {global=false}
  self.canProtoShield = {global=globals.player[self.player] == "proto"}
end

function megaman:transferState(to)
  to.ground = self.ground
  to.slide = self.slide
  to.climb = self.climb
  to.currentLadder = self.currentLadder
  if globals.player[self.player] == "bass" then
    self.transform.y = to.transform.y - (self.gravity >= 0 and (self.collisionShape.h - to.collisionShape.h) or 0)
  end
  if self.slideTimer ~= self.maxSlideTime then
    to.slideTimer = to.maxSlideTime - 2
  end
  to.collisionShape = self.collisionShape
  to.side = self.side
end

function megaman:regBox()
  self:setRectangleCollision(11, 21)
end

function megaman:basicSlideBox()
  self:setRectangleCollision(11, globals.player[self.player] == "bass" and 21 or 14)
end

function megaman:slideBox()
  self:setRectangleCollision(17, globals.player[self.player] == "bass" and 21 or 14)
end

function megaman:checkRegBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.transform.y
  self:regBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaman:checkSlideBox(ox, oy)
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

function megaman:checkBasicSlideBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.transform.y
  self:basicSlideBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaman:regToSlide()
  local w, h = self.collisionShape.w, self.collisionShape.h
  self:basicSlideBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
end

function megaman:slideToReg()
  local w, h = self.collisionShape.w, self.collisionShape.h
  self:regBox()
  self.transform.y = self.transform.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
end

function megaman:initChargingColors()
  if globals.player[self.player] == "roll" then
    self.chargeColorOutlines = {}
    self.chargeColorOutlines["rollBuster"] = {}
    self.chargeColorOutlines["rollBuster"][0] = {}
    self.chargeColorOutlines["rollBuster"][1] = {}
    self.chargeColorOutlines["rollBuster"][2] = {}
    self.chargeColorOutlines["rollBuster"][0][1] = {0, 0, 0}
    self.chargeColorOutlines["rollBuster"][1][1] = {248, 56, 0}
    self.chargeColorOutlines["rollBuster"][1][2] = {0, 0, 0}
    self.chargeColorOutlines["rollBuster"][2][1] = {0, 168, 0}
    self.chargeColorOutlines["rollBuster"][2][2] = {248, 56, 0}
    self.chargeColorOutlines["rollBuster"][2][3] = {0, 0, 0}
    self.chargeColorOnes = {}
    self.chargeColorOnes["rollBuster"] = {}
    self.chargeColorOnes["rollBuster"][0] = {}
    self.chargeColorOnes["rollBuster"][1] = {}
    self.chargeColorOnes["rollBuster"][2] = {}
    self.chargeColorOnes["rollBuster"][0][1] = {248, 56, 0}
    self.chargeColorOnes["rollBuster"][1][1] = {248, 56, 0}
    self.chargeColorOnes["rollBuster"][1][2] = {248, 56, 0}
    self.chargeColorOnes["rollBuster"][2][1] = {0, 0, 0}
    self.chargeColorOnes["rollBuster"][2][2] = {0, 168, 0}
    self.chargeColorOnes["rollBuster"][2][3] = {248, 56, 0}
    self.chargeColorTwos = {}
    self.chargeColorTwos["rollBuster"] = {}
    self.chargeColorTwos["rollBuster"][0] = {}
    self.chargeColorTwos["rollBuster"][1] = {}
    self.chargeColorTwos["rollBuster"][2] = {}
    self.chargeColorTwos["rollBuster"][0][1] = {0, 168, 0}
    self.chargeColorTwos["rollBuster"][1][1] = {0, 168, 0}
    self.chargeColorTwos["rollBuster"][1][2] = {0, 168, 0}
    self.chargeColorTwos["rollBuster"][2][1] = {0, 168, 0}
    self.chargeColorTwos["rollBuster"][2][2] = {0, 0, 0}
    self.chargeColorTwos["rollBuster"][2][3] = {248, 56, 0}
  elseif globals.player[self.player] == "proto" then
    self.chargeColorOutlines = {}
    self.chargeColorOutlines["protoBuster"] = {}
    self.chargeColorOutlines["protoBuster"][0] = {}
    self.chargeColorOutlines["protoBuster"][1] = {}
    self.chargeColorOutlines["protoBuster"][2] = {}
    self.chargeColorOutlines["protoBuster"][0][1] = {0, 0, 0}
    self.chargeColorOutlines["protoBuster"][1][1] = {216, 40, 0}
    self.chargeColorOutlines["protoBuster"][1][2] = {0, 0, 0}
    self.chargeColorOutlines["protoBuster"][2][1] = {184, 184, 184}
    self.chargeColorOutlines["protoBuster"][2][2] = {216, 40, 0}
    self.chargeColorOutlines["protoBuster"][2][3] = {0, 0, 0}
    self.chargeColorOnes = {}
    self.chargeColorOnes["protoBuster"] = {}
    self.chargeColorOnes["protoBuster"][0] = {}
    self.chargeColorOnes["protoBuster"][1] = {}
    self.chargeColorOnes["protoBuster"][2] = {}
    self.chargeColorOnes["protoBuster"][0][1] = {216, 40, 0}
    self.chargeColorOnes["protoBuster"][1][1] = {216, 40, 0}
    self.chargeColorOnes["protoBuster"][1][2] = {216, 40, 0}
    self.chargeColorOnes["protoBuster"][2][1] = {0, 0, 0}
    self.chargeColorOnes["protoBuster"][2][2] = {184, 184, 184}
    self.chargeColorOnes["protoBuster"][2][3] = {216, 40, 0}
    self.chargeColorTwos = {}
    self.chargeColorTwos["protoBuster"] = {}
    self.chargeColorTwos["protoBuster"][0] = {}
    self.chargeColorTwos["protoBuster"][1] = {}
    self.chargeColorTwos["protoBuster"][2] = {}
    self.chargeColorTwos["protoBuster"][0][1] = {184, 184, 184}
    self.chargeColorTwos["protoBuster"][1][1] = {184, 184, 184}
    self.chargeColorTwos["protoBuster"][1][2] = {184, 184, 184}
    self.chargeColorTwos["protoBuster"][2][1] = {184, 184, 184}
    self.chargeColorTwos["protoBuster"][2][2] = {0, 0, 0}
    self.chargeColorTwos["protoBuster"][2][3] = {216, 40, 0}
  else
    self.chargeColorOutlines = {}
    self.chargeColorOutlines["megaBuster"] = {}
    self.chargeColorOutlines["megaBuster"][0] = {}
    self.chargeColorOutlines["megaBuster"][1] = {}
    self.chargeColorOutlines["megaBuster"][2] = {}
    self.chargeColorOutlines["megaBuster"][0][1] = {0, 0, 0}
    self.chargeColorOutlines["megaBuster"][1][1] = {0, 232, 216}
    self.chargeColorOutlines["megaBuster"][1][2] = {0, 0, 0}
    self.chargeColorOutlines["megaBuster"][2][1] = {0, 120, 248}
    self.chargeColorOutlines["megaBuster"][2][2] = {0, 0, 0}
    self.chargeColorOutlines["megaBuster"][2][3] = {0, 232, 216}
    self.chargeColorOnes = {}
    self.chargeColorOnes["megaBuster"] = {}
    self.chargeColorOnes["megaBuster"][0] = {}
    self.chargeColorOnes["megaBuster"][1] = {}
    self.chargeColorOnes["megaBuster"][2] = {}
    self.chargeColorOnes["megaBuster"][0][1] = {0, 120, 248}
    self.chargeColorOnes["megaBuster"][1][1] = {0, 120, 248}
    self.chargeColorOnes["megaBuster"][1][2] = {0, 120, 248}
    self.chargeColorOnes["megaBuster"][2][1] = {0, 232, 216}
    self.chargeColorOnes["megaBuster"][2][2] = {0, 120, 248}
    self.chargeColorOnes["megaBuster"][2][3] = {0, 0, 0}
    self.chargeColorTwos = {}
    self.chargeColorTwos["megaBuster"] = {}
    self.chargeColorTwos["megaBuster"][0] = {}
    self.chargeColorTwos["megaBuster"][1] = {}
    self.chargeColorTwos["megaBuster"][2] = {}
    self.chargeColorTwos["megaBuster"][0][1] = {0, 232, 216}
    self.chargeColorTwos["megaBuster"][1][1] = {0, 232, 216}
    self.chargeColorTwos["megaBuster"][1][2] = {0, 232, 216}
    self.chargeColorTwos["megaBuster"][2][1] = {0, 0, 0}
    self.chargeColorTwos["megaBuster"][2][2] = {0, 232, 216}
    self.chargeColorTwos["megaBuster"][2][3] = {0, 120, 248}
  end
end

function megaman:new(x, y, side, drop, p, g)
  megaman.super.new(self)
  megautils.registerPlayer(self, p)
  megaman.properties(self, g)
  self:calcGrav()
  if globals.player[self.player] == "mega" then
    self.texOutline = loader.get("mega_man_outline")
    self.texOne = loader.get("mega_man_one")
    self.texTwo = loader.get("mega_man_two")
    self.texFace = loader.get("mega_man_face")
  elseif globals.player[self.player] == "proto" then
    self.texOutline = loader.get("proto_man_outline")
    self.texOne = loader.get("proto_man_one")
    self.texTwo = loader.get("proto_man_two")
    self.texFace = loader.get("proto_man_face")
  elseif globals.player[self.player] == "bass" then
    self.texOutline = loader.get("bass_outline")
    self.texOne = loader.get("bass_one")
    self.texTwo = loader.get("bass_two")
    self.texFace = loader.get("bass_face")
  elseif globals.player[self.player] == "roll" then
    self.texOutline = loader.get("roll_outline")
    self.texOne = loader.get("roll_one")
    self.texTwo = loader.get("roll_two")
    self.texFace = loader.get("roll_face")
  end
  self.teleportOffY = 0
  self.side = side or 1
  self.transform.y = y
  self.transform.x = x
  self.class = megaman
  self.icoTex = loader.get("weapon_select_icon")
  self.iconQuad = love.graphics.newQuad(0, 0, 16, 16, 112, 48)
  self.icons = {}
  if globals.player[self.player] == "proto" then
    self.icons[0] = {16, 32}
  elseif globals.player[self.player] == "bass" then
    self.icons[0] = {32, 32}
  elseif globals.player[self.player] == "roll" then
    self.icons[0] = {48, 32}
  else
    self.icons[0] = {0, 0}
  end
  self.icons[1] = {16, 0}
  self.icons[2] = {16, 16}
  self.icons[3] = {32, 0}
  self.icons[4] = {32, 16}
  self.icons[5] = {48, 0}
  self.icons[6] = {48, 16}
  self.icons[7] = {64, 0}
  self.icons[8] = {64, 16}
  if globals.player[self.player] == "proto" then
    self.icons[9] = {80, 0}
  elseif globals.player[self.player] == "roll" then
    self.icons[9] = {96, 0}
  elseif globals.player[self.player] == "bass" then
    self.icons[9] = {64, 32}
  else
    self.icons[9] = {0, 16}
  end
  if globals.player[self.player] == "proto" then
    self.icons[10] = {80, 16}
  elseif globals.player[self.player] == "roll" then
    self.icons[10] = {96, 16}
  else
    self.icons[10] = {0, 32}
  end
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
  self.drop = drop==nil and true or drop
  self.rise = false
  self.idleMoving = false
  self.stepTime = 0
  self.shootTimer = self.maxShootTime
  self.stopOnShot = false
  self.slideTimer = self.maxSlideTime
  self.dashJump = false
  self.wallJumpTimer = 0
  self.dropLanded = not self.drop
  self.control = not self.drop
  self.bubbleTimer = 0
  self.runCheck = false
  self.standSolidJumpTimer = 0
  self.extraJumps = 0
  self.rapidShotTime = self.maxRapidShotTime
  self.treble = false
  self.trebleSine = 0
  self.trebleForce = velocity()
  self.alwaysMove = false
  self.protoShielding = false
  
  self.groundUpdateFuncs = {}
  self.airUpdateFuncs = {}
  self.slideUpdateFuncs = {}
  self.climbUpdateFuncs = {}
  self.knockbackUpdateFuncs = {}
  
  megautils.adde(megaman.weaponHandler[self.player])
  self.healthHandler = megautils.add(healthhandler, {252, 224, 168}, {255, 255, 255}, {0, 0, 0},
    nil, nil, globals.lifeSegments, self)
  self.healthHandler.render = false
  
  megaman.colorOutline[self.player] = megaman.weaponHandler[self.player].colorOutline[0]
  megaman.colorOne[self.player] = megaman.weaponHandler[self.player].colorOne[0]
  megaman.colorTwo[self.player] = megaman.weaponHandler[self.player].colorTwo[0]
  megaman.weaponHandler[self.player]:reinit()
  megaman.weaponHandler[self.player].render = false
  self.health = self.healthHandler.health
  self.healthHandler:updateThis()
  if not camera.main.funcs["megaman"] then
    camera.main.funcs["megaman"] = function(s)
      for i=0, #globals.allPlayers-1 do
        local player = globals.allPlayers[i+1]
        if player then
          player.healthHandler.render = not player.drop
          megaman.weaponHandler[player.player].render = not player.drop
          player.healthHandler.transform.x = view.x+24 + (i*32)
          player.healthHandler.transform.y = view.y+80
          megaman.weaponHandler[player.player].transform.x = view.x+32 + (i*32)
          megaman.weaponHandler[player.player].transform.y = view.y+80
        end
      end
    end
  end
  self.curAnim = self.drop and "spawn" or "idle"
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
  self.dashAnimation = {regular=(self:checkFalse(self.canDashShoot) and globals.player[self.player] == "mega") and "dash" or "slide", shoot="dashShoot"}
  self.trebleAnimation = {regular="treble", shoot="trebleShoot"}
  self.animations = {}
  local pp = "mega_man_grid"
  if globals.player[self.player] == "bass" then
    pp = "bass_grid"
    self.animations["trebleStart"] = anim8.newAnimation(loader.get(pp)(4, 10, "1-4", 11, 1, 12), 1/8, "pauseAtEnd")
    self.animations["treble"] = anim8.newAnimation(loader.get(pp)("2-3", 12), 1/12)
    self.animations["trebleShoot"] = anim8.newAnimation(loader.get(pp)(4, 12, 1, 13), 1/12)
  elseif globals.player[self.player] == "roll" then
    pp = "roll_grid"
  end
  if globals.player[self.player] == "proto" then
    self.animations["idle"] = anim8.newAnimation(loader.get(pp)(1, 1, 2, 1), 1/8)
  else
    self.animations["idle"] = anim8.newAnimation(loader.get(pp)(1, 1, 2, 1), {2.5, 0.1})
  end
  self.animations["idleShoot"] = anim8.newAnimation(loader.get(pp)(1, 4), 1)
  self.animations["idleShootDM"] = anim8.newAnimation(loader.get(pp)(3, 6), 1)
  self.animations["idleShootUM"] = anim8.newAnimation(loader.get(pp)(4, 6), 1)
  self.animations["idleShootU"] = anim8.newAnimation(loader.get(pp)(1, 7), 1)
  self.animations["idleThrow"] = anim8.newAnimation(loader.get(pp)(4, 7), 1)
  self.animations["nudge"] = anim8.newAnimation(loader.get(pp)(3, 1), 1)
  self.animations["jump"] = anim8.newAnimation(loader.get(pp)(4, 2), 1)
  self.animations["jumpShoot"] = anim8.newAnimation(loader.get(pp)(1, 5), 1)
  self.animations["jumpShootDM"] = anim8.newAnimation(loader.get(pp)(1, 10), 1)
  self.animations["jumpShootUM"] = anim8.newAnimation(loader.get(pp)(2, 10), 1)
  self.animations["jumpShootU"] = anim8.newAnimation(loader.get(pp)(3, 10), 1)
  self.animations["jumpThrow"] = anim8.newAnimation(loader.get(pp)(1, 8), 1)
  self.animations["jumpProtoShield"] = anim8.newAnimation(loader.get(pp)(3, 6), 1)
  self.animations["jumpProtoShield2"] = anim8.newAnimation(loader.get(pp)(4, 6), 1)
  self.animations["run"] = anim8.newAnimation(loader.get(pp)(4, 1, "1-2", 2, 1, 2), 1/8)
  self.animations["runShoot"] = anim8.newAnimation(loader.get(pp)("2-4", 4, 3, 4), 1/8)
  self.animations["runThrow"] = anim8.newAnimation(loader.get(pp)("2-4", 8, 3, 8), 1/8)
  self.animations["climb"] = anim8.newAnimation(loader.get(pp)("1-2", 3), 1/8)
  self.animations["climbShoot"] = anim8.newAnimation(loader.get(pp)(2, 5), 1)
  self.animations["climbShootDM"] = anim8.newAnimation(loader.get(pp)(2, 9), 1)
  self.animations["climbShootUM"] = anim8.newAnimation(loader.get(pp)(3, 9), 1)
  self.animations["climbShootU"] = anim8.newAnimation(loader.get(pp)(4, 9), 1)
  self.animations["climbThrow"] = anim8.newAnimation(loader.get(pp)(1, 9), 1)
  self.animations["climbTip"] = anim8.newAnimation(loader.get(pp)(3, 3), 1)
  self.animations["hit"] = anim8.newAnimation(loader.get(pp)(4, 3), 1)
  self.animations["wallJump"] = anim8.newAnimation(loader.get(pp)(2, 9), 1)
  self.animations["wallJumpShoot"] = anim8.newAnimation(loader.get(pp)(3, 9), 1)
  self.animations["wallJumpThrow"] = anim8.newAnimation(loader.get(pp)(4, 9), 1)
  self.animations["slide"] = anim8.newAnimation(loader.get(pp)(3, 2), 1/14, "pauseAtEnd")
  self.animations["dash"] = anim8.newAnimation(loader.get(pp)("1-2", 10), 1/8, "pauseAtEnd")
  self.animations["dashShoot"] = anim8.newAnimation(loader.get(pp)(4, 10), 1)
  self.animations["dashThrow"] = anim8.newAnimation(loader.get(pp)(1, 11), 1)
  self.animations["spawn"] = anim8.newAnimation(loader.get(pp)("3-4", 5), 0.08)
  self.animations["spawnLand"] = anim8.newAnimation(loader.get(pp)("1-2", 6, 1, 6), 1/20)
  self:face(self.side)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("submergable")
    self:addToGroup("carry")
  end
  self.render = not self.drop
end

function megaman:face(n)
  self.animations[self.curAnim].flippedH = (n == 1) and true or false
end

function megaman:useShootAnimation()
  self.idleAnimation.shoot = "idleShoot"
  self.nudgeAnimation.shoot = "idleShoot"
  self.jumpAnimation.shoot = "jumpShoot"
  self.runAnimation.shoot = "runShoot"
  self.climbAnimation.shoot = "climbShoot"
  self.wallJumpAnimation.shoot = "wallJumpShoot"
  self.dashAnimation.shoot = "dashShoot"
end

function megaman:useThrowAnimation()
  self.idleAnimation.shoot = "idleThrow"
  self.nudgeAnimation.shoot = "idleThrow"
  self.jumpAnimation.shoot = "jumpThrow"
  self.runAnimation.shoot = "runThrow"
  self.climbAnimation.shoot = "climbThrow"
  self.wallJumpAnimation.shoot = "wallJumpThrow"
  self.dashAnimation.shoot = "dashThrow"
end

function megaman:attemptWeaponUsage()
  local w = megaman.weaponHandler[self.player]
  if control.shootDown[self.player] then
    if w.current == "bassBuster" or
      (w.weapons[0] == "bassBuster" and (w.current == "rushJet" or w.current == "rushCoil")) then
      self.rapidShotTime = math.min(self.rapidShotTime + 1, self.maxRapidShotTime)
      if self.rapidShotTime == self.maxRapidShotTime then
        self.rapidShotTime = 0
        if w.current == "rushCoil" and w.energy[w.currentSlot] > 0 and
          (not megautils.groups()["rushCoil" .. w.id] or #megautils.groups()["rushCoil" .. w.id] < 1) then
          megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
            self.transform.y, self.side, self, w)
          self.maxShootTime = 14
          self.shootTimer = 0
          self:useShootAnimation()
        elseif w.current == "rushJet" and w.energy[w.currentSlot] > 0 and
          (not megautils.groups()["rushJet" .. w.id] or #megautils.groups()["rushJet" .. w.id] < 1) then
          megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
              self.transform.y+6, self.side, self, w)
          self.maxShootTime = 14
          self.shootTimer = 0
          self:useShootAnimation()
        else
          if not megautils.groups()["bassBuster" .. w.id] or #megautils.groups()["bassBuster" .. w.id] < 4 then
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
            megautils.add(bassBuster, self.transform.x+tx, self.transform.y+ty, dir, w)
          end
          self.maxShootTime = 14
          self.shootTimer = 0
          self:resetCharge()
          self:useShootAnimation()
          self.stopOnShot = true
        end
      end
    end
  else
    self.rapidShotTime = self.maxRapidShotTime
  end
  if control.shootPressed[self.player] then
    if (w.current == "megaBuster" or (w.weapons[0] == "megaBuster" and (w.current == "rushJet" or w.current == "rushCoil")))
      and (not megautils.groups()["megaBuster" .. w.id] or
      #megautils.groups()["megaBuster" .. w.id] < 3) and (not megautils.groups()["megaChargedBuster" .. w.id] or
      #megautils.groups()["megaChargedBuster" .. w.id] == 0) then
      if w.current == "rushCoil" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()["rushCoil" .. w.id] or #megautils.groups()["rushCoil" .. w.id] < 1) then
        megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self.side, self, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "rushJet" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()["rushJet" .. w.id] or #megautils.groups()["rushJet" .. w.id] < 1) then
        megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
            self.transform.y+6, self.side, self, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        megautils.add(megaBuster, self.transform.x+(self.side==1 and 17 or -14), 
          self.transform.y+(self.gravity >= 0 and 6 or (self.climb and 10 or 9)), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif (w.current == "protoBuster" or (w.weapons[0] == "protoBuster" and (w.current == "rushJet" or w.current == "rushCoil")))
      and (not megautils.groups()["megaBuster" .. w.id] or
      #megautils.groups()["megaBuster" .. w.id] < 3) then
      if w.current == "rushCoil" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()["rushCoil" .. w.id] or #megautils.groups()["rushCoil" .. w.id] < 1) then
        megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self.side, self, w, "proto_rush")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "rushJet" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()["rushJet" .. w.id] or #megautils.groups()["rushJet" .. w.id] < 1) then
        megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
            self.transform.y+6, self.side, self, w, "proto_rush")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        megautils.add(megaBuster, self.transform.x+(self.side==1 and 16 or -13), 
          self.transform.y+(self.climb and (self.gravity >= 0 and 8 or 7) or (self.gravity >= 0 and 10 or 5)), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif (w.current == "rollBuster" or (w.weapons[0] == "rollBuster" and (w.current == "rushJet" or w.current == "rushCoil")))
      and (not megautils.groups()["megaBuster" .. w.id] or
      #megautils.groups()["megaBuster" .. w.id] < 3) then
      if w.current == "rushCoil" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()["rushCoil" .. w.id] or #megautils.groups()["rushCoil" .. w.id] < 1) then
        megautils.add(rushCoil, self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self.side, self, w, "tango")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "rushJet" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()["rushJet" .. w.id] or #megautils.groups()["rushJet" .. w.id] < 1) then
        megautils.add(rushJet, self.transform.x+(self.side==1 and 18 or -32),
            self.transform.y+6, self.side, self, w, "tango")
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        megautils.add(megaBuster, self.transform.x+(self.side==1 and 24 or -20), 
          self.transform.y+(self.gravity >= 0 and 6 or 9), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "trebleBoost" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()[w.current .. w.id] or
        #megautils.groups()[w.current .. w.id] < 1) then
      if self.treble == 2 then
        if (not megautils.groups()["bassBuster" .. w.id] or
          #megautils.groups()["bassBuster" .. w.id] < 1) then
          megautils.add(bassBuster, self.transform.x+(self.side==1 and 16 or -14), self.transform.y+(self.gravity >= 0 and 5 or 10),
            self.side==1 and 0 or 180, w, true)
          megautils.add(bassBuster, self.transform.x+(self.side==1 and 16 or -14), self.transform.y+(self.gravity >= 0 and 5 or 10),
            self.side==1 and 45 or 180+45, w, true)
          megautils.add(bassBuster, self.transform.x+(self.side==1 and 16 or -14), self.transform.y+(self.gravity >= 0 and 5 or 10),
            self.side==1 and -45 or 180-45, w, true)
          self.maxShootTime = 14
          self.shootTimer = 0
          self:resetCharge()
          self:useShootAnimation()
          mmSfx.play("buster")
        end
      else
        megautils.add(trebleBoost, self.transform.x+(self.side==1 and 24 or -34), 
          self.transform.y, self.side, self, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "stickWeapon" and w.energy[w.currentSlot] > 0 and
      (not megautils.groups()[w.current .. w.id] or
        #megautils.groups()[w.current .. w.id] < 1) and self.shootTimer == self.maxShootTime then
      megautils.add(stickWeapon, self.transform.x+(self.side==1 and 17 or -14), 
        self.slide and self.transform.y+3 or self.transform.y+6, self.side, w)
      self.maxShootTime = 14
      self.shootTimer = 0
      self:resetCharge()
      self:useShootAnimation()
      w.energy[w.currentSlot] = w.energy[w.currentSlot] - 1
    end
  end
  if not control.shootDown[self.player] and self.chargeState ~= 0 then
    if w.current == "megaBuster" then
      if self.chargeState == 1 then
        megautils.add(megaSemiBuster, self.transform.x+(self.side==1 and 17 or -20), 
          self.transform.y+(self.gravity >= 0 and 4 or (self.climb and 8 or 7)), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        megautils.add(megaChargedBuster, self.transform.x+(self.side==1 and 17 or -20), 
          self.transform.y+(self.gravity >= 0 and -2 or 1), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "protoBuster" then
      if self.chargeState == 1 then
        megautils.add(protoSemiBuster, self.transform.x+(self.side==1 and 17 or -16), 
          self.transform.y+(self.climb and 9 or (self.gravity >= 0 and 10 or 7)), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        megautils.add(protoChargedBuster, self.transform.x+(self.side==1 and 16 or -34), 
          self.transform.y+(self.climb and 7 or (self.gravity >= 0 and 9 or 5)), self.side, w)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "rollBuster" then
      if self.chargeState == 1 then
        megautils.add(protoSemiBuster, self.transform.x+(self.side==1 and 19 or -18), 
          self.transform.y+(self.climb and (self.gravity >= 0 and 5 or 9) or (self.gravity >= 0 and 7 or 10)), self.side, w, true)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        megautils.add(protoChargedBuster, self.transform.x+(self.side==1 and 16 or -34), 
          self.transform.y+(self.climb and (self.gravity >= 0 and 4 or 7) or (self.gravity >= 0 and 6 or 8)), self.side, w, true)
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    end
  end
  if control.shootDown[self.player] then
    if self:checkFalse(self.canChargeBuster) and self.chargeColorOutlines[w.current] and
      self.chargeColorOnes[w.current] and self.chargeColorTwos[w.current] then
      self:charge()
    end
  end
end

function megaman:attemptClimb()
  if not control.downDown[self.player] and not control.upDown[self.player] then
    return
  end
  local lads = self:collisionTable(megautils.groups()["ladder"], 0, self.gravity >= 0 and 1 or -1)
  local downDown, upDown
  if self.gravity >= 0 then
    downDown = control.downDown[self.player]
    upDown = control.upDown[self.player]
  else
    downDown = control.upDown[self.player]
    upDown = control.downDown[self.player]
  end
  if #lads ~= 0 then
    self.currentLadder = lads[1]
    local betwn = math.between(self.transform.x+self.collisionShape.w/2,
      self.currentLadder.transform.x, self.currentLadder.transform.x+self.currentLadder.collisionShape.w)
    if (downDown and self.ground and self:collision(self.currentLadder)) or
      (upDown and self.ground and not self:collision(self.currentLadder)) or
      (not betwn) then
      self.currentLadder = nil
      return
    end
    if self.slide then
      self:slideToReg()
    end
    if downDown and betwn and self.ground and not self:collision(self.currentLadder) then
      self.transform.y = self.transform.y + (self.gravity >= 0 and (math.round(self.collisionShape.h/2) + 2) or (-math.round(self.collisionShape.h/2) - 2))
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
    self.animations["climb"]:gotoFrame(1)
    if self.gravity >= 0 then
      self.climbTip = self.transform.y < self.currentLadder.transform.y
    else
      self.climbTip = self.transform.y+self.collisionShape.h > self.currentLadder.transform.y+self.currentLadder.collisionShape.h
    end
    self.transform.x = self.currentLadder.transform.x+(self.currentLadder.collisionShape.w/2)-
      ((self.collisionShape.w)/2)
  end
end

function megaman:checkProtoShield(e, side)
  local x, y = self.transform.x, self.transform.y
  local w, h = self.collisionShape.w, self.collisionShape.h
  
  if side == -1 then
    self.transform.x = x+self.protoShieldLeftCollision.x
    self.transform.y = y+self.protoShieldLeftCollision.y
    self.collisionShape.w = self.protoShieldLeftCollision.w
    self.collisionShape.h = self.protoShieldLeftCollision.h
  else
    self.transform.x = x+self.protoShieldRightCollision.x
    self.transform.y = y+self.protoShieldRightCollision.y
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

function megaman:addHealth(c)
  self.changeHealth = c
  if self.changeHealth ~= 0 then
    self.health = self.health + self.changeHealth
    self.healthHandler.change = self.changeHealth
    self.healthHandler:updateThis()
  end
end

function megaman:healthChanged(o, c, i)
  if not self.control or o.dinked == 2 then return end
  if self.protoShielding and o.dink and self:checkProtoShield(o, self.side) then
    o:dink(self)
    return
  end
  self:addHealth((c < 0 and (self:checkTrue(self.canBeInvincible) or self.maxIFrame ~= self.iFrame)) and 0 or c)
  if self.changeHealth < 0 then
    self.maxIFrame = i
    self.iFrame = 0
    if self.health <= 0 then
      if #globals.allPlayers == 1 then
        if ((self.gravity >= 0 and self.transform.y < view.y+view.h) or (self.gravity < 0 and self.transform.y+self.collisionShape.h > view.y)) then
          explodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-12),
            self.transform.y+((self.collisionShape.h/2)-12))
        end
        self.render = false
        self.control = false
        self.died = true
        healthhandler.playerTimers = {}
        for i=1, maxPlayerCount do
          healthhandler.playerTimers[i] = -2
        end
        megautils.add(timer, 160, function(t)
          megautils.add(fade, true, nil, nil, function(s)
            globals.resetState = true
            globals.mainPlayer = nil
            if not globals.infiniteLives and globals.lives <= 0 then
              megautils.resetGameObjects()
              globals.gameOverContinueState = states.current
              states.set("states/gameover.state.lua")
            else
              globals.manageStageResources = false
              if not globals.infiniteLives then
                globals.lives = globals.lives - 1
              end
              states.set(states.current)
            end
            megautils.remove(s, true)
          end)
          megautils.remove(t, true)
        end)
        megautils.unregisterPlayer(self)
        megautils.remove(self, true)
        mmMusic.stopMusic()
        mmSfx.play("die")
        return
      else
        self.dying = true
        self.iFrame = self.maxIFrame
        megautils.freeze({self})
        local dx, dy
        local ox, oy = camera.main.transform.x, camera.main.transform.y
        camera.main:doView(nil, nil, self)
        dx = camera.main.transform.x
        dy = camera.main.transform.y
        camera.main.transform.x = ox
        camera.main.transform.y = oy
        self.cameraTween = tween.new(0.4, camera.main.transform, {x=dx, y=dy})
        return
      end
    else
      if not self:checkTrue(self.canIgnoreKnockback) then
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
      megautils.add(damageSteam, self.transform.x+((self.collisionShape.w/2)+2)-11, self.transform.y-8)
      megautils.add(damageSteam, self.transform.x+((self.collisionShape.w/2)+2), self.transform.y-8)
      megautils.add(damageSteam, self.transform.x+((self.collisionShape.w/2)+2)+11, self.transform.y-8)
      mmSfx.play("hurt")
    end
  end
end

function megaman:code(dt)
  self.canIgnoreKnockback["global"] = false
  self.protoShielding = false
  self.runCheck = ((control.leftDown[self.player] and not control.rightDown[self.player]) or (control.rightDown[self.player] and not control.leftDown[self.player]))
  if self.hitTimer ~= self.maxHitTime then
    self.hitTimer = math.min(self.hitTimer+1, self.maxHitTime)
    for k, v in pairs(self.knockbackUpdateFuncs) do
      v(self)
    end
    self:phys()
    if self:checkFalse(self.canShoot) and control.shootDown[self.player] then
      self:charge()
    else
      self:charge(true)
    end
  elseif self.treble then
    if self.treble == 2 then
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
        local w = megaman.weaponHandler[self.player]
        w.energy[w.currentSlot] = w.energy[w.currentSlot] - 1
      end
    end
    self:phys()
    if self.treble == 1 then
      if self.animations["trebleStart"].looped then
        self.treble = 2
        self.trebleTimer = 0
        self.canBeInvincible["treble"] = false
      elseif self.animations["trebleStart"].position == 4 and self.trebleTimer == 0 then
        self.trebleTimer = 1
        mmSfx.play("treble_start")
      end
    elseif self.treble == 2 then
      self:attemptWeaponUsage()
    end
    if megaman.weaponHandler[self.player].current ~= "trebleBoost" or
      (megaman.weaponHandler[self.player].current == "trebleBoost" and
      megaman.weaponHandler[self.player].energy[megaman.weaponHandler[self.player].currentSlot] <= 0) then
      self.treble = false
      self.canBeInvincible["treble"] = false
      self.trebleSine = 0
      self.trebleTimer = 0
      self.trebleForce.velx = 0
      self.trebleForce.vely = 0
    end
  elseif self.climb then
    if control.leftDown[self.player] then
      self.side = -1
    elseif control.rightDown[self.player] then
      self.side = 1
    end
    if not self.alwaysMove then
      self.velocity.velx = 0
      self.velocity.vely = 0
    end
    self.transform.x = self.currentLadder.transform.x+(self.currentLadder.collisionShape.w/2)-
      ((self.collisionShape.w)/2)
    local downDown, upDown
    if self.gravity >= 0 then
      downDown = control.downDown[self.player]
      upDown = control.upDown[self.player]
    else
      downDown = control.upDown[self.player]
      upDown = control.downDown[self.player]
    end
    if self.gravity >= 0 then
      downDown = control.downDown[self.player]
      upDown = control.upDown[self.player]
    else
      downDown = control.upDown[self.player]
      upDown = control.downDown[self.player]
    end
    
    if control.upDown[self.player] and self.shootTimer == self.maxShootTime then
      self.velocity.vely = self.climbUpSpeed
    elseif control.downDown[self.player] and self.shootTimer == self.maxShootTime then
      self.velocity.vely = self.climbDownSpeed
    end
    if not self:collision(self.currentLadder) then
      self.climb = false
    elseif upDown and ((self.gravity >= 0 and self.transform.y+((self.collisionShape.h/2)-2) < self.currentLadder.transform.y) or 
      (self.gravity < 0 and self.transform.y+((self.collisionShape.h/2)+2) > self.currentLadder.transform.y+self.currentLadder.collisionShape.h)) then
        self.velocity.vely = 0
        self.transform.y = math.round(self.transform.y)
        local hit = false
        while self:collision(self.currentLadder) do
          collision.shiftObject(self, 0, self.gravity >= 0 and -1 or 1, true)
          if self.ycoll ~= 0 then
            hit = true
            break
          end
        end
        if not hit then
          collision.shiftObject(self, 0, self.gravity >= 0 and 1 or -1, true)
        end
        self.climb = false
    end
    if self.transform.x == view.x-self.collisionShape.w/2 or
      self.transform.x == (view.x+view.w)-self.collisionShape.w/2 or not self:collision(self.currentLadder) then
      self.climb = false
    end
    if self.ground and downDown then
      self.climb = false
    end
    if control.jumpPressed[self.player] and not (downDown or upDown) then
      self.climb = false
    end
    for k, v in pairs(self.climbUpdateFuncs) do
      v(self)
    end
    self:phys()
    self:attemptWeaponUsage()
    if self.shootTimer ~= self.maxShootTime then
      self.velocity.vely = 0      
    end
    if self.gravity >= 0 then
      self.climbTip = self.transform.y < self.currentLadder.transform.y
    else
      self.climbTip = self.transform.y+self.collisionShape.h > self.currentLadder.transform.y+self.currentLadder.collisionShape.h
    end
  elseif self.slide then
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
      self.canIgnoreKnockback["global"] = rb
      if self.slideTimer == self.maxSlideTime and not rb and (self.ground or sb) then
        self.slide = false
        self:slideToReg()
      elseif not rb and self.xcoll ~= 0 then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self:slideToReg()
      elseif self:checkFalse(self.canJump) and self:checkFalse(self.canJumpOutFromDash) and
        control.jumpPressed[self.player] and not rb
        and (self.ground or sb) and not control.downDown[self.player] then
        self.slide = false
        jumped = true
        self.velocity.vely = self.jumpSpeed * (self.gravity < 0 and -1 or 1)
        self.slideTimer = self.maxSlideTime
        self.hitTimer = self.maxHitTime
        self:slideToReg()
        self.dashJump = self:checkFalse(self.canDashJump)
      elseif not (self.ground or sb) and rb then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self.hitTimer = self.maxHitTime
        local w = self.collisionShape.w
        self:regBox()
        while collision.checkSolid(self) do
          self.transform.y = self.transform.y + 1
        end
      elseif self:checkFalse(self.canBackOutFromDash) and lastSide ~= self.side and not rb then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self:slideToReg()
      end
    end
    if not self.slide and not jumped then self.velocity.vely = 0 end
    for k, v in pairs(self.slideUpdateFuncs) do
      v(self)
    end
    self:phys()
    local cd, cs = self:checkFalse(self.canDashShoot), self:checkFalse(self.canShoot)
    if cs and not cd and control.shootDown[self.player] then
      self:charge()
    elseif cs and cd then
      self:attemptWeaponUsage()
    else
      self:charge(true)
    end
    self:attemptClimb()
  elseif self.ground then
    if self:checkFalse(self.canWalk) and not (self.stopOnShot and self.shootTimer ~= self.maxShootTime) then
      if self.runCheck and not self.step then
        self.side = control.leftDown[self.player] and -1 or 1
        local sv = self:checkFalse(self.canStepVelocity)
        if sv or self.stepTime == 0 then
          self.velocity.velx = self.velocity.velx + (self.side==1 and self.stepRightSpeed or self.stepLeftSpeed)
        elseif not sv then
          self.velocity.velx = 0
        end
        self.stepTime = math.min(self.stepTime+1, self.maxStepTime)
        if self.stepTime == self.maxStepTime then
          self.step = true
          self.stepTime = 0
        end
      elseif self.runCheck then
        self.side = control.leftDown[self.player] and -1 or 1
        self.velocity.velx = self.velocity.velx + (self.side == -1 and self.leftSpeed or self.rightSpeed)
      elseif not self.alwaysMove then
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
    if self:checkFalse(self.canDash) and (control.dashPressed[self.player] or
      (control[self.gravity >= 0 and "downDown" or "upDown"][self.player] and control.jumpPressed[self.player])) and
      not self:checkBasicSlideBox(self.side, 0) then
      if self.shootTimer ~= self.maxShootTime then
        self.animations[self.dashAnimation["regular"]]:gotoFrame(
          table.length(self.animations[self.dashAnimation["regular"]].frames))
        self.animations[self.dashAnimation["regular"]]:pause()
      else
        self.animations[self.dashAnimation["regular"]]:gotoFrame(1)
        self.animations[self.dashAnimation["regular"]]:resume()
      end
      self.slide = true
      self:regToSlide()
      self.slideTimer = 0
      megautils.add(slideParticle, self.transform.x+(self.side==-1 and self.collisionShape.w or 4),
        self.transform.y+(self.gravity > 0 and self.collisionShape.h-6 or 0), self.side)
    elseif self:checkFalse(self.canJump) and self.inStandSolid and control.jumpDown[self.player] and
      self.standSolidJumpTimer ~= self.maxStandSolidJumpTime and
      self.standSolidJumpTimer ~= -1 then
      self.velocity.vely = self.jumpSpeed * (self.gravity < 0 and -1 or 1)
      self.standSolidJumpTimer = math.min(self.standSolidJumpTimer+1, self.maxStandSolidJumpTime)
    elseif self:checkFalse(self.canJump) and control.jumpPressed[self.player] and
      not (control[self.gravity >= 0 and "downDown" or "upDown"][self.player] and self:checkBasicSlideBox(self.side, 0)) then
      self.velocity.vely = self.jumpSpeed * (self.gravity < 0 and -1 or 1)
      self.protoShielding = self:checkFalse(self.canProtoShield)
    else
      self.velocity.vely = 0
    end
    if self.standSolidJumpTimer > 0 and (not control.jumpDown[self.player] or
      self.standSolidJumpTimer == self.maxStandSolidJumpTime) then
      self.standSolidJumpTimer = -1
      mmSfx.play("land")
    end
    if self.standSolidJumpTimer == -1 and not control.jumpDown[self.player] then
      self.standSolidJumpTimer = 0
    end
    self.velocity.velx = math.clamp(self.velocity.velx, self.maxLeftSpeed, self.maxRightSpeed)
    for k, v in pairs(self.groundUpdateFuncs) do
      v(self)
    end
    self:phys()
    if not self.ground then
      self.standSolidJumpTimer = -1
    end
    if self:checkFalse(self.canShoot) then
      self:attemptWeaponUsage()
    end
    self:attemptClimb()
  else
    self.protoShielding = self:checkFalse(self.canProtoShield)
    self.wallJumping = false
    local ns = control.leftDown[self.player] and -1 or (control.rightDown[self.player] and 1 or 0)
    if self.wallJumpTimer ~= 0 then
      self.wallJumpTimer = math.max(self.wallJumpTimer-1, 0)
      self.velocity.velx = self.wallKickSpeed * self.side
      if (self.side == 1 and control.rightDown[self.player]) or 
        (self.side == -1 and control.leftDown[self.player]) then
        self.wallJumpTimer = 0
      end
    elseif self:checkFalse(self.canWallJump) and self.velocity.vely > 0 and collision.checkSolid(self, ns, 0) then
      self.side = -ns
      self.velocity.velx = -self.side
      self.wallJumping = true
      self.velocity.vely = self.wallSlideSpeed * (self.gravity >= 0 and 1 or -1)
      if control.jumpPressed[self.player] then
        self.wallJumpTimer = self.maxWallJumpTime
        self.velocity.vely = self.wallJumpSpeed * (self.gravity >= 0 and 1 or -1)
        self.dashJump = true
        megautils.add(kickParticle, self.transform.x+(self.side==1 and -4 or self.collisionShape.w-4),
          self.transform.y+(self.gravity > 0 and self.collisionShape.h-10 or 0), -self.side)
      end
    elseif self.runCheck then
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
    elseif not self.alwaysMove then
      self.velocity:slowX(self.side == -1 and self.leftAirDecel or self.rightAirDecel)
      self.velocity.velx = math.clamp(self.velocity.velx, self.maxLeftAirSpeed, self.maxRightAirSpeed)
      self.stepTime = 0
      self.step = false
    end
    if control.jumpPressed[self.player] and self.extraJumps < self.maxExtraJumps then
      self.extraJumps = self.extraJumps + 1
      self.velocity.vely = self.jumpSpeed * (self.gravity >= 0 and 1 or -1)
    end
    if self:checkFalse(self.canStopJump) and not control.jumpDown[self.player] and
      ((self.gravity < 0 and self.velocity.vely > 0) or (self.gravity >= 0 and self.velocity.vely < 0)) then
      self.velocity:slowY(self.jumpDecel)
    end
    for k, v in pairs(self.airUpdateFuncs) do
      v(self)
    end
    self:phys()
    if self.died then return end
    if self.ground then
      self.dashJump = false
      self.canStopJump["global"] = true
      self.extraJumps = 0
      mmSfx.play("land")
    else
      self:attemptClimb()
    end
    if self:checkFalse(self.canShoot) then
      self:attemptWeaponUsage()
    end
  end
  if megautils.groups()["enemyWeapon"] then
    for k, v in ipairs(megautils.groups()["enemyWeapon"]) do
      if self.protoShielding and not v.dinked and v.dink and self:checkProtoShield(v, self.side) then
        v:dink(self)
      end
    end
  end
  if #self:collisionTable(megautils.groups()["water"]) ~= 0 then
    self.bubbleTimer = math.min(self.bubbleTimer+1, self.maxBubbleTime)
    if self.bubbleTimer == self.maxBubbleTime then
      self.bubbleTimer = 0
      megautils.add(airBubble, self.transform.x+(self.side==-1 and -4 or self.collisionShape.w), self.transform.y+4)
    end
  end
  self.transform.x = math.clamp(self.transform.x, view.x+(-self.collisionShape.w/2)+2,
    (view.x+view.w)+(-self.collisionShape.w/2)-2)
  self.transform.y = math.clamp(self.transform.y, view.y-(self.collisionShape.h*1.4),
    view.y+view.h+4)
  self.shootTimer = math.min(self.shootTimer+1, self.maxShootTime)
  if ((self.gravity >= 0 and self.transform.y >= view.y+view.h) or (self.gravity < 0 and self.transform.y+self.collisionShape.h <= view.y)) or 
    (self.blockCollision and self:checkTrue(self.canGetCrushed) and collision.checkSolid(self)) then
    self.iFrame = self.maxIFrame
    for k, v in pairs(self.canBeInvincible) do
      self.canBeInvincible[k] = false
    end
    self:hurt({self}, -999, 1)
  end
  self:updateIFrame()
  self:updateFlash()
  self.health = self.healthHandler.health
  if self.stopOnShot and self.shootTimer == self.maxShootTime then
    self.stopOnShot = false
  end
  if globals.mainPlayer and control.startPressed[self.player] and self.control and globals.mainPlayer.control and globals.mainPlayer.updated
    and self:checkFalse(self.canPause) then
    self.weaponSwitchTimer = 70
    megautils.add(fade, true, nil, nil, function(s)
          self.pauseMenu = megautils.add(weaponSelect, megaman.weaponHandler[self.player], self.healthHandler, self.player)
          local ff = megautils.add(fade, false, nil, nil, function(ss)
                megautils.freeze({self.pauseMenu})
                megautils.remove(ss, true)
              end)
          megautils.remove(s, true)
          end)
    mmSfx.play("pause")
  end
end

function megaman:resetStates()
  self.step = false
  self.stepTime = 0
  self.climb = false
  self.currentLadder = nil
  self.iFrame = self.maxIFrame
  self.wallJumping = false
  self.dashJump = false
  self.treble = false
  self.trebleSine = 0
  self.trebleTimer = 0
  self.trebleForce.velx = 0
  self.trebleForce.vely = 0
  self.canBeInvincible["treble"] = false
  self.extraJumps = 0
  self.shootTimer = self.maxShootTime
  if self.slide then
    self:slideToReg()
    self.slide = false
  end
  self:useShootAnimation()
end

function megaman:resetCharge()
  self.chargeState = 0
  self.chargeFrame = 1
  self.chargeTimer = 0
  self.chargeTimer2 = 0
  if self.chargeColorOutlines[megaman.weaponHandler[self.player].current]
   and self.chargeColorOnes[megaman.weaponHandler[self.player].current]
    and self.chargeColorTwos[megaman.weaponHandler[self.player].current] then
    megaman.colorOutline[self.player] = self.chargeColorOutlines[megaman.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
    megaman.colorOne[self.player] = self.chargeColorOnes[megaman.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
    megaman.colorTwo[self.player] = self.chargeColorTwos[megaman.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
  end
  mmSfx.stop("charge")
  mmSfx.stop("proto_charge")
end

function megaman:charge(animOnly)
  if self.chargeColorOutlines[megaman.weaponHandler[self.player].current] then
    self.chargeTimer2 = math.min(self.chargeTimer2+1, 4)
    if self.chargeTimer2 == 4 and self.chargeColorOutlines[megaman.weaponHandler[self.player].current]
    and self.chargeColorOnes[megaman.weaponHandler[self.player].current]
      and self.chargeColorTwos[megaman.weaponHandler[self.player].current] then
      self.chargeTimer2 = 0
      self.chargeFrame = math.wrap(self.chargeFrame+1, 1,
        table.length(self.chargeColorOutlines[megaman.weaponHandler[self.player].current][self.chargeState]))
    end
    if not animOnly then
      self.chargeTimer = math.min(self.chargeTimer+1, self.maxChargeTime)
    end
    if self.chargeTimer == self.maxChargeTime and self.chargeState <
      table.length(self.chargeColorOutlines[megaman.weaponHandler[self.player].current])-1 then
      self.chargeTimer = 0
      self.chargeFrame = 1
      if self.chargeState == 0 then
        if megaman.weaponHandler[self.player].current == "protoBuster" then
          mmSfx.play("proto_charge")
        else
          mmSfx.play("charge")
        end
      end
      if animOnly==nil and true or not animOnly then
        self.chargeState = math.min(self.chargeState+1, 
          table.length(self.chargeColorOutlines[megaman.weaponHandler[self.player].current])-1)
      end
    end
    if self.chargeColorOutlines[megaman.weaponHandler[self.player].current]
    and self.chargeColorOnes[megaman.weaponHandler[self.player].current]
      and self.chargeColorTwos[megaman.weaponHandler[self.player].current] then
      megaman.colorOutline[self.player] = self.chargeColorOutlines[megaman.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
      megaman.colorOne[self.player] = self.chargeColorOnes[megaman.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
      megaman.colorTwo[self.player] = self.chargeColorTwos[megaman.weaponHandler[self.player].current][self.chargeState][self.chargeFrame]
    end
  end
end

function megaman:grav()
  if self.climb or self.slide or self.treble then return end
  if self.gravityType == 0 then
    self.velocity.vely = self.velocity.vely+self.gravity
  elseif self.gravityType == 1 then
    self.velocity:slowY(self.gravity)
  end
end

function megaman:phys()
  self.velocity.vely = self.gravity >= 0 and math.min(self.maxAirSpeed, self.velocity.vely) or math.max(-self.maxAirSpeed, self.velocity.vely)
  collision.doCollision(self)
  if self.blockCollision and self:checkFalse(self.canDieFromSpikes) and
    (self.xcoll ~= 0 or self.ycoll ~= 0 or (self.ground and self.gravity ~= 0)) then
    local t = self:collisionTable(megautils.groups()["death"], self.xcoll, self.ycoll+math.sign(self.gravity))
    if #t ~= 0 then
      local lx, ly = self.transform.x, self.transform.y
      local lg = self.ground
      local lcx, lcy = self.xcoll, self.ycoll
      local lss = self.inStandSolid
      local lmf = self.onMovingFloor
      for i=1, #t do
        t[i].isSolid = 0
      end
      collision.shiftObject(self, self.xcoll, self.ycoll+math.sign(self.gravity), true, false)
      for i=1, #t do
        t[i].isSolid = 1
      end
      if collision.checkSolid(self) then
        local dv = self:collisionTable(megautils.groups()["death"])
        self:hurt({self}, dv[1] and dv[1].harm or -9999999, 80)
        if self.health <= 0 then
          self.ground = false
        else
          self.ground = lg
          self.xcoll = lcx
          self.ycoll = lcy
          self.inStandSolid = lss
          self.onMovingFloor = lmf
        end
      else
        self.ground = lg
        self.xcoll = lcx
        self.ycoll = lcy
        self.inStandSolid = lss
        self.onMovingFloor = lmf
      end
      self.transform.x = lx
      self.transform.y = ly
    end
  end
end

function megaman:updatePallete()
  if control.prevDown[self.player] and control.nextDown[self.player]
    and megaman.weaponHandler[self.player].currentSlot ~= 0 then
    megaman.weaponHandler[self.player]:switch(0)
    megaman.colorOutline[self.player] = megaman.weaponHandler[self.player].colorOutline[0]
    megaman.colorOne[self.player] = megaman.weaponHandler[self.player].colorOne[0]
    megaman.colorTwo[self.player] = megaman.weaponHandler[self.player].colorTwo[0]
    local w = math.wrap(megaman.weaponHandler[self.player].currentSlot+1, 0, megaman.weaponHandler[self.player].slotSize)
    while not megaman.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w+1, 0, megaman.weaponHandler[self.player].slotSize)
    end
    self.nextWeapon = w
    w = math.wrap(megaman.weaponHandler[self.player].currentSlot-1, 0, megaman.weaponHandler[self.player].slotSize)
    while not megaman.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w-1, 0, megaman.weaponHandler[self.player].slotSize)
    end
    self.prevWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    mmSfx.play("switch")
  elseif control.nextPressed[self.player] and not control.prevDown[self.player] then
    self.prevWeapon = megaman.weaponHandler[self.player].currentSlot
    local w = math.wrap(megaman.weaponHandler[self.player].currentSlot+1, 0, megaman.weaponHandler[self.player].slotSize)
    while not megaman.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w+1, 0, megaman.weaponHandler[self.player].slotSize)
    end
    megaman.weaponHandler[self.player]:switch(w)
    megaman.colorOutline[self.player] = megaman.weaponHandler[self.player].colorOutline[w]
    megaman.colorOne[self.player] = megaman.weaponHandler[self.player].colorOne[w]
    megaman.colorTwo[self.player] = megaman.weaponHandler[self.player].colorTwo[w]
    w = math.wrap(megaman.weaponHandler[self.player].currentSlot+1, 0, megaman.weaponHandler[self.player].slotSize)
    while not megaman.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w+1, 0, megaman.weaponHandler[self.player].slotSize)
    end
    self.nextWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    mmSfx.play("switch")
  elseif control.prevPressed[self.player] and not control.nextDown[self.player] then
    self.nextWeapon = megaman.weaponHandler[self.player].currentSlot
    local w = math.wrap(megaman.weaponHandler[self.player].currentSlot-1, 0, megaman.weaponHandler[self.player].slotSize)
    while not megaman.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w-1, 0, megaman.weaponHandler[self.player].slotSize)
    end
    megaman.weaponHandler[self.player]:switch(w)
    megaman.colorOutline[self.player] = megaman.weaponHandler[self.player].colorOutline[w]
    megaman.colorOne[self.player] = megaman.weaponHandler[self.player].colorOne[w]
    megaman.colorTwo[self.player] = megaman.weaponHandler[self.player].colorTwo[w]
    w = math.wrap(megaman.weaponHandler[self.player].currentSlot-1, 0, megaman.weaponHandler[self.player].slotSize)
    while not megaman.weaponHandler[self.player].weapons[w] do
      w = math.wrap(w-1, 0, megaman.weaponHandler[self.player].slotSize)
    end
    self.prevWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    mmSfx.play("switch")
  end
end

function megaman:bassBusterAnim(shoot)
  if megaman.weaponHandler[self.player].current ~= "bassBuster" then return shoot end
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

function megaman:animate()
  if self.drop or self.rise then
    self.curAnim = self.dropLanded and self.dropLandAnimation["regular"] or self.dropAnimation["regular"]
  elseif self.control then
    local shoot = "regular"
    if self.shootTimer ~= self.maxShootTime then
      shoot = "shoot"
    end
    if self.treble then
      if self.treble == 2 then
        self.curAnim = self.trebleAnimation[shoot]
      end
    elseif self.hitTimer ~= self.maxHitTime then
      self.curAnim = self.hitAnimation["regular"]
    elseif self.climb then
      shoot = self:bassBusterAnim(shoot)
      self.curAnim = self.climbAnimation[shoot]
      if self.climbTip then
        if self.shootTimer ~= self.maxShootTime then
          self.curAnim = self.climbAnimation[shoot]
        else
          self.curAnim = self.climbTipAnimation["regular"]
        end
      elseif not self.alwaysMove and not (control.downDown[self.player] or
        control.upDown[self.player]) and 
        self.animations[self.climbAnimation["regular"]].status == "playing" then
        self.animations[self.climbAnimation["regular"]]:pause()
      elseif control.downDown[self.player] or control.upDown[self.player] and 
        self.animations[self.climbAnimation["regular"]].status == "paused" then
        self.animations[self.climbAnimation["regular"]]:resume()
      end
      if shoot == "shoot" or shoot == "throw" then
        if self.side == -1 then
          self.animations[self.climbAnimation["regular"]]:gotoFrame(2)
        else
          self.animations[self.climbAnimation["regular"]]:gotoFrame(1)
        end
      end
    elseif self.slide then
      self.curAnim = self.dashAnimation[self:checkFalse(self.canDashShoot) and shoot or "regular"]
    elseif self.ground then
      if self:checkFalse(self.canWalk) and not self.step and self.runCheck then
        shoot = self:bassBusterAnim(shoot)
        if self.standSolidJumpTimer > 0 then
          if self.protoShielding and shoot == "regular" then
            shoot = "ps"
          end
          self.curAnim = self.jumpAnimation[shoot]
        else
          self.curAnim = self.nudgeAnimation[shoot]
        end
      elseif (self:checkFalse(self.canWalk) and ((not self.idleMoving and self.alwaysMove and self.velocity.velx ~= 0) or
        self.runCheck)) and
        not (self.stopOnShot and self.shootTimer ~= self.maxShootTime) then
        self.curAnim = self.runAnimation[shoot]
      else
        shoot = self:bassBusterAnim(shoot)
        self.animations[self.runAnimation["regular"]]:gotoFrame(1)
        self.animations[self.runAnimation["shoot"]]:gotoFrame(1)
        if self.standSolidJumpTimer > 0 then
          if self.protoShielding and shoot == "regular" then
            shoot = "ps"
          end
          self.curAnim = self.jumpAnimation[shoot]
        else
          self.curAnim = self.idleAnimation[shoot]
        end
      end
    else
      if self.wallJumping then
        self.curAnim = self.wallJumpAnimation[shoot]
      else
        shoot = self:bassBusterAnim(shoot)
        if self.protoShielding and shoot == "regular" then
          shoot = "ps"
        end
        self.curAnim = self.jumpAnimation[shoot]
      end
    end
    local time = self.animations[self.curAnim].timer
    if self.curAnim == self.runAnimation["regular"] then
      self.animations[self.runAnimation["shoot"]]:gotoFrame(self.animations[self.runAnimation["regular"]].position)
      self.animations[self.runAnimation["shoot"]].timer = time
    elseif self.curAnim == self.runAnimation["shoot"] then
      self.animations[self.runAnimation["regular"]]:gotoFrame(self.animations[self.runAnimation["shoot"]].position)
      self.animations[self.runAnimation["regular"]].timer = time
    elseif self.curAnim == self.trebleAnimation["regular"] then
      self.animations[self.trebleAnimation["shoot"]]:gotoFrame(self.animations[self.trebleAnimation["regular"]].position)
      self.animations[self.trebleAnimation["shoot"]].timer = time
    elseif self.curAnim == self.trebleAnimation["shoot"] then
      self.animations[self.trebleAnimation["regular"]]:gotoFrame(self.animations[self.trebleAnimation["shoot"]].position)
      self.animations[self.trebleAnimation["regular"]].timer = time
    end
  end
  if self.curAnim ~= self.climbAnimation["regular"] and self.curAnim ~= self.climbTipAnimation["regular"] then
    self:face(self.side)
  else
    self:face(-1)
  end
  self.animations[self.curAnim].flippedV = self.gravity < 0
  self.animations[self.curAnim]:update(1/60)
end

function megaman:update(dt)
  self.player = megautils.networkGameStarted and 1 or self.player
  if self.dying then
    if self.cameraTween:update(1/60) then
      self.control = false
      if self.transform.y < view.y+view.h then
        explodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-12),
          self.transform.y+((self.collisionShape.h/2)-12))
      end
      self.healthHandler.change = self.changeHealth
      self.healthHandler:updateThis()
      healthhandler.playerTimers[self.player] = 180
      megautils.remove(megaman.weaponHandler[self.player], true)
      megautils.remove(self.healthHandler, true)
      megautils.unregisterPlayer(self)
      megautils.remove(self, true)
      megautils.unfreeze()
      mmSfx.play("die")
      return
    end
    view.x, view.y = math.round(camera.main.transform.x), math.round(camera.main.transform.y)
    camera.main:updateFuncs()
  else
    self.runCheck = false
    if self.rise then
      self.control = false
      if self.dropLanded then
        self.dropLanded = not self.animations[self.dropLandAnimation["regular"]].looped
        if not self.dropLanded then
          mmSfx.play("ascend")
        end
      else
        self.teleportOffY = self.teleportOffY+self.riseSpeed
      end
    elseif self.drop then
      if not self.render then
        self.teleportOffY = view.y-self.transform.y
      end
      self.render = true
      self.teleportOffY = math.min(self.teleportOffY+self.dropSpeed, 0)
      if self.teleportOffY == 0 then
        self.dropLanded = true
        if self.animations[self.dropLandAnimation["regular"]].looped then
          self.drop = false
          self.animations[self.dropLandAnimation["regular"]]:gotoFrame(1)
          self.control = true
          mmSfx.play("start")
        end
      end
    elseif self.control then
      self:code(dt)
    end
    if self.doAnimation then self:animate(dt) end
    if self:checkFalse(self.canSwitchWeapons) then self:updatePallete() end
    self.weaponSwitchTimer = math.min(self.weaponSwitchTimer+1, 70)
  end
end

function megaman:afterUpdate(dt)
  if not self.dying and camera.main and globals.mainPlayer == self and
    self:checkFalse(self.canHaveCameraFocus) and not self.drop and not self.rise
    and self.collisionShape then
    camera.main:updateCam(0, self.slide and -3 or 0)
  end
end

function megaman:draw()
  local roundx, roundy = math.round(self.transform.x), math.round(self.transform.y)
  local offsetx, offsety = self.offsetx, self.offsety
  
  if globals.player[self.player] == "bass" then
    offsety, offsetx = -10, -18
    if table.contains(self.climbAnimation, self.curAnim) or 
      table.contains(self.jumpAnimation, self.curAnim) or 
      table.contains(self.wallJumpAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -8 or -12
    elseif table.contains(self.hitAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -6 or -14
    elseif table.contains(self.dashAnimation, self.curAnim) then
      offsety = -10
    end
  elseif globals.player[self.player] == "roll" then
    offsety, offsetx = self.gravity >= 0 and -10 or -3, -18
    if table.contains(self.climbAnimation, self.curAnim) or 
      table.contains(self.jumpAnimation, self.curAnim) or 
      table.contains(self.wallJumpAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -8 or -7
    elseif table.contains(self.hitAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -6 or -14
    elseif table.contains(self.dashAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -17 or -3
    end
  else
    offsety, offsetx = self.gravity >= 0 and -8 or -1, -15
    if table.contains(self.climbAnimation, self.curAnim) or 
      table.contains(self.jumpAnimation, self.curAnim) or 
      table.contains(self.wallJumpAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -2 or -6
    elseif table.contains(self.hitAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -4 or -5
    elseif table.contains(self.dashAnimation, self.curAnim) then
      offsety = self.gravity >= 0 and -13 or -3
    end
  end
  offsety = offsety + self.teleportOffY
  if globals.player[self.player] == "bass" or globals.player[self.player] == "roll" then
    if self.curAnim == "climbShoot" or self.curAnim == "climbShootDM" or self.curAnim == "climbShootUM"
      or self.curAnim == "climbShootU" or self.curAnim == "climbThrow" then
      offsetx = self.side == -1 and -17 or -18
    elseif self.curAnim == "climb" then
      offsetx = self.animations["climb"].position==1 and -18 or -17
    elseif self.curAnim == "slide" then
      offsetx = self.side==1 and -14 or -20
    end
  else
    if self.curAnim == "climbShoot" or self.curAnim == "climbShootDM" or self.curAnim == "climbShootUM"
      or self.curAnim == "climbShootU" or self.curAnim == "climbThrow" then
      offsetx = self.side == -1 and -15 or -16
    elseif self.curAnim == "climb" then
      offsetx = self.animations["climb"].position==1 and -16 or -15
    elseif self.curAnim == "slide" then
      offsetx = self.side==1 and -12 or -18
    end
  end
  
  love.graphics.setColor(megaman.colorOutline[self.player][1]/255, megaman.colorOutline[self.player][2]/255, megaman.colorOutline[self.player][3]/255, 1)
  self.animations[self.curAnim]:draw(self.texOutline, roundx+offsetx,
    roundy+offsety)
  love.graphics.setColor(megaman.colorOne[self.player][1]/255, megaman.colorOne[self.player][2]/255, megaman.colorOne[self.player][3]/255, 1)
  self.animations[self.curAnim]:draw(self.texOne, roundx+offsetx,
    roundy+offsety)
  love.graphics.setColor(megaman.colorTwo[self.player][1]/255, megaman.colorTwo[self.player][2]/255, megaman.colorTwo[self.player][3]/255, 1)
  self.animations[self.curAnim]:draw(self.texTwo, roundx+offsetx,
    roundy+offsety)
  love.graphics.setColor(1, 1, 1, 1)
  self.animations[self.curAnim]:draw(self.texFace, roundx+offsetx,
    roundy+offsety)
  
  if self.weaponSwitchTimer ~= 70 then
    love.graphics.setColor(1, 1, 1, 1)
    if self:checkFalse(self.canHaveThreeWeaponIcons) then
      self.iconQuad:setViewport(self.icons[self.nextWeapon][1],
        self.icons[self.nextWeapon][2], 16, 16)
      love.graphics.draw(self.icoTex, self.iconQuad, roundx+math.round(math.round(self.collisionShape.w/2))+8,
        roundy-18, 0, 1, 1)
      self.iconQuad:setViewport(self.icons[self.prevWeapon][1],
        self.icons[self.prevWeapon][2], 16, 16)
      love.graphics.draw(self.icoTex, self.iconQuad, roundx+math.round(math.round(self.collisionShape.w/2))-24,
        roundy-18, 0, 1, 1)
    end
    self.iconQuad:setViewport(self.icons[megaman.weaponHandler[self.player].currentSlot][1],
      self.icons[megaman.weaponHandler[self.player].currentSlot][2], 16, 16)
    love.graphics.draw(self.icoTex, self.iconQuad, roundx+math.round(math.round(self.collisionShape.w/2))-8,
      roundy-20)
  end
  --self:drawCollision()
end