addobjects.register("player_one", function(v)
  if (v.properties["spawnCamera"] == nil or v.properties["spawnCamera"]) and
    v.properties["checkpoint"] == globals.checkpoint then
    megautils.add(camera(v.x, v.y, v.properties["doScrollX"], v.properties["doScrollY"]))
    camera.once = false
  end
end, -1)

addobjects.register("player_one", function(v)
  if (v.properties["spawnCamera"] == nil or v.properties["spawnCamera"]) and
    v.properties["checkpoint"] == globals.checkpoint and not camera.once and camera.main ~= nil then
    camera.once = true
    camera.main:setRectangleCollision(8, 8)
    camera.main:updateBounds()
    camera.main:setRectangleCollision(view.w, view.h)
    camera.main.transform.x = math.round(v.x) - (view.w/2) + ((11)/2)
    camera.main.transform.x = math.clamp(camera.main.transform.x, camera.main.scrollx,
      camera.main.scrollx+camera.main.scrollw-view.w)
    camera.main.transform.y = math.round(v.y-5) - (view.h/2) + ((21)/2)
    camera.main.transform.y = math.clamp(camera.main.transform.y, camera.main.scrolly,
      camera.main.scrolly+camera.main.scrollh-view.h)
    view.x, view.y = camera.main.transform.x, camera.main.transform.y
  end
end, 2)

addobjects.register("player_one", function(v)
  if v.properties["checkpoint"] == globals.checkpoint then
    globals.mainPlayer = megaman(v.x, v.y-5, v.properties["side"], v.properties["drop"])
    megautils.add(globals.mainPlayer)
  end
end)

megaman = entity:extend()

function megaman.properties(self)
  self.gravityType = 0
  self.gravity = 0.25
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
  self.dashJumpMultiplier = 1.2
  self.maxSlideTime = 26
  self.climbUpSpeed = -1.3
  self.climbDownSpeed = 1.3
  self.stepLeftSpeed = -1
  self.stepRightSpeed = 1
  self.stepVelocity = false
  self.maxStepTime = 8
  self.maxHitTime = 32
  self.leftKnockBackSpeed = -0.5
  self.rightKnockBackSpeed = 0.5
  self.maxShootTime = 14
  self.alwaysMove = false
  self.inv = false
  self.canGetCrushed = false
  self.canStopJump = true
  self.maxWallJumpTime = 8
  self.wallSlideSpeed = 0.5
  self.canDashShoot = false
  self.canDashJump = false
  self.canDash = true
  self.canShoot = true
  self.canWallJump = false
  self.canChargeBuster = true
  self.canWalk = true
  self.canJump = true
  self.maxNormalBusterShots = 3
  self.cameraFocus = true
  self.threeWeaponIcons = false
  self.cameraOffsetX = 0
  self.cameraOffsetY = 0
  self.cameraWidth = 11
  self.cameraHeight = 21
  self.dropSpeed = 8
  self.riseSpeed = -8
  self.maxBubbleTime = 120
  self.canJumpOutFromDash = true
  self.canBackOutFromDash = true
  self.canSwitchWeapons = true
end

megaman.weaponHandler = {}
megaman.healthHandler = {}

megaman.colorOne = {}
megaman.colorTwo = {}
megaman.colorOutline = {}

function megaman:regBox()
  self:setRectangleCollision(11, 21)
end

function megaman:basicSlideBox()
  self:setRectangleCollision(11, 14)
end

function megaman:slideBox()
  self:setRectangleCollision(17, 14)
end

function megaman:checkRegBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.transform.y
  self:regBox()
  self.transform.y = self.transform.y + (h-self.collisionShape.h)
  local result = self:solid(ox, oy)
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaman:checkSlideBox(ox, oy)
  local s = side
  local w, h, olx, oly = self.collisionShape.w, self.collisionShape.h, self.transform.x, self.transform.y
  self:slideBox()
  self.transform.x = self.transform.x + (w-self.collisionShape.w)/2
  self.transform.y = self.transform.y + (h-self.collisionShape.h)
  local result = self:solid(ox, oy)
  self.transform.x = olx
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaman:checkBasicSlideBox(ox, oy)
  local w, h, oly = self.collisionShape.w, self.collisionShape.h, self.transform.y
  self:basicSlideBox()
  self.transform.y = self.transform.y + (h-self.collisionShape.h)
  local result = self:solid(ox, oy)
  self.transform.y = oly
  self:setRectangleCollision(w, h)
  return result
end

function megaman:regToSlide()
  local w, h = self.collisionShape.w, self.collisionShape.h
  self:basicSlideBox()
  self.transform.y = self.transform.y + (h-self.collisionShape.h)
end

function megaman:slideToReg()
  local w, h = self.collisionShape.w, self.collisionShape.h
  self:regBox()
  self.transform.y = self.transform.y + (h-self.collisionShape.h)
end

