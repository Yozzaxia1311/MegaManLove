megaMan = entity:extend()

megaMan.autoClean = false

function megaMan.ser()
  local skins = {}
  for k, v in pairs(megaMan.skins) do
    skins[k] = v.path
  end
  return {
    skins = skins,
    oldSkin = megaMan.oldSkin,
    we = megaMan.weaponHandler,
    players = megaMan.allPlayers,
    main = megaMan.mainPlayer ~= nil,
    outline = megaMan.colorOutline,
    one = megaMan.colorOne,
    two = megaMan.colorTwo,
    once = megaMan.once
  }
end

function megaMan.deser(t)
  for k, v in pairs(t.skins) do
    megaMan.setSkin(k, v)
  end
  megaMan.oldSkin = t.oldSkin
  megaMan.weaponHandler = t.we
  megaMan.allPlayers = t.players
  megaMan.colorOutline = t.outline
  megaMan.colorOne = t.one
  megaMan.colorTwo = t.two
  megaMan.mainPlayer = nil
  if t.main then
    megaMan.mainPlayer = megaMan.allPlayers[1]
  end
  megaMan.once = t.once
end

megaMan.mainPlayer = nil
megaMan.allPlayers = {}
megaMan.skins = {}
megaMan.skinCache = {}
megaMan.colorOutline = {}
megaMan.colorOne = {}
megaMan.colorTwo = {}
megaMan.weaponHandler = {}
megaMan.playerCount = 1
megaMan.allPlayers = {}
megaMan.playerToInput = {}
for i = 1, maxPlayerCount do
  megaMan.playerToInput[i] = i
end

function megaMan.resources()
   mmWeaponsMenu.resources()
  
  loader.load("assets/sfx/mmLand.ogg")
  loader.load("assets/sfx/mmHurt.ogg")
  loader.load("assets/sfx/mmStart.ogg")
  loader.load("assets/sfx/mmHeal.ogg")
  loader.load("assets/sfx/ascend.ogg")
  loader.load("assets/sfx/switch.ogg")
  loader.load("assets/sfx/treble.ogg")
  loader.load("assets/players/player.animset")
end

function megaMan:setSkin(path)
  local player = (type(self) == "number") and self or self.player
  
  if table.length(megaMan.skinCache) > maxPlayerCount + 1 then
    for p, skin in safepairs(megaMan.skinCache) do
      if not table.contains(megaMan.skins, skin) then
        megaMan.skinCache[p][2]:release()
        megaMan.skinCache[p][3]:release()
        megaMan.skinCache[p][4]:release()
        megaMan.skinCache[p][5]:release()
        megaMan.skinCache[p] = nil
        if table.length(megaMan.skinCache) <= maxPlayerCount + 1 then
          break
        end
      end
    end
  end
  
  if not path then
    megaMan.skins[player] = nil
  else
    local finfo = love.filesystem.getInfo(path)
    assert(finfo, "Skin \"" .. path .. "\" does not exist")
    
    if not megaMan.skinCache[path] or megaMan.skinCache[path][7] ~= finfo.modtime then
      local t = parseConf(path .. "/conf.txt")
      
      assert(t, "\"" .. path .. "/conf.txt\" could not be parsed")
      
      megaMan.skinCache[path] = {path, imageWrapper(path .. "/player.png"),
        imageWrapper(path .. "/outline.png"),
        imageWrapper(path .. "/one.png"),
        imageWrapper(path .. "/two.png"), t, finfo.modtime}
    end
  end
  
  local p, tex, out, on, tw, t = unpack(megaMan.skinCache[path])
  
  megaMan.skins[player] = {traits = t, path = p, texture = tex, outline = out, one = on, two = tw}
  
  megaMan.registerWeapons(player)
  
  if type(self) == "table" then
    self:syncPlayerSkin()
  end
  
  megautils.runCallback(megautils.skinChangeFuncs, player, path, self)
end

function megaMan:getSkin()
  local player = (type(self) == "number") and self or self.player
  return megaMan.skins[player]
end

megautils.initEngineFuncs.megaMan = {func=function()
    for i=1, maxPlayerCount do
      megaMan.setSkin(i, "assets/players/megaMan")
    end
    
    megaMan.colorOutline = {}
    megaMan.colorOne = {}
    megaMan.colorTwo = {}
    megaMan.weaponHandler = {}
    megaMan.individualLanded = {}
  end, autoClean=false}

megautils.reloadStateFuncs.megaMan = {func=function()
    megaMan.once = nil
    vPad.active = false
  end, autoClean=false}

megautils.cleanFuncs.megaMan = {func=function()
    megaMan.mainPlayer = nil
    megaMan.allPlayers = {}
    vPad.active = false
  end, autoClean=false}

megautils.resetGameObjectsFuncs.megaMan = {func=function()
    megaMan.colorOutline = {}
    megaMan.colorOne = {}
    megaMan.colorTwo = {}
    megaMan.weaponHandler = {}
    megaMan.mainPlayer = nil
    megaMan.allPlayers = {}
    megaMan.individualLanded = {}
    megautils.setLives((megautils.getLives() > globals.startingLives) and megautils.getLives() or globals.startingLives)
    globals.checkpoint = globals.overrideCheckpoint or "start"
    globals.overrideCheckpoint = nil
    megaMan.playerCount = globals.overridePlayerCount or megaMan.playerCount
    globals.overridePlayerCount = nil
    vPad.active = false
    
    megaMan.resources()
    
    for i = 1, megaMan.playerCount do
      megaMan.weaponHandler[i] = weaponHandler(nil, nil, 10)
      megaMan.registerWeapons(i)
    end
  end, autoClean=false}

megautils.difficultyChangeFuncs.megaMan = {func=function(d)
    for _, v in ipairs(megaMan.allPlayers) do
      if d == "easy" then
        v.jumpAnimation.ps = "jumpProtoShield2"
        v.protoShieldLeftCollision = {x=-7, y=0, w=8, h=20, goy=2}
        v.protoShieldRightCollision = {x=10, y=0, w=8, h=20, goy=2}
      else
        v.jumpAnimation.ps = "jumpProtoShield"
        v.protoShieldLeftCollision = {x=-7, y=0, w=8, h=14, goy=8}
        v.protoShieldRightCollision = {x=10, y=0, w=8, h=14, goy=8}
      end
    end
  end, autoClean=false}

mapEntity.register("player", function(v)
    if v.properties.checkpoint == globals.checkpoint and not camera.once then
      camera.once = true
      entities.add(camera, v.x, v.y, v.properties.doScrollX, v.properties.doScrollY)
    end
  end, -1, true)

