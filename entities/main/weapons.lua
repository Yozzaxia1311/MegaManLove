megautils.loadResource("assets/sfx/enemyHit.ogg", "enemyHit", true)
megautils.loadResource("assets/sfx/enemyExplode.ogg", "enemyExplode", true)
megautils.loadResource("assets/sfx/buster.ogg", "buster", true)
megautils.loadResource("assets/sfx/reflect.ogg", "dink", true)

playerWeapon = entity:extend()

playerWeapon.DAMAGENONE = 0
playerWeapon.DAMAGEPLAYER = 1
playerWeapon.DAMAGEENEMY = 2
playerWeapon.DAMAGEBOTH = 3

playerWeapon.removeGroups = {}
playerWeapon.resources = {}

function playerWeapon:new(p)
  playerWeapon.super.new(self)
  self:setRectangleCollision(8, 8)
  self.autoHit = true
  self.sound = "buster"
  self.soundOnDink = "dink"
  self.damage = -1
  self.damageType = damType or playerWeapon.DAMAGEENEMY
  self.iFramesOnDamage = (self.damageType == playerWeapon.DAMAGEPLAYER) and 80 or 1
  self.dinked = false
  self.damageTypeOnDink = playerWeapon.DAMAGENONE
  self.user = p
  self.flipWithUser = true
  self.weaponGroup = nil
  self.removeWhenOutside = true
  self.autoCollision = true
  self.autoGravity = false
  self.autoFace = -1
  self.applyAutoFace = false
  self.doAutoCollisionBeforeUpdate = true
  self.doDink = true
  self._didCol = false
end

function playerWeapon:added()
  if self.weaponGroup then
    self:addToGroup(self.weaponGroup)
    if self.user and megaMan.weaponHandler[self.user.player] then
      self:addToGroup(self.weaponGroup .. megaMan.weaponHandler[self.user.player].id)
    end
  end
  self:addToGroup("freezable")
  self:addToGroup("removeOnTransition")
  self:addToGroup("collision")
  self:addToGroup("playerWeapon")
  if self.sound then
    if megautils.getResource(self.sound) then
      megautils.playSound(self.sound)
    else
      megautils.playSoundFromFile(self.sound)
    end
  end
end

function playerWeapon:grav()
  if self.ground then return end
  self.velocity.vely = self.velocity.vely+self.gravity
  self.velocity:clampY(7)
end

function playerWeapon:dink(e)
  self.velocity.velx = self.velocity.velx >= 0 and -4 or 4
  self.velocity.vely = (self.gravity >= 0) and -4 or 4
  self.dinked = true
  self.dinkedBy = e
  self.blockCollision.global = false
  self.damageType = self.damageTypeOnDink
  if self.soundOnDink then
    if megautils.getResource(self.soundOnDink) then
      megautils.playSound(self.soundOnDink)
    else
      megautils.playSoundFromFile(self.soundOnDink)
    end
  end
end

function playerWeapon:dinking(e, dt) end

function playerWeapon:act(dt) end

function playerWeapon:beforeUpdate()
  if self.flipWithUser and self.user then
    self:setGravityMultiplier("flipWithUser", self.user.gravityMultipliers.gravityFlip or 1)
  end
  if self.autoGravity then
    collision.doGrav(self)
  end
  self._didCol = false
  if self.doAutoCollisionBeforeUpdate then
    collision.doCollision(self)
    self._didCol = true
  end
  if self.user then
    local s = megautils.side(self, self.user, true)
    self.autoFace = s or self.autoFace
    if self.applyAutoFace then
      self.side = self.autoFace
    end
  end
  if self.removeWhenOutside and megautils.outside(self) then
    megautils.removeq(self)
  end
end

function playerWeapon:update(dt)
  if self.dinked and self.doDink then
    self:dinking(self.dinkedBy, dt)
  else
    self:act(dt)
  end
end

function playerWeapon:afterUpdate()
  if self.autoHit then
    if self.damageType == playerWeapon.DAMAGEENEMY or self.damageType == playerWeapon.DAMAGEBOTH then
      self:interact(self:collisionTable(megautils.groups().hurtable), self.damage, self.iFramesOnDamage)
    end
    if self.damageType == playerWeapon.DAMAGEPLAYER or self.damageType == playerWeapon.DAMAGEBOTH then
      self:interact(self:collisionTable(megaMan.allPlayers), self.damage, self.iFramesOnDamage)
    end
  end
  if self.autoCollision and not self.doAutoCollisionBeforeUpdate and not self._didCol then
    collision.doCollision(self)
  end