function megaman:new(x, y, side, drop)
  megaman.super.new(self)
  megaman.properties(self)
  self.side = side or 1
  self.toY = y
  self.transform.y = ternary(drop==nil or drop, view.y, y)
  self.transform.x = x
  megaman.colorOne = {0, 120, 248}
  megaman.colorTwo = {0, 232, 216}
  megaman.colorOutline = {0, 0, 0}
  self.class = megaman
  self.icoTex = loader.get("weapon_select_icon")
  self.iconQuad = love.graphics.newQuad(0, 0, 16, 16, 80, 48)
  self.icons = {}
  self.icons[0] = {0, 0}
  self.icons[1] = {16, 0}
  self.icons[2] = {16, 16}
  self.icons[3] = {32, 0}
  self.icons[4] = {32, 16}
  self.icons[5] = {48, 0}
  self.icons[6] = {48, 16}
  self.icons[7] = {64, 0}
  self.icons[8] = {64, 16}
  self.icons[9] = {0, 16}
  self.icons[10] = {0, 32}
  self.nextWeapon = 0
  self.prevWeapon = 0
  self.weaponSwitchTimer = 70
  self:regBox()
  self.doAnimation = true
  self.velocity = velocity()
  self.chargeTimer2 = 0
  self.chargeFrame = 1
  self.chargeState = 0
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
  self.chargeTimer = 0
  self.step = false
  self.hitTimer = self.maxHitTime
  self.climbTip = false
  self.ground = true
  self.climb = false
  self.slide = false
  self.drop = ternary(drop~=nil, drop, true)
  self.rise = false
  self.idleMoving = false
  self.stepTime = 0
  self.shootTimer = self.maxShootTime
  self.stopOnShot = false
  self.slideTimer = self.maxSlideTime
  self.dashJump = false
  self.wallJumpTimer = 0
  self.dropLanded = not self.drop
  self.ignoreTransitions = self.drop
  self.control = not self.drop
  self.bubbleTimer = 0
  self.runCheck = false
  
  self.groundUpdateFuncs = {}
  self.airUpdateFuncs = {}
  self.slideUpdateFuncs = {}
  self.climbUpdateFuncs = {}
  self.knockbackUpdateFuncs = {}
  
  megaman.healthHandler = healthhandler({252, 224, 168}, {255, 255, 255}, {0, 0, 0}, nil, nil, globals.lifeSegments)
  megaman.weaponHandler:reinit()
  megautils.add(megaman.weaponHandler)
  megautils.add(megaman.healthHandler)
  self.health = megaman.healthHandler.health
  megaman.healthHandler:updateThis()
  if camera.main.funcs["megaman"] == nil then
    camera.main.funcs["megaman"] = function(s)
      if megaman.healthHandler ~= nil then
        megaman.healthHandler.transform.x = view.x+24
        megaman.healthHandler.transform.y = view.y+80
      end
      if megaman.weaponHandler ~= nil then
        megaman.weaponHandler.transform.x = view.x+32
        megaman.weaponHandler.transform.y = view.y+80
      end
    end
  end
  self.curAnim = ternary(self.drop, "spawn", "idle")
  self.dropAnimation = {["regular"]="spawn"}
  self.dropLandAnimation = {["regular"]="spawnLand"}
  self.idleAnimation = {["regular"]="idle", ["shoot"]="idleShoot"}
  self.nudgeAnimation = {["regular"]="nudge", ["shoot"]="idleShoot"}
  self.jumpAnimation = {["regular"]="jump", ["shoot"]="jumpShoot"}
  self.runAnimation = {["regular"]="run", ["shoot"]="runShoot"}
  self.climbAnimation = {["regular"]="climb", ["shoot"]="climbShoot"}
  self.climbTipAnimation = {["regular"]="climbTip"}
  self.hitAnimation = {["regular"]="hit"}
  self.wallJumpAnimation = {["regular"]="wallJump", ["shoot"]="wallJumpShoot"}
  self.dashAnimation = {["regular"]=ternary(self.canDashShoot, "dash", "slide"), ["shoot"]="dashShoot"}
  self.animations = {}
  self.animations["idle"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 1, 2, 1), {2.5, 0.1})
  self.animations["idleShoot"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 4), 1)
  self.animations["idleThrow"] = anim8.newAnimation(loader.get("mega_man_grid")(4, 7), 1)
  self.animations["nudge"] = anim8.newAnimation(loader.get("mega_man_grid")(3, 1), 1)
  self.animations["jump"] = anim8.newAnimation(loader.get("mega_man_grid")(4, 2), 1)
  self.animations["jumpShoot"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 5), 1)
  self.animations["jumpThrow"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 8), 1)
  self.animations["run"] = anim8.newAnimation(loader.get("mega_man_grid")(4, 1, "1-2", 2, 1, 2), 1/8)
  self.animations["runShoot"] = anim8.newAnimation(loader.get("mega_man_grid")("2-4", 4, 3, 4), 1/8)
  self.animations["runThrow"] = anim8.newAnimation(loader.get("mega_man_grid")("2-4", 8, 3, 8), 1/8)
  self.animations["climb"] = anim8.newAnimation(loader.get("mega_man_grid")("1-2", 3), 1/8)
  self.animations["climbShoot"] = anim8.newAnimation(loader.get("mega_man_grid")(2, 5), 1)
  self.animations["climbThrow"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 9), 1)
  self.animations["climbTip"] = anim8.newAnimation(loader.get("mega_man_grid")(3, 3), 1)
  self.animations["hit"] = anim8.newAnimation(loader.get("mega_man_grid")(4, 3), 1)
  self.animations["wallJump"] = anim8.newAnimation(loader.get("mega_man_grid")(2, 9), 1)
  self.animations["wallJumpShoot"] = anim8.newAnimation(loader.get("mega_man_grid")(3, 9), 1)
  self.animations["wallJumpThrow"] = anim8.newAnimation(loader.get("mega_man_grid")(4, 9), 1)
  self.animations["slide"] = anim8.newAnimation(loader.get("mega_man_grid")(3, 2), 1/14, "pauseAtEnd")
  self.animations["dash"] = anim8.newAnimation(loader.get("mega_man_grid")("1-2", 10), 1/8, "pauseAtEnd")
  self.animations["dashShoot"] = anim8.newAnimation(loader.get("mega_man_grid")(4, 10), 1)
  self.animations["dashThrow"] = anim8.newAnimation(loader.get("mega_man_grid")(1, 11), 1)
  self.animations["spawn"] = anim8.newAnimation(loader.get("mega_man_grid")("3-4", 5), 0.08)
  self.animations["spawnLand"] = anim8.newAnimation(loader.get("mega_man_grid")("1-2", 6, 1, 6), 1/20)
  self:face(self.side)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("submergable")
    self:addToGroup("carry")
    self:addToGroup("hurtableOther")
  end
  self:setLayer(2)
  self.render = not self.drop
end

function megaman:face(n)
  self.animations[self.curAnim].flippedH = (n == 1) and true or false