mapEntity.register("player", function(v)
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

mapEntity.register("player", function(v)
    if v.properties.checkpoint == globals.checkpoint then
      local g = v.properties.gravMult * v.properties.gravFlip
      if v.properties.individual and v.properties.individual > 0 then
        if v.properties.individual <= megaMan.playerCount then
          megaMan.individualLanded[#megaMan.individualLanded+1] = v.properties.individual
          entities.add(megaMan, v.x+11, v.y+((g >= 0) and 11 or 0),
            v.properties.side, v.properties.drop, v.properties.individual,
            v.properties.gravMult, v.properties.gravFlip, v.properties.control,
            v.properties.doReady, v.properties.teleporter, v.properties.doWhistleForReady)
        end
      else
        for i=1, megaMan.playerCount do
          if not table.icontains(megaMan.individualLanded, i) then
            entities.add(megaMan, v.x+11, v.y+((g >= 0) and 11 or 0),
              v.properties.side, v.properties.drop, i, v.properties.gravMult,
                v.properties.gravFlip, v.properties.control,
                v.properties.doReady, v.properties.teleporter, v.properties.doWhistleForReady)
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
  self.maxTrebleSpeed = 2
  self.trebleDecel = 0.1
  if megautils.getDifficulty() == "easy" then
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
  self.canClimb = {global=true}
  self.canHaveCameraFocus = {global=true}
  self.canHaveThreeWeaponIcons = {global=false}
  self.canBeInvincible = {global=false}
  self.canGetCrushed = {global=false}
  self.canStopJump = {global=true}
  self.canStep = {global=true}
  self.canIgnoreKnockback = {global=false}
  self.canProtoShield = {global=false}
  self.canHaveSmallSlide = {global=true}
  self.canControl = {global=(c == nil) or c}
end

function megaMan.registerWeapons(p)
  if megaMan.weaponHandler[p] then
    local skin = megaMan.getSkin(p)
    
    for i=0, 10 do
      if skin.traits["slot" .. i] then
        megaMan.weaponHandler[p]:register(i, skin.traits["slot" .. i], true)
      else
        megaMan.weaponHandler[p]:unregister(i)
      end
    end
    
    for _, v in pairs(globals.defeats) do
      if type(v) == "table" then
        if not v.weaponSlot and not v.weaponName and type(v[1]) == "table" then
          for i = 1, #v do
            megaMan.weaponHandler[p]:register(v[i].weaponSlot or 1, v[i].weaponName or "WEAPON")
          end
        else
          megaMan.weaponHandler[p]:register(v.weaponSlot or 1, v.weaponName or "WEAPON")
        end
      end
    end
  end
end

function megaMan:syncPlayerSkin()
  local skin = megaMan.getSkin(self.player)
  
  self.texOutline = skin.outline
  self.texOne = skin.one
  self.texTwo = skin.two
  self.texBase = skin.texture
  
  self.canWalk.global = skin.traits.canWalk == nil and self.canWalk.global or skin.traits.canWalk
  self.canJump.global = skin.traits.canJump == nil and self.canJump.global or skin.traits.canJump
  self.canShoot.global = skin.traits.canShoot == nil and self.canShoot.global or skin.traits.canShoot
  self.canClimb.global = skin.traits.canClimb == nil and self.canClimb.global or skin.traits.canClimb
  self.canDash.global = skin.traits.canDash == nil and self.canDash.global or skin.traits.canDash
  self.canHaveSmallSlide.global = skin.traits.smallSlideHitbox == nil and self.canHaveSmallSlide.global or
    skin.traits.smallSlideHitbox
  self.canProtoShield.global = skin.traits.protoShield == nil and self.canProtoShield.global or skin.traits.protoShield
  self.protoIdle = skin.traits.protoIdleAnim == nil and self.protoIdle or skin.traits.protoIdleAnim
  self.protoWhistle = skin.traits.protoWhistle == nil and self.protoWhistle or skin.traits.protoWhistle
  self.maxExtraJumps = skin.traits.extraJumps == nil and self.maxExtraJumps or skin.traits.extraJumps
  self.canDashJump.global = skin.traits.canDashJump == nil and self.canDashJump.global or skin.traits.canDashJump
  
  self.shootOffsetXTable = {}
  self.shootOffsetYTable = {}
  for k, v in pairs(skin.traits) do
    local s, e = k:find("shootX")
    if s == 1 and k:len() > e then
      self.shootOffsetXTable[k:sub(e + 1)] = clampSkinShootOffsets and math.clamp(v, 0, 63) or v
    end
    s, e = k:find("shootY")
    if s == 1 and k:len() > e then
      self.shootOffsetYTable[k:sub(e + 1)] = clampSkinShootOffsets and math.clamp(v, 0, 41) or v
    end
  end
  
  self.shootX = skin.traits.shootX or self.shootX
  self.shootY = skin.traits.shootY or self.shootY
  
  self:switchWeaponSlot(0)
end

for i=1, maxPlayerCount do
  megaMan.setSkin(i, "assets/players/megaMan")
end

function megaMan:new(x, y, side, drop, p, g, gf, c, dr, tp, doWhistle)
  megaMan.resources()
  megaMan.super.new(self)
  self.doWeaponGet = states.currentStatePath == globals.weaponGetState
  self.x = x or 0
  self.y = y or 0
  self.player = p or 1
  self.input = megaMan.playerToInput[self.player]
  megaMan.properties(self, g, gf, c)
  self.nextWeapon = 0
  self.prevWeapon = 0
  self.weaponSwitchTimer = 70
  self:regBox()
  self.doAnimation = true
  self.chargeTimer2 = 0
  self.chargeFrame = 1
  self.chargeState = 0
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
  self.shootFrames = 0
  self.stopOnShot = false
  self.slideTimer = self.maxSlideTime
  self.dashJump = false
  self.dropLanded = not self.drop
  self.bubbleTimer = 0
  self.runCheck = false
  self.standSolidJumpTimer = 0
  self.extraJumps = 0
  self.rapidShotTime = 0
  self.treble = false
  self.trebleSine = 0
  self.trebleVelX = 0
  self.trebleVelY = 0
  self.protoShielding = false
  self.doSplashing = not self.drop
  self.teleporter = tp
  self.protoIdle = false
  self.protoWhistle = false
  self.doWhistleForReady = doWhistle
  self.slideXColl = 0
  self.standSolidJumpTimer = -1
  self.shootOffsetXTable = {}
  self.shootOffsetYTable = {}
  self.shootX = 50
  self.shootY = 29
  
  self.dropAnimation = {regular="spawn"}
  self.dropLandAnimation = {regular="spawnLand"}
  self.idleAnimation = {regular="idle", shoot="idleShoot", s_dm="idleShootDM", s_um="idleShootUM",
    s_u="idleShootU", proto="protoIdle"}
  self.nudgeAnimation = {regular="nudge", shoot="idleShoot", s_dm="idleShootDM", s_um="idleShootUM", s_u="idleShootU"}
  self.jumpAnimation = {regular="jump", shoot="jumpShoot", s_dm="jumpShootDM", s_um="jumpShootUM",
    s_u="jumpShootU",
    ps=(megautils.getDifficulty() == "easy") and "jumpProtoShield2" or "jumpProtoShield"}
  self.runAnimation = {regular="run", shoot="runShoot"}
  self.climbAnimation = {regular="climb", shoot="climbShoot", s_dm="climbShootDM", s_um="climbShootUM",
    s_u="climbShootU"}
  self.climbTipAnimation = {regular="climbTip"}
  self.hitAnimation = {regular="hit"}
  self.dashAnimation = {regular="dash", shoot="dashShoot"}
  self.trebleAnimation = {regular="treble", shoot="trebleShoot", start="trebleStart"}
  
  self.anims = animationSet("assets/players/player.animset")
  
  self:syncPlayerSkin()
  
  if self.doWeaponGet then
    self.canControl.global = false
    self.drop = false
    self.y = -self.collisionShape.h
    self.x = math.floor(view.w/2)-(self.collisionShape.w/2)
    self.canDraw.global = false
    self.autoGravity.weaponGet = false
  elseif (dr == nil or dr) and not self.teleporter then
    self._checkDR = true
  end
  self.side = side or 1
  
  self.anims:set(self.drop and "spawn" or "idle")
end

function megaMan:begin()
  if self.drop then
    self.teleportOffY = (not self.teleporter and self.drop) and (view.y-self.y) or 0
  end
end

function megaMan:added()
  megautils.registerPlayer(self)
  
  self:addToGroup("submergable")
  
  if not self.drop then
    self.autoGravity.global = true
  end
  
  if self._checkDR and megaMan.mainPlayer == self then
    if self.doWhistleForReady and self.protoWhistle then
      self.ready = entities.add(ready, nil, 32)
      if music._queue then
        self.mq = music._queue
        music.stop()
      end
      sfx.playFromFile((self.protoWhistle == true) and "assets/sfx/protoReady.ogg" or self.protoWhistle)
    else
      self.ready = entities.add(ready)
    end
    
    self._checkDR = nil
  end
  
  if not self.doWeaponGet then
    if self.healthHandler and not self.healthHandler.isRemoved then
      entities.remove(self.healthHandler)
    end
    
    self.healthHandler = entities.add(healthHandler, nil, nil, nil,
      nil, nil, self._lSeg or globals.lifeSegments, self)
    self._lSeg = nil
    self.healthHandler.canDraw.global = false
    if self._lHealth then
      self.healthHandler:instantUpdate(self._lHealth)
      self._lHealth = nil
    end
    
    if megaMan.weaponHandler[self.player] and not megaMan.weaponHandler[self.player].isRemoved then
      entities.remove(megaMan.weaponHandler[self.player])
    end
    
    local w = entities.adde(megaMan.weaponHandler[self.player])
    megaMan.colorOutline[self.player] = weapon.colors[w.current].outline
    megaMan.colorOne[self.player] = weapon.colors[w.current].one
    megaMan.colorTwo[self.player] = weapon.colors[w.current].two
    w:reinit()
    w.canDraw.global = false
    
    if camera.main and not camera.main.funcs.megaMan then
      camera.main.funcs.megaMan = function(s)
        for i=0, #megaMan.allPlayers-1 do
          local player = megaMan.allPlayers[i+1]
          if player then
            player.healthHandler.canDraw.global = not player.drop
            megaMan.weaponHandler[player.player].canDraw.global = not player.drop
            player.healthHandler.x = view.x+24 + (i*32)
            player.healthHandler.y = view.y+80
            megaMan.weaponHandler[player.player].x = view.x+32 + (i*32)
            megaMan.weaponHandler[player.player].y = view.y+80
          end
        end
      end
    end
  end
  
  megautils.runCallback(megautils.playerCreatedFuncs, self)
end

function megaMan:useShootAnimation()
  self.idleAnimation.shoot = "idleShoot"
  self.nudgeAnimation.shoot = "idleShoot"
  self.jumpAnimation.shoot = "jumpShoot"
  self.runAnimation.shoot = "runShoot"
  self.climbAnimation.shoot = "climbShoot"
  self.dashAnimation.shoot = "dashShoot"
end

function megaMan:useThrowAnimation()
  self.idleAnimation.shoot = "idleThrow"
  self.nudgeAnimation.shoot = "idleThrow"
  self.jumpAnimation.shoot = "jumpThrow"
  self.runAnimation.shoot = "runThrow"
  self.climbAnimation.shoot = "climbThrow"
  self.dashAnimation.shoot = "dashThrow"
end

function megaMan:transferState(to)
  to.ground = self.ground
  to.climb = self.climb
  to.currentLadder = self.currentLadder
  to.side = self.side
  to.gravityMultipliers = table.clone(self.gravityMultipliers)
  to.gravity = self.gravity
  to.x = self.x
  to.y = self.y
  if self.slide and not to.slide then
    if checkFalse(to.canDash) then
      to.slideTimer = to.maxSlideTime
      to:slideBox()
      to.slide = true
    else
      to.tempShortBox = true
      to:shortBox()
    end
  elseif not self.slide and to.slide then
    to.slideTimer = to.maxSlideTime
    to:regBox()
    to.slide = false
  end
  megautils.runCallback(megautils.playerTransferFuncs, self, to)
end

function megaMan:resetStates()
  self.step = false
  self.stepTime = 0
  self.climb = false
  self.currentLadder = nil
  self.iFrames = 0
  self.canDraw.flash = true
  self.dashJump = false
  self.treble = false
  self.trebleSine = 0
  self.trebleTimer = 0
  self.trebleVelX = 0
  self.trebleVelY = 0
  self.canBeInvincible.treble = false
  self.extraJumps = 0
  self.shootFrames = 0
  self.standSolidJumpTimer = -1
  if self.slide then
    self:slideToReg()
    self.slide = false
    self.slideXColl = 0
  end
  self:useShootAnimation()
  self:animate()
end

function megaMan:camOffX()
  return self.cameraOffsetX
end

function megaMan:camOffY()
  return self.cameraOffsetY + (checkFalse(self.canHaveSmallSlide) and
    ((self.gravity >= 0) and (self.slide and -3 or 0) or (self.slide and 4 or 0)) or 0)
end

function megaMan:regBox()
  self:setRectangleCollision(11, 21)
end

function megaMan:basicSlideBox()
  self:setRectangleCollision(11, checkFalse(self.canHaveSmallSlide) and 14 or 21)
end

function megaMan:slideBox()
  self:setRectangleCollision(17, checkFalse(self.canHaveSmallSlide) and 14 or 21)
end

function megaMan:shortBox()
  self:setRectangleCollision(11, 14)
end

function megaMan:checkRegBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.y
  self:regBox()
  self.y = self.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaMan:checkSlideBox(ox, oy)
  local w, h, olx, oly = self.collisionShape.w, self.collisionShape.h, self.x, self.y
  self:slideBox()
  self.x = self.x + (w-self.collisionShape.w)/2
  self.y = self.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.x = olx
  self.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaMan:checkBasicSlideBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.y
  self:basicSlideBox()
  self.y = self.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
  local result = collision.checkSolid(self, ox, oy)
  self.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaMan:regToSlide()
  local h = self.collisionShape.h
  self:basicSlideBox()
  self.y = self.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
end

function megaMan:slideToReg()
  local h = self.collisionShape.h
  self:regBox()
  self.y = self.y + (self.gravity < 0 and 0 or h-self.collisionShape.h)
end

function megaMan:checkLadder(x, y, tip)
  local w, h, ox = self.collisionShape.w, self.collisionShape.h, self.x
  self:setRectangleCollision(1, tip and 1 or h)
  self.x = self.x + (w/2)
  local result = self:collisionTable(collision.getLadders(self:getSurroundingEntities()), x, y)
  local highest = result[1]
  if highest then
    for _, v in ipairs(result) do
      if self.gravity >= 0 and (v.y > highest.y) or (v.y < highest.y) then
        highest = v
      end
    end
  end
  self:setRectangleCollision(w, h)
  self.x = ox
  return highest
end

function megaMan:numberOfShots(n)
  local w = megaMan.weaponHandler[self.player]
  return entities.groups[n .. tostring(w.id)] and #entities.groups[n .. tostring(w.id)] or 0
end

function megaMan:checkWeaponEnergy(n)
  local w = megaMan.weaponHandler[self.player]
  return w.energy[w.slots[n]] > 0
end

function megaMan:shootOffX(n)
  local an, fr = self:animate(true)
  local x, y = self.anims:getFramePosition(fr, an)
  local key =  x .. "-" .. y
  local sotx = self.shootOffsetXTable[key]
  local offx = sotx or self.shootX
  
  if self.side == -1 then
    return self.collisionShape.w - (math.round(self.collisionShape.w/2) - 32 + (n or 0) + offx)
  else
    return math.round(self.collisionShape.w/2) - 32 + (n or 0) + offx
  end
end

function megaMan:shootOffY(n)
  local an, fr = self:animate(true)
  local x, y = self.anims:getFramePosition(fr, an)
  local key =  x .. "-" .. y
  local soty = self.shootOffsetYTable[key]
  local offy = soty or self.shootY
  
  if self.gravity < 0 then
    return self.collisionShape.h - (self.collisionShape.h - 41 + (n or 0) + offy)
  else
    return self.collisionShape.h - 41 + (n or 0) + offy
  end
end

function megaMan:attemptWeaponUsage()
  if not checkFalse(self.canShoot) then return end
  
  local w = megaMan.weaponHandler[self.player]
  local shots = next(megautils.playerAttemptWeaponFuncs) ~= nil and {}
  
  if (input.down["shoot" .. tostring(self.input)] or self.tShoot) and weapon.rapidFireFuncs[w.current] and
    (weapon.ignoreEnergy[w.current] or self:checkWeaponEnergy(w.current)) then
    self.rapidShotTime = math.max(self.rapidShotTime - 1, 0)
    
    if self.rapidShotTime == 0 then
      local e, energy = weapon.rapidFireFuncs[w.current](self)
      
      if e then
        self.shootFrames = weapon.shootFrames[w.current] or 14
        self.rapidShotTime = weapon.rapidFire[w.current] or 5
        if weapon.throwAnim[w.current] then
          self:useThrowAnimation()
        else
          self:useShootAnimation()
        end
        self.stopOnShot = weapon.stopOnShot[w.current]
        self:resetCharge()
        if shots and type(e) == "table" then
          if type(e.is) == "function" and e:is(weapon) then
            shots[#shots + 1] = e
          else
            for i = 1, #e do
              shots[#shots + 1] = e[i]
            end
          end
        end
        if energy and energy ~= 0 then
          w:updateCurrent(w.energy[w.currentSlot] + energy)
        end
      end
    end
  else
    self.rapidShotTime = 0
  end
  
  if (input.pressed["shoot" .. tostring(self.input)] or self.tShootPressed) and weapon.shootFuncs[w.current] and
    (weapon.ignoreEnergy[w.current] or self:checkWeaponEnergy(w.current)) then
    local e, energy = weapon.shootFuncs[w.current](self)
    
    if e then
      self.shootFrames = weapon.shootFrames[w.current] or 14
      if weapon.throwAnim[w.current] then
        self:useThrowAnimation()
      else
        self:useShootAnimation()
      end
      self.stopOnShot = weapon.stopOnShot[w.current]
      self:resetCharge()
      if shots and type(e) == "table" then
        if type(e.is) == "function" and e:is(weapon) then
          shots[#shots + 1] = e
        else
          for i = 1, #e do
            shots[#shots + 1] = e[i]
          end
        end
      end
      if energy and energy ~= 0 then
        w:updateCurrent(w.energy[w.currentSlot] + energy)
      end
    end
  end
  if not (input.down["shoot" .. tostring(self.input)] or self.tShoot) and
    self.chargeState ~= 0 and weapon.chargeShotFuncs[w.current] and
    (weapon.ignoreEnergy[w.current] or self:checkWeaponEnergy(w.current)) and weapon.chargeColors[w.current] then
    local e, energy = weapon.chargeShotFuncs[w.current](self, self.chargeState)
    
    if e then
      self.shootFrames = weapon.shootFrames[w.current] or 14
      if weapon.throwAnim[w.current] then
        self:useThrowAnimation()
      else
        self:useShootAnimation()
      end
      self.stopOnShot = weapon.stopOnShot[w.current]
      self:resetCharge()
      if shots and type(e) == "table" then
        if type(e.is) == "function" and e:is(weapon) then
          shots[#shots + 1] = e
        else
          for i = 1, #e do
            shots[#shots + 1] = e[i]
          end
        end
      end
      if energy and energy ~= 0 then
        w:updateCurrent(w.energy[w.currentSlot] + energy)
      end
    end
  end
  
  if (input.down["shoot" .. tostring(self.input)] or self.tShoot) and
    (w.current ~= "M.BUSTER" or w.current ~= "P.BUSTER" or w.current ~= "R.BUSTER" or
    checkFalse(self.canChargeBuster)) then
    self:charge()
  end
  
  megautils.runCallback(megautils.playerAttemptWeaponFuncs, self, shots)
end

function megaMan:attemptClimb()
  if not checkFalse(self.canClimb) or (not (input.down["down" .. tostring(self.input)] or self.tDown) and
    not (input.down["up" .. tostring(self.input)] or self.tUp)) then
    return
  end
  local lad = self:checkLadder(0, self.gravity >= 0 and 1 or -1)
  local downDown, upDown
  if self.gravity >= 0 then
    downDown = input.down["down" .. tostring(self.input)] or self.tDown
    upDown = input.down["up" .. tostring(self.input)] or self.tUp
  else
    downDown = input.down["up" .. tostring(self.input)] or self.tUp
    upDown = input.down["down" .. tostring(self.input)] or self.tDown
  end
  if lad then
    self.currentLadder = lad
    if (downDown and self.ground and self:collision(self.currentLadder)) or
      (upDown and not self:collision(self.currentLadder)) then
      self.currentLadder = nil
      return
    end
    if self.slide then
      self:slideToReg()
    end
    if downDown and self.ground and not self:collision(self.currentLadder) then
      self.y = self.y + (self.gravity >= 0 and (math.round(self.collisionShape.h*0.3)) or
        (-math.round(self.collisionShape.h*0.3)))
    end
    self.velY = 0
    self.velX = 0
    self.climb = true
    self.dashJump = false
    self.ground = false
    self.slide = false
    self.extraJumps = 0
    self.slideTimer = self.maxSlideTime
    self.climbTip = self.currentLadder and
      not self:checkLadder(0, (self.gravity >= 0) and (self.collisionShape.h * 0.4) or (self.collisionShape.h * 0.6), true)
      and not self:checkLadder(0, self.gravity >= 0 and -1 or self.collisionShape.h, true)
    self.x = self.currentLadder.x+math.floor(self.currentLadder.collisionShape.w/2)-math.floor(self.collisionShape.w/2) - 1
  end
end

function megaMan:checkProtoShield(e, side)
  local x, y = self.x, self.y
  local w, h = self.collisionShape.w, self.collisionShape.h
  
  if side == -1 then
    self.x = x+self.protoShieldLeftCollision.x
    self.y = y+self.protoShieldLeftCollision.y+(self.gravity >= 0 and 0 or self.protoShieldLeftCollision.goy)
    self.collisionShape.w = self.protoShieldLeftCollision.w
    self.collisionShape.h = self.protoShieldLeftCollision.h
  else
    self.x = x+self.protoShieldRightCollision.x
    self.y = y+self.protoShieldRightCollision.y+(self.gravity >= 0 and 0 or self.protoShieldRightCollision.goy)
    self.collisionShape.w = self.protoShieldRightCollision.w
    self.collisionShape.h = self.protoShieldRightCollision.h
  end
  
  local result = self:collision(e)
  
  self.x = x
  self.y = y
  self.collisionShape.w = w
  self.collisionShape.h = h
  
  return result
end

function megaMan:weaponTable(o)
  if o.death and megautils.getDifficulty() == "easy" then
    return -14
  end
end

function megaMan:determineIFrames(o)
  return o.suggestedIFrameForInteracted or 80
end

function megaMan:interactedWith(o, c)
  if not checkFalse(self.canControl) or megautils.isInvincible() or megautils.isNoClip() then return end
  if self.protoShielding and not o.dinked and o.dink and self:checkProtoShield(o, self.side) and o ~= self then
    o:dink(self)
    v.pierceType = pierce.NOPIERCE
    return
  end
  if c < 0 and checkTrue(self.canBeInvincible) and o ~= self then
    self.changeHealth = 0
  else
    self.changeHealth = self:weaponTable(o) or c
    if self.changeHealth < 0 then
      if self.iFrames <= 0 then
        self.iFrames = self:determineIFrames(o)
      else
        return
      end
    end
  end
  megautils.runCallback(megautils.playerInteractedWithFuncs, self, o, self.changeHealth)
  self.healthHandler:updateThis(self.healthHandler.health + self.changeHealth)
  if self.changeHealth < 0 then
    if self.healthHandler.health <= 0 and not self.dead then
      self.dead = true
      self.autoGravity.global = false
      self.autoCollision.global = false
      self.noFreeze = true
      entities.freeze("dying")
      if camera.main then
        if self.input == 1 then
          vPad.active = false
        end
        local active = {}
        for _, v in ipairs(megaMan.allPlayers) do
          if not v.cameraTween then
            active[#active + 1] = v
          end
        end
        
        if #active <= 1 then
          if checkFalse(self.canHaveCameraFocus) and
            not self.drop and not self.rise and self.collisionShape then
            camera.main:updateCam()
          end
          self.cameraTween = timer((((self.gravity >= 0 and self.y < view.y+view.h) or
            (self.gravity < 0 and self.y+self.collisionShape.h > view.y)) and 28 or 0))
          music.stop()
        else
          local dx, dy
          local ox, oy = camera.main.x, camera.main.y
          camera.main:doView(999, 999, self)
          dx = camera.main.x
          dy = camera.main.y
          camera.main.x = ox
          camera.main.y = oy
          camera.main.approachX = oy
          camera.main.approachY = ox
          camera.main:set()
          self.cameraTween = tween.new(0.4, camera.main, {x=dx, y=dy, approachX=dx, approachY=dy})
        end
      else
        self.cameraTween = true
      end
      if o.pierceType == pierce.NOPIERCE and o.pierceType ~= pierce.PIERCEIFKILLING then
        entities.remove(o)
      end
      return
    else
      if not checkTrue(self.canIgnoreKnockback) then
        self.velX = (self.side==1 and self.leftKnockBackSpeed or self.rightKnockBackSpeed)
        self.velY = 0
        self.hitTimer = 0
      end
      if self.slide and not self:checkRegBox() then
        self.slide = false
        self:slideToReg()
      elseif self.slide and self:checkRegBox() then
        self.hitTimer = self.maxHitTime
        self.velX = 0
      end
      self.climb = false
      self.dashJump = false
      entities.add(harm, self)
      entities.add(damageSteam, self.x+(self.collisionShape.w/2)-2.5-11,
        self.y+(self.gravity >= 0 and -8 or self.collisionShape.h), self)
      entities.add(damageSteam, self.x+(self.collisionShape.w/2)-2.5,
        self.y+(self.gravity >= 0 and -8 or self.collisionShape.h), self)
      entities.add(damageSteam, self.x+(self.collisionShape.w/2)-2.5+11,
        self.y+(self.gravity >= 0 and -8 or self.collisionShape.h), self)
      if o.pierceType == pierce.NOPIERCE or o.pierceType == pierce.PIERCEIFKILLING then
        entities.remove(o)
      end
      sfx.play("assets/sfx/mmHurt.ogg")
    end
  end
end

function megaMan:crushed(other)
  if not other.dontKillWhenCrushing then
    for k, _ in pairs(self.canBeInvincible) do
      self.canBeInvincible[k] = false
    end
    self.iFrames = 0
    other:interact(self, -99999, true)
  end
end

function megaMan:beforeCollisionFunc()
  if checkFalse(self.blockCollision) and entities.groups.bossDoor then
    for _, v in ipairs(entities.groups.bossDoor) do
      v._LST = v.solidType
      v.solidType = v.canWalkThrough and 0 or 1
    end
  end
  
  self._lastGround = self.ground
end

function megaMan:afterCollisionFunc()
  if entities.groups.bossDoor then
    for _, v in ipairs(entities.groups.bossDoor) do
      v.solidType = v._LST
      v._LST = nil
    end
  end
  
  self.slideXColl = self.xColl
  
  if not self.slide and self.tempShortBox and not self:checkRegBox() then
    self.tempShortBox = nil
    self:slideToReg()
  end
  
  if not self.ground then
    self.standSolidJumpTimer = -1
  end
  
  if self.ground ~= self._lastGround and self.ground and not self.slide and
    not self.treble and not self.cameraTween and not self.died and not self.climb and not self.justDidClimb then
    self.dashJump = false
    self.canStopJump.global = true
    self.extraJumps = 0
    if checkFalse(self.canControl) then
      sfx.play("assets/sfx/mmLand.ogg")
    end
  end
end

function megaMan:code(dt)
  if self.dieNextFrame then
    self.iFrames = 0
    for k, _ in pairs(self.canBeInvincible) do
      self.canBeInvincible[k] = false
    end
    self:interact(self, -99999, true)
    self.dieNextFrame = nil
  end
  
  self.justDidClimb = false
  
  self.canIgnoreKnockback.global = false
  self.protoShielding = false
  self.runCheck = (((input.down["left" .. tostring(self.input)] or self.tLeft) and
    not (input.down["right" .. tostring(self.input)] or self.tRight)) or
    ((input.down["right" .. tostring(self.input)] or self.tRight) and
    not (input.down["left" .. tostring(self.input)] or self.tLeft)))
  self.blockCollision.noClip = true
  if megautils.isNoClip() then
    self.blockCollision.noClip = false
    self.velX = 0
    self.velY = 0
    local m = (input.down["jump" .. tostring(self.input)] or self.tJump) and 2 or 1
    if self.runCheck then
      if input.down["right" .. tostring(self.input)] or self.tRight then
        self.velX = 2*m
        self.side = 1
      else
        self.velX = -2*m
        self.side = -1
      end
    end
    if (((input.down["up" .. tostring(self.input)] or self.tUp) and
      not (input.down["down" .. tostring(self.input)] or self.tDown)) or
      ((input.down["down" .. tostring(self.input)] or self.tDown) and
      not (input.down["up" .. tostring(self.input)] or self.tUp))) then
      if input.down["down" .. tostring(self.input)] or self.tDown then
        self.velY = 2*m
      else
        self.velY = -2*m
      end
    end
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
          sfx.play("assets/sfx/treble.ogg")
        end
        if self.anims:looped() then
          self.treble = 3
          self.trebleTimer = 0
          self.canBeInvincible.treble = false
        end
      end
    elseif self.treble == 3 and self.hitTimer == self.maxHitTime then
      if self.runCheck then
        self.side = (input.down["left" .. tostring(self.input)] or self.tLeft) and -1 or 1
        self.trebleVelX = math.clamp(self.trebleVelX + (self.side == 1 and 0.1 or -0.1),
          -self.maxTrebleSpeed, self.maxTrebleSpeed)
      else
        self.trebleVelX = math.approach(self.trebleVelX, 0, self.trebleDecel)
      end
      if (((input.down["up" .. tostring(self.input)] or self.tUp) and
        not (input.down["down" .. tostring(self.input)] or self.tDown)) or
        ((input.down["down" .. tostring(self.input)] or self.tDown) and
        not (input.down["up" .. tostring(self.input)] or self.tUp))) then
        self.trebleVelY = math.clamp(self.trebleVelY +
          ((input.down["down" .. tostring(self.input)] or self.tDown) and 0.1 or -0.1),
          -self.maxTrebleSpeed, self.maxTrebleSpeed)
      else
        self.trebleVelY = math.approach(self.trebleVelY, 0, self.trebleDecel)
      end
      self.velX = self.trebleVelX
      self.velY = self.trebleVelY
      self.trebleSine = self.trebleSine + 0.13
      self.velY = self.velY + (math.sin(self.trebleSine) * 0.3)
      self.velX = math.clamp(self.velX, -self.maxTrebleSpeed, self.maxTrebleSpeed)
      self.velY = math.clamp(self.velY, -self.maxTrebleSpeed, self.maxTrebleSpeed)
      self.trebleTimer = self.trebleTimer + 1
      if self.trebleTimer == 60 then
        self.trebleTimer = 0
        local w = megaMan.weaponHandler[self.player]
        w:updateCurrent(w:currentWE() - 1)
      end
      
      self:attemptWeaponUsage()
    end
    
    megautils.runCallback(megautils.playerTrebleFuncs, self)

    if megaMan.weaponHandler[self.player].current ~= "T. BOOST" or
      (megaMan.weaponHandler[self.player].current == "T. BOOST" and
      megaMan.weaponHandler[self.player].energy[megaMan.weaponHandler[self.player].currentSlot] <= 0) then
      self.treble = false
      self.canBeInvincible.treble = false
      self.trebleSine = 0
      self.trebleTimer = 0
      self.trebleVelX = 0
      self.trebleVelY = 0
    end
  elseif self.hitTimer ~= self.maxHitTime then
    self.hitTimer = math.min(self.hitTimer+1, self.maxHitTime)
    megautils.runCallback(megautils.playerKnockbackFuncs, self, self.hitTimer)
    if input.down["shoot" .. tostring(self.input)] or self.tShoot then
      self:charge()
    else
      self:charge(true)
    end
  elseif self.climb then
    self.currentLadder = self:checkLadder(0, (self.gravity >= 0) and (self.collisionShape.h * 0.4) or
      (self.collisionShape.h * 0.6), true)
    local tipc = self.currentLadder ~= nil
    if not self.currentLadder then
      self.currentLadder = self:checkLadder()
    end
    
    self.velX = 0
    self.velY = 0
    
    local downDown, upDown
    if self.gravity >= 0 then
      downDown = input.down["down" .. tostring(self.input)] or self.tDown
      upDown = input.down["up" .. tostring(self.input)] or self.tUp
    else
      downDown = input.down["up" .. tostring(self.input)] or self.tUp
      upDown = input.down["down" .. tostring(self.input)] or self.tDown
    end
    
    if not self.currentLadder or self.ground or
      ((input.pressed["jump" .. tostring(self.input)] or self.tJumpPressed) and not (downDown or upDown)) or
      self.x <= view.x-(self.collisionShape.w/2)+2 or
      self.x >= (view.x+view.w)-(self.collisionShape.w/2)-2 then
      self.climb = false
      self.justDidClimb = true
    elseif upDown and ((self.gravity >= 0 and self.y+(self.collisionShape.h*0.8) < self.currentLadder.y) or 
      (self.gravity < 0 and self.y+(self.collisionShape.h*0.2) > self.currentLadder.y+self.currentLadder.collisionShape.h)) and
      not tipc then
        self.velY = 0
        self.y = math.round(self.y)
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
        self.justDidClimb = true
    else
      if self.runCheck then
        if input.down["left" .. tostring(self.input)] or self.tLeft then
          self.side = -1
        else
          self.side = 1
        end
      end
      self.x = self.currentLadder.x+math.floor(self.currentLadder.collisionShape.w/2)-math.floor(self.collisionShape.w/2) - 1
      if ((input.down["up" .. tostring(self.input)] or self.tUp) or
        (input.down["down" .. tostring(self.input)] or self.tDown)) and self.shootFrames == 0 then
        if input.down["up" .. tostring(self.input)] or self.tUp then
          self.velY = self.climbUpSpeed
        else
          self.velY = self.climbDownSpeed
        end
      end
      if self.currentLadder.velY then
        self.velY = self.velY + self.currentLadder.velY
      end
    end
    
    megautils.runCallback(megautils.playerClimbFuncs, self)
    
    self:attemptWeaponUsage()
    if self.shootFrames ~= 0 then
      self.velY = 0      
    end
    self.currentLadder = self:checkLadder()
    if not self.currentLadder then
      self.climb = false
      self.velY = 0 
    end
    self.climbTip = self.currentLadder and not tipc and not self:checkLadder(0, self.gravity >= 0 and -1 or self.collisionShape.h, true)
  elseif self.slide then
    collision.checkGround(self, true)
    local lastSide = self.side
    if input.down["left" .. tostring(self.input)] or self.tLeft then
      self.side = -1
      self.step = true
      self.stepTime = 0
    elseif input.down["right" .. tostring(self.input)] or self.tRight then
      self.side = 1
      self.step = true
      self.stepTime = 0
    end
    self.velX = self.side==1 and self.slideRightSpeed or self.slideLeftSpeed
    self.velX = math.clamp(self.velX, self.slideLeftSpeed, self.slideRightSpeed)
    local jumped = false
    local sb = self:checkSlideBox(0, math.sign(self.gravity))
    if not sb and not self.ground then
      self.slide = false
      self.velX = 0
      local w = self.collisionShape.w
      self:regBox()
      self.slideTimer = self.maxSlideTime
      local cgrav = self.gravity >= 0 and 1 or -1
      if self:checkRegBox() then
        while collision.checkSolid(self) do
          self.y = self.y + cgrav
        end
      else
        if collision.checkSolid(self) then
          self.y = math.round(self.y + cgrav)
          while collision.checkSolid(self) do
            self.y = self.y - cgrav
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
      elseif not rb and self.slideXColl ~= 0 then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self:slideToReg()
        self.standSolidJumpTimer = -1
      elseif checkFalse(self.canJump) and checkFalse(self.canJumpOutFromDash) and
        (input.pressed["jump" .. tostring(self.input)] or self.tJumpPressed) and not rb
        and (self.ground or sb) and not (input.down["down" .. tostring(self.input)] or self.tDown) then
        self.slide = false
        jumped = true
        self.velY = self.jumpSpeed * (self.gravity >= 0 and 1 or -1)
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
        local cgrav = self.gravity >= 0 and 1 or -1
        self:regBox()
        while collision.checkSolid(self) do
          self.y = self.y + cgrav
        end
      elseif checkFalse(self.canBackOutFromDash) and lastSide ~= self.side and not rb then
        self.slide = false
        self.slideTimer = self.maxSlideTime
        self:slideToReg()
      end
    end
    if not self.slide then
      if not jumped then
        self.velY = 0
      end
      self.slideXColl = 0
    end
    
    megautils.runCallback(megautils.playerSlideFuncs, self)
    
    local cd = checkFalse(self.canDashShoot)
    if not cd and (input.down["shoot" .. tostring(self.input)] or self.tShoot) then
      self:charge()
    elseif cd then
      self:attemptWeaponUsage()
    else
      self:charge(true)
    end
    self:attemptClimb()
  elseif self.ground then
    if checkFalse(self.canWalk) and not (self.stopOnShot and self.shootFrames ~= 0) then
      if self.runCheck and not self.step then
        self.side = (input.down["left" .. tostring(self.input)] or self.tLeft) and -1 or 1
        local sv = checkFalse(self.canStep)
        if sv and self.stepTime == 0 then
          collision.shiftObject(self, (self.side == -1) and self.stepLeftSpeed or self.stepRightSpeed, 0, true)
        end
        self.stepTime = math.min(self.stepTime+1, self.maxStepTime)
        if self.stepTime == self.maxStepTime then
          self.step = true
          self.stepTime = 0
        end
        self.velX = math.approach(self.velX, 0, self.side == -1 and self.leftDecel or self.rightDecel)
      elseif self.runCheck then
        self.side = (input.down["left" .. tostring(self.input)] or self.tLeft) and -1 or 1
        self.velX = self.velX + (self.side == -1 and self.leftSpeed or self.rightSpeed)
      else
        self.velX = math.approach(self.velX, 0, self.side == -1 and self.leftDecel or self.rightDecel)
        self.stepTime = 0
        self.step = false
      end
    else
      if self.runCheck then
        self.side = (input.down["left" .. tostring(self.input)] or self.tLeft) and -1 or 1
      end
      self.velX = math.approach(self.velX, 0, self.side == -1 and self.leftDecel or self.rightDecel)
      self.stepTime = 0
      self.step = false
    end
    if checkFalse(self.canDash) and ((input.pressed["dash" .. tostring(self.input)] or self.tDashPressed) or
      ((input.down[(self.gravity >= 0 and "down" or "up") .. tostring(self.input)] or
      self["t" .. (self.gravity >= 0 and "Down" or "Up")]) and
      (input.pressed["jump" .. tostring(self.input)] or self.tJumpPressed))) and
      not self:checkBasicSlideBox(self.side, 0) then
      self.slide = true
      self:regToSlide()
      self.slideTimer = 0
      entities.add(slideParticle, self.x+(self.side==-1 and self.collisionShape.w-8 or 0),
        self.y+(self.gravity >= 0 and self.collisionShape.h-6 or -2), self, self.side)
    elseif checkFalse(self.canJump) and self.inStandSolid and
      (input.down["jump" .. tostring(self.input)] or self.tJump) and
      self.standSolidJumpTimer ~= self.maxStandSolidJumpTime and
      self.standSolidJumpTimer ~= -1 then
      self.velY = self.jumpSpeed * (self.gravity >= 0 and 1 or -1)
      self.standSolidJumpTimer = math.min(self.standSolidJumpTimer+1, self.maxStandSolidJumpTime)
    elseif checkFalse(self.canJump) and (input.pressed["jump" .. tostring(self.input)] or self.tJumpPressed) and
      not ((input.down[(self.gravity >= 0 and "down" or "up") .. tostring(self.input)] or
      self["t" .. (self.gravity >= 0 and "Down" or "Up")]) and
      self:checkBasicSlideBox(self.side, 0)) then
      self.velY = self.jumpSpeed * (self.gravity >= 0 and 1 or -1)
      self.protoShielding = checkFalse(self.canProtoShield)
      self.ground = false
    else
      self.velY = 0
    end
    if self.standSolidJumpTimer > 0 and (not (input.down["jump" .. tostring(self.input)] or self.tJump) or
      self.standSolidJumpTimer == self.maxStandSolidJumpTime) then
      self.standSolidJumpTimer = -1
      sfx.play("assets/sfx/mmLand.ogg")
    end
    if self.standSolidJumpTimer == -1 and not (input.down["jump" .. tostring(self.input)] or self.tJump) then
      self.standSolidJumpTimer = 0
    end
    self.velX = math.clamp(self.velX, self.maxLeftSpeed, self.maxRightSpeed)
    
    megautils.runCallback(megautils.playerGroundFuncs, self)
    
    self:attemptWeaponUsage()
    self:attemptClimb()
  else
    self.protoShielding = checkFalse(self.canProtoShield)
    if self.runCheck then
      self.side = (input.down["left" .. tostring(self.input)] or self.tLeft) and -1 or 1
      self.velX = self.velX + (self.side == -1 and 
        (self.dashJump and self.slideLeftSpeed*self.dashJumpMultiplier or self.leftAirSpeed) or 
        (self.dashJump and self.slideRightSpeed*self.dashJumpMultiplier or self.rightAirSpeed))
      if self.dashJump then
        self.velX = math.clamp(self.velX, -(self.slideLeftSpeed*self.dashJumpMultiplier),
          (self.slideLeftSpeed*self.dashJumpMultiplier))
      else
        self.velX = math.clamp(self.velX, self.maxLeftAirSpeed, self.maxRightAirSpeed)
      end
      self.stepTime = 0
      self.step = true
    else
      self.velX = math.approach(self.velX, 0, self.side == -1 and self.leftAirDecel or self.rightAirDecel)
      self.velX = math.clamp(self.velX, self.maxLeftAirSpeed, self.maxRightAirSpeed)
      self.stepTime = 0
      self.step = false
    end
    if (input.pressed["jump" .. tostring(self.input)] or self.tJumpPressed) and
      self.extraJumps < self.maxExtraJumps then
      self.extraJumps = self.extraJumps + 1
      self.velY = self.jumpSpeed * (self.gravity >= 0 and 1 or -1)
    end
    if checkFalse(self.canStopJump) and not (input.down["jump" .. tostring(self.input)] or self.tJump) and
      ((self.gravity < 0 and self.velY > 0) or (self.gravity >= 0 and self.velY < 0)) then
      self.velY = math.approach(self.velY, 0, self.jumpDecel)
    end
    
    megautils.runCallback(megautils.playerAirFuncs, self)
    
    self:attemptClimb()
    self:attemptWeaponUsage()
  end
  if entities.groups.enemyWeapon then
    for _, v in safeipairs(entities.groups.enemyWeapon) do
      if self.protoShielding and not v.dinked and v.dink and self:checkProtoShield(v, self.side) then
        v:dink(self)
        v.pierceType = pierce.NOPIERCE
      end
    end
  end
  if self:collisionNumber(entities.groups.water) ~= 0 then
    self.bubbleTimer = math.min(self.bubbleTimer+1, self.maxBubbleTime)
    if self.bubbleTimer == self.maxBubbleTime then
      self.bubbleTimer = 0
      entities.add(airBubble, self.x+(self.side==-1 and -4 or self.collisionShape.w), self.y+4, self)
    end
  end
  self.x = math.clamp(self.x, view.x+(-self.collisionShape.w/2)+2,
    (view.x+view.w)+(-self.collisionShape.w/2)-2)
  self.y = math.clamp(self.y, view.y-(self.collisionShape.h*1.4),
    view.y+view.h+4)
  self.shootFrames = math.max(self.shootFrames-1, 0)
  if ((self.gravity >= 0 and self.y >= view.y+view.h) or (self.gravity < 0 and
    self.y+self.collisionShape.h <= view.y)) or (checkFalse(self.blockCollision) and
    checkTrue(self.canGetCrushed) and collision.checkSolid(self)) then
    self.dieNextFrame = true
    self.pitDeath = true
  end
  self:updateIFrame()
  self:updateFlash()
  if self.stopOnShot and self.shootFrames == 0 then
    self.stopOnShot = false
  end
  
  if self.treble or self.climb or self.slide then
    self.autoGravity.sub = false
  else
    self.autoGravity.sub = true
  end
  
  if megaMan.mainPlayer and (input.pressed["start" .. tostring(self.input)] or self.tStartPressed) and
    checkFalse(megaMan.mainPlayer.canControl) and checkFalse(megaMan.mainPlayer.canUpdate) and
    checkFalse(self.canPause) then
    self.weaponSwitchTimer = 70
    vPad.active = false
    mmWeaponsMenu.pause(self)
  end
  
  megautils.runCallback(megautils.playerControlUpdateFuncs, self)
end

function megaMan:resetCharge()
  self.chargeState = 0
  self.chargeFrame = 1
  self.chargeTimer = 0
  self.chargeTimer2 = 0
  local w = megaMan.weaponHandler[self.player]
  megaMan.colorOutline[self.player] = weapon.colors[w.current].outline
  megaMan.colorOne[self.player] = weapon.colors[w.current].one
  megaMan.colorTwo[self.player] = weapon.colors[w.current].two
  sfx.stop(weapon.chargeSounds[w.current])
end

function megaMan:charge(animOnly)
  if not checkFalse(self.canShoot) then return end
  local w = megaMan.weaponHandler[self.player]
  if weapon.chargeColors[w.current] then
    if self.chargeState > 0 then
      self.chargeTimer2 = math.min(self.chargeTimer2+1, 4)
      if self.chargeTimer2 == 4 then
        self.chargeTimer2 = 0
        self.chargeFrame = math.wrap(self.chargeFrame+1, 1, table.length(weapon.chargeColors[w.current].outline[self.chargeState]))
      end
    end
    if not animOnly then
      self.chargeTimer = math.min(self.chargeTimer+1, self.maxChargeTime)
    end
    if self.chargeTimer == self.maxChargeTime and self.chargeState <
      table.length(weapon.chargeColors[w.current].outline) then
      self.chargeTimer = 0
      self.chargeFrame = 1
      if self.chargeState == 0 then
        sfx.play(weapon.chargeSounds[w.current])
      end
      if not animOnly then
        self.chargeState = math.min(self.chargeState+1, 
          table.length(weapon.chargeColors[w.current].outline))
      end
    end
    
    if self.chargeState > 0 then
      megaMan.colorOutline[self.player] = weapon.chargeColors[w.current].outline[self.chargeState][self.chargeFrame]
      megaMan.colorOne[self.player] = weapon.chargeColors[w.current].one[self.chargeState][self.chargeFrame]
      megaMan.colorTwo[self.player] = weapon.chargeColors[w.current].two[self.chargeState][self.chargeFrame]
    else
      megaMan.colorOutline[self.player] = weapon.colors[w.current].outline
      megaMan.colorOne[self.player] = weapon.colors[w.current].one
      megaMan.colorTwo[self.player] = weapon.colors[w.current].two
    end
  end
end

function megaMan:grav()
  if not megautils.isNoClip() then
    if self.gravityType == 0 then
      self.velY = self.velY + self.gravity
    elseif self.gravityType == 1 then
      self.velY = math.approach(self.velY, 0, self.gravity)
    end
    self.velY = self.gravity >= 0 and math.min(self.maxAirSpeed, self.velY) or
      math.max(-self.maxAirSpeed, self.velY)
  end
end

function megaMan:attemptWeaponSwitch()
  if input.down["prev" .. tostring(self.input)] and input.down["next" .. tostring(self.input)]
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
    sfx.play("assets/sfx/switch.ogg")
  elseif input.pressed["next" .. tostring(self.input)] and not input.pressed["prev" .. tostring(self.input)] then
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
    sfx.play("assets/sfx/switch.ogg")
  elseif input.pressed["prev" .. tostring(self.input)] and not input.pressed["next" .. tostring(self.input)] then
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
    sfx.play("assets/sfx/switch.ogg")
  end
end

function megaMan:switchWeapon(n)
  local w = megaMan.weaponHandler[self.player]
  local changing = w.current ~= n
  w:switchName(n)
  megaMan.colorOutline[self.player] = weapon.colors[w.current].outline
  megaMan.colorOne[self.player] = weapon.colors[w.current].one
  megaMan.colorTwo[self.player] = weapon.colors[w.current].two
  if changing then
    self:resetCharge()
  end
end

function megaMan:switchWeaponSlot(s)
  local w = megaMan.weaponHandler[self.player]
  local changing = w.currentSlot ~= s
  w:switch(s)
  megaMan.colorOutline[self.player] = weapon.colors[w.current].outline
  megaMan.colorOne[self.player] = weapon.colors[w.current].one
  megaMan.colorTwo[self.player] = weapon.colors[w.current].two
  if changing then
    self:resetCharge()
  end
end

function megaMan:bassBusterAnim(shoot)
  if not weapon.sevenWayAnim[megaMan.weaponHandler[self.player].current] then return shoot end
  local dir = shoot
  if self.shootFrames ~= 0 then
    if input.down["up" .. tostring(self.input)] or self.tUp then
      if (input.down["left" .. tostring(self.input)] or self.tLeft) or
        (input.down["right" .. tostring(self.input)] or self.tRight) then
        dir = self.gravity >= 0 and "s_um" or "s_dm"
      else
        dir = self.gravity >= 0 and "s_u" or "s_dm"
      end
    elseif input.down["down" .. tostring(self.input)] or self.tDown then
      if self.gravity < 0 and ((input.down["left" .. tostring(self.input)] or self.tLeft) or
        (input.down["right" .. tostring(self.input)] or self.tRight)) then
        dir = "s_um"
      else
        dir = self.gravity >= 0 and "s_dm" or "s_u"
      end
    end
  end
  return dir
end

function megaMan:animate(getDataOnly)
  local newAnim = self.anims.current
  local newFrame
  local newTime
  local pause
  local resume
  
  if self.drop or self.rise then
    newAnim = self.dropLanded and self.dropLandAnimation.regular or self.dropAnimation.regular
  elseif checkFalse(self.canControl) then
    local shoot = "regular"
    if self.shootFrames ~= 0 then
      shoot = "shoot"
    end
    if self.treble then
      if self.treble == 1 then
        newAnim = self.idleAnimation.regular
      elseif self.treble == 2 then
        newAnim = self.trebleAnimation.start
      elseif self.treble == 3 then
        if table.contains(self.trebleAnimation, self.anims.current) and
          self.anims.current ~= self.trebleAnimation.start and
          self.anims.current ~= self.trebleAnimation[shoot] then
          newAnim, newFrame, newTime = self.trebleAnimation[shoot], self.anims:frame(), self.anims:time()
        else
          newAnim = self.trebleAnimation[shoot]
        end
      end
    elseif self.hitTimer ~= self.maxHitTime then
      newAnim = self.hitAnimation.regular
    elseif self.climb then
      shoot = self:bassBusterAnim(shoot)
      newAnim = self.climbAnimation[shoot]
      if self.climbTip then
        if self.shootFrames ~= 0 then
          newAnim = self.climbAnimation[shoot]
        else
          newAnim = self.climbTipAnimation.regular
        end
      elseif not ((input.down["down" .. tostring(self.input)] or self.tDown) or
        (input.down["up" .. tostring(self.input)] or self.tUp)) then
        pause = true
        if shoot == "regular" and self.anims.current ~= self.climbAnimation.regular and
          table.contains(self.climbAnimation, self.anims.current) then
          if self.side == 1 then
            newFrame = 2
          else
            newFrame = 1
          end
        end
      elseif ((input.down["down" .. tostring(self.input)] or self.tDown) or
        (input.down["up" .. tostring(self.input)] or self.tUp)) and self.anims:isPaused() then
        resume = true
      end
    elseif self.slide then
      newAnim = self.dashAnimation[checkFalse(self.canDashShoot) and shoot or "regular"]
      if shoot == "regular" and self.anims.current ~= self.dashAnimation.regular and table.contains(self.dashAnimation, self.anims.current) then
        newFrame = self.anims:length(self.dashAnimation.regular)
      end
    elseif self.ground then
      if checkFalse(self.canWalk) and not self.step and self.runCheck then
        shoot = self:bassBusterAnim(shoot)
        if self.standSolidJumpTimer > 0 then
          if self.protoShielding and shoot == "regular" then
            shoot = "ps"
          end
          newAnim = self.jumpAnimation[shoot]
        else
          newAnim = self.nudgeAnimation[shoot]
        end
      elseif checkFalse(self.canWalk) and self.runCheck and
        not (self.stopOnShot and self.shootFrames ~= 0) then
        if table.contains(self.runAnimation, self.anims.current) and self.anims.current ~= self.runAnimation[shoot] then
          newAnim, newFrame, newTime = self.runAnimation[shoot], self.anims:frame(), self.anims:time()
        else
          newAnim = self.runAnimation[shoot]
        end
      else
        shoot = self:bassBusterAnim(shoot)
        if self.standSolidJumpTimer > 0 then
          if self.protoShielding and shoot == "regular" then
            shoot = "ps"
          end
          newAnim = self.jumpAnimation[shoot]
        else
          if shoot == "regular" and self.protoIdle then
            shoot = "proto"
          end
          newAnim = self.idleAnimation[shoot]
        end
      end
    else
      shoot = self:bassBusterAnim(shoot)
      if self.protoShielding and shoot == "regular" then
        shoot = "ps"
      end
      newAnim = self.jumpAnimation[shoot]
    end
  end
  
  if not getDataOnly then
    if newAnim then
      self.anims:set(newAnim)
    end
    if newFrame then
      self.anims:gotoFrame(newFrame)
    end
    if newTime then
      self.anims:setTime(newTime)
    end
    if pause then
      self.anims:pause()
    end
    if resume then
      self.anims:resume()
    end
    
    self.anims:update(1/60)
  else
    return newAnim, newFrame, newTime, pause, resume
  end
end

function megaMan:die()
  if not self.pitDeath then
    deathExplodeParticle.createExplosion(self.x+((self.collisionShape.w/2)-12),
      self.y+((self.collisionShape.h/2)-12))
  end
  
  if self.healthHandler.health ~= 0 then
    self.healthHandler:updateThis(0)
  end
  
  if #megaMan.allPlayers == 1 then
    healthHandler.playerTimers = {}
    for i=1, maxPlayerCount do
      healthHandler.playerTimers[i] = -2
    end
    
    entities.add(timer, 160, function(t)
      entities.add(fade, true, nil, nil, function(s)
        megautils.reloadState = true
        if not megautils.hasInfiniteLives() then
          megautils.setLives(math.max(megautils.getLives()-1, -1))
        end
        if not megautils.hasInfiniteLives() and megautils.getLives() < 0 then
          megautils.reloadState = true
          megautils.resetGameObjects = true
          globals.gameOverContinueState = states.currentStatePath
          states.setq(globals.gameOverState)
        else
          megautils.reloadState = true
          megautils.resetGameObjects = false
          states.setq(states.currentStatePath)
        end
        entities.remove(s)
      end)
      entities.remove(t)
    end)
  else
    healthHandler.playerTimers[self.player] = 180
    entities.remove(megaMan.weaponHandler[self.player])
    entities.remove(self.healthHandler)
  end
  self.canDraw.global = false
  self.canControl.global = false
  self.died = true
  
  if self.input == 1 then
    vPad.active = false
  end
  
  self._lHealth = nil
  self._lSeg = nil
  entities.remove(self)
  sfx.play("assets/sfx/dieExplode.ogg")
end

function megaMan:removed()
  megautils.unregisterPlayer(self)
  self._lHealth = self.healthHandler and self.healthHandler.health
  self._lSeg = self.healthHandler and self.healthHandler.segments
end

function megaMan:update()
  if self.input == 1 then
    local exludeTrans = {unpack(self.canControl)}
    exludeTrans.trans = nil
    vPad.active = not self.died and not self.cameraTween and checkFalse(exludeTrans) and not self.doWeaponGet and input.usingTouch
    self.tLeft = vPad.down.left
    self.tLeftPressed = vPad.pressed.left
    self.tRight = vPad.down.right
    self.tRightPressed = vPad.pressed.right
    self.tUp = vPad.down.up
    self.tUpPressed = vPad.pressed.up
    self.tDown = vPad.down.down
    self.tDownPressed = vPad.pressed.down
    self.tJump = vPad.down.jump
    self.tJumpPressed = vPad.pressed.jump
    self.tShoot = vPad.down.shoot
    self.tShootPressed = vPad.pressed.shoot
    self.tDash = vPad.down.dash
    self.tDashPressed = vPad.pressed.dash
    self.tStart = vPad.down.start
    self.tStartPressed = vPad.pressed.start
    self.tSelect = vPad.down.select
    self.tSelectPressed = vPad.pressed.select
  end
  
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
      self._halfWidth = love.graphics.newText(mmFont, self._text):getWidth()/2
      self._w1 = megaMan.weaponHandler[self.player].current
      self._w2 = self._wgv and self._wgv.weaponName
      self.canDraw.global = true
    elseif self._subState == 0 then
      self.y = math.min(self.y + 10, math.floor(view.h/2)-(self.collisionShape.h/2))
      if self.y == math.floor(view.h/2)-(self.collisionShape.h/2) then
        self._subState = (type(self._wgv) == "table") and 1 or 2
        if self._subState == 1 then
          megaMan.weaponHandler[self.player]:register(self._wgv.weaponSlot or 1,
            self._wgv.weaponName or "WEAPON")
        end
      end
    elseif self._subState == 1 then
      self._timer = self._timer + 1
      self:switchWeapon((self._timer % 16 > 8) and self._w2 or self._w1)
      local w = megaMan.weaponHandler[self.player]
      banner.colorOutline = weapon.colors[w.current].outline
      banner.colorOne = weapon.colors[w.current].one
      banner.colorTwo = weapon.colors[w.current].two
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
        states.fadeToState(self._wgs)
      end
    end
    self.anims:update(1/60)
  else
    if megaMan.mainPlayer and megaMan.mainPlayer.ready then
      if megaMan.mainPlayer == self and self.ready.isRemoved then
        self.ready = nil
        if self.mq then
          music.playq(unpack(self.mq))
          self.mq = nil
        end
      end
      self.teleportOffY = nil
      self._rw = true
    elseif self.dead then
      megautils.runCallback(megautils.playerDeathFuncs, self)
      local done = self.cameraTween:update(1/60)
      if camera.main then
        camera.main:set()
      end
      if done then
        self:die()
        entities.unfreeze("dying")
        return
      end
    else
      self.runCheck = false
      if self.rise then
        self.autoGravity.global = false
        if not self.teleportOffY then
          self.teleportOffY = 0
        end
        if self.dropLanded then
          self.dropLanded = not self.anims:looped()
          if not self.dropLanded then
            self.doSplashing = false
            sfx.play("assets/sfx/ascend.ogg")
          end
        else
          self.teleportOffY = self.teleportOffY+self.riseSpeed
        end
      elseif self.drop then
        self.autoGravity.global = false
        if not self.teleportOffY then
          self.teleportOffY = (not self.teleporter and self.drop) and (view.y-self.y) or 0
        end
        self.teleportOffY = math.min(self.teleportOffY+self.dropSpeed, 0)
        if self.teleportOffY == 0 then
          self.dropLanded = true
          if self.anims:looped() then
            self.drop = false
            self.autoGravity.global = true
            self.doSplashing = true
            self.teleportOffY = nil
            self.anims:set(self.ground and self.idleAnimation.regular or self.jumpAnimation.regular)
            sfx.play("assets/sfx/mmStart.ogg")
          end
        end
      elseif checkFalse(self.canControl) then
        self:code(dt)
      end
      if self.doAnimation then self:animate() end
      if checkFalse(self.canSwitchWeapons) and not self.drop and not self.rise then self:attemptWeaponSwitch() end
      self.weaponSwitchTimer = math.min(self.weaponSwitchTimer+1, 70)
    end
  end
end

function megaMan:afterUpdate(dt)
  if not self.dead and camera.main and megaMan.mainPlayer == self and
    checkFalse(self.canHaveCameraFocus) and not self.drop and not self.rise
    and self.collisionShape and not self.cameraTween then
    camera.main:updateCam()
  end
end

function megaMan:draw()
  if (megaMan.mainPlayer and megaMan.mainPlayer.ready) or (self.drop and entities.checkFrozen("fade")) or
    self.dieNextFrame or self._rw then
    if self._rw then
      self._rw = nil
    end
    return
  end
  
  local offsetx, offsety = math.round(self.collisionShape.w/2),
    (self.gravity >= 0 and self.collisionShape.h or 0) + (self.teleportOffY or 0)
  local floorX, floorY = drawShader and #megaMan.allPlayers == 1 and (camera.main == nil or camera.main.transition or
    camera.main.x <= camera.main.scrollx or
    camera.main.x + camera.main.collisionShape.w >= camera.main.scrollx + camera.main.scrollw),
    drawShader and #megaMan.allPlayers == 1 and (camera.main == nil or camera.main.transition or
    camera.main.y <= camera.main.scrolly or
    camera.main.y + camera.main.collisionShape.h >= camera.main.scrolly + camera.main.scrollh)
  local thisX, thisY = floorX and self.x or math.floor(self.x), floorY and self.y or math.floor(self.y)
  local fx = self.side ~= 1
  local sy = self.gravity >= 0 and 1 or -1
  
  if table.contains(self.climbAnimation, self.anims.current) then
    if self.anims.current == self.climbAnimation.regular or self.anims.current == self.climbTipAnimation.regular then
      fx = false
    end
    
    if not (not fx and self.anims.current ~= "climb") then
      offsetx = offsetx + 1
    end
  end
  
  love.graphics.setColor(1, 1, 1, 1)
  self.texBase:draw(self.anims, thisX, thisY, 0, 1, sy, 32, 41, offsetx, offsety, fx)
  love.graphics.setColor(megaMan.colorOutline[self.player][1]/255, megaMan.colorOutline[self.player][2]/255,
    megaMan.colorOutline[self.player][3]/255, 1)
  self.texOutline:draw(self.anims, thisX, thisY, 0, 1, sy, 32, 41, offsetx, offsety, fx)
  love.graphics.setColor(megaMan.colorOne[self.player][1]/255, megaMan.colorOne[self.player][2]/255,
    megaMan.colorOne[self.player][3]/255, 1)
  self.texOne:draw(self.anims, thisX, thisY, 0, 1, sy, 32, 41, offsetx, offsety, fx)
  love.graphics.setColor(megaMan.colorTwo[self.player][1]/255, megaMan.colorTwo[self.player][2]/255,
    megaMan.colorTwo[self.player][3]/255, 1)
  self.texTwo:draw(self.anims, thisX, thisY, 0, 1, sy, 32, 41, offsetx, offsety, fx)
  
  if self.weaponSwitchTimer ~= 70 then
    love.graphics.setColor(1, 1, 1, 1)
    local w = megaMan.weaponHandler[self.player]
    local woff = self.gravity >= 0 and -20 or (self.collisionShape.h + 4)
    local cgrav = self.gravity >= 0 and 1 or -1
    if checkFalse(self.canHaveThreeWeaponIcons) then
      weapon.drawIcon(w.weapons[self.nextWeapon], true, thisX+math.round(self.collisionShape.w/2)+8,
        thisY+woff+(2*cgrav))
      weapon.drawIcon(w.weapons[self.prevWeapon], true, thisX+math.round(self.collisionShape.w/2)-24,
        thisY+woff+(2*cgrav))
    end
    weapon.drawIcon(w.current, true, thisX+math.round(self.collisionShape.w/2)-8, thisY+woff)
  end
  
  if self.doWeaponGet and self._text then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self._text:sub(0, self._textPos or 0), (view.w/2)-self._halfWidth, 142)
  end
end