end

playerWeapon.removeGroups["P.BUSTER"] = {"megaBuster", "protoChargedBuster"}

playerWeapon.resources["P.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/misc/weapons/protoBuster.png", "protoBuster")
    megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge")
    megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged")
    megautils.loadResource(10, 0, 29, 10, "protoBusterGrid")
  end

playerWeapon.resources["R.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/misc/weapons/rollBuster.png", "rollBuster")
    megautils.loadResource("assets/sfx/protoCharge.ogg", "protoCharge")
    megautils.loadResource("assets/sfx/protoCharged.ogg", "protoCharged")
    megautils.loadResource(10, 0, 29, 10, "protoBusterGrid")
  end

protoSemiBuster = playerWeapon:extend()

function protoSemiBuster:new(x, y, p, dir, skin)
  protoSemiBuster.super.new(self, p)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(10, 10)
  self.tex = megautils.getResource(skin)
  self.quad = quad(0, 0, 10, 10)
  self.side = dir
  self.velocity.velx = self.side * 5
  self.weaponGroup = "megaBuster"
  self.sound = "semiCharged"
  self.damage = -1
end

function protoSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-3)
end

protoChargedBuster = playerWeapon:extend()

function protoChargedBuster:new(x, y, p, dir, skin)
  protoChargedBuster.super.new(self, p)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(29, 8)
  self.tex = megautils.getResource(skin)
  self.anim = megautils.newAnimation("protoBusterGrid", {"1-2", 1}, 1/20)
  self.side = dir
  self.velocity.velx = self.side * 6
  self.anim.flipX = self.side ~= 1
  self.pierceType = enemyEntity.PIERCEIFKILLING
  self.sound = "protoCharged"
  self.weaponGroup = "protoChargedBuster"
  self.damage = -2
end

function protoChargedBuster:act()
  self.anim:update(defaultFramerate)
end

function protoChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-1)
end

bassBuster = playerWeapon:extend()

playerWeapon.removeGroups["B.BUSTER"] = {"bassBuster"}

playerWeapon.resources["B.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster")
  end

function bassBuster:new(x, y, p, dir, t)
  bassBuster.super.new(self, p)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(6, 6)
  self.tex = megautils.getResource("bassBuster")
  self.velocity.velx = megautils.calcX(dir) * 5
  self.velocity.vely = megautils.calcY(dir) * 5
  self.side = self.velocity.velx < 0 and -1 or 1
  self.treble = t
  if not self.treble then
    self.damage = -0.5
  end
  self.weaponGroup = "bassBuster"
end

function bassBuster:act()
  local col = collision.checkSolid(self, self.velocity.velx, self.velocity.vely)
  if not self.treble and not self.dinked and col then
    megautils.removeq(self)
  end
end

function bassBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x)-1, math.round(self.transform.y)-1)
end

megaBuster = playerWeapon:extend()

playerWeapon.removeGroups["M.BUSTER"] = {"megaBuster", "megaChargedBuster"}

playerWeapon.resources["M.BUSTER"] = function()
    megautils.loadResource("assets/misc/weapons/buster.png", "busterTex")
    megautils.loadResource("assets/sfx/charge.ogg", "charge")
    megautils.loadResource("assets/sfx/semi.ogg", "semiCharged")
    megautils.loadResource("assets/sfx/charged.ogg", "charged")
    megautils.loadResource(33, 30, "chargeGrid")
    megautils.loadResource(8, 31, 17, 16, "smallChargeGrid")
  end

function megaBuster:new(x, y, p, dir)
  megaBuster.super.new(self, p)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = megautils.getResource("busterTex")
  self.quad = quad(0, 31, 8, 6)
  self.side = dir
  self.velocity.velx = self.side * 5
  self.weaponGroup = "megaBuster"
end

function megaBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.quad:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end

megaSemiBuster = playerWeapon:extend()