end

function megaman:solid(x, y, d)
  return #self:collisionTable(megautils.groups()["solid"], x, y) ~= 0 or
    (ternary(d~=nil, d, true) and #self:collisionTable(megautils.groups()["death"], x, y)) ~= 0 or
    #oneway.collisionTable(self, megautils.groups()["oneway"], x, y) ~= 0 or
    #self:collisionTable(megautils.groups()["movingSolid"], x, y) ~= 0
end

function megaman:checkGround()
  local tmp = table.merge({self:collisionTable(megautils.groups()["solid"], 0, 1),
    self:collisionTable(megautils.groups()["death"], 0, 1),
    oneway.collisionTable(self, megautils.groups()["oneway"], 0, 1),
    self:collisionTable(megautils.groups()["movingSolid"], 0, 1)})
  local result = false
  for k, v in ipairs(tmp) do
    if self.transform.y == v.transform.y - self.collisionShape.h then
      result = true
      break
    end
  end
  return result
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
  local w = megaman.weaponHandler
  if control.shootPressed then
    if (w.current == "megaBuster" or w.current == "rushJet" or w.current == "rushCoil")
    and (megautils.groups()["megaBuster"] == nil or
    #megautils.groups()["megaBuster"] < self.maxNormalBusterShots) and (megautils.groups()["megaChargedBuster"] == nil or
    #megautils.groups()["megaChargedBuster"] == 0) then
      if w.current == "rushCoil" and w.energy[w.currentSlot] > 0 and
      (megautils.groups()[w.current] == nil or #megautils.groups()[w.current] < 1) then
        megautils.add(rushCoil(self.transform.x+(self.side==1 and 18 or -32),
          self.transform.y, self.side, w))
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      elseif w.current == "rushJet" and w.energy[w.currentSlot] > 0 and
      (megautils.groups()[w.current] == nil or #megautils.groups()[w.current] < 1) then
        megautils.add(rushJet(self.transform.x+(self.side==1 and 18 or -32),
            self.transform.y+6, self.side, w))
        self.maxShootTime = 14
        self.shootTimer = 0
        self:useShootAnimation()
      else
        megautils.add(megaBuster(self.transform.x+(self.side==1 and 17 or -14), 
            ternary(self.slide, self.transform.y+3, self.transform.y+6), self.side, w))
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    elseif w.current == "babyRattle" and w.energy[w.currentSlot] > 0 and
      (megautils.groups()[w.current] == nil or
        #megautils.groups()[w.current] < 1) and self.shootTimer == self.maxShootTime then
      megautils.add(babyRattle(self, -30, -4, 6, -4, function(s)
        if self.curAnim == "runThrow" or self.curAnim == "jumpThrow" or 
          self.curAnim == "climbThrow" then
          s.righty = -12
          s.lefty = -12
        elseif self.curAnim == "dashShoot" or self.curAnim == "dashThrow" then
          s.righty = -15
          s.lefty = -15
        else
          s.righty = -4
          s.lefty = -4
        end
      end, w))
      w.energy[w.currentSlot] = w.energy[w.currentSlot] - 1
      self.maxShootTime = 14
      self.shootTimer = 0
      self.stopOnShot = true
      self:useThrowAnimation()
    elseif w.current == "stickWeapon" and w.energy[w.currentSlot] > 0 and
      (megautils.groups()[w.current] == nil or
        #megautils.groups()[w.current] < 1) and self.shootTimer == self.maxShootTime then
      megautils.add(stickWeapon(self.transform.x+(self.side==1 and 17 or -14), 
        ternary(self.slide, self.transform.y+3, self.transform.y+6), self.side, w))
      self.maxShootTime = 14
      self.shootTimer = 0
      self:resetCharge()
      self:useShootAnimation()
      w.energy[w.currentSlot] = w.energy[w.currentSlot] - 1
    end
  end
  if not control.shootDown and self.chargeState ~= 0 then
    if w.current == "megaBuster" then
      if self.chargeState == 1 then
        megautils.add(megaSemiBuster(self.transform.x+(self.side==1 and 17 or -20), 
            ternary(self.slide, self.transform.y+1, self.transform.y+4), self.side, w))
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      elseif self.chargeState == 2 then
        megautils.add(megaChargedBuster(self.transform.x+(self.side==1 and 17 or -20), 
            ternary(self.slide, self.transform.y-6, self.transform.y-2), self.side, w))
        self.maxShootTime = 14
        self.shootTimer = 0
        self:resetCharge()
        self:useShootAnimation()
      end
    end
  end
  if control.shootDown then
    if self.canChargeBuster and w.current == "megaBuster" then
      self:charge()
    end
  end
end

function megaman:attemptClimb()
  if not control.downDown and not control.upDown then
    return
  end
  local lads = self:collisionTable(megautils.groups()["ladder"], 0, 1)
  if #lads ~= 0 then
    self.currentLadder = lads[1]
    if (control.downDown and (self:checkGround() or self.onSlope or self.onMovingFloor) and
      not oneway.collision(self, self.currentLadder, 0, 1)) or
      (control.upDown and oneway.collision(self, self.currentLadder, 0, 1)) or
      (not math.between(self.transform.x+self.collisionShape.w/2,
      self.currentLadder.transform.x, self.currentLadder.transform.x+self.currentLadder.collisionShape.w)) then
      self.currentLadder = nil
      return
    end
    if self.slide then
      local lh = self.collisionShape.h
      self:regBox()
      self.transform.y = self.transform.y - (self.collisionShape.h - lh)
    end
    if self:collision(self.currentLadder, 0, 1) and self.transform.y+self.collisionShape.h-1 < self.currentLadder.transform.y and
      control.downDown then
      self.transform.y = self.transform.y + math.round(self.collisionShape.h/2) + 2
    end
    self.velocity.vely = 0
    self.velocity.velx = 0
    self.climb = true
    self.dashJump = false
    self.wallJumpTimer = 0
    self.wallJumping = false
    self.ground = false
    self.slide = false
    self.slideTimer = self.maxSlideTime
    self.animations["climb"]:gotoFrame(1)
    self.climbTip = self.transform.y+math.round(self.collisionShape.h/6) < self.currentLadder.transform.y
  end
end

function megaman:addHealth(c)
  self.changeHealth = c
  self.health = self.health + self.changeHealth
  megaman.healthHandler.change = self.changeHealth
  megaman.healthHandler:updateThis()
end

function megaman:healthChanged(o, c, i)
  if not self.control then return end
  if not self:iFrameIsDone() then return else
    self.maxIFrame = i
    self.iFrame = 0
  end
  self.changeHealth = ternary(c < 0 and self.inv, 0, c)
  self.health = self.health + self.changeHealth
  if not self.inv and self.health <= 0 and self.control then
    self.control = false
    self.render = false
    mmSfx.play("die")
    if self.transform.y < view.y+view.h then
      explodeParticle.createExplosion(self.transform.x+((self.collisionShape.w/2)-12),
        self.transform.y+((self.collisionShape.h/2)-12))
    end
    mmMusic.stopMusic()
    megaman.healthHandler.change = self.changeHealth
    megaman.healthHandler:updateThis()
    megautils.add(timer(160, function(t)
      if globals.lives ~= -42 then
        megautils.add(fade(true, nil, nil, function(s)
          globals.resetState = true
          globals.mainPlayer = nil
          if not globals.infiniteLives and globals.lives <= 0 then
            globals.lives = -42
            megautils.resetPlayer()
            globals.gameOverContinueState = states.current
            states.set("states/menus/gameoverstate.lua")
          else
            globals.manageStageResources = false
            if not globals.infiniteLives then
              globals.lives = globals.lives - 1
            end
            states.set(states.current)
          end
        megautils.remove(s, true)
      end))
    end
      megautils.remove(t, true)
    end))
    megautils.remove(self, true)
    return
  end
  if self.inv then
    self.iFrame = self.maxIFrame
  end
  if self.changeHealth < 0 and not self.inv then
    self.hitTimer = 0
    self.velocity.velx = ternary(self.side==1, self.leftKnockBackSpeed, self.rightKnockBackSpeed)
    self.velocity.vely = 0
    if self.slide and not self:checkRegBox() then
      self.slide = false
      self:slideToReg()
    elseif self.slide and self:checkRegBox() then
      self.hitTimer = self.maxHitTime
      self.velocity.velx = 0
    end
    self.climb = false
    self.dashJump = false
    mmSfx.play("hurt")
    megautils.add(harm(self))
    megautils.add(damageSteam(self.transform.x+((self.collisionShape.w/2)+2)-11, self.transform.y-8))
    megautils.add(damageSteam(self.transform.x+((self.collisionShape.w/2)+2), self.transform.y-8))
    megautils.add(damageSteam(self.transform.x+((self.collisionShape.w/2)+2)+11, self.transform.y-8))
    megaman.healthHandler.change = self.changeHealth
    megaman.healthHandler:updateThis()
  elseif self.changeHealth > 0 then
    megaman.healthHandler.change = self.changeHealth
    megaman.healthHandler:updateThis()
  end
end

function megaman:code(dt)
  self.runCheck = ((control.leftDown and not control.rightDown) or (control.rightDown and not control.leftDown))
  if self.hitTimer ~= self.maxHitTime then
    self.hitTimer = math.min(self.hitTimer+1, self.maxHitTime)
    self:grav()
    self:phys()
    if self:checkGround() or self.onSlope or self.onMovingFloor then
      self.ground = true
    else
      self.ground = false
    end
    if self.canShoot and control.shootDown then
      self:charge()
    else
      self:charge(true)
    end
    for k, v in pairs(self.knockbackUpdateFuncs) do
      v(self)
    end
  elseif self.climb then
    if control.leftDown then
      self.side = -1
    elseif control.rightDown then
      self.side = 1
    end
    if not self.alwaysMove then
      self.velocity.velx = 0
      self.velocity.vely = 0
    end
    self.transform.x = self.currentLadder.transform.x+(self.currentLadder.collisionShape.w/2)-
      ((self.collisionShape.w)/2)
    if control.upDown and self.shootTimer == self.maxShootTime then
      self.velocity.vely = self.climbUpSpeed
    elseif control.downDown and self.shootTimer == self.maxShootTime then
      self.velocity.vely = self.climbDownSpeed
    end
    self:phys()
    if not self:collision(self.currentLadder) and self.transform.y >= self.currentLadder.transform.y then
      self.climb = false
      self.ground = self:checkGround() or self.onSlope or self.onMovingFloor
    elseif self.transform.y+math.round(self.collisionShape.h/2) < self.currentLadder.transform.y+2
      and control.upDown then
        self.velocity.vely = 0
        self.transform.y = math.round(self.transform.y)
        while self:collision(self.currentLadder) do
          self.transform.y = self.transform.y - 1
        end
        while not self:collision(self.currentLadder, 0, 1) do
          self.transform.y = self.transform.y + 1
        end
        self.climb = false
        self.ground = true
    end
    if self.transform.x == view.x-self.collisionShape.w/2 or
      self.transform.x == (view.x+view.w)-self.collisionShape.w/2 or not self:collision(self.currentLadder) then
      self.climb = false
    end
    if (self:checkGround() or self.onSlope or self.onMovingFloor) and control.downDown then
      self.climb = false
      self.ground = true
    end
    if control.jumpPressed and not (control.downDown or
      control.upDown) then
      self.climb = false
    end
    self:attemptWeaponUsage()
    if self.shootTimer ~= self.maxShootTime then
      self.velocity.vely = 0      
    end
    self.climbTip = self.transform.y+math.round(self.collisionShape.h/6) < self.currentLadder.transform.y
    for k, v in pairs(self.climbUpdateFuncs) do
      v(self)
    end
  elseif self.slide then
    if self:checkGround() then
      self.velocity.vely = 1
    end
    local lastSide = self.side
    if control.leftDown then
      self.side = -1
      self.step = true
      self.stepTime = 0
    elseif control.rightDown then
      self.side = 1
      self.step = true
      self.stepTime = 0
    end
    self.velocity.velx = ternary(self.side==1, self.slideRightSpeed, self.slideLeftSpeed)
    self.velocity.velx = math.clamp(self.velocity.velx, self.slideLeftSpeed, self.slideRightSpeed)
    self:phys()
    if self:checkRegBox() and not (self:checkGround() or self.onSlope or self.onMovingFloor or self:checkSlideBox(0, 1)) then
      self.slide = false
      local w = self.collisionShape.w
      self:regBox()
      while self:solid(0, -1) do
        self.transform.y = self.transform.y + 1
      end
      return
    elseif not (self:checkGround() or self.onSlope or self.onMovingFloor or self:checkSlideBox(0, 1)) then
      self.ground = false
      self.slide = false
      self.velocity.velx = 0
      local w = self.collisionShape.w
      self:regBox()
      self.slideTimer = self.maxSlideTime
      return
    end
    self.slideTimer = math.min(self.slideTimer+1, self.maxSlideTime)
    if self.slideTimer == self.maxSlideTime and not self:checkRegBox()
      and (self:checkGround() or self.onSlope or self.onMovingFloor or self:checkSlideBox(0, 1)) then
      self.slide = false
      self.ground = true
      self:slideToReg()
      return
    elseif not self:checkRegBox() and (self.collisionChecks.leftWall or self.collisionChecks.rightWall)
      and (self:checkGround() or self.onSlope or self.onMovingFloor or self:checkSlideBox(0, 1)) then
      self.slide = false
      self.slideTimer = self.maxSlideTime
      self.hitTimer = self.maxHitTime
      self:slideToReg()
      return
    elseif self.canJump and self.canJumpOutFromDash and control.jumpPressed and not self:checkRegBox()
      and (self:checkGround() or self.onSlope or self.onMovingFloor or self:checkSlideBox(0, 1))
        and not control.downDown then
      self.slide = false
      self.ground = false
      self.velocity.vely = self.jumpSpeed
      self.slideTimer = self.maxSlideTime
      self.hitTimer = self.maxHitTime
      self:slideToReg()
      self.dashJump = self.canDashJump
      return
    elseif not (self:checkGround() or self.onSlope or self.onMovingFloor or self:checkSlideBox(0, 1))
      and self:checkRegBox() then
      self.slide = false
      self.ground = false
      self.slideTimer = self.maxSlideTime
      self.hitTimer = self.maxHitTime
      local w = self.collisionShape.w
      self:regBox()
      while self:solid(0, 0) do
        self.transform.y = self.transform.y + 1
      end
      return
    elseif self.canBackOutFromDash and lastSide ~= self.side and not self:checkRegBox() then
      self.slide = false
      self.ground = true
      self.slideTimer = self.maxSlideTime
      self:slideToReg()
    end
    if self.canShoot and not self.canDashShoot and control.shootDown then
      self:charge()
    elseif self.canShoot and self.canDashShoot then
      self:attemptWeaponUsage()
    else
      self:charge(true)
    end
    self:attemptClimb()
    for k, v in pairs(self.slideUpdateFuncs) do
      v(self)
    end
  elseif self.ground then
    if self:checkGround() then
      self.velocity.vely = 1
    end
    if self.canWalk and not (self.stopOnShot and self.shootTimer ~= self.maxShootTime) then
      if self.runCheck and not self.step then
        self.side = control.leftDown and -1 or 1
        if self.stepVelocity or self.stepTime == 0 then
          self.velocity.velx = self.velocity.velx + ternary(self.side==1, self.stepRightSpeed, self.stepLeftSpeed)
        elseif not self.stepVelocity then
          self.velocity.velx = 0
        end
        self.stepTime = math.min(self.stepTime+1, self.maxStepTime)
        if self.stepTime == self.maxStepTime then
          self.step = true
          self.stepTime = 0
        end
      elseif self.runCheck then
        self.side = control.leftDown and -1 or 1
        self.velocity.velx = self.velocity.velx + (self.side == -1 and self.leftSpeed or self.rightSpeed)
      elseif not self.alwaysMove then
        self.velocity:slowX(self.side == -1 and self.leftDecel or self.rightDecel)
        self.stepTime = 0
        self.step = false
      end
    else
      if self.runCheck then
        self.side = control.leftDown and -1 or 1
      end
      self.velocity:slowX(self.side == -1 and self.leftDecel or self.rightDecel)
      self.stepTime = 0
      self.step = false
    end
    if self.canDash and (control.dashPressed or
      (control.downDown and control.jumpPressed)) and
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
      megautils.add(slideParticle(self.transform.x+ternary(self.side==-1, self.collisionShape.w, 4),
        self.transform.y+self.collisionShape.h-6, self.side))
    elseif self.canJump and control.jumpPressed and
      not (control.downDown and self:checkBasicSlideBox(self.side, 0)) then
      self.velocity.vely = self.jumpSpeed
      self.ground = false
    end
    if self.collisionChecks.leftWall or self.collisionChecks.rightWall then
      self.velocity.velx = 0
    end
    self.velocity.velx = math.clamp(self.velocity.velx, self.maxLeftSpeed, self.maxRightSpeed)
    self:phys()
    if not (self:solid(0, 1, true) or self.onSlope or self.onMovingFloor) then
      self.ground = false
    end
    if self.canShoot then
      self:attemptWeaponUsage()
    end
    self:attemptClimb()
    for k, v in pairs(self.groundUpdateFuncs) do
      v(self)
    end
  else
    self.wallJumping = false
    local ns = ternary(control.leftDown, -1, ternary(control.rightDown, 1, 0))
    if self.wallJumpTimer ~= 0 then
      self.wallJumpTimer = math.max(self.wallJumpTimer-1, 0)
      self.velocity.velx = self.wallKickSpeed * self.side
      if (self.side == 1 and control.rightDown) or 
        (self.side == -1 and control.leftDown) then
        self.wallJumpTimer = 0
      end
    elseif self.canWallJump and self.velocity.vely > 0 and (self:solid(ns, 0, true) or self.onMovingLeftWall or
      self.onMovingRightWall) then
      self.side = -ns
      self.velocity.velx = -self.side
      self.wallJumping = true
      self.velocity.vely = self.wallSlideSpeed
      if control.jumpPressed then
        self.wallJumpTimer = self.maxWallJumpTime
        self.velocity.vely = self.wallJumpSpeed
        self.dashJump = true
        megautils.add(kickParticle(self.transform.x+ternary(self.side==1, -4, 
          self.collisionShape.w-4),
          self.transform.y+self.collisionShape.h-10, -self.side))
      end
    elseif control.leftDown or control.rightDown then
      self.side = control.leftDown and -1 or 1
      self.velocity.velx = self.velocity.velx + ternary(self.side == -1, 
        ternary(self.dashJump, self.slideLeftSpeed*self.dashJumpMultiplier, self.leftAirSpeed), 
        ternary(self.dashJump, self.slideRightSpeed*self.dashJumpMultiplier, self.rightAirSpeed))
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
    if self.canStopJump and not control.jumpDown and self.velocity.vely < 0 then
      self.velocity:slowY(self.jumpDecel)
    end
    self:grav()
    self:phys()
    if self.collisionChecks.ground or self.onMovingFloor then
      self.ground = true
      self.dashJump = false
      self.canStopJump = true
      mmSfx.play("land")
    else
      self:attemptClimb()
    end
    if self.canShoot then
      self:attemptWeaponUsage()
    end
    for k, v in pairs(self.airUpdateFuncs) do
      v(self)
    end
  end
  if #self:collisionTable(megautils.groups()["water"]) ~= 0 then
    self.bubbleTimer = math.min(self.bubbleTimer+1, self.maxBubbleTime)
    if self.bubbleTimer == self.maxBubbleTime then
      self.bubbleTimer = 0
      megautils.add(airBubble(self.transform.x+ternary(self.side==-1, -4, self.collisionShape.w), self.transform.y+4))
    end
  end
  self.transform.x = math.clamp(self.transform.x, view.x+(-self.collisionShape.w/2)+2,
    (view.x+view.w)+(-self.collisionShape.w/2)-2)
  self.transform.y = math.clamp(self.transform.y, view.y-(self.collisionShape.h*1.4),
    view.y+view.h+4)
  self.shootTimer = math.min(self.shootTimer+1, self.maxShootTime)
  if (self.transform.y >= view.y+view.h) and self.inv then
    self.inv = false
  end
  if (self.transform.y >= view.y+view.h) or 
    (self.canGetCrushed and self.transform.y <= view.y-self.collisionShape.h+1 and (self:solid(0, 1) or
      self.onSlope or self.onMovingFloor)) or 
      (self.canGetCrushed and self.transform.x >= (view.x+view.w)-self.collisionShape.w/2 and self:solid(-1, 0)) or 
        (self.canGetCrushed and self.transform.x <= view.x-self.collisionShape.w/2 and self:solid(1, 0)) then
    self.iFrame = self.maxIFrame
    self:hurt({self}, -999, 1)
    self.control = false
  end
  self:updateIFrame()
  self:updateFlash()
  self.health = megaman.healthHandler.health
  if self.stopOnShot and self.shootTimer == self.maxShootTime then
    self.stopOnShot = false
  end
  if control.startPressed and self.control then
    globals.resetState = false
    globals.pauseLastState = states.currentstate
    globals.pauseLastStateName = states.current
    globals.lastCamPosX = view.x
    globals.lastCamPosY = view.y
    self.weaponSwitchTimer = 70
    globals.manageStageResources = false
    megautils.gotoState("states/menus/pausestate.lua", nil, nil, love.filesystem.load("states/menus/pausestate.lua")())
    globals.pauseWeaponSelect = weaponSelect(megaman.weaponHandler, megaman.healthHandler)
    mmSfx.play("pause")
  end
end

function megaman:resetStates()
  self.velocity.velx = 0
  self.velocity.vely = 0
  self.step = false
  self.stepTime = 0
  self.ground = true
  self.climb = false
  self.currentLadder = nil
  self.iFrame = self.maxIFrame
  self.wallJumping = false
  self.dashJump = false
  self.curAnim = "idle"
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
  if self.chargeColorOutlines[megaman.weaponHandler.current] ~= nil
   and self.chargeColorOnes[megaman.weaponHandler.current] ~= nil
    and self.chargeColorTwos[megaman.weaponHandler.current] ~= nil then
    megaman.colorOutline = self.chargeColorOutlines[megaman.weaponHandler.current][self.chargeState][self.chargeFrame]
    megaman.colorOne = self.chargeColorOnes[megaman.weaponHandler.current][self.chargeState][self.chargeFrame]
    megaman.colorTwo = self.chargeColorTwos[megaman.weaponHandler.current][self.chargeState][self.chargeFrame]
  end
  mmSfx.stop("charge")
end

function megaman:charge(animOnly)
  if self.chargeColorOutlines[megaman.weaponHandler.current] ~= nil then
    self.chargeTimer2 = math.min(self.chargeTimer2+1, 4)
    if self.chargeTimer2 == 4 and self.chargeColorOutlines[megaman.weaponHandler.current] ~= nil
    and self.chargeColorOnes[megaman.weaponHandler.current] ~= nil
      and self.chargeColorTwos[megaman.weaponHandler.current] ~= nil then
      self.chargeTimer2 = 0
      self.chargeFrame = math.wrap(self.chargeFrame+1, 1,
        table.length(self.chargeColorOutlines[megaman.weaponHandler.current][self.chargeState]))
    end
    if animOnly == nil or not animOnly then
      self.chargeTimer = math.min(self.chargeTimer+1, self.maxChargeTime)
    end
    if self.chargeTimer == self.maxChargeTime and self.chargeState <
      table.length(self.chargeColorOutlines[megaman.weaponHandler.current])-1 then
      self.chargeTimer = 0
      self.chargeFrame = 1
      if self.chargeState == 0 then
        mmSfx.play("charge")
      end
      if ternary(animOnly~=nil, not animOnly, true) then
        self.chargeState = math.min(self.chargeState+1, 
          table.length(self.chargeColorOutlines[megaman.weaponHandler.current])-1)
      end
    end
    if self.chargeColorOutlines[megaman.weaponHandler.current] ~= nil
    and self.chargeColorOnes[megaman.weaponHandler.current] ~= nil
      and self.chargeColorTwos[megaman.weaponHandler.current] ~= nil then
      megaman.colorOutline = self.chargeColorOutlines[megaman.weaponHandler.current][self.chargeState][self.chargeFrame]
      megaman.colorOne = self.chargeColorOnes[megaman.weaponHandler.current][self.chargeState][self.chargeFrame]
      megaman.colorTwo = self.chargeColorTwos[megaman.weaponHandler.current][self.chargeState][self.chargeFrame]
    end
  end
end

function megaman:grav()
  if self.gravityType == 0 then
    self.velocity.vely = self.velocity.vely+self.gravity
  elseif self.gravityType == 1 then
    self.velocity:slowY(self.gravity)
  end
end

function megaman:deathBlocks(group, x, y)
  if self.iFrame == self.maxIFrame and not self.inv then
    local tmp = self:collisionTable(group, x, y)
    return tmp
  else
    solid.blockFromGroup(self, group, x, y)
  end
  return false
end

function megaman:phys()
  self.velocity:clampY(self.maxAirSpeed)
  self:resetCollisionChecks()
  slope.blockFromGroup(self, megautils.groups()["slope"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  oneway.blockFromGroup(self, megautils.groups()["oneway"], self.velocity.vely)
  self:block(self.velocity)
  solid.blockFromGroup(self, megautils.groups()["solid"], self.velocity.velx, self.velocity.vely)
  self:block(self.velocity)
  local tmp = self:deathBlocks(megautils.groups()["death"], self.velocity.velx, self.velocity.vely)
  if tmp and #tmp ~= 0 then
    self:hurt({self}, tmp[1].harm, 80)
  end
  self:block(self.velocity)
  self:moveBy(self.velocity.velx, self.velocity.vely)
end

function megaman:updatePallete()
  if control.prevDown and control.nextDown
    and megaman.weaponHandler.currentSlot ~= 0 then
    megaman.weaponHandler:switch(0)
    megaman.colorOutline = megaman.weaponHandler.colorOutline[0]
    megaman.colorOne = megaman.weaponHandler.colorOne[0]
    megaman.colorTwo = megaman.weaponHandler.colorTwo[0]
    local w = math.wrap(megaman.weaponHandler.currentSlot+1, 0, megaman.weaponHandler.slotSize)
    while megaman.weaponHandler.weapons[w] == nil do
      w = math.wrap(w+1, 0, megaman.weaponHandler.slotSize)
    end
    self.nextWeapon = w
    w = math.wrap(megaman.weaponHandler.currentSlot-1, 0, megaman.weaponHandler.slotSize)
    while megaman.weaponHandler.weapons[w] == nil do
      w = math.wrap(w-1, 0, megaman.weaponHandler.slotSize)
    end
    self.prevWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    mmSfx.play("switch")
  elseif control.nextPressed and not control.prevDown then
    self.prevWeapon = megaman.weaponHandler.currentSlot
    local w = math.wrap(megaman.weaponHandler.currentSlot+1, 0, megaman.weaponHandler.slotSize)
    while megaman.weaponHandler.weapons[w] == nil do
      w = math.wrap(w+1, 0, megaman.weaponHandler.slotSize)
    end
    megaman.weaponHandler:switch(w)
    megaman.colorOutline = megaman.weaponHandler.colorOutline[w]
    megaman.colorOne = megaman.weaponHandler.colorOne[w]
    megaman.colorTwo = megaman.weaponHandler.colorTwo[w]
    w = math.wrap(megaman.weaponHandler.currentSlot+1, 0, megaman.weaponHandler.slotSize)
    while megaman.weaponHandler.weapons[w] == nil do
      w = math.wrap(w+1, 0, megaman.weaponHandler.slotSize)
    end
    self.nextWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    mmSfx.play("switch")
  elseif control.prevPressed and not control.nextDown then
    self.nextWeapon = megaman.weaponHandler.currentSlot
    local w = math.wrap(megaman.weaponHandler.currentSlot-1, 0, megaman.weaponHandler.slotSize)
    while megaman.weaponHandler.weapons[w] == nil do
      w = math.wrap(w-1, 0, megaman.weaponHandler.slotSize)
    end
    megaman.weaponHandler:switch(w)
    megaman.colorOutline = megaman.weaponHandler.colorOutline[w]
    megaman.colorOne = megaman.weaponHandler.colorOne[w]
    megaman.colorTwo = megaman.weaponHandler.colorTwo[w]
    w = math.wrap(megaman.weaponHandler.currentSlot-1, 0, megaman.weaponHandler.slotSize)
    while megaman.weaponHandler.weapons[w] == nil do
      w = math.wrap(w-1, 0, megaman.weaponHandler.slotSize)
    end
    self.prevWeapon = w
    self.weaponSwitchTimer = 0
    self:resetCharge()
    mmSfx.play("switch")
  end
end

function megaman:animate()
  if self.drop or self.rise then
    self.curAnim = ternary(self.dropLanded, self.dropLandAnimation["regular"], self.dropAnimation["regular"])
  elseif self.control then
    local shoot = "regular"
    if self.shootTimer ~= self.maxShootTime then
      shoot = "shoot"
    end
    if self.hitTimer ~= self.maxHitTime then
      self.curAnim = self.hitAnimation["regular"]
    elseif self.climb then
      self.curAnim = self.climbAnimation[shoot]
      if self.climbTip then
        if self.shootTimer ~= self.maxShootTime then
          self.curAnim = self.climbAnimation[shoot]
        else
          self.curAnim = self.climbTipAnimation["regular"]
        end
      elseif not self.alwaysMove and not (control.downDown or
        control.upDown) and 
        self.animations[self.climbAnimation["regular"]].status == "playing" then
        self.animations[self.climbAnimation["regular"]]:pause()
      elseif control.downDown or control.upDown and 
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
      self.curAnim = self.dashAnimation[shoot]
    elseif self.ground then
      if self.canWalk and not self.step and self.runCheck then
        self.curAnim = self.nudgeAnimation[shoot]
      elseif (self.canWalk and ((not self.idleMoving and self.alwaysMove and self.velocity.velx ~= 0) or
        self.runCheck)) and
        not (self.stopOnShot and self.shootTimer ~= self.maxShootTime) then
        self.curAnim = self.runAnimation[shoot]
      else
        self.animations[self.runAnimation["regular"]]:gotoFrame(1)
        self.animations[self.runAnimation["shoot"]]:gotoFrame(1)
        self.curAnim = self.idleAnimation[shoot]
      end
    else
      if self.wallJumping then
        self.curAnim = self.wallJumpAnimation[shoot]
      else
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
    end
  end
  self.animations[self.curAnim]:update(1/60)
  if self.curAnim ~= self.climbAnimation["regular"] and self.curAnim ~= self.climbTipAnimation["regular"] then
    self:face(self.side)
  else
    self:face(-1)
  end
end

function megaman:update(dt)
  self.runCheck = false
  if self.rise then
    self.control = false
    if self.dropLanded then
      self.dropLanded = not self.animations[self.dropLandAnimation["regular"]].looped
      if not self.dropLanded then
        mmSfx.play("ascend")
      end
    else
      self.transform.y = math.max(self.transform.y+self.riseSpeed, view.y-(self.collisionShape.h*1.4))
      self.render = self.transform.y ~= view.y-(self.collisionShape.h*1.4)
    end
  elseif self.drop then
    if not self.render then
      self.transform.y = view.y
    end
    self.render = true
    self.transform.y = math.min(self.transform.y+self.dropSpeed, self.toY)
    if self.transform.y == self.toY then
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
  if self.canSwitchWeapons then self:updatePallete() end
  if camera.main ~= nil and globals.mainPlayer == self and self.cameraFocus and not self.drop and not self.rise
    and self.collisionShape ~= nil then
    camera.main:updateCam(self, self.cameraOffsetX,
      self.cameraOffsetY+ternary(self.slide, -7, 0),
      self.cameraWidth, self.cameraHeight)
  end
  self.weaponSwitchTimer = math.min(self.weaponSwitchTimer+1, 70)
end

function megaman:draw()
  if self.weaponSwitchTimer ~= 70 then
    love.graphics.setColor(1, 1, 1, 1)
    if self.threeWeaponIcons then
      self.iconQuad:setViewport(self.icons[self.nextWeapon][1],
        self.icons[self.nextWeapon][2], 16, 16)
      love.graphics.draw(self.icoTex, self.iconQuad, math.round(self.transform.x+math.round(self.collisionShape.w/2))+8,
        math.round(self.transform.y-18), 0, 1, 1)
      self.iconQuad:setViewport(self.icons[self.prevWeapon][1],
        self.icons[self.prevWeapon][2], 16, 16)
      love.graphics.draw(self.icoTex, self.iconQuad, math.round(self.transform.x+math.round(self.collisionShape.w/2))-24,
        math.round(self.transform.y-18), 0, 1, 1)
    end
    self.iconQuad:setViewport(self.icons[megaman.weaponHandler.currentSlot][1],
      self.icons[megaman.weaponHandler.currentSlot][2], 16, 16)
    love.graphics.draw(self.icoTex, self.iconQuad, math.round(self.transform.x+math.round(self.collisionShape.w/2))-8,
      math.round(self.transform.y-20))
  end
  local offsety, offsetx = 0, 0
  if table.contains(self.climbAnimation, self.curAnim) or 
    table.contains(self.jumpAnimation, self.curAnim) or 
    table.contains(self.wallJumpAnimation, self.curAnim) then
    offsety = 6
  elseif table.contains(self.hitAnimation, self.curAnim) then
    offsety = 4
  elseif table.contains(self.dashAnimation, self.curAnim) then
    offsety = -5
  end
  if self.curAnim == "climbShoot" or self.curAnim == "climbThrow" then
    offsetx = ternary(self.side == -1, 0, -1)
  elseif self.curAnim == "climb" then
    offsetx = ternary(self.animations["climb"].position==1, -1, 0)
  elseif self.curAnim == "slide" then
    offsetx = ternary(self.side==1, 3, -3)
  end
  love.graphics.setColor(megaman.colorOutline[1]/255, megaman.colorOutline[2]/255, megaman.colorOutline[3]/255, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_outline"), math.round(self.transform.x-15)+offsetx,
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(megaman.colorOne[1]/255, megaman.colorOne[2]/255, megaman.colorOne[3]/255, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_one"), math.round(self.transform.x-15)+offsetx,
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(megaman.colorTwo[1]/255, megaman.colorTwo[2]/255, megaman.colorTwo[3]/255, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_two"), math.round(self.transform.x-15)+offsetx,
    math.round(self.transform.y-8+offsety))
  love.graphics.setColor(1, 1, 1, 1)
  self.animations[self.curAnim]:draw(loader.get("mega_man_face"), math.round(self.transform.x-15)+offsetx,
    math.round(self.transform.y-8+offsety))
  --self:drawCollision()
end