function megaSemiBuster:new(x, y, p, dir)
  megaSemiBuster.super.new(self, p)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(16, 10)
  self.tex = megautils.getResource("busterTex")
  self.anim = megautils.newAnimation("smallChargeGrid", {"1-2", 1}, 1/12)
  self.side = dir
  self.velocity.velx = self.side * 5
  self.anim.flipX = self.side ~= 1
  self.sound = "semiCharged"
  self.weaponGroup = "megaBuster"
end

function megaSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-3)
end

megaChargedBuster = playerWeapon:extend()

function megaChargedBuster:new(x, y, p, dir)
  megaChargedBuster.super.new(self, p)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(24, 24)
  self.tex = megautils.getResource("busterTex")
  self.anim = megautils.newAnimation("chargeGrid", {"1-4", 1}, 1/20)
  self.side = dir
  self.velocity.velx = self.side * 5.5
  self.anim.flipX = self.side ~= 1
  self.pierceType = enemyEntity.PIERCEIFKILLING
  self.sound = "charged"
  self.weaponGroup = "megaChargedBuster"
  self.damage = -2
end

function megaChargedBuster:act()
  self.anim:update(defaultFramerate)
end

function megaChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-8, math.round(self.transform.y)-3)
end

trebleBoost = playerWeapon:extend()

playerWeapon.removeGroups["T. BOOST"] = {"trebleBoost", "bassBuster"}

playerWeapon.resources["T. BOOST"] = function()
    megautils.loadResource("assets/misc/weapons/bassBuster.png", "bassBuster")
    megautils.loadResource("assets/misc/weapons/treble.png", "trebleTex")
    megautils.loadResource("assets/sfx/treble.ogg", "treble")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(33, 32, "trebleGrid")    
  end

function trebleBoost:new(x, y, p, side)
  trebleBoost.super.new(self, p)
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = megautils.getResource("trebleTex")
  self.anims = animationSet()
  self.anims:add("spawn", megautils.newAnimation("trebleGrid", {1, 1}))
  self.anims:add("spawnLand", megautils.newAnimation("trebleGrid", {2, 1, 1, 1, 3, 1}, 1/20))
  self.anims:add("idle", megautils.newAnimation("trebleGrid", {4, 1}))
  self.anims:add("start", megautils.newAnimation("trebleGrid", {"5-6", 1, "5-6", 1, "5-6", 1, "5-6", 1, "7-8", 1}, 1/16, "pauseAtEnd"))
  self.side = side
  self.s = 0
  self.timer = 0
  self.blockCollision.global = true
  self.sound = nil
  self.applyAutoFace = true
  self.weaponGroup = "trebleBoost"
  self.doDink = false
end

function trebleBoost:added()
  trebleBoost.super.added(self)
  self:addToGroup("submergable")
end

function trebleBoost:act()
  self.anims:update(defaultFramerate)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velocity.vely = 8
        self.blockCollision.global = true
        self.autoGravity = true
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.ground then
      self.anims:set("spawnLand")
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims:looped() then
      self.anims:set("idle")
      self.s = 3
      megautils.playSound("start")
    end
  elseif self.s == 3 then
    if self.user and not self.user.climb and self.user.ground and self.user:collision(self) then
      self.user:resetStates()
      self.user.treble = 1
      self.user.velocity.velx = 0
      self.s = 4
      self.anims:set("start")
    end
  elseif self.s == 4 then
    if self.anims:looped() then
      self.s = 5
    end
  elseif self.s == 5 then
    self.timer = self.timer + 1
    if self.timer == 20 then
      megautils.removeq(self)
    end
  end
  
  self.anims.flipX = self.side ~= (self.s >= 4 and -1 or 1)
  self.anims.flipY = self.gravity < 0
end

function trebleBoost:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims:draw(self.tex, math.round(self.transform.x)-6, math.round(self.transform.y)-12+(self.gravity >= 0 and 0 or 11))
end

rushJet = playerWeapon:extend()

playerWeapon.removeGroups["RUSH JET"] = {"rushJet", "megaBuster", "bassBuster"}

playerWeapon.resources["RUSH JET"] = function()
    megautils.loadResource("assets/misc/weapons/rush.png", "rush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(32, 32, "rushGrid")
    
    playerWeapon.resources["M.BUSTER"]() -- So it's possible to use the Mega Buster shots even if the weapon wasn't already loaded in for some reason...
  end

playerWeapon.removeGroups["PROTO JET"] = {"rushJet", "megaBuster", "bassBuster"}

playerWeapon.resources["PROTO JET"] = function()
    megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(32, 32, "rushGrid")
    
    playerWeapon.resources["P.BUSTER"]()
  end

playerWeapon.removeGroups["TANGO JET"] = {"rushJet", "megaBuster", "bassBuster"}

playerWeapon.resources["TANGO JET"] = function()
    megautils.loadResource("assets/misc/weapons/tango.png", "tango")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(32, 32, "rushGrid")
    
    playerWeapon.resources["R.BUSTER"]()
  end

function rushJet:new(x, y, p, side, skin)
  rushJet.super.new(self, p)
  self.transform.x = x
  self.transform.y = view.y
  self.toY = y
  self:setRectangleCollision(27, 8)
  self.tex = megautils.getResource(skin) or megautils.loadResource(skin, skin)
  self.skin = skin
  self.anims = animationSet()
  self.anims:add("spawn", megautils.newAnimation("rushGrid", {1, 1}))
  self.anims:add("spawnLand", megautils.newAnimation("rushGrid", {2, 1, 1, 1, 3, 1}, 1/20))
  self.anims:add("jet", megautils.newAnimation("rushGrid", {"2-3", 2}, 1/8))
  self.side = side
  self.s = 0
  self.timer = 0
  self.blockCollision.global = true
  self.playerOn = false
  self.exclusivelySolidFor = {self.user}
  self.sound = nil
  self.weaponGroup = "rushJet"
  self.doDink = false
end

function rushJet:added()
  rushJet.super.added(self)
  self:addToGroup("submergable")
end

function rushJet:act(dt)
  self.anims:update(defaultFramerate)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.anims:set("spawnLand")
        self.s = 1
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.anims:looped() then
      self.anims:set("jet")
      self.s = 2
      self.solidType = collision.ONEWAY
      megautils.playSound("start")
    end
  elseif self.s == 2 then
    if self.user and self.user.ground and self.user:collision(self, 0, self.user.gravity >= 0 and 1 or -1) and
      not self.user:collision(self) then
      self.s = 3
      self.velocity.velx = self.side
      self.user.canWalk.rj = false
      self.playerOn = true
    end
  elseif self.s == 3 then
    if self.playerOn and self.user then
      if control.upDown[self.user.player] then
        self.velocity.vely = -1
      elseif control.downDown[self.user.player] then
        self.velocity.vely = 1
      else
        self.velocity.vely = 0
      end
    else
      self.velocity.vely = 0
      if self.user and self.user.ground and self.user:collision(self, 0, self.user.gravity >= 0 and 1 or -1) and
        not self.player:collision(self) then
        self.s = 3
        self.velocity.velx = self.side
        self.user.canWalk.rj = false
        self.playerOn = true
      end
    end
    if self.playerOn and self.user and (not self.user.ground or
      not (self.user:collision(self, 0, self.user.gravity >= 0 and 1 or -1) and
      not self.user:collision(self))) then
      self.user.canWalk.rj = true
      self.playerOn = false
    end
    if self.xColl ~= 0 or
      (self.playerOn and self.user and collision.checkSolid(self.user, 0, self.user.gravity >= 0 and -4 or 4)) then
      if self.playerOn then self.user.canWalk.rj = true end
      self.anims:set("spawnLand")
      self.s = 4
      self.solidType = collision.NONE
      megautils.playSound("ascend")
    end
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      if self.user then
        megaMan.weaponHandler[self.user.player]:updateCurrent(megaMan.weaponHandler[self.user.player]:currentWE() - 1)
      end
    end
  elseif self.s == 4 then
    if self.anims:looped() then
      self.s = 5
      self.anims:set("spawn")
      self.velocity.vely = -8
    end
  end
  
  self.anims.flipX = self.side ~= 1
  self.anims.flipY = self.gravity < 0
end

function rushJet:removed()
  if self.user then
    self.user.canWalk.rj = true
  end
end

function rushJet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if (self.anims.current == "spawn" or self.anims.current == "spawnLand") and self.user then
    self.anims:draw(self.tex, math.round(self.transform.x)-4, math.round(self.transform.y)+(self.user.gravity >= 0 and -16 or -6))
  else
    self.anims:draw(self.tex, math.round(self.transform.x)-4, math.round(self.transform.y)-12)
  end
end

rushCoil = playerWeapon:extend()

playerWeapon.removeGroups["RUSH C."] = {"rushCoil", "megaBuster", "bassBuster", "rollBuster"}

playerWeapon.resources["RUSH C."] = function()
    megautils.loadResource("assets/misc/weapons/rush.png", "rush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(32, 32, "rushGrid")
    
    playerWeapon.resources["M.BUSTER"]() -- So it's possible to use the Mega Buster shots even if the weapon wasn't already loaded in for some reason...
  end

playerWeapon.resources["PROTO C."] = function()
    megautils.loadResource("assets/misc/weapons/protoRush.png", "protoRush")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(32, 32, "rushGrid")
    
    playerWeapon.resources["P.BUSTER"]()
  end

playerWeapon.resources["TANGO C."] = function()
    megautils.loadResource("assets/misc/weapons/tango.png", "tango")
    megautils.loadResource("assets/sfx/mmStart.ogg", "start")
    megautils.loadResource("assets/sfx/ascend.ogg", "ascend")
    megautils.loadResource(32, 32, "rushGrid")
    
    playerWeapon.resources["R.BUSTER"]()
  end

function rushCoil:new(x, y, p, side, skin)
  rushCoil.super.new(self, p)
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = megautils.getResource(skin)
  self.skin = skin
  self.anims = animationSet()
  self.anims:add("spawn", megautils.newAnimation("rushGrid", {1, 1}))
  self.anims:add("spawnLand", megautils.newAnimation("rushGrid", {2, 1, 1, 1, 3, 1}, 1/20))
  self.anims:add("idle", megautils.newAnimation("rushGrid", {4, 1, 1, 2}, 1/8))
  self.anims:add("coil", megautils.newAnimation("rushGrid", {4, 2}))
  self.side = side
  self.s = 0
  self.timer = 0
  self.weaponGroup = "rushCoil"
  self.sound = nil
  self.doDink = false
end

function rushCoil:added()
  rushCoil.super.added(self)
  self:addToGroup("submergable")
end

function rushCoil:act(dt)
  self.anims:update(defaultFramerate)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velocity.vely = 8
        self.autoGravity = true
        self.blockCollision.global = true
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.ground then
      self.anims:set("spawnLand")
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims:looped() then
      self.anims:set("idle")
      self.s = 3
      megautils.playSound("start")
    end
  elseif self.s == 3 then
    if self.user and not self.user.climb and
      (self.user.gravity >= 0 and (self.user.velocity.vely > 0) or (self.user.velocity.vely < 0)) and
      math.between(self.user.transform.x+self.user.collisionShape.w/2,
      self.transform.x, self.transform.x+self.collisionShape.w) and
      self.user:collision(self) then
      self.user:resetStates()
      self.user.canStopJump.global = false
      self.user.velocity.vely = -7.5 * (self.user.gravity >= 0 and 1 or -1)
      self.s = 4
      self.anims:set("coil")
      megaMan.weaponHandler[self.user.player]:updateCurrent(megaMan.weaponHandler[self.user.player]:currentWE() - 7)
    end
  elseif self.s == 4 then
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.s = 5
      self.anims:set("spawnLand")
      self.autoGravity = false
      self.blockCollision.global = false
      megautils.playSound("ascend")
    end
  elseif self.s == 5 then
    if self.anims:looped() then
      self.s = 6
      self.anims:set("spawn")
      self.velocity.vely = -8
    end
  end
  
  self.anims.flipX = self.side ~= 1
  self.anims.flipY = self.gravity < 0
end

function rushCoil:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims:draw(self.tex, math.round(self.transform.x)-8, math.round(self.transform.y)-12+(self.gravity >= 0 and 0 or 11))
end

stickWeapon = playerWeapon:extend()

playerWeapon.removeGroups["STICK W."] = {"stickWeapon"}

playerWeapon.resources["STICK W."] = function()
    megautils.loadResource("assets/misc/weapons/stickWeapon.png", "stickWeapon")
  end

function stickWeapon:new(x, y, p, dir)
  stickWeapon.super.new(self, p)
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(8, 6)
  self.tex = megautils.getResource("stickWeapon")
  self.side = dir
  self.velocity.velx = self.side * 8
  self.weaponGroup = "stickWeapon"
end

function stickWeapon:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end
